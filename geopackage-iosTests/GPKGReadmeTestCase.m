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
#import "PROJProjectionFactory.h"
#import "GPKGUrlTileGenerator.h"
#import "GPKGFeatureTileGenerator.h"
#import "PROJProjectionConstants.h"
#import "GPKGManagerTestCase.h"
#import "GPKGGeoPackageTileRetriever.h"
#import "GPKGImageConverter.h"
#import "GPKGTileCreator.h"
#import "GPKGNumberFeaturesTile.h"

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
    NSArray<NSString *> *features = [geoPackage featureTables];
    NSArray<NSString *> *tiles = [geoPackage tileTables];

    // Query Features
    NSString *featureTable = [features objectAtIndex:0];
    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
    GPKGMapShapeConverter *converter = [[GPKGMapShapeConverter alloc] initWithProjection:featureDao.projection];
    GPKGRowResultSet *featureResults = [featureDao results:[featureDao queryForAll]];
    @try {
        for(GPKGFeatureRow *featureRow in featureResults){
            GPKGGeometryData *geometryData = [featureRow geometry];
            if(geometryData != nil && !geometryData.empty){
                SFGeometry *geometry = geometryData.geometry;
                GPKGMapShape *shape = [converter toShapeWithGeometry:geometry];
                GPKGMapShape *mapShape = [GPKGMapShapeConverter addMapShape:shape toMapView:mapView];
                // ...
            }
        }
    }@finally {
        [converter destroy];
        [featureResults close];
    }

    // Query Tiles
    NSString *tileTable = [tiles objectAtIndex:0];
    GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:tileTable];
    GPKGRowResultSet *tileResults = [tileDao results:[tileDao queryForAll]];
    @try {
        for(GPKGTileRow *tileRow in tileResults){
            NSData *tileData = [tileRow tileData];
            UIImage *tileImage = [tileRow tileDataImage];
            // ...
        }
    }@finally {
        [tileResults close];
    }
    
    // Retrieve Tiles by XYZ
    NSObject<GPKGTileRetriever> *retriever = [[GPKGGeoPackageTileRetriever alloc] initWithTileDao:tileDao];
    GPKGGeoPackageTile *geoPackageTile = [retriever tileWithX:2 andY:2 andZoom:2];
    if(geoPackageTile != nil){
        NSData *tileData = geoPackageTile.data;
        UIImage *tileImage = [GPKGImageConverter toImage:tileData];
        // ...
    }
    
    // Retrieve Tiles by Bounding Box
    GPKGTileCreator *tileCreator = [[GPKGTileCreator alloc] initWithTileDao:tileDao andProjection:[PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    GPKGGeoPackageTile *geoPackageTile2 = [tileCreator tileWithBoundingBox:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90.0 andMinLatitudeDouble:0.0 andMaxLongitudeDouble:0.0 andMaxLatitudeDouble:66.513260]];
    if(geoPackageTile2 != nil){
        NSData *tileData = geoPackageTile2.data;
        UIImage *tileImage = [GPKGImageConverter toImage:tileData];
        // ...
    }
    
    // Tile Overlay (GeoPackage or Standard API)
    MKTileOverlay *tileOverlay = [GPKGOverlayFactory tileOverlayWithTileDao:tileDao];
    tileOverlay.canReplaceMapContent = false;
    [mapView addOverlay:tileOverlay];
    
    GPKGBoundingBox *boundingBox = [GPKGBoundingBox worldWebMercator];
    PROJProjection *projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];

    // Index Features
    GPKGFeatureIndexManager *indexer = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
    [indexer setIndexLocation:GPKG_FIT_RTREE];
    int indexedCount = [indexer index];
    
    // Query Indexed Features in paginated chunks
    GPKGFeatureIndexResults *indexResults = [indexer queryForChunkWithBoundingBox:boundingBox inProjection:projection andLimit:50];
    GPKGRowPaginatedResults *paginatedResults = [indexer paginate:indexResults];
    for(GPKGFeatureRow *featureRow in paginatedResults){
        GPKGGeometryData *geometryData = [featureRow geometry];
        if(geometryData != nil && !geometryData.empty){
            SFGeometry *geometry = geometryData.geometry;
            // ...
        }
    }
    
    // Feature Tile Overlay (dynamically draw tiles from features)
    GPKGFeatureTiles *featureTiles = [[GPKGFeatureTiles alloc] initWithFeatureDao:featureDao];
    [featureTiles setMaxFeaturesPerTile:[NSNumber numberWithInt:1000]];
    GPKGNumberFeaturesTile *numberFeaturesTile = [[GPKGNumberFeaturesTile alloc] init];
    [featureTiles setMaxFeaturesTileDraw:numberFeaturesTile];
    [featureTiles setIndexManager:indexer];
    GPKGFeatureOverlay *featureOverlay = [[GPKGFeatureOverlay alloc] initWithFeatureTiles:featureTiles];
    [featureOverlay setMinZoom:[NSNumber numberWithInt:[featureDao zoomLevel]]];
    [mapView addOverlay:featureOverlay];

    // URL Tile Generator (generate tiles from a URL)
    GPKGTileGenerator *urlTileGenerator = [[GPKGUrlTileGenerator alloc] initWithGeoPackage:geoPackage andTableName:@"url_tile_table" andTileUrl:@"http://url/{z}/{x}/{y}.png" andMinZoom:0 andMaxZoom:0 andBoundingBox:boundingBox andProjection:projection];
    int urlTileCount = [urlTileGenerator generateTiles];

    // Feature Tile Generator (generate tiles from features)
    GPKGTileGenerator *featureTileGenerator = [[GPKGFeatureTileGenerator alloc] initWithGeoPackage:geoPackage andTableName:[NSString stringWithFormat:@"tiles_%@", featureTable] andFeatureTiles:featureTiles andMinZoom:1 andMaxZoom:2 andBoundingBox:boundingBox andProjection:projection];
    int featureTileCount = [featureTileGenerator generateTiles];

    // Close database when done
    [geoPackage close];

    // Close manager when done
    [manager close];
    
}

@end
