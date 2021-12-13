//
//  GPKGReadmeTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 10/21/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGReadmeTestCase.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGTestConstants.h"
#import "GPKGSchemaExtension.h"
#import "GPKGMetadataExtension.h"
#import "GPKGMapShapeConverter.h"
#import "GPKGOverlayFactory.h"
#import "GPKGFeatureOverlay.h"
#import "PROJProjectionFactory.h"
#import "GPKGUrlTileGenerator.h"
#import "GPKGFeatureTileGenerator.h"
#import "PROJProjectionConstants.h"
#import "GPKGManagerTestCase.h"

@implementation GPKGReadmeTestCase

/**
 * README example tests
 */
-(void) testGeoPackage{
    [[GPKGGeoPackageFactory manager] delete:GPKG_TEST_IMPORT_DB_NAME];
    [self testGeoPackageWithFile:[[[NSBundle bundleForClass:[GPKGManagerTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_IMPORT_DB_FILE_NAME]
                      andMapView:[[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]];
}

/**
 * README example tests
 */
-(void) testGeoPackageWithFile: (NSString *) geoPackageFile andMapView: (MKMapView *) mapView{

    // NSString *geoPackageFile = ...;
    // MKMapView *mapView = ...;

    // Get a manager
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory manager];

    // Available databases
    NSArray *databases = [manager databases];

    // Import database
    BOOL imported = [manager importGeoPackageFromPath:geoPackageFile];

    // Open database
    GPKGGeoPackage *geoPackage = [manager open:[databases objectAtIndex:0]];

    // GeoPackage Table DAOs
    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage spatialReferenceSystemDao];
    GPKGContentsDao *contentsDao =  [geoPackage contentsDao];
    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage geometryColumnsDao];
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage tileMatrixSetDao];
    GPKGTileMatrixDao *tileMatrixDao = [geoPackage tileMatrixDao];
    GPKGSchemaExtension *schemaExtension = [[GPKGSchemaExtension alloc] initWithGeoPackage:geoPackage];
    GPKGDataColumnsDao *dataColumnsDao = [schemaExtension dataColumnsDao];
    GPKGDataColumnConstraintsDao *dataColumnConstraintsDao = [schemaExtension dataColumnConstraintsDao];
    GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
    GPKGMetadataDao *metadataDao = [metadataExtension metadataDao];
    GPKGMetadataReferenceDao *metadataReferenceDao = [metadataExtension metadataReferenceDao];
    GPKGExtensionsDao *extensionsDao = [geoPackage extensionsDao];

    // Feature and tile tables
    NSArray *features = [geoPackage featureTables];
    NSArray *tiles = [geoPackage tileTables];

    // Query Features
    NSString *featureTable = [features objectAtIndex:0];
    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
    GPKGMapShapeConverter *converter = [[GPKGMapShapeConverter alloc] initWithProjection:featureDao.projection];
    GPKGResultSet *featureResults = [featureDao queryForAll];
    @try {
        while([featureResults moveToNext]){
            GPKGFeatureRow *featureRow = [featureDao featureRow:featureResults];
            GPKGGeometryData *geometryData = [featureRow geometry];
            if(geometryData != nil && !geometryData.empty){
                SFGeometry *geometry = geometryData.geometry;
                GPKGMapShape *shape = [converter toShapeWithGeometry:geometry];
                GPKGMapShape *mapShape = [GPKGMapShapeConverter addMapShape:shape toMapView:mapView];
                // ...
            }
        }
    }@finally {
        [featureResults close];
    }

    // Query Tiles
    NSString *tileTable = [tiles objectAtIndex:0];
    GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:tileTable];
    GPKGResultSet *tileResults = [tileDao queryForAll];
    @try {
        while([tileResults moveToNext]){
            GPKGTileRow *tileRow = [tileDao tileRow:tileResults];
            NSData *tileData = [tileRow tileData];
            UIImage *tileImage = [tileRow tileDataImage];
            // ...
        }
    }@finally {
        [tileResults close];
    }
    
    // Tile Overlay (GeoPackage or Standard API)
    MKTileOverlay *tileOverlay = [GPKGOverlayFactory tileOverlayWithTileDao:tileDao];
    tileOverlay.canReplaceMapContent = false;
    [mapView addOverlay:tileOverlay];

    // Feature Tile Overlay (dynamically draw tiles from features)
    GPKGFeatureTiles *featureTiles = [[GPKGFeatureTiles alloc] initWithFeatureDao:featureDao];
    GPKGFeatureOverlay *featureOverlay = [[GPKGFeatureOverlay alloc] initWithFeatureTiles:featureTiles];
    [mapView addOverlay:featureOverlay];

    GPKGBoundingBox *boundingBox = [GPKGBoundingBox worldWebMercator];
    PROJProjection *projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];

    // URL Tile Generator (generate tiles from a URL)
    GPKGTileGenerator *urlTileGenerator = [[GPKGUrlTileGenerator alloc] initWithGeoPackage:geoPackage andTableName:@"url_tile_table" andTileUrl:@"http://url/{z}/{x}/{y}.png" andMinZoom:1 andMaxZoom:2 andBoundingBox:boundingBox andProjection:projection];
    int urlTileCount = [urlTileGenerator generateTiles];

    // Feature Tile Generator (generate tiles from features)
    GPKGTileGenerator *featureTileGenerator = [[GPKGFeatureTileGenerator alloc] initWithGeoPackage:geoPackage andTableName:[NSString stringWithFormat:@"%@_tiles", featureTable] andFeatureTiles:featureTiles andMinZoom:1 andMaxZoom:2 andBoundingBox:boundingBox andProjection:projection];
    int featureTileCount = [featureTileGenerator generateTiles];

    // Close database when done
    [geoPackage close];

    // Close manager when done
    [manager close];
    
}

@end
