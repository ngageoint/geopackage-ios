//
//  GPKGGeoPackageTestUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/16/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageTestUtils.h"
#import "GPKGUtils.h"
#import "GPKGTestUtils.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionConstants.h"
#import "GPKGFeatureIndexManager.h"

@implementation GPKGGeoPackageTestUtils

+(void)testCreateFeatureTableWithMetadata: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata"];
    [geometryColumns setColumnName:@"geom"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage getSpatialReferenceSystemDao] getOrCreateWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    geometryColumns = [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andBoundingBox:boundingBox andSrsId:srs.srsId];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:nil];
}

+(void)testCreateFeatureTableWithMetadataIdColumn: (GPKGGeoPackage *) geoPackage{

    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata2"];
    [geometryColumns setColumnName:@"geom2"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage getSpatialReferenceSystemDao] getOrCreateWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    NSString * idColumn = @"my_id";
    geometryColumns = [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andIdColumnName:idColumn andBoundingBox:boundingBox andSrsId:srs.srsId];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:idColumn andAdditionalColumns:nil];
}

+(void)testCreateFeatureTableWithMetadataAdditionalColumns: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata3"];
    [geometryColumns setColumnName:@"geom3"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    NSArray * additionalColumns = [self getFeatureColumns];
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage getSpatialReferenceSystemDao] getOrCreateWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    geometryColumns = [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andAdditionalColumns:additionalColumns andBoundingBox:boundingBox andSrsId:srs.srsId];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:additionalColumns];
}

+(void)testCreateFeatureTableWithMetadataIdColumnAdditionalColumns: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata4"];
    [geometryColumns setColumnName:@"geom4"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    NSArray * additionalColumns = [self getFeatureColumns];
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage getSpatialReferenceSystemDao] getOrCreateWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    NSString * idColumn = @"my_other_id";
    geometryColumns = [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andIdColumnName:idColumn andAdditionalColumns:additionalColumns andBoundingBox:boundingBox andSrsId:srs.srsId];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:idColumn andAdditionalColumns:additionalColumns];
}

+(NSArray *) getFeatureColumns{
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:7 andName:@"test_text_limited" andDataType:GPKG_DT_TEXT andMax: [NSNumber numberWithInt:5] andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:8 andName:@"test_blob_limited" andDataType:GPKG_DT_BLOB andMax: [NSNumber numberWithInt:7] andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:9 andName:@"test_date" andDataType:GPKG_DT_DATE andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:10 andName:@"test_datetime" andDataType:GPKG_DT_DATETIME andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:2 andName:@"test_text" andDataType:GPKG_DT_TEXT andNotNull:false andDefaultValue:@""] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:3 andName:@"test_real" andDataType:GPKG_DT_REAL andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:4 andName:@"test_boolean" andDataType:GPKG_DT_BOOLEAN andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:5 andName:@"test_blob" andDataType:GPKG_DT_BLOB andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:6 andName:@"test_integer" andDataType:GPKG_DT_INTEGER andNotNull:false andDefaultValue:nil] toArray:columns];
    
    return columns;
}

+(void) validateFeatureTableWithMetadata: (GPKGGeoPackage *) geoPackage andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumn andAdditionalColumns: (NSArray *) additionalColumns{
    
    GPKGGeometryColumnsDao * dao = [geoPackage getGeometryColumnsDao];
    
    GPKGGeometryColumns * queryGeometryColumns = (GPKGGeometryColumns *)[dao queryForMultiIdObject:[dao getMultiId:geometryColumns]];
    [GPKGTestUtils assertNotNil:queryGeometryColumns];
    
    [GPKGTestUtils assertEqualWithValue:geometryColumns.tableName andValue2:queryGeometryColumns.tableName];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.columnName andValue2:queryGeometryColumns.columnName];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.geometryTypeName andValue2:queryGeometryColumns.geometryTypeName];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.z andValue2:queryGeometryColumns.z];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.m andValue2:queryGeometryColumns.m];
    
    GPKGFeatureDao * featureDao = [geoPackage getFeatureDaoWithTableName:geometryColumns.tableName];
    GPKGFeatureRow * featureRow = [featureDao newRow];
    
    [GPKGTestUtils assertEqualIntWithValue:(2 + (additionalColumns != nil ? (int)[additionalColumns count] : 0)) andValue2:[featureRow columnCount]];
    if(idColumn == nil){
        idColumn = @"id";
    }
    [GPKGTestUtils assertEqualWithValue:idColumn andValue2:[featureRow getColumnNameWithIndex:0]];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.columnName andValue2:[featureRow getColumnNameWithIndex:1]];
    
    if(additionalColumns != nil){
        [GPKGTestUtils assertEqualWithValue:@"test_text" andValue2:[featureRow getColumnNameWithIndex:2]];
        [GPKGTestUtils assertEqualWithValue:@"test_real" andValue2:[featureRow getColumnNameWithIndex:3]];
        [GPKGTestUtils assertEqualWithValue:@"test_boolean" andValue2:[featureRow getColumnNameWithIndex:4]];
        [GPKGTestUtils assertEqualWithValue:@"test_blob" andValue2:[featureRow getColumnNameWithIndex:5]];
        [GPKGTestUtils assertEqualWithValue:@"test_integer" andValue2:[featureRow getColumnNameWithIndex:6]];
        [GPKGTestUtils assertEqualWithValue:@"test_text_limited" andValue2:[featureRow getColumnNameWithIndex:7]];
        [GPKGTestUtils assertEqualWithValue:@"test_blob_limited" andValue2:[featureRow getColumnNameWithIndex:8]];
        [GPKGTestUtils assertEqualWithValue:@"test_date" andValue2:[featureRow getColumnNameWithIndex:9]];
        [GPKGTestUtils assertEqualWithValue:@"test_datetime" andValue2:[featureRow getColumnNameWithIndex:10]];
    }
}

+(void)testDeleteTables: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    GPKGContentsDao *contentsDao = [geoPackage getContentsDao];
    
    [GPKGTestUtils assertTrue:[geometryColumnsDao tableExists] || [tileMatrixSetDao tableExists]];
    
    if([geometryColumnsDao tableExists]){
        
        [GPKGTestUtils assertEqualIntWithValue:(int)[geoPackage getFeatureTables].count andValue2:[geometryColumnsDao count]];
        for(NSString *featureTable in [geoPackage getFeatureTables]){
            [GPKGTestUtils assertTrue:[geoPackage isTable:featureTable]];
            [GPKGTestUtils assertNotNil:[contentsDao queryForIdObject:featureTable]];
            [geoPackage deleteTable:featureTable];
            [GPKGTestUtils assertFalse:[geoPackage isTable:featureTable]];
            [GPKGTestUtils assertNil:[contentsDao queryForIdObject:featureTable]];
        }
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[geometryColumnsDao count]];
        
        [geoPackage dropTable:GPKG_GC_TABLE_NAME];
        
        [GPKGTestUtils assertFalse:[geometryColumnsDao tableExists]];
    }
    
    if([tileMatrixSetDao tableExists]){
        GPKGTileMatrixDao *tileMatrixDao = [geoPackage getTileMatrixDao];
        
        [GPKGTestUtils assertTrue:[tileMatrixSetDao tableExists]];
        [GPKGTestUtils assertTrue:[tileMatrixDao tableExists]];
        
        [GPKGTestUtils assertEqualIntWithValue:(int)[geoPackage getTablesByType:GPKG_CDT_TILES].count + (int)[geoPackage getTablesByType:GPKG_CDT_GRIDDED_COVERAGE].count andValue2:[tileMatrixSetDao count]];
        for(NSString *tileTable in [geoPackage getTileTables]){
            [GPKGTestUtils assertTrue:[geoPackage isTable:tileTable]];
            [GPKGTestUtils assertNotNil:[contentsDao queryForIdObject:tileTable]];
            [geoPackage deleteTable:tileTable];
            [GPKGTestUtils assertFalse:[geoPackage isTable:tileTable]];
            [GPKGTestUtils assertNil:[contentsDao queryForIdObject:tileTable]];
        }
        [GPKGTestUtils assertEqualIntWithValue:(int)[geoPackage getTablesByType:GPKG_CDT_GRIDDED_COVERAGE].count andValue2:[tileMatrixSetDao count]];
        
        [geoPackage dropTable:GPKG_TM_TABLE_NAME];
        [geoPackage dropTable:GPKG_TMS_TABLE_NAME];
        
        [GPKGTestUtils assertFalse:[tileMatrixSetDao tableExists]];
        [GPKGTestUtils assertFalse:[tileMatrixDao tableExists]];
    }
    
    for(NSString *attributeTable in [geoPackage getAttributesTables]){
        [GPKGTestUtils assertTrue:[geoPackage isTable:attributeTable]];
        [GPKGTestUtils assertNotNil:[contentsDao queryForIdObject:attributeTable]];
        [geoPackage deleteTable:attributeTable];
        [GPKGTestUtils assertFalse:[geoPackage isTable:attributeTable]];
        [GPKGTestUtils assertNil:[contentsDao queryForIdObject:attributeTable]];
    }
    
}

+(void)testBounds: (GPKGGeoPackage *) geoPackage{
    
    SFPProjection *projection = [SFPProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_EPSG andIntCode:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    // Create a feature table with empty contents
    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_empty_contents"];
    [geometryColumns setColumnName:@"geom"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    GPKGSpatialReferenceSystem *srs = [[geoPackage getSpatialReferenceSystemDao] queryForOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andBoundingBox:nil andSrsId:srs.srsId];
    
    GPKGBoundingBox *geoPackageContentsBoundingBox = [geoPackage contentsBoundingBoxInProjection:projection];
    
    GPKGBoundingBox *expectedContentsBoundingBox = nil;
    
    GPKGContentsDao *contentsDao = [geoPackage getContentsDao];
    GPKGResultSet *contentsResults = [contentsDao queryForAll];
    @try {
        while([contentsResults moveToNext]){
            GPKGContents *contents = (GPKGContents *)[contentsDao getObject:contentsResults];
            
            GPKGBoundingBox *contentsBoundingBox = [contentsDao boundingBoxOfContents:contents inProjection:projection];
            if(contentsBoundingBox != nil){
                [GPKGTestUtils assertTrue:[geoPackageContentsBoundingBox contains:contentsBoundingBox]];
                
                if(expectedContentsBoundingBox == nil){
                    expectedContentsBoundingBox = contentsBoundingBox;
                }else{
                    expectedContentsBoundingBox = [expectedContentsBoundingBox union:contentsBoundingBox];
                }
                
                [GPKGTestUtils assertEqualWithValue:contentsBoundingBox andValue2:[geoPackage contentsBoundingBoxOfTable:contents.tableName inProjection:projection]];
                [GPKGTestUtils assertEqualWithValue:[contents getBoundingBox] andValue2:[geoPackage contentsBoundingBoxOfTable:contents.tableName]];
            }
        }
    } @finally {
        [contentsResults close];
    }
    
    [GPKGTestUtils assertEqualWithValue:expectedContentsBoundingBox andValue2:geoPackageContentsBoundingBox];
    
    GPKGBoundingBox *geoPackageBoundingBox = [geoPackage boundingBoxInProjection:projection];
    GPKGBoundingBox *geoPackageManualBoundingBox = [geoPackage boundingBoxInProjection:projection andManual:YES];

    GPKGBoundingBox *expectedBoundingBox = expectedContentsBoundingBox;
    GPKGBoundingBox *expectedManualBoundingBox = expectedContentsBoundingBox;

    contentsResults = [contentsDao queryForAll];
    @try {
        while([contentsResults moveToNext]){
            GPKGContents *contents = (GPKGContents *)[contentsDao getObject:contentsResults];
            
            enum GPKGContentsDataType dataType = [contents getContentsDataType];
            if((int)dataType != -1){
                
                switch (dataType) {
                    case GPKG_CDT_FEATURES:
                        {
                            GPKGFeatureIndexManager *manager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureTable:contents.tableName];
                            GPKGBoundingBox *featureBoundingBox = [manager boundingBoxInProjection:projection];
                            if(featureBoundingBox != nil){
                                if([manager isIndexed]){
                                    expectedBoundingBox = [expectedBoundingBox union:featureBoundingBox];
                                }
                                expectedManualBoundingBox = [expectedManualBoundingBox union:featureBoundingBox];
                            }
                            
                            GPKGBoundingBox *expectedFeatureProjectionBoundingBox = [contentsDao boundingBoxOfContents:contents inProjection:projection];
                            if(featureBoundingBox != nil && [manager isIndexed]){
                                if (expectedFeatureProjectionBoundingBox == nil) {
                                    expectedFeatureProjectionBoundingBox = featureBoundingBox;
                                } else {
                                    expectedFeatureProjectionBoundingBox = [expectedFeatureProjectionBoundingBox union:featureBoundingBox];
                                }
                            }
                            GPKGBoundingBox *featureProjectionBoundingBox = [geoPackage boundingBoxOfTable:contents.tableName inProjection:projection];
                            if (featureProjectionBoundingBox == nil) {
                                [GPKGTestUtils assertNil:expectedFeatureProjectionBoundingBox];
                            } else {
                                [GPKGTestUtils assertTrue:[expectedBoundingBox contains:featureProjectionBoundingBox]];
                                [GPKGTestUtils assertEqualWithValue:expectedFeatureProjectionBoundingBox andValue2:featureProjectionBoundingBox];
                            }
                            
                            GPKGBoundingBox *expectedFeatureManualProjectionBoundingBox = [contentsDao boundingBoxOfContents:contents inProjection:projection];
                            if (featureBoundingBox != nil) {
                                if (expectedFeatureManualProjectionBoundingBox == nil) {
                                    expectedFeatureManualProjectionBoundingBox = featureBoundingBox;
                                } else {
                                    expectedFeatureManualProjectionBoundingBox = [expectedFeatureManualProjectionBoundingBox union:featureBoundingBox];
                                }
                            }
                            GPKGBoundingBox *featureManualProjectionBoundingBox = [geoPackage boundingBoxOfTable:contents.tableName inProjection:projection andManual:YES];
                            if (featureManualProjectionBoundingBox == nil) {
                                [GPKGTestUtils assertNil:expectedFeatureManualProjectionBoundingBox];
                            } else {
                                [GPKGTestUtils assertTrue:[expectedManualBoundingBox contains:featureManualProjectionBoundingBox]];
                                [GPKGTestUtils assertEqualWithValue:expectedFeatureManualProjectionBoundingBox andValue2:featureManualProjectionBoundingBox];
                            }
                            
                            featureBoundingBox = [manager boundingBox];
                            
                            GPKGBoundingBox *expectedFeatureBoundingBox = [contents getBoundingBox];
                            if(featureBoundingBox != nil && [manager isIndexed]){
                                if (expectedFeatureBoundingBox == nil) {
                                    expectedFeatureBoundingBox = featureBoundingBox;
                                } else {
                                    expectedFeatureBoundingBox = [expectedFeatureBoundingBox union:featureBoundingBox];
                                }
                            }
                            GPKGBoundingBox *featureBox = [geoPackage boundingBoxOfTable:contents.tableName];
                            if(featureBox == nil){
                                [GPKGTestUtils assertNil:expectedFeatureBoundingBox];
                            }else{
                                [GPKGTestUtils assertEqualWithValue:expectedFeatureBoundingBox andValue2:featureBox];
                            }
                            
                            GPKGBoundingBox *expectedFeatureManualBoundingBox = [contents getBoundingBox];
                            if (featureBoundingBox != nil) {
                                if (expectedFeatureManualBoundingBox == nil) {
                                    expectedFeatureManualBoundingBox = featureBoundingBox;
                                } else {
                                    expectedFeatureManualBoundingBox = [expectedFeatureManualBoundingBox union:featureBoundingBox];
                                }
                            }
                            GPKGBoundingBox *featureManualBoundingBox = [geoPackage boundingBoxOfTable:contents.tableName andManual:YES];
                            if (featureManualBoundingBox == nil) {
                                [GPKGTestUtils assertNil:expectedFeatureManualBoundingBox];
                            } else {
                                [GPKGTestUtils assertEqualWithValue:expectedFeatureManualBoundingBox andValue2:featureManualBoundingBox];
                            }
                            
                            [manager close];
                        }
                        break;
                      
                    case GPKG_CDT_TILES:
                    case GPKG_CDT_GRIDDED_COVERAGE:
                        {
                            GPKGTileDao *tileDao = [geoPackage getTileDaoWithTableName:contents.tableName];
                            GPKGBoundingBox *tileBoundingBox = [tileDao boundingBoxInProjection:projection];
                            expectedBoundingBox = [expectedBoundingBox union:tileBoundingBox];
                            expectedManualBoundingBox = [expectedManualBoundingBox union: tileBoundingBox];
                            
                            GPKGBoundingBox *expectedProjectionTileBoundingBox = [tileBoundingBox union:[contentsDao boundingBoxOfContents:contents inProjection:projection]];
                            [GPKGTestUtils assertEqualWithValue:expectedProjectionTileBoundingBox andValue2:[geoPackage boundingBoxOfTable:contents.tableName inProjection:projection]];
                            [GPKGTestUtils assertEqualWithValue:expectedProjectionTileBoundingBox andValue2:[geoPackage boundingBoxOfTable:contents.tableName inProjection:projection andManual:YES]];
                            
                            GPKGBoundingBox *expectedTileBoundingBox = [[tileDao getBoundingBox] union:[contents getBoundingBox]];
                            [GPKGTestUtils assertEqualWithValue:expectedTileBoundingBox andValue2:[geoPackage boundingBoxOfTable:contents.tableName]];
                            [GPKGTestUtils assertEqualWithValue:expectedTileBoundingBox andValue2:[geoPackage boundingBoxOfTable:contents.tableName andManual:YES]];
                        }
                        break;
                        
                    default:
                        break;
                }
                
            }
        }
    } @finally {
        [contentsResults close];
    }
    
    [GPKGTestUtils assertEqualWithValue:expectedBoundingBox andValue2:geoPackageBoundingBox];
    [GPKGTestUtils assertEqualWithValue:expectedManualBoundingBox andValue2:geoPackageManualBoundingBox];
    
}

@end
