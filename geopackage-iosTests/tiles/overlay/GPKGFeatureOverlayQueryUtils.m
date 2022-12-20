//
//  GPKGFeatureOverlayQueryUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 5/3/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGFeatureOverlayQueryUtils.h"
#import "GPKGMapShapeConverter.h"
#import "GPKGFeatureOverlayQuery.h"
#import "GPKGTestUtils.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "PROJProjectionConstants.h"

@implementation GPKGFeatureOverlayQueryUtils

static int MAX_CLICKS_PER_TABLE = 10;

+(void) testBuildMapClickTableData: (GPKGGeoPackage *) geoPackage{

    float scale = [UIScreen mainScreen].nativeScale;

    for(NSString *featureTable in [geoPackage featureTables]){

        GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];

        // Index if not already
        GPKGFeatureIndexManager *indexer = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        @try {
            if(![indexer isIndexed]){
                [indexer setIndexLocation:GPKG_FIT_GEOPACKAGE];
                [indexer index];
            }
        } @finally {
            [indexer close];
        }
        
        PROJProjection *projection = [featureDao projection];
        GPKGMapShapeConverter *shapeConverter = [[GPKGMapShapeConverter alloc] initWithProjection:projection];
        GPKGBoundingBox *featureBounds = [featureDao boundingBox];

        GPKGFeatureTiles *featureTiles = [[GPKGFeatureTiles alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao andScale:scale];
        @try {
            GPKGFeatureOverlay *featureOverlay = [[GPKGFeatureOverlay alloc] initWithFeatureTiles:featureTiles];

            GPKGFeatureOverlayQuery *featureOverlayQuery = [[GPKGFeatureOverlayQuery alloc] initWithBoundedOverlay:featureOverlay andFeatureTiles:featureTiles];
            [featureOverlayQuery calculateStylePixelBounds];

            NSMutableArray<SFGeometry *> *geometries = [NSMutableArray array];
            
            GPKGFeatureIndexResults *indexResults = [featureOverlayQuery queryFeaturesWithBoundingBox:featureBounds];
            @try {
                for (GPKGFeatureRow *featureRow in indexResults) {
                    SFGeometry *geometry = [featureRow geometryValue];
                    if (geometry != nil) {
                        [geometries addObject:geometry];
                        if(geometries.count >= MAX_CLICKS_PER_TABLE){
                            break;
                        }
                    }
                }
            } @finally {
                [indexResults close];
            }

            if([projection.authority isEqualToString:PROJ_AUTHORITY_NONE]){
                continue;
            }
            
            for(SFGeometry *geometry in geometries){

                SFPoint *point = [geometry centroid];
                GPKGMapPoint *clickLocation = [shapeConverter toMapPointWithPoint:point];

                double zoom = [GPKGTestUtils randomDouble] * 20.0;

                GPKGBoundingBox *tileBounds = [GPKGTileBoundingBoxUtils wgs84TileBoundsInProjection:projection andPoint:point andZoom:(int)zoom];

                GPKGFeatureTableData *featureTableData = [featureOverlayQuery buildMapClickTableDataWithLocationCoordinate:clickLocation.coordinate andZoom:zoom andMapBounds:tileBounds];

                if(geometry.geometryType == SF_POINT){
                    [GPKGTestUtils assertNotNil:featureTableData];
                }

                if(featureTableData != nil){

                    [GPKGTestUtils assertEqualWithValue:featureTable andValue2:[featureTableData name]];
                    [GPKGTestUtils assertTrue:featureTableData.count > 0];
                    [GPKGTestUtils assertEqualIntWithValue:featureTableData.count andValue2:(int)[featureTableData rows].count];

                    BOOL nonPoint = NO;

                    for(GPKGFeatureRowData *featureRowData in [featureTableData rows]){

                        [GPKGTestUtils assertNotNil:[featureRowData idColumn]];
                        [GPKGTestUtils assertTrue:[featureRowData id] >= 0];
                        [GPKGTestUtils assertNotNil:[featureRowData geometryColumn]];
                        [GPKGTestUtils assertNotNil:[featureRowData geometryData]];
                        [GPKGTestUtils assertNotNil:[featureRowData geometry]];
                        enum SFGeometryType geometryType = [featureRowData geometryType];
                        [GPKGTestUtils assertTrue:geometryType != SF_NONE && (int)geometryType >= 0];
                        [GPKGTestUtils assertNotNil:[featureRowData geometryEnvelope]];
                        if(geometryType != SF_CURVEPOLYGON){
                            [GPKGTestUtils assertNotNil:[featureRowData jsonCompatible]];
                        }

                        if(geometryType == SF_POINT){
                            [GPKGTestUtils assertFalse:nonPoint];
                        }else {
                            nonPoint = YES;
                        }
                    }

                }

            }

        } @finally {
            [featureTiles close];
        }
    }
    
}

@end
