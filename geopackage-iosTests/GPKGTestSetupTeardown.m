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
#import "GPKGUtils.h"
#import "GPKGAttributesColumn.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGDateTimeUtils.h"

NSInteger const GPKG_TEST_SETUP_CREATE_SRS_COUNT = 3;
NSInteger const GPKG_TEST_SETUP_CREATE_CONTENTS_COUNT = 6;
NSInteger const GPKG_TEST_SETUP_CREATE_GEOMETRY_COLUMNS_COUNT = 4;
NSInteger const GPKG_TEST_SETUP_CREATE_TILE_MATRIX_SET_COUNT = 1;
NSInteger const GPKG_TEST_SETUP_CREATE_TILE_MATRIX_COUNT = 3;
NSInteger const GPKG_TEST_SETUP_CREATE_DATA_COLUMN_COUNT = 4;
NSInteger const GPKG_TEST_SETUP_CREATE_DATA_COLUMN_CONSTRAINTS_COUNT = 7;
NSInteger const GPKG_TEST_SETUP_CREATE_METADATA_COUNT = 4;
NSInteger const GPKG_TEST_SETUP_CREATE_METADATA_REFERENCE_COUNT = 13;
NSInteger const GPKG_TEST_SETUP_CREATE_EXTENSIONS_COUNT = 7;

@implementation GPKGTestSetupTeardown

+(GPKGGeoPackage *) setUpCreateWithFeatures: (BOOL) features andTiles: (BOOL) tiles{
    return [self setUpCreateWithFeatures:features andAllowEmptyFeatures:YES andTiles:tiles];
}

+(GPKGGeoPackage *) setUpCreateWithFeatures: (BOOL) features andAllowEmptyFeatures: (BOOL) allowEmptyFeatures andTiles: (BOOL) tiles{
    return [self setUpCreateWithName:GPKG_TEST_DB_NAME andFeatures:features  andAllowEmptyFeatures:allowEmptyFeatures andTiles:tiles];
}

+(GPKGGeoPackage *) setUpCreateWithName: (NSString *) name andFeatures: (BOOL) features andAllowEmptyFeatures: (BOOL) allowEmptyFeatures andTiles: (BOOL) tiles{
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory manager];
    
    // Delete
    [manager delete:name];
    
    // Create
    [manager create:name];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:name];
    [manager close];
    if(geoPackage == nil){
        [NSException raise:@"Failed to Open" format:@"Failed to open database"];
    }
    
    [GPKGTestUtils assertEqualWithValue:[geoPackage applicationId] andValue2:GPKG_APPLICATION_ID];
    [GPKGTestUtils assertEqualIntWithValue:[geoPackage userVersion] andValue2:(int)GPKG_USER_VERSION];
    NSString * userVersionString= [NSString stringWithFormat:@"%d",[geoPackage userVersion]];
    NSString * majorVersion = [userVersionString substringWithRange:NSMakeRange(0, userVersionString.length - 4)];
    NSString * minorVersion = [userVersionString substringWithRange:NSMakeRange(userVersionString.length - 4, userVersionString.length - 3)];
    NSString * patchVersion = [userVersionString substringFromIndex:userVersionString.length - 2];
    [GPKGTestUtils assertEqualIntWithValue:[geoPackage userVersionMajor] andValue2:[majorVersion intValue]];
    [GPKGTestUtils assertEqualIntWithValue:[geoPackage userVersionMinor] andValue2:[minorVersion intValue]];
    [GPKGTestUtils assertEqualIntWithValue:[geoPackage userVersionPatch] andValue2:[patchVersion intValue]];
    
    if(features){
        [self setUpCreateFeaturesWithGeoPackage:geoPackage andAllowEmptyFeatures:allowEmptyFeatures];
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
    GPKGMetadataDao * metadataDao = [geoPackage metadataDao];
    
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
    GPKGMetadataReferenceDao * metadataReferenceDao = [geoPackage metadataReferenceDao];
    
    GPKGMetadataReference * reference1 = [[GPKGMetadataReference alloc] init];
    [reference1 setReferenceScopeType:GPKG_RST_GEOPACKAGE];
    // [reference1 setTimestamp:[NSDate date]];
    [reference1 setMetadata:metadata1];
    [metadataReferenceDao create:reference1];
    
    GPKGMetadataReference * reference2 = [[GPKGMetadataReference alloc] init];
    [reference2 setReferenceScopeType:GPKG_RST_TABLE];
    [reference2 setTableName:@"TEST_TABLE_NAME_2"];
    // [reference2 setTimestamp:[NSDate date]];
    [reference2 setMetadata:metadata2];
    [reference2 setParentMetadata:metadata1];
    [metadataReferenceDao create:reference2];
    
    GPKGMetadataReference * reference3 = [[GPKGMetadataReference alloc] init];
    [reference3 setReferenceScopeType:GPKG_RST_ROW_COL];
    [reference3 setTableName:@"TEST_TABLE_NAME_3"];
    [reference3 setColumnName:@"TEST_COLUMN_NAME_3"];
    [reference3 setRowIdValue:[NSNumber numberWithInt:5]];
    // [reference3 setTimestamp:[NSDate date]];
    [reference3 setMetadata:metadata3];
    [metadataReferenceDao create:reference3];
    
    // Extensions
    [geoPackage createExtensionsTable];
    GPKGExtensionsDao * extensionsDao = [geoPackage extensionsDao];
    
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
    
    // Attributes
    
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    
    [GPKGUtils addObject:[GPKGAttributesColumn createColumnWithIndex:6 andName:@"test_text_limited" andDataType:GPKG_DT_TEXT andMax: [NSNumber numberWithInt:5]] toArray:columns];
    [GPKGUtils addObject:[GPKGAttributesColumn createColumnWithIndex:7 andName:@"test_blob_limited" andDataType:GPKG_DT_BLOB andMax: [NSNumber numberWithInt:7]] toArray:columns];
    [GPKGUtils addObject:[GPKGAttributesColumn createColumnWithIndex:8 andName:@"test_date" andDataType:GPKG_DT_DATE] toArray:columns];
    [GPKGUtils addObject:[GPKGAttributesColumn createColumnWithIndex:9 andName:@"test_datetime" andDataType:GPKG_DT_DATETIME] toArray:columns];
    [GPKGUtils addObject:[GPKGAttributesColumn createColumnWithIndex:1 andName:@"test_text" andDataType:GPKG_DT_TEXT andNotNull:false andDefaultValue:@""] toArray:columns];
    [GPKGUtils addObject:[GPKGAttributesColumn createColumnWithIndex:2 andName:@"test_real" andDataType:GPKG_DT_REAL] toArray:columns];
    [GPKGUtils addObject:[GPKGAttributesColumn createColumnWithIndex:3 andName:@"test_boolean" andDataType:GPKG_DT_BOOLEAN] toArray:columns];
    [GPKGUtils addObject:[GPKGAttributesColumn createColumnWithIndex:4 andName:@"test_blob" andDataType:GPKG_DT_BLOB] toArray:columns];
    [GPKGUtils addObject:[GPKGAttributesColumn createColumnWithIndex:5 andName:@"test_integer" andDataType:GPKG_DT_INTEGER] toArray:columns];
    
    GPKGAttributesTable * attributesTable = [geoPackage createAttributesTableWithTableName:@"test_attributes" andAdditionalColumns:columns];
    [GPKGTestUtils assertNotNil:attributesTable];
    GPKGContents * attributesContents = attributesTable.contents;
    [GPKGTestUtils assertNotNil:attributesContents];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_CDT_ATTRIBUTES andValue2:[attributesContents contentsDataType]];
    [GPKGTestUtils assertEqualWithValue:@"test_attributes" andValue2:attributesContents.tableName];
    [GPKGTestUtils assertEqualWithValue:attributesContents.tableName andValue2:attributesTable.tableName];
    
    GPKGMetadata * attributesMetadata = [[GPKGMetadata alloc] init];
    [attributesMetadata setId:[NSNumber numberWithInt:4]];
    [attributesMetadata setMetadataScopeType:GPKG_MST_ATTRIBUTE_TYPE];
    [attributesMetadata setStandardUri:@"ATTRIBUTES_TEST_URI"];
    [attributesMetadata setMimeType:@"text/plain"];
    [attributesMetadata setMetadata:@"ATTRIBUTES METADATA"];
    [metadataDao create:attributesMetadata];
    
    GPKGAttributesDao * attributesDao = [geoPackage attributesDaoWithTableName:attributesTable.tableName];
    
    for (int i = 0; i < 10; i++) {
        
        GPKGAttributesRow * newRow = [attributesDao newRow];
        
        for (GPKGAttributesColumn * column in attributesTable.columns) {
            if(!column.primaryKey){
                
                // Leave nullable columns null 20% of the time
                if(!column.notNull){
                    if ([GPKGTestUtils randomDouble] < 0.2) {
                        continue;
                    }
                }
                
                NSObject * value = nil;
                
                switch (column.dataType) {
                        
                    case GPKG_DT_TEXT:
                    {
                        NSString * text = [[NSProcessInfo processInfo] globallyUniqueString];
                        if(column.max != nil && [text length] > [column.max intValue]){
                            text = [text substringToIndex:[column.max intValue]];
                        }
                        value = text;
                    }
                        break;
                    case GPKG_DT_REAL:
                    case GPKG_DT_DOUBLE:
                        value = [[NSDecimalNumber alloc] initWithDouble:[GPKGTestUtils randomDoubleLessThan:5000.0]];
                        break;
                    case GPKG_DT_BOOLEAN:
                        value = [NSNumber numberWithBool:([GPKGTestUtils randomDouble] < .5 ? false : true)];
                        break;
                    case GPKG_DT_INTEGER:
                    case GPKG_DT_INT:
                        value = [NSNumber numberWithInt:[GPKGTestUtils randomIntLessThan:500]];
                        break;
                    case GPKG_DT_BLOB:
                        {
                            NSData * blob = [[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding];
                            if(column.max != nil && [blob length] > [column.max intValue]){
                                blob = [blob subdataWithRange:NSMakeRange(0, [column.max intValue])];
                            }
                            value = blob;
                        }
                        break;
                    case GPKG_DT_DATE:
                    case GPKG_DT_DATETIME:
                        {
                            NSDate *date = [NSDate date];
                            if([GPKGTestUtils randomDouble] < .5){
                                if(column.dataType == GPKG_DT_DATE){
                                    value = [GPKGDateTimeUtils convertToDateWithString:[GPKGDateTimeUtils convertToStringWithDate:date andType:column.dataType]];
                                }else{
                                    value = date;
                                }
                            }else{
                                value = [GPKGDateTimeUtils convertToStringWithDate:date andType:column.dataType];
                            }
                        }
                        break;
                    default:
                        [NSException raise:@"Not implemented" format:@"Not implemented for data type: %u", column.dataType];
                }
                
                [newRow setValueWithColumnName:column.name andValue:value];
                
            }
        }
        int rowId = (int)[attributesDao create:newRow];
        
        GPKGMetadataReference * attributesReference = [[GPKGMetadataReference alloc] init];
        [attributesReference setReferenceScopeType:GPKG_RST_ROW];
        [attributesReference setTableName:attributesTable.tableName];
        [attributesReference setRowIdValue:[NSNumber numberWithInt:rowId]];
        // [attributesReference setTimestamp:[NSDate date]];
        [attributesReference setMetadata:attributesMetadata];
        [metadataReferenceDao create:attributesReference];
        
    }
}

+(void) setUpCreateFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage andAllowEmptyFeatures: (BOOL) allowEmptyFeatures{
    
    // Get existing SRS objects
    GPKGSpatialReferenceSystemDao * srsDao = [geoPackage spatialReferenceSystemDao];
    
    GPKGSpatialReferenceSystem * epsgSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:[NSNumber numberWithInt:4326]];
    GPKGSpatialReferenceSystem * undefinedCartesianSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:[NSNumber numberWithInt:-1]];
    GPKGSpatialReferenceSystem * undefinedGeographicSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:[NSNumber numberWithInt:0]];
    
    [GPKGTestUtils assertNotNil:epsgSrs];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs];
    [GPKGTestUtils assertNotNil:undefinedGeographicSrs];
    
    // Create the Geometry Columns Table
    [geoPackage createGeometryColumnsTable];
    
    // Create new Contents
    GPKGContentsDao * contentsDao = [geoPackage contentsDao];
    
    GPKGContents * point2dContents = [[GPKGContents alloc] init];
    [point2dContents setTableName:@"point2d"];
    [point2dContents setContentsDataType:GPKG_CDT_FEATURES];
    [point2dContents setIdentifier:@"point2d"];
    // [point2dContents setTheDescription:@""];
    // [point2dContents setLastChange:[NSDate date]];
    [point2dContents setMinX:[[NSDecimalNumber alloc] initWithDouble:-180.0]];
    [point2dContents setMinY:[[NSDecimalNumber alloc] initWithDouble:-90.0]];
    [point2dContents setMaxX:[[NSDecimalNumber alloc] initWithDouble:180.0]];
    [point2dContents setMaxY:[[NSDecimalNumber alloc] initWithDouble:90.0]];
    [point2dContents setSrs:epsgSrs];
    
    GPKGContents * polygon2dContents = [[GPKGContents alloc] init];
    [polygon2dContents setTableName:@"polygon2d"];
    [polygon2dContents setContentsDataType:GPKG_CDT_FEATURES];
    [polygon2dContents setIdentifier:@"polygon2d"];
    // [polygon2dContents setTheDescription:@""];
    // [polygon2dContents setLastChange:[NSDate date]];
    [polygon2dContents setMinX:[[NSDecimalNumber alloc] initWithDouble:0.0]];
    [polygon2dContents setMinY:[[NSDecimalNumber alloc] initWithDouble:0.0]];
    [polygon2dContents setMaxX:[[NSDecimalNumber alloc] initWithDouble:10.0]];
    [polygon2dContents setMaxY:[[NSDecimalNumber alloc] initWithDouble:10.0]];
    [polygon2dContents setSrs:undefinedGeographicSrs];
    
    GPKGContents * point3dContents = [[GPKGContents alloc] init];
    [point3dContents setTableName:@"point3d"];
    [point3dContents setContentsDataType:GPKG_CDT_FEATURES];
    [point3dContents setIdentifier:@"point3d"];
    // [point3dContents setTheDescription:@""];
    // [point3dContents setLastChange:[NSDate date]];
    [point3dContents setMinX:[[NSDecimalNumber alloc] initWithDouble:-180.0]];
    [point3dContents setMinY:[[NSDecimalNumber alloc] initWithDouble:-90.0]];
    [point3dContents setMaxX:[[NSDecimalNumber alloc] initWithDouble:180.0]];
    [point3dContents setMaxY:[[NSDecimalNumber alloc] initWithDouble:90.0]];
    [point3dContents setSrs:undefinedCartesianSrs];
    
    GPKGContents * lineString3dMContents = [[GPKGContents alloc] init];
    [lineString3dMContents setTableName:@"lineString3dM"];
    [lineString3dMContents setContentsDataType:GPKG_CDT_FEATURES];
    [lineString3dMContents setIdentifier:@"lineString3dM"];
    // [lineString3dMContents setTheDescription:@""];
    // [lineString3dMContents setLastChange:[NSDate date]];
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
    GPKGFeatureTable * point2dTable = [GPKGTestUtils createFeatureTableWithGeoPackage:geoPackage andContents:point2dContents andGeometryColumn:geometryColumn andGeometryType:SF_POINT];
    GPKGFeatureTable * polygon2dTable = [GPKGTestUtils createFeatureTableWithGeoPackage:geoPackage andContents:polygon2dContents andGeometryColumn:geometryColumn andGeometryType:SF_POLYGON];
    GPKGFeatureTable * point3dTable = [GPKGTestUtils createFeatureTableWithGeoPackage:geoPackage andContents:point3dContents andGeometryColumn:geometryColumn andGeometryType:SF_POINT];
    GPKGFeatureTable * lineString3dMTable = [GPKGTestUtils createFeatureTableWithGeoPackage:geoPackage andContents:lineString3dMContents andGeometryColumn:geometryColumn andGeometryType:SF_LINESTRING];
    
    // Create the contents
    [contentsDao create:point2dContents];
    [contentsDao create:polygon2dContents];
    [contentsDao create:point3dContents];
    [contentsDao create:lineString3dMContents];
    
    // Create new Geometry Columns
    GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage geometryColumnsDao];
    
    GPKGGeometryColumns * point2dGeometryColumns = [[GPKGGeometryColumns alloc] init];
    [point2dGeometryColumns setContents:point2dContents];
    [point2dGeometryColumns setColumnName:geometryColumn];
    [point2dGeometryColumns setGeometryType:SF_POINT];
    [point2dGeometryColumns setSrsId: point2dContents.srsId];
    [point2dGeometryColumns setZ:[NSNumber numberWithInt:0]];
    [point2dGeometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumnsDao create:point2dGeometryColumns];
    
    GPKGGeometryColumns * polygon2dGeometryColumns = [[GPKGGeometryColumns alloc] init];
    [polygon2dGeometryColumns setContents:polygon2dContents];
    [polygon2dGeometryColumns setColumnName:geometryColumn];
    [polygon2dGeometryColumns setGeometryType:SF_POLYGON];
    [polygon2dGeometryColumns setSrsId: polygon2dContents.srsId];
    [polygon2dGeometryColumns setZ:[NSNumber numberWithInt:0]];
    [polygon2dGeometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumnsDao create:polygon2dGeometryColumns];
    
    GPKGGeometryColumns * point3dGeometryColumns = [[GPKGGeometryColumns alloc] init];
    [point3dGeometryColumns setContents:point3dContents];
    [point3dGeometryColumns setColumnName:geometryColumn];
    [point3dGeometryColumns setGeometryType:SF_POINT];
    [point3dGeometryColumns setSrsId: point3dContents.srsId];
    [point3dGeometryColumns setZ:[NSNumber numberWithInt:1]];
    [point3dGeometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumnsDao create:point3dGeometryColumns];
    
    GPKGGeometryColumns * lineString3dMGeometryColumns = [[GPKGGeometryColumns alloc] init];
    [lineString3dMGeometryColumns setContents:lineString3dMContents];
    [lineString3dMGeometryColumns setColumnName:geometryColumn];
    [lineString3dMGeometryColumns setGeometryType:SF_LINESTRING];
    [lineString3dMGeometryColumns setSrsId: lineString3dMContents.srsId];
    [lineString3dMGeometryColumns setZ:[NSNumber numberWithInt:1]];
    [lineString3dMGeometryColumns setM:[NSNumber numberWithInt:1]];
    [geometryColumnsDao create:lineString3dMGeometryColumns];
    
    // Populate the feature tables with rows
    [GPKGTestUtils addRowsToFeatureTableWithGeoPackage:geoPackage andGeometryColumns:point2dGeometryColumns andFeatureTable:point2dTable andNumRows:3 andHasZ:false andHasM:false andAllowEmptyFeatures:allowEmptyFeatures];
    [GPKGTestUtils addRowsToFeatureTableWithGeoPackage:geoPackage andGeometryColumns:polygon2dGeometryColumns andFeatureTable:polygon2dTable andNumRows:3 andHasZ:false andHasM:false andAllowEmptyFeatures:allowEmptyFeatures];
    [GPKGTestUtils addRowsToFeatureTableWithGeoPackage:geoPackage andGeometryColumns:point3dGeometryColumns andFeatureTable:point3dTable andNumRows:3 andHasZ:true andHasM:false andAllowEmptyFeatures:allowEmptyFeatures];
    [GPKGTestUtils addRowsToFeatureTableWithGeoPackage:geoPackage andGeometryColumns:lineString3dMGeometryColumns andFeatureTable:lineString3dMTable andNumRows:3 andHasZ:true andHasM:true andAllowEmptyFeatures:allowEmptyFeatures];

}

+(void) setUpCreateTilesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Get existing SRS objects
    GPKGSpatialReferenceSystemDao * srsDao = [geoPackage spatialReferenceSystemDao];
    
    GPKGSpatialReferenceSystem * epsgSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:[NSNumber numberWithInt:4326]];
    
    [GPKGTestUtils assertNotNil:epsgSrs];
    
    // Create the Tile Matrix Set and Tile Matrix tables
    [geoPackage createTileMatrixSetTable];
    [geoPackage createTileMatrixTable];
    
    // Create new Contents
    GPKGContentsDao * contentsDao = [geoPackage contentsDao];
    
    
    GPKGContents * contents = [[GPKGContents alloc] init];
    [contents setTableName:@"test_tiles"];
    [contents setContentsDataType:GPKG_CDT_TILES];
    [contents setIdentifier:@"test_tiles"];
    // [contents setTheDescription:@""];
    // [contents setLastChange:[NSDate date]];
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
    GPKGTileMatrixSetDao * tileMatrixSetDao = [geoPackage tileMatrixSetDao];
    
    GPKGTileMatrixSet * tileMatrixSet = [[GPKGTileMatrixSet alloc] init];
    [tileMatrixSet setContents:contents];
    [tileMatrixSet setSrs:epsgSrs];
    [tileMatrixSet setMinX:contents.minX];
    [tileMatrixSet setMinY:contents.minY];
    [tileMatrixSet setMaxX:contents.maxX];
    [tileMatrixSet setMaxY:contents.maxY];
    [tileMatrixSetDao create:tileMatrixSet];
    
    // Create new Tile Matrix rows
    GPKGTileMatrixDao * tileMatrixDao = [geoPackage tileMatrixDao];
    
    // Read the asset tile to bytes and convert to bitmap
    NSString *tilePath  = [[[NSBundle bundleForClass:[GPKGTestSetupTeardown class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_TILE_FILE_NAME];
    NSData *tilePathData = [[NSFileManager defaultManager] contentsAtPath:tilePath];
    UIImage * image = [GPKGImageConverter toImage:tilePathData];
    
    // Get the width and height of the bitmap
    int tileWidth = image.size.width;
    int tileHeight = image.size.height;
    
    int matrixWidthAndHeight = 2;
    double pixelXSize = ([tileMatrixSet.maxX doubleValue] - [tileMatrixSet.minX doubleValue]) / (matrixWidthAndHeight * tileWidth);
    double pixelYSize = ([tileMatrixSet.maxY doubleValue] - [tileMatrixSet.minY doubleValue]) / (matrixWidthAndHeight * tileHeight);
    
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
        [tileMatrix setPixelXSizeValue:pixelXSize];
        [tileMatrix setPixelYSizeValue:pixelYSize];
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
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory manager];
    [manager delete:GPKG_TEST_DB_NAME];
    [manager close];
}

+(GPKGGeoPackage *) setUpImport{
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory manager];
    
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
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory manager];
    [manager delete:GPKG_TEST_IMPORT_DB_NAME];
    [manager close];
}

@end
