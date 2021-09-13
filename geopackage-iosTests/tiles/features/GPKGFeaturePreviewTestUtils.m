//
//  GPKGFeaturePreviewTestUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 3/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGFeaturePreviewTestUtils.h"
#import "GPKGSqlUtils.h"
#import "PROJProjectionConstants.h"
#import "GPKGFeaturePreview.h"
#import "GPKGTestUtils.h"
#import "GPKGTileUtils.h"

@implementation GPKGFeaturePreviewTestUtils

+(void) testDrawWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    for (NSString *featureTable in [geoPackage featureTables]) {
    
        GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
        int count = [featureDao countWhere:[NSString stringWithFormat:@"%@ IS NOT NULL", [GPKGSqlUtils quoteWrapName:[featureDao geometryColumnName]]]];

        GPKGBoundingBox *contentsBoundingBox = [geoPackage contentsBoundingBoxOfTable:featureTable];
        GPKGBoundingBox *indexedBoundingBox = [geoPackage boundingBoxOfTable:featureTable];
        BOOL expectImage = (contentsBoundingBox != nil || indexedBoundingBox != nil) && count > 0;
        BOOL epsg = [[[featureDao projection] authority] caseInsensitiveCompare:PROJ_AUTHORITY_EPSG] == NSOrderedSame;
        
        GPKGFeaturePreview *preview = [[GPKGFeaturePreview alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];

        UIImage *image = [preview draw];
        if(epsg){
            [GPKGTestUtils assertEqualBoolWithValue:expectImage andValue2:image != nil];
        }

        [preview setBufferPercentage:0.4];
        [preview setLimit:[NSNumber numberWithInt:(int)ceil(count / 2.0)]];
        UIImage *imageLimit = [preview draw];
        if(epsg){
            [GPKGTestUtils assertEqualBoolWithValue:expectImage andValue2:imageLimit != nil];
        }

        [preview setManual:YES];
        [preview setBufferPercentage:0.05];
        [preview setLimit:nil];
        GPKGFeatureTiles *featureTiles = [preview featureTiles];
        [featureTiles setTileWidth:GPKG_TU_TILE_PIXELS_DEFAULT];
        [featureTiles setTileHeight:GPKG_TU_TILE_PIXELS_DEFAULT];
        [featureTiles setScale:GPKG_TU_SCALE_FACTOR_DEFAULT];
        [featureTiles clearIconCache];
        UIImage *imageManual = [preview draw];
        if(epsg){
            [GPKGTestUtils assertNotNil:imageManual];
        }

        [preview setBufferPercentage:0.35];
        [preview setLimit:[NSNumber numberWithInt:MAX(count - 1, 1)]];
        [featureTiles setScale:1.0f];
        [featureTiles clearIconCache];
        UIImage *imageManualLimit = [preview draw];
        if(epsg){
            [GPKGTestUtils assertNotNil:imageManualLimit];
        }
        
        [preview setBufferPercentage:0.15];
        [preview setLimit:nil];
        [preview appendWhere:[NSString stringWithFormat:@"%@ > %d", [GPKGSqlUtils quoteWrapName:[featureDao idColumnName]], (int) floor(count / 2.0)]];
        UIImage *imageManualWhere = [preview draw];
        if(epsg){
            [GPKGTestUtils assertNotNil:imageManualWhere];
        }
        
        [preview close];
        
    }
    
}

@end
