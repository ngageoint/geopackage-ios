//
//  GPKGDgiwgGeoPackageTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 12/1/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgGeoPackageTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGDgiwgGeoPackageFactory.h"
#import "GPKGDgiwgGeoPackageManagerTestCase.h"
#import "GPKGTestConstants.h"
#import "GPKGGeoPackageConstants.h"

@implementation GPKGDgiwgGeoPackageTestCase

/**
 * Test creating tiles with maximum CRS bounds
 */
-(void) testCreateTiles{
    
    NSString *table = @"dgiwg_tiles";
    NSString *identifier = @"dgiwg identifier";
    NSString *description = @"dgiwg description";
    GPKGBoundingBox *informativeBounds = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-8922952 andMinLatitudeDouble:4539748 andMaxLongitudeDouble:-8453324 andMaxLatitudeDouble:4696291];
    
    GPKGDgiwgCoordinateReferenceSystems *crs = [GPKGDgiwgCoordinateReferenceSystems fromType:GPKG_DGIWG_CRS_EPSG_3395];
    int minZoom = 8;
    int maxZoom = 10;
    int matrixWidth = [GPKGTileBoundingBoxUtils tilesPerSideWithZoom:minZoom];
    int matrixHeight = matrixWidth;
    
    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    [manager delete:GPKG_DGIWG_TEST_FILE_NAME];
    GPKGDgiwgFile *geoPackageFile = [manager create:GPKG_DGIWG_TEST_FILE_NAME withMetadata:[GPKGDgiwgGeoPackageTestCase metadata]];
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:geoPackageFile];
    
    GPKGTileMatrixSet *tileMatrixSet = [geoPackage createTilesWithTable:table andIdentifier:identifier andDescription:description andInformativeBounds:informativeBounds andCRS:crs];
    
    [geoPackage createTileMatricesWithTileMatrixSet:tileMatrixSet andMinZoom:minZoom andMaxZoom:maxZoom andWidth:matrixWidth andHeight:matrixHeight];
    
    GPKGTileDao *tileDao = [geoPackage tileDaoWithTileMatrixSet:tileMatrixSet];
    
    GPKGBoundingBox *bounds = [tileMatrixSet boundingBox];
    GPKGTileGrid *tileGrid = [GPKGTileBoundingBoxUtils tileGridWithTotalBoundingBox:bounds andMatrixWidth:matrixWidth andMatrixHeight:matrixHeight andBoundingBox:informativeBounds];
    GPKGBoundingBox *tileBounds = [GPKGTileBoundingBoxUtils boundingBoxWithTotalBoundingBox:bounds andTileMatrixWidth:matrixWidth andTileMatrixHeight:matrixHeight andTileGrid:tileGrid];
    
    NSString *tilePath  = [[[NSBundle bundleForClass:[GPKGDgiwgGeoPackageTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_TILE_FILE_NAME];
    NSData *tileData = [[NSFileManager defaultManager] contentsAtPath:tilePath];
    
    for(int zoom = minZoom; zoom <= maxZoom; zoom++){
        
        for(int row = tileGrid.minY; row <= tileGrid.maxY; row++){
            
            for(int column = tileGrid.minX; column <= tileGrid.maxX; column++){
                
                GPKGTileRow *tile = [tileDao newRow];
                
                [tile setZoomLevel:zoom];
                [tile setTileColumn:column];
                [tile setTileRow:row];
                [tile setTileData:tileData];
                
                [tileDao create:tile];
                
            }
            
        }
        
        tileGrid = [GPKGTileBoundingBoxUtils tileGrid:tileGrid zoomIncrease:1];
        
    }
    
    for(int zoom = minZoom; zoom <= maxZoom; zoom++){
        [GPKGTestUtils assertEqualWithValue:tileBounds andValue2:[tileDao boundingBoxWithZoomLevel:zoom]];
    }
    
    GPKGDgiwgValidationErrors *errors = [geoPackage validate];
    if([errors hasErrors]){
        NSLog(@"%@", errors);
    }
    [GPKGTestUtils assertTrue:[geoPackage isValid]];
    
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager deleteDGIWG:geoPackageFile]];
}

/**
 * Test creating tiles with a subset of CRS bounds
 */
-(void) testCreateTilesSubsetBounds{

    NSString *table = @"dgiwg_tiles";
    
    GPKGDgiwgCoordinateReferenceSystems *crs = [GPKGDgiwgCoordinateReferenceSystems fromType:GPKG_DGIWG_CRS_EPSG_3395];
    int minZoom = 8;
    int maxZoom = 10;
    int matrixWidth = 3;
    int matrixHeight = 2;
    
    int tiles = [GPKGTileBoundingBoxUtils tilesPerSideWithZoom:minZoom];
    GPKGTileGrid *tileGrid = [[GPKGTileGrid alloc] initWithMinX:71 andMinY:105 andMaxX:73 andMaxY:106];
    
    GPKGBoundingBox *tileBounds = [GPKGTileBoundingBoxUtils boundingBoxWithTotalBoundingBox:[crs bounds] andTileMatrixWidth:tiles andTileMatrixHeight:tiles andTileGrid:tileGrid];

    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    [manager delete:GPKG_DGIWG_TEST_FILE_NAME_NON_INFORMATIVE];
    GPKGDgiwgFile *geoPackageFile = [manager create:GPKG_DGIWG_TEST_FILE_NAME_NON_INFORMATIVE withMetadata:[GPKGDgiwgGeoPackageTestCase metadata]];
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:geoPackageFile];

    GPKGTileMatrixSet *tileMatrixSet = [geoPackage createTilesWithTable:table andCRS:crs andExtentBounds:tileBounds];
    
    [geoPackage createTileMatricesWithTileMatrixSet:tileMatrixSet andMinZoom:minZoom andMaxZoom:maxZoom andWidth:matrixWidth andHeight:matrixHeight];
    
    GPKGTileDao *tileDao = [geoPackage tileDaoWithTileMatrixSet:tileMatrixSet];
    
    NSString *tilePath  = [[[NSBundle bundleForClass:[GPKGDgiwgGeoPackageTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_TILE_FILE_NAME];
    NSData *tileData = [[NSFileManager defaultManager] contentsAtPath:tilePath];
    
    for(int zoom = minZoom; zoom <= maxZoom; zoom++){
        
        for(int row = 0; row < matrixHeight; row++){
            
            for(int column = 0; column < matrixWidth; column++){
                
                GPKGTileRow *tile = [tileDao newRow];
                
                [tile setZoomLevel:zoom];
                [tile setTileColumn:column];
                [tile setTileRow:row];
                [tile setTileData:tileData];
                
                [tileDao create:tile];
                
            }
            
        }
        
        matrixHeight *= 2;
        matrixWidth *= 2;
        
    }

    for(int zoom = minZoom; zoom <= maxZoom; zoom++){
        [GPKGTestUtils assertEqualWithValue:tileBounds andValue2:[tileDao boundingBoxWithZoomLevel:zoom]];
    }
    
    GPKGDgiwgValidationErrors *errors = [geoPackage validate];
    if([errors hasErrors]){
        NSLog(@"%@", errors);
    }
    [GPKGTestUtils assertTrue:[geoPackage isValid]];
    
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager deleteDGIWG:geoPackageFile]];
}

/**
 * Test creating features
 */
-(void) testCreateFeatures{

    NSString *table = @"dgiwg_features";
    
    GPKGDgiwgCoordinateReferenceSystems *crs = [GPKGDgiwgCoordinateReferenceSystems fromType:GPKG_DGIWG_CRS_EPSG_4326];

    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    [manager delete:GPKG_DGIWG_TEST_FILE_NAME];
    GPKGDgiwgFile *geoPackageFile = [manager create:GPKG_DGIWG_TEST_FILE_NAME withMetadata:[GPKGDgiwgGeoPackageTestCase metadata]];
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:geoPackageFile];
    
    GPKGGeometryColumns *geometryColumns = [geoPackage createFeaturesWithTable:table andGeometryType:SF_GEOMETRY andCRS:crs];
    NSNumber *srsId = geometryColumns.srsId;

    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];

    GPKGFeatureRow *featureRow = [featureDao newRow];
    [featureRow setGeometry:[[GPKGGeometryData alloc] initWithSrsId:srsId andGeometry:[GPKGTestUtils createPointWithHasZ:NO andHasM:NO]]];
    [featureDao insert:featureRow];

    featureRow = [featureDao newRow];
    [featureRow setGeometry:[[GPKGGeometryData alloc] initWithSrsId:srsId andGeometry:[GPKGTestUtils createLineStringWithHasZ:NO andHasM:NO andRing:NO]]];
    [featureDao insert:featureRow];

    featureRow = [featureDao newRow];
    [featureRow setGeometry:[[GPKGGeometryData alloc] initWithSrsId:srsId andGeometry:[GPKGTestUtils createPolygonWithHasZ:NO andHasM:NO]]];
    [featureDao insert:featureRow];

    [GPKGTestUtils assertEqualIntWithValue:3 andValue2:[featureDao count]];

    GPKGDgiwgValidationErrors *errors = [geoPackage validate];
    if([errors hasErrors]){
        NSLog(@"%@", errors);
    }
    [GPKGTestUtils assertTrue:[geoPackage isValid]];
    
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager deleteDGIWG:geoPackageFile]];
}

/**
 * Test creating tiles with a Lambert Conic Conformal CRS
 */
-(void) testCreateTilesLambert{

    NSString *table = @"dgiwg_tiles";

    int epsg = 3978;
    NSString *name = @"NAD83 / Canada Atlas Lambert";
    enum CRSType crsType = CRS_TYPE_GEOGRAPHIC;
    CRSGeoDatums *datum = [CRSGeoDatums fromType:CRS_DATUM_NAD83];
    double standardParallel1 = 49;
    double standardParallel2 = 77;
    double latitudeOfOrigin = 49;
    double centralMeridian = -95;
    double falseEasting = 0;
    double falseNorthing = 0;

    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-7786476.885838887 andMinLatitudeDouble:-5153821.09213678 andMaxLongitudeDouble:7148753.233541353 andMaxLatitudeDouble:7928343.534071138];

    GPKGSpatialReferenceSystem *srs = [GPKGDgiwgCoordinateReferenceSystems createLambertConicConformal2SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:[datum type] andStandardParallel1:standardParallel1 andStandardParallel2:standardParallel2 andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andFalseEasting:falseEasting andFalseNorthing:falseNorthing];

    int minZoom = 2;
    int maxZoom = 5;
    int matrixWidth = [GPKGTileBoundingBoxUtils tilesPerSideWithZoom:minZoom];
    int matrixHeight = matrixWidth;

    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    [manager delete:GPKG_DGIWG_TEST_FILE_NAME_NON_INFORMATIVE2];
    GPKGDgiwgFile *geoPackageFile = [manager create:GPKG_DGIWG_TEST_FILE_NAME_NON_INFORMATIVE2 withMetadata:[GPKGDgiwgGeoPackageTestCase metadata]];
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:geoPackageFile];

    GPKGTileMatrixSet *tileMatrixSet = [geoPackage createTilesWithTable:table andSRS:srs andExtentBounds:boundingBox];
    
    [geoPackage createTileMatricesWithTileMatrixSet:tileMatrixSet andMinZoom:minZoom andMaxZoom:maxZoom andWidth:matrixWidth andHeight:matrixHeight];
    
    GPKGTileDao *tileDao = [geoPackage tileDaoWithTileMatrixSet:tileMatrixSet];
    
    NSString *tilePath  = [[[NSBundle bundleForClass:[GPKGDgiwgGeoPackageTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_TILE_FILE_NAME];
    NSData *tileData = [[NSFileManager defaultManager] contentsAtPath:tilePath];
    
    for(int zoom = minZoom; zoom <= maxZoom; zoom++){
        
        for(int row = 0; row < matrixHeight; row++){
            
            for(int column = 0; column < matrixWidth; column++){
                
                GPKGTileRow *tile = [tileDao newRow];
                
                [tile setZoomLevel:zoom];
                [tile setTileColumn:column];
                [tile setTileRow:row];
                [tile setTileData:tileData];
                
                [tileDao create:tile];
                
            }
            
        }
        
        matrixHeight *= 2;
        matrixWidth *= 2;
        
    }

    for(int zoom = minZoom; zoom <= maxZoom; zoom++){
        [GPKGTestUtils assertEqualWithValue:boundingBox andValue2:[tileDao boundingBoxWithZoomLevel:zoom]];
    }
    
    GPKGDgiwgValidationErrors *errors = [geoPackage validate];
    if([errors hasErrors]){
        NSLog(@"%@", errors);
    }
    [GPKGTestUtils assertTrue:[geoPackage isValid]];
    
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager deleteDGIWG:geoPackageFile]];
}

/**
 * Test creating features with compound wkt
 */
-(void) testCreateFeaturesCompound{

    NSString *table = @"dgiwg_features";
    
    GPKGDgiwgCoordinateReferenceSystems *crs = [GPKGDgiwgCoordinateReferenceSystems fromType:GPKG_DGIWG_CRS_EPSG_9518];

    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    [manager delete:GPKG_DGIWG_TEST_FILE_NAME];
    GPKGDgiwgFile *geoPackageFile = [manager create:GPKG_DGIWG_TEST_FILE_NAME withMetadata:[GPKGDgiwgGeoPackageTestCase metadata]];
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:geoPackageFile];
    
    GPKGGeometryColumns *geometryColumns = [geoPackage createFeaturesWithTable:table andGeometryType:SF_GEOMETRY andCRS:crs];
    NSNumber *srsId = geometryColumns.srsId;

    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];

    GPKGFeatureRow *featureRow = [featureDao newRow];
    [featureRow setGeometry:[[GPKGGeometryData alloc] initWithSrsId:srsId andGeometry:[GPKGTestUtils createPointWithHasZ:NO andHasM:NO]]];
    [featureDao insert:featureRow];
    
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[featureDao count]];

    GPKGSpatialReferenceSystem *srs = [[geoPackage spatialReferenceSystemDao] queryForOrganization:[crs authority] andCoordsysId:[NSNumber numberWithInt:[crs code]]];
    [GPKGTestUtils assertNotNil:srs];
    [GPKGTestUtils assertEqualWithValue:GPKG_UNDEFINED_DEFINITION andValue2:srs.definition];
    NSString *definition_12_063 = srs.definition_12_063;
    [GPKGTestUtils assertNotNil:definition_12_063];
    [GPKGTestUtils assertFalse:[definition_12_063 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0];
    [GPKGTestUtils assertFalse:[[definition_12_063 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] caseInsensitiveCompare:GPKG_UNDEFINED_DEFINITION] == NSOrderedSame];
    
    GPKGDgiwgValidationErrors *errors = [geoPackage validate];
    if([errors hasErrors]){
        NSLog(@"%@", errors);
    }
    [GPKGTestUtils assertTrue:[geoPackage isValid]];
    
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager deleteDGIWG:geoPackageFile]];
}

+(NSString *) metadata{
    NSString *metadataPath  = [[[NSBundle bundleForClass:[GPKGDgiwgGeoPackageTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_DGIWG_METADATA_2];
    NSData *metadataData = [[NSFileManager defaultManager] contentsAtPath:metadataPath];
    NSString *metadata = [NSString stringWithUTF8String:[metadataData bytes]];
    return metadata;
}

/**
 * Test creating tiles from CRS
 */
-(void) testCreateCRSTiles{

    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    [manager delete:GPKG_DGIWG_TEST_FILE_NAME];
    GPKGDgiwgFile *geoPackageFile = [manager create:GPKG_DGIWG_TEST_FILE_NAME withMetadata:[GPKGDgiwgGeoPackageTestCase metadata]];
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:geoPackageFile];

    int minZoom = 0;
    int maxZoom = 1;

    NSString *tilePath  = [[[NSBundle bundleForClass:[GPKGDgiwgGeoPackageTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_TILE_FILE_NAME];
    NSData *tileData = [[NSFileManager defaultManager] contentsAtPath:tilePath];

    for(GPKGDgiwgCoordinateReferenceSystems *crs in [GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemsForContentsType:GPKG_CDT_TILES]){

        NSString *table = [NSString stringWithFormat:@"%@_%d", [crs authority], [crs code]];

        int matrixWidth = [GPKGTileBoundingBoxUtils tilesPerSideWithZoom:minZoom];
        int matrixHeight = matrixWidth;

        GPKGTileMatrixSet *tileMatrixSet = [geoPackage createTilesWithTable:table andCRS:crs];
        
        [geoPackage createTileMatricesWithTileMatrixSet:tileMatrixSet andMinZoom:minZoom andMaxZoom:maxZoom andWidth:matrixWidth andHeight:matrixHeight];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTileMatrixSet:tileMatrixSet];

        for(int zoom = minZoom; zoom <= maxZoom; zoom++){
            
            for(int row = 0; row < matrixHeight; row++){
                
                for(int column = 0; column < matrixWidth; column++){
                    
                    GPKGTileRow *tile = [tileDao newRow];
                    
                    [tile setZoomLevel:zoom];
                    [tile setTileColumn:column];
                    [tile setTileRow:row];
                    [tile setTileData:tileData];
                    
                    [tileDao create:tile];
                    
                }
                
            }
            
            matrixHeight *= 2;
            matrixWidth *= 2;
            
        }

        GPKGBoundingBox *bounds = [crs bounds];

        for(int zoom = minZoom; zoom <= maxZoom; zoom++){
            GPKGBoundingBox *zoomBounds = [tileDao boundingBoxWithZoomLevel:zoom];
            [GPKGTestUtils assertEqualDoubleWithValue:[bounds.minLongitude doubleValue] andValue2:[zoomBounds.minLongitude doubleValue] andDelta:0.00000001];
            [GPKGTestUtils assertEqualDoubleWithValue:[bounds.minLatitude doubleValue] andValue2:[zoomBounds.minLatitude doubleValue] andDelta:0.00000001];
            [GPKGTestUtils assertEqualDoubleWithValue:[bounds.maxLongitude doubleValue] andValue2:[zoomBounds.maxLongitude doubleValue] andDelta:0.00000001];
            [GPKGTestUtils assertEqualDoubleWithValue:[bounds.maxLatitude doubleValue] andValue2:[zoomBounds.maxLatitude doubleValue] andDelta:0.00000001];
        }

        GPKGDgiwgValidationErrors *errors = [geoPackage validateTable:table];
        if([errors hasErrors]){
            NSLog(@"%@", errors);
        }
        [GPKGTestUtils assertTrue:[geoPackage isValid]];

    }

    GPKGDgiwgValidationErrors *errors = [geoPackage validate];
    if([errors hasErrors]){
        NSLog(@"%@", errors);
    }
    [GPKGTestUtils assertTrue:[geoPackage isValid]];
    
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager deleteDGIWG:geoPackageFile]];
}

/**
 * Test creating features from CRS
 */
-(void) testCreateCRSFeatures{

    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    [manager delete:GPKG_DGIWG_TEST_FILE_NAME];
    GPKGDgiwgFile *geoPackageFile = [manager create:GPKG_DGIWG_TEST_FILE_NAME withMetadata:[GPKGDgiwgGeoPackageTestCase metadata]];
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:geoPackageFile];

    for(GPKGDgiwgCoordinateReferenceSystems *crs in [GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemsForContentsType:GPKG_CDT_FEATURES]){

        NSString *table = [NSString stringWithFormat:@"%@_%d", [crs authority], [crs code]];

        GPKGGeometryColumns *geometryColumns = [geoPackage createFeaturesWithTable:table andGeometryType:SF_GEOMETRY andCRS:crs];
        NSNumber *srsId = geometryColumns.srsId;

        GPKGFeatureDao *featureDao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];

        GPKGFeatureRow *featureRow = [featureDao newRow];
        [featureRow setGeometry:[[GPKGGeometryData alloc] initWithSrsId:srsId andGeometry:[GPKGTestUtils createPointWithHasZ:NO andHasM:NO]]];
        [featureDao insert:featureRow];
        
        featureRow = [featureDao newRow];
        [featureRow setGeometry:[[GPKGGeometryData alloc] initWithSrsId:srsId andGeometry:[GPKGTestUtils createLineStringWithHasZ:NO andHasM:NO andRing:NO]]];
        [featureDao insert:featureRow];

        featureRow = [featureDao newRow];
        [featureRow setGeometry:[[GPKGGeometryData alloc] initWithSrsId:srsId andGeometry:[GPKGTestUtils createPolygonWithHasZ:NO andHasM:NO]]];
        [featureDao insert:featureRow];

        [GPKGTestUtils assertEqualIntWithValue:3 andValue2:[featureDao count]];

        GPKGDgiwgValidationErrors *errors = [geoPackage validateTable:table];
        if([errors hasErrors]){
            NSLog(@"%@", errors);
        }
        [GPKGTestUtils assertTrue:[geoPackage isValid]];

    }

    GPKGDgiwgValidationErrors *errors = [geoPackage validate];
    if([errors hasErrors]){
        NSLog(@"%@", errors);
    }
    [GPKGTestUtils assertTrue:[geoPackage isValid]];
    
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager deleteDGIWG:geoPackageFile]];
}

@end
