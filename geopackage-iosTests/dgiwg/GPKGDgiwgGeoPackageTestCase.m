//
//  GPKGDgiwgGeoPackageTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 12/1/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgGeoPackageTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGDgiwgCoordinateReferenceSystems.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGDgiwgGeoPackageFactory.h"
#import "GPKGDgiwgGeoPackageManagerTestCase.h"
#import "GPKGTestConstants.h"

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

+(NSString *) metadata{
    NSString *metadataPath  = [[[NSBundle bundleForClass:[GPKGDgiwgGeoPackageTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_DGIWG_METADATA_2];
    NSData *metadataData = [[NSFileManager defaultManager] contentsAtPath:metadataPath];
    NSString *metadata = [NSString stringWithUTF8String:[metadataData bytes]];
    return metadata;
}

@end
