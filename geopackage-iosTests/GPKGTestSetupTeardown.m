//
//  GPKGTestSetupTeardown.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTestSetupTeardown.h"
#import "GPKGTestUtils.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGTestConstants.h"
#import "GPKGMetadata.h"
#import "GPKGMetadataReference.h"
#import <UIKit/UIKit.h>
#import "GPKGCompressFormats.h"
#import "GPKGImageConverter.h"

NSInteger const GPKG_TEST_SETUP_CREATE_SRS_COUNT = 3;
NSInteger const GPKG_TEST_SETUP_CREATE_CONTENTS_COUNT = 5;
NSInteger const GPKG_TEST_SETUP_CREATE_GEOMETRY_COLUMNS_COUNT = 4;
NSInteger const GPKG_TEST_SETUP_CREATE_TILE_MATRIX_SET_COUNT = 1;
NSInteger const GPKG_TEST_SETUP_CREATE_TILE_MATRIX_COUNT = 3;
NSInteger const GPKG_TEST_SETUP_CREATE_DATA_COLUMN_COUNT = 4;
NSInteger const GPKG_TEST_SETUP_CREATE_DATA_COLUMN_CONSTRAINTS_COUNT = 7;
NSInteger const GPKG_TEST_SETUP_CREATE_METADATA_COUNT = 3;
NSInteger const GPKG_TEST_SETUP_CREATE_METADATA_REFERENCE_COUNT = 3;
NSInteger const GPKG_TEST_SETUP_CREATE_EXTENSIONS_COUNT = 3;

@implementation GPKGTestSetupTeardown

+(GPKGGeoPackage *) setUpCreateWithFeatures: (BOOL) features andTiles: (BOOL) tiles{
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    
    // Delete
    [manager delete:GPKG_TEST_DB_NAME];
    
    // Create
    [manager create:GPKG_TEST_DB_NAME];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:GPKG_TEST_DB_NAME];
    [manager close];
    if(geoPackage == nil){
        [NSException raise:@"Failed to Open" format:@"Failed to open database"];
    }
    
    if(features){
        [self setUpCreateFeaturesWithGeoPackage:geoPackage];
    }
    
    if(tiles){
        [self setUpCreateTilesWithGeoPackage:geoPackage];
    }
    
    [self setUpCreateCommonWithGeoPackage:geoPackage];
    
    return geoPackage;
}

+(void) setUpCreateCommonWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Metadata
    [geoPackage createMetadataTable];
    GPKGMetadataDao * metadataDao = [geoPackage getMetadataDao];
    
    GPKGMetadata * metadata1 = [[GPKGMetadata alloc] init];
    [metadata1 setId:[NSNumber numberWithInt:1]];
    [metadata1 setMetadataScopeType:GPKG_MST_DATASET];
    [metadata1 setStandardUri:@"TEST_URI_1"];
    [metadata1 setMimeType:@"text/xml"];
    [metadata1 setMetadata:@"TEST METADATA 1"];
    [metadataDao create:metadata1];
    
    GPKGMetadata * metadata2 = [[GPKGMetadata alloc] init];
    [metadata2 setId:[NSNumber numberWithInt:2]];
    [metadata2 setMetadataScopeType:GPKG_MST_FEATURE_TYPE];
    [metadata2 setStandardUri:@"TEST_URI_2"];
    [metadata2 setMimeType:@"text/xml"];
    [metadata2 setMetadata:@"TEST METADATA 2"];
    [metadataDao create:metadata2];
    
    GPKGMetadata * metadata3 = [[GPKGMetadata alloc] init];
    [metadata3 setId:[NSNumber numberWithInt:3]];
    [metadata3 setMetadataScopeType:GPKG_MST_TILE];
    [metadata3 setStandardUri:@"TEST_URI_3"];
    [metadata3 setMimeType:@"text/xml"];
    [metadata3 setMetadata:@"TEST METADATA 3"];
    [metadataDao create:metadata3];
    
    // Metadata Reference
    [geoPackage createMetadataReferenceTable];
    GPKGMetadataReferenceDao * metadataReferenceDao = [geoPackage getMetadataReferenceDao];
    
    GPKGMetadataReference * reference1 = [[GPKGMetadataReference alloc] init];
    [reference1 setReferenceScopeType:GPKG_RST_GEOPACKAGE];
    [reference1 setTimestamp:[NSDate date]];
    [reference1 setMetadata:metadata1];
    [metadataReferenceDao create:reference1];
    
    GPKGMetadataReference * reference2 = [[GPKGMetadataReference alloc] init];
    [reference2 setReferenceScopeType:GPKG_RST_TABLE];
    [reference2 setTableName:@"TEST_TABLE_NAME_2"];
    [reference2 setTimestamp:[NSDate date]];
    [reference2 setMetadata:metadata2];
    [reference2 setParentMetadata:metadata1];
    [metadataReferenceDao create:reference2];
    
    GPKGMetadataReference * reference3 = [[GPKGMetadataReference alloc] init];
    [reference3 setReferenceScopeType:GPKG_RST_ROW_COL];
    [reference2 setTableName:@"TEST_TABLE_NAME_3"];
    [reference2 setColumnName:@"TEST_COLUMN_NAME_3"];
    [reference2 setRowIdValue:[NSNumber numberWithInt:5]];
    [reference3 setTimestamp:[NSDate date]];
    [reference3 setMetadata:metadata3];
    [metadataReferenceDao create:reference3];
    
    // Extensions
    [geoPackage createExtensionsTable];
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    GPKGExtensions * extensions1 = [[GPKGExtensions alloc] init];
    [extensions1 setTableName:@"TEST_TABLE_NAME_1"];
    [extensions1 setColumnName:@"TEST_COLUMN_NAME_1"];
    [extensions1 setExtensionNameWithAuthor:@"nga" andExtensionName:@"test_extension_1"];
    [extensions1 setDefinition:@"TEST DEFINITION 1"];
    [extensions1 setExtensionScopeType:GPKG_EST_READ_WRITE];
    [extensionsDao create:extensions1];
    
    GPKGExtensions * extensions2 = [[GPKGExtensions alloc] init];
    [extensions2 setTableName:@"TEST_TABLE_NAME_2"];
    [extensions2 setExtensionNameWithAuthor:@"nga" andExtensionName:@"test_extension_2"];
    [extensions2 setDefinition:@"TEST DEFINITION 2"];
    [extensions2 setExtensionScopeType:GPKG_EST_WRITE_ONLY];
    [extensionsDao create:extensions2];
    
    GPKGExtensions * extensions3 = [[GPKGExtensions alloc] init];
    [extensions3 setExtensionNameWithAuthor:@"nga" andExtensionName:@"test_extension_3"];
    [extensions3 setDefinition:@"TEST DEFINITION 3"];
    [extensions3 setExtensionScopeType:GPKG_EST_READ_WRITE];
    [extensionsDao create:extensions3];
}

+(void) setUpCreateFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Get existing SRS objects
    GPKGSpatialReferenceSystemDao * srsDao = [geoPackage getSpatialReferenceSystemDao];
    
    GPKGSpatialReferenceSystem * epsgSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:[NSNumber numberWithInt:4326]];
    GPKGSpatialReferenceSystem * undefinedCartesianSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:[NSNumber numberWithInt:-1]];
    GPKGSpatialReferenceSystem * undefinedGeographicSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:[NSNumber numberWithInt:0]];
    
    [GPKGTestUtils assertNotNil:epsgSrs];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs];
    [GPKGTestUtils assertNotNil:undefinedGeographicSrs];
    
    // Create the Geometry Columns Table
    [geoPackage createGeometryColumnsTable];
    
    // Create new Contents
    GPKGContentsDao * contentsDao = [geoPackage getContentsDao];
    
    GPKGContents * point2dContents = [[GPKGContents alloc] init];
    [point2dContents setTableName:@"point2d"];
    [point2dContents setContentsDataType:GPKG_CDT_FEATURES];
    [point2dContents setIdentifier:@"point2d"];
    //[point2dContents setTheDescription:@""];
    [point2dContents setLastChange:[NSDate date]];
    [point2dContents setMinX:[[NSDecimalNumber alloc] initWithDouble:-180.0]];
    [point2dContents setMinY:[[NSDecimalNumber alloc] initWithDouble:-90.0]];
    [point2dContents setMaxX:[[NSDecimalNumber alloc] initWithDouble:180.0]];
    [point2dContents setMaxY:[[NSDecimalNumber alloc] initWithDouble:90.0]];
    [point2dContents setSrs:epsgSrs];
    
    GPKGContents * polygon2dContents = [[GPKGContents alloc] init];
    [polygon2dContents setTableName:@"polygon2d"];
    [polygon2dContents setContentsDataType:GPKG_CDT_FEATURES];
    [polygon2dContents setIdentifier:@"polygon2d"];
    //[polygon2dContents setTheDescription:@""];
    [polygon2dContents setLastChange:[NSDate date]];
    [polygon2dContents setMinX:[[NSDecimalNumber alloc] initWithDouble:0.0]];
    [polygon2dContents setMinY:[[NSDecimalNumber alloc] initWithDouble:0.0]];
    [polygon2dContents setMaxX:[[NSDecimalNumber alloc] initWithDouble:10.0]];
    [polygon2dContents setMaxY:[[NSDecimalNumber alloc] initWithDouble:10.0]];
    [polygon2dContents setSrs:undefinedGeographicSrs];
    
    GPKGContents * point3dContents = [[GPKGContents alloc] init];
    [point3dContents setTableName:@"point3d"];
    [point3dContents setContentsDataType:GPKG_CDT_FEATURES];
    [point3dContents setIdentifier:@"point3d"];
    //[point3dContents setTheDescription:@""];
    [point3dContents setLastChange:[NSDate date]];
    [point3dContents setMinX:[[NSDecimalNumber alloc] initWithDouble:-180.0]];
    [point3dContents setMinY:[[NSDecimalNumber alloc] initWithDouble:-90.0]];
    [point3dContents setMaxX:[[NSDecimalNumber alloc] initWithDouble:180.0]];
    [point3dContents setMaxY:[[NSDecimalNumber alloc] initWithDouble:90.0]];
    [point3dContents setSrs:undefinedCartesianSrs];
    
    GPKGContents * lineString3dMContents = [[GPKGContents alloc] init];
    [lineString3dMContents setTableName:@"lineString3dM"];
    [lineString3dMContents setContentsDataType:GPKG_CDT_FEATURES];
    [lineString3dMContents setIdentifier:@"lineString3dM"];
    //[lineString3dMContents setTheDescription:@""];
    [lineString3dMContents setLastChange:[NSDate date]];
    [lineString3dMContents setMinX:[[NSDecimalNumber alloc] initWithDouble:-180.0]];
    [lineString3dMContents setMinY:[[NSDecimalNumber alloc] initWithDouble:-90.0]];
    [lineString3dMContents setMaxX:[[NSDecimalNumber alloc] initWithDouble:180.0]];
    [lineString3dMContents setMaxY:[[NSDecimalNumber alloc] initWithDouble:90.0]];
    [lineString3dMContents setSrs:undefinedCartesianSrs];
    
    // Create Data Column Constraints table and rows
    [GPKGTestUtils createConstraints:geoPackage];
    
    // Create data columns table
    [geoPackage createDataColumnsTable];
    
    NSString * geometryColumn = @"geometry";
    
    // Create the feature tables
    GPKGFeatureTable * point2dTable = [GPKGTestUtils createFeatureTableWithGeoPackage:geoPackage andContents:point2dContents andGeometryColumn:geometryColumn andGeometryType:WKB_POINT];
    GPKGFeatureTable * polygon2dTable = [GPKGTestUtils createFeatureTableWithGeoPackage:geoPackage andContents:polygon2dContents andGeometryColumn:geometryColumn andGeometryType:WKB_POLYGON];
    GPKGFeatureTable * point3dTable = [GPKGTestUtils createFeatureTableWithGeoPackage:geoPackage andContents:point3dContents andGeometryColumn:geometryColumn andGeometryType:WKB_POINT];
    GPKGFeatureTable * lineString3dMTable = [GPKGTestUtils createFeatureTableWithGeoPackage:geoPackage andContents:lineString3dMContents andGeometryColumn:geometryColumn andGeometryType:WKB_LINESTRING];
    
    // Create the contents
    [contentsDao create:point2dContents];
    [contentsDao create:polygon2dContents];
    [contentsDao create:point3dContents];
    [contentsDao create:lineString3dMContents];
    
    // Create new Geometry Columns
    GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    GPKGGeometryColumns * point2dGeometryColumns = [[GPKGGeometryColumns alloc] init];
    [point2dGeometryColumns setContents:point2dContents];
    [point2dGeometryColumns setColumnName:geometryColumn];
    [point2dGeometryColumns setGeometryType:WKB_POINT];
    [point2dGeometryColumns setSrsId: point2dContents.srsId];
    [point2dGeometryColumns setZ:[NSNumber numberWithInt:0]];
    [point2dGeometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumnsDao create:point2dGeometryColumns];
    
    GPKGGeometryColumns * polygon2dGeometryColumns = [[GPKGGeometryColumns alloc] init];
    [polygon2dGeometryColumns setContents:polygon2dContents];
    [polygon2dGeometryColumns setColumnName:geometryColumn];
    [polygon2dGeometryColumns setGeometryType:WKB_POLYGON];
    [polygon2dGeometryColumns setSrsId: polygon2dContents.srsId];
    [polygon2dGeometryColumns setZ:[NSNumber numberWithInt:0]];
    [polygon2dGeometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumnsDao create:polygon2dGeometryColumns];
    
    GPKGGeometryColumns * point3dGeometryColumns = [[GPKGGeometryColumns alloc] init];
    [point3dGeometryColumns setContents:point3dContents];
    [point3dGeometryColumns setColumnName:geometryColumn];
    [point3dGeometryColumns setGeometryType:WKB_POINT];
    [point3dGeometryColumns setSrsId: point3dContents.srsId];
    [point3dGeometryColumns setZ:[NSNumber numberWithInt:1]];
    [point3dGeometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumnsDao create:point3dGeometryColumns];
    
    GPKGGeometryColumns * lineString3dMGeometryColumns = [[GPKGGeometryColumns alloc] init];
    [lineString3dMGeometryColumns setContents:lineString3dMContents];
    [lineString3dMGeometryColumns setColumnName:geometryColumn];
    [lineString3dMGeometryColumns setGeometryType:WKB_LINESTRING];
    [lineString3dMGeometryColumns setSrsId: lineString3dMContents.srsId];
    [lineString3dMGeometryColumns setZ:[NSNumber numberWithInt:1]];
    [lineString3dMGeometryColumns setM:[NSNumber numberWithInt:1]];
    [geometryColumnsDao create:lineString3dMGeometryColumns];
    
    // Populate the feature tables with rows
    [GPKGTestUtils addRowsToFeatureTableWithGeoPackage:geoPackage andGeometryColumns:point2dGeometryColumns andFeatureTable:point2dTable andNumRows:3 andHasZ:false andHasM:false];
    [GPKGTestUtils addRowsToFeatureTableWithGeoPackage:geoPackage andGeometryColumns:polygon2dGeometryColumns andFeatureTable:polygon2dTable andNumRows:3 andHasZ:false andHasM:false];
    [GPKGTestUtils addRowsToFeatureTableWithGeoPackage:geoPackage andGeometryColumns:point3dGeometryColumns andFeatureTable:point3dTable andNumRows:3 andHasZ:true andHasM:false];
    [GPKGTestUtils addRowsToFeatureTableWithGeoPackage:geoPackage andGeometryColumns:lineString3dMGeometryColumns andFeatureTable:lineString3dMTable andNumRows:3 andHasZ:true andHasM:true];

}

+(void) setUpCreateTilesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Get existing SRS objects
    GPKGSpatialReferenceSystemDao * srsDao = [geoPackage getSpatialReferenceSystemDao];
    
    GPKGSpatialReferenceSystem * epsgSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:[NSNumber numberWithInt:4326]];
    
    [GPKGTestUtils assertNotNil:epsgSrs];
    
    // Create the Tile Matrix Set and Tile Matrix tables
    [geoPackage createTileMatrixSetTable];
    [geoPackage createTileMatrixTable];
    
    // Create new Contents
    GPKGContentsDao * contentsDao = [geoPackage getContentsDao];
    
    
    GPKGContents * contents = [[GPKGContents alloc] init];
    [contents setTableName:@"test_tiles"];
    [contents setContentsDataType:GPKG_CDT_TILES];
    [contents setIdentifier:@"test_tiles"];
    //[contents setTheDescription:@""];
    [contents setLastChange:[NSDate date]];
    [contents setMinX:[[NSDecimalNumber alloc] initWithDouble:-180.0]];
    [contents setMinY:[[NSDecimalNumber alloc] initWithDouble:-90.0]];
    [contents setMaxX:[[NSDecimalNumber alloc] initWithDouble:180.0]];
    [contents setMaxY:[[NSDecimalNumber alloc] initWithDouble:90.0]];
    [contents setSrs:epsgSrs];
    
    // Create the user tile table
    GPKGTileTable * tileTable = [GPKGTestUtils buildTileTableWithTableName:contents.tableName];
    [geoPackage createTileTable:tileTable];
    
    // Create the contents
    [contentsDao create:contents];
    
    // Create the new Tile Matrix Set
    GPKGTileMatrixSetDao * tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    
    GPKGTileMatrixSet * tileMatrixSet = [[GPKGTileMatrixSet alloc] init];
    [tileMatrixSet setContents:contents];
    [tileMatrixSet setSrs:epsgSrs];
    [tileMatrixSet setMinX:contents.minX];
    [tileMatrixSet setMinY:contents.minY];
    [tileMatrixSet setMaxX:contents.maxX];
    [tileMatrixSet setMaxY:contents.maxY];
    [tileMatrixSetDao create:tileMatrixSet];
    
    // Create new Tile Matrix rows
    GPKGTileMatrixDao * tileMatrixDao = [geoPackage getTileMatrixDao];
    
    int matrixWidthAndHeight = 2;
    double pixelXSize = 69237.2;
    double pixelYSize = 68412.1;
    
    // Read the asset tile to bytes and convert to bitmap
    NSString *tilePath  = [[[NSBundle bundleForClass:[GPKGTestSetupTeardown class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_TILE_FILE_NAME];
    NSData *tilePathData = [[NSFileManager defaultManager] contentsAtPath:tilePath];
    UIImage * image = [GPKGImageConverter toImage:tilePathData];
    
    // Get the width and height of the bitmap
    int tileWidth = image.size.width;
    int tileHeight = image.size.height;
    
    // Compress the bitmap back to bytes and use those for the test
    NSData * tileData = [GPKGImageConverter toData:image andFormat:[GPKGCompressFormats fromName:GPKG_TEST_TILE_FILE_NAME_EXTENSION]];
    
    for(int zoom = 0; zoom < GPKG_TEST_SETUP_CREATE_TILE_MATRIX_COUNT; zoom++){
        
        GPKGTileMatrix * tileMatrix = [[GPKGTileMatrix alloc] init];
        [tileMatrix setContents:contents];
        [tileMatrix setZoomLevel:[NSNumber numberWithInt:zoom]];
        [tileMatrix setMatrixWidth:[NSNumber numberWithInt:matrixWidthAndHeight]];
        [tileMatrix setMatrixHeight:[NSNumber numberWithInt:matrixWidthAndHeight]];
        [tileMatrix setTileWidth:[NSNumber numberWithInt:tileWidth]];
        [tileMatrix setTileHeight:[NSNumber numberWithInt:tileHeight]];
        [tileMatrix setPixelXSize:[[NSDecimalNumber alloc] initWithDouble:pixelXSize]];
        [tileMatrix setPixelYSize:[[NSDecimalNumber alloc] initWithDouble:pixelYSize]];
        [tileMatrixDao create:tileMatrix];
        
        matrixWidthAndHeight *= 2;
        pixelXSize /= 2.0;
        pixelYSize /= 2.0;
        
        // Populate the tile table with rows
        [GPKGTestUtils addRowsToTileTableWithGeoPackage:geoPackage andTileMatrix:tileMatrix andData:tileData];
    }
    
}

+(void) tearDownCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
 
    // Close
    if (geoPackage != nil) {
        [geoPackage close];
    }
    
    // Delete
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    [manager delete:GPKG_TEST_DB_NAME];
    [manager close];
}

+(GPKGGeoPackage *) setUpImport{
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    
    // Delete
    [manager delete:GPKG_TEST_IMPORT_DB_NAME];
    
    NSString *filePath  = [[[NSBundle bundleForClass:[GPKGTestSetupTeardown class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_IMPORT_DB_FILE_NAME];
    
    // Import
    //NSURL *url =  [NSURL URLWithString:@"http://www.geopackage.org/data/gdal_sample.gpkg"];
    //NSURL *url =  [NSURL URLWithString:@"http://www.geopackage.org/data/haiti-vectors-split.gpkg"];
    //[manager importGeoPackageFromUrl:url andDatabase:GPKG_TEST_IMPORT_DB_NAME];
    [manager importGeoPackageFromPath:filePath withName:GPKG_TEST_IMPORT_DB_NAME];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:GPKG_TEST_IMPORT_DB_NAME];
    [manager close];
    if(geoPackage == nil){
        [NSException raise:@"Failed to Open" format:@"Failed to open database"];
    }
    
    return geoPackage;
}

+(void) tearDownImportWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Close
    if (geoPackage != nil) {
        [geoPackage close];
    }
    
    // Delete
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    [manager delete:GPKG_TEST_IMPORT_DB_NAME];
    [manager close];
}

@end
