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
#import "PROJProjectionFactory.h"
#import "PROJProjectionConstants.h"
#import "GPKGFeatureIndexManager.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGCoverageData.h"

@implementation GPKGGeoPackageTestUtils

+(void)testCreateFeatureTableWithMetadata: (GPKGGeoPackage *) geoPackage{
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage spatialReferenceSystemDao] srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata"];
    [geometryColumns setColumnName:@"geom"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    [geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andBoundingBox:boundingBox]];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:nil];
}

+(void)testCreateFeatureTableWithMetadataIdColumn: (GPKGGeoPackage *) geoPackage{

    GPKGSpatialReferenceSystem *srs = [[geoPackage spatialReferenceSystemDao] srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata2"];
    [geometryColumns setColumnName:@"geom2"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    NSString * idColumn = @"my_id";
    [geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andIdColumn:idColumn andBoundingBox:boundingBox]];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:idColumn andAdditionalColumns:nil];
}

+(void)testCreateFeatureTableWithMetadataAdditionalColumns: (GPKGGeoPackage *) geoPackage{
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage spatialReferenceSystemDao] srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata3"];
    [geometryColumns setColumnName:@"geom3"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    NSArray * additionalColumns = [self featureColumns];
    
    [geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andAdditionalColumns:additionalColumns andBoundingBox:boundingBox]];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:additionalColumns];
}

+(void)testCreateFeatureTableWithMetadataIdColumnAdditionalColumns: (GPKGGeoPackage *) geoPackage{
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage spatialReferenceSystemDao] srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata4"];
    [geometryColumns setColumnName:@"geom4"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    NSArray * additionalColumns = [self featureColumns];
    
    NSString * idColumn = @"my_other_id";
    [geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andIdColumn:idColumn andAdditionalColumns:additionalColumns andBoundingBox:boundingBox]];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:idColumn andAdditionalColumns:additionalColumns];
}

+(NSArray *) featureColumns{
    NSMutableArray * columns = [NSMutableArray array];
    
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:7 andName:@"test_text_limited" andDataType:GPKG_DT_TEXT andMax: [NSNumber numberWithInt:5] andNotNull:NO andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:8 andName:@"test_blob_limited" andDataType:GPKG_DT_BLOB andMax: [NSNumber numberWithInt:7] andNotNull:NO andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:9 andName:@"test_date" andDataType:GPKG_DT_DATE andNotNull:NO andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:10 andName:@"test_datetime" andDataType:GPKG_DT_DATETIME andNotNull:NO andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:2 andName:@"test_text" andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:@""] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:3 andName:@"test_real" andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:4 andName:@"test_boolean" andDataType:GPKG_DT_BOOLEAN andNotNull:NO andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:5 andName:@"test_blob" andDataType:GPKG_DT_BLOB andNotNull:NO andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:6 andName:@"test_integer" andDataType:GPKG_DT_INTEGER andNotNull:NO andDefaultValue:nil] toArray:columns];
    
    return columns;
}

+(void) validateFeatureTableWithMetadata: (GPKGGeoPackage *) geoPackage andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumn andAdditionalColumns: (NSArray *) additionalColumns{
    
    GPKGGeometryColumnsDao * dao = [geoPackage geometryColumnsDao];
    
    GPKGGeometryColumns * queryGeometryColumns = (GPKGGeometryColumns *)[dao queryForMultiIdObject:[dao multiId:geometryColumns]];
    [GPKGTestUtils assertNotNil:queryGeometryColumns];
    
    [GPKGTestUtils assertEqualWithValue:geometryColumns.tableName andValue2:queryGeometryColumns.tableName];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.columnName andValue2:queryGeometryColumns.columnName];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.geometryTypeName andValue2:queryGeometryColumns.geometryTypeName];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.z andValue2:queryGeometryColumns.z];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.m andValue2:queryGeometryColumns.m];
    
    GPKGFeatureDao * featureDao = [geoPackage featureDaoWithTableName:geometryColumns.tableName];
    GPKGFeatureRow * featureRow = [featureDao newRow];
    
    [GPKGTestUtils assertEqualIntWithValue:(2 + (additionalColumns != nil ? (int)[additionalColumns count] : 0)) andValue2:[featureRow columnCount]];
    if(idColumn == nil){
        idColumn = @"id";
    }
    [GPKGTestUtils assertEqualWithValue:idColumn andValue2:[featureRow columnNameWithIndex:0]];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.columnName andValue2:[featureRow columnNameWithIndex:1]];
    
    if(additionalColumns != nil){
        [GPKGTestUtils assertEqualWithValue:@"test_text" andValue2:[featureRow columnNameWithIndex:2]];
        [GPKGTestUtils assertEqualWithValue:@"test_real" andValue2:[featureRow columnNameWithIndex:3]];
        [GPKGTestUtils assertEqualWithValue:@"test_boolean" andValue2:[featureRow columnNameWithIndex:4]];
        [GPKGTestUtils assertEqualWithValue:@"test_blob" andValue2:[featureRow columnNameWithIndex:5]];
        [GPKGTestUtils assertEqualWithValue:@"test_integer" andValue2:[featureRow columnNameWithIndex:6]];
        [GPKGTestUtils assertEqualWithValue:@"test_text_limited" andValue2:[featureRow columnNameWithIndex:7]];
        [GPKGTestUtils assertEqualWithValue:@"test_blob_limited" andValue2:[featureRow columnNameWithIndex:8]];
        [GPKGTestUtils assertEqualWithValue:@"test_date" andValue2:[featureRow columnNameWithIndex:9]];
        [GPKGTestUtils assertEqualWithValue:@"test_datetime" andValue2:[featureRow columnNameWithIndex:10]];
    }
}

+(void)testDeleteTables: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage geometryColumnsDao];
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage tileMatrixSetDao];
    GPKGContentsDao *contentsDao = [geoPackage contentsDao];
    
    [GPKGTestUtils assertTrue:[geometryColumnsDao tableExists] || [tileMatrixSetDao tableExists]];
    
    [geoPackage foreignKeysAsOn:NO];
    
    if([geometryColumnsDao tableExists]){
        
        [GPKGTestUtils assertEqualIntWithValue:(int)[geoPackage featureTables].count andValue2:[geometryColumnsDao count]];
        for(NSString *featureTable in [geoPackage featureTables]){
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
        GPKGTileMatrixDao *tileMatrixDao = [geoPackage tileMatrixDao];
        
        [GPKGTestUtils assertTrue:[tileMatrixSetDao tableExists]];
        [GPKGTestUtils assertTrue:[tileMatrixDao tableExists]];
        
        [GPKGTestUtils assertEqualIntWithValue:(int)[geoPackage tablesByType:GPKG_CDT_TILES].count + (int)[geoPackage tablesByTypeName:GPKG_CD_GRIDDED_COVERAGE].count andValue2:[tileMatrixSetDao count]];
        for(NSString *tileTable in [geoPackage tileTables]){
            [GPKGTestUtils assertTrue:[geoPackage isTable:tileTable]];
            [GPKGTestUtils assertNotNil:[contentsDao queryForIdObject:tileTable]];
            [geoPackage deleteTable:tileTable];
            [GPKGTestUtils assertFalse:[geoPackage isTable:tileTable]];
            [GPKGTestUtils assertNil:[contentsDao queryForIdObject:tileTable]];
        }
        [GPKGTestUtils assertEqualIntWithValue:(int)[geoPackage tablesByTypeName:GPKG_CD_GRIDDED_COVERAGE].count andValue2:[tileMatrixSetDao count]];
        
        [geoPackage dropTable:GPKG_TM_TABLE_NAME];
        [geoPackage dropTable:GPKG_TMS_TABLE_NAME];
        
        [GPKGTestUtils assertFalse:[tileMatrixSetDao tableExists]];
        [GPKGTestUtils assertFalse:[tileMatrixDao tableExists]];
    }
    
    for(NSString *attributeTable in [geoPackage attributesTables]){
        [GPKGTestUtils assertTrue:[geoPackage isTable:attributeTable]];
        [GPKGTestUtils assertNotNil:[contentsDao queryForIdObject:attributeTable]];
        [geoPackage deleteTable:attributeTable];
        [GPKGTestUtils assertFalse:[geoPackage isTable:attributeTable]];
        [GPKGTestUtils assertNil:[contentsDao queryForIdObject:attributeTable]];
    }
    
}

+(void)testBounds: (GPKGGeoPackage *) geoPackage{
    
    PROJProjection *projection = [PROJProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_EPSG andIntCode:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage spatialReferenceSystemDao] queryForOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    // Create a feature table with empty contents
    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_empty_contents"];
    [geometryColumns setColumnName:@"geom"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];
    [geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns]];
    
    GPKGBoundingBox *geoPackageContentsBoundingBox = [geoPackage contentsBoundingBoxInProjection:projection];
    
    GPKGBoundingBox *expectedContentsBoundingBox = nil;
    
    GPKGContentsDao *contentsDao = [geoPackage contentsDao];
    GPKGResultSet *contentsResults = [contentsDao queryForAll];
    @try {
        while([contentsResults moveToNext]){
            GPKGContents *contents = (GPKGContents *)[contentsDao object:contentsResults];
            
            GPKGBoundingBox *contentsBoundingBox = [contentsDao boundingBoxOfContents:contents inProjection:projection];
            if(contentsBoundingBox != nil){
                [GPKGTestUtils assertTrue:[geoPackageContentsBoundingBox contains:contentsBoundingBox]];
                
                if(expectedContentsBoundingBox == nil){
                    expectedContentsBoundingBox = contentsBoundingBox;
                }else{
                    expectedContentsBoundingBox = [expectedContentsBoundingBox union:contentsBoundingBox];
                }
                
                [GPKGTestUtils assertEqualWithValue:contentsBoundingBox andValue2:[geoPackage contentsBoundingBoxOfTable:contents.tableName inProjection:projection]];
                [GPKGTestUtils assertEqualWithValue:[contents boundingBox] andValue2:[geoPackage contentsBoundingBoxOfTable:contents.tableName]];
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
            GPKGContents *contents = (GPKGContents *)[contentsDao object:contentsResults];
            
            enum GPKGContentsDataType dataType = [contents contentsDataType];
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
                            
                            GPKGBoundingBox *expectedFeatureBoundingBox = [contents boundingBox];
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
                            
                            GPKGBoundingBox *expectedFeatureManualBoundingBox = [contents boundingBox];
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
                        {
                            GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:contents.tableName];
                            GPKGBoundingBox *tileBoundingBox = [tileDao boundingBoxInProjection:projection];
                            expectedBoundingBox = [expectedBoundingBox union:tileBoundingBox];
                            expectedManualBoundingBox = [expectedManualBoundingBox union: tileBoundingBox];
                            
                            GPKGBoundingBox *expectedProjectionTileBoundingBox = [tileBoundingBox union:[contentsDao boundingBoxOfContents:contents inProjection:projection]];
                            [GPKGTestUtils assertEqualWithValue:expectedProjectionTileBoundingBox andValue2:[geoPackage boundingBoxOfTable:contents.tableName inProjection:projection]];
                            [GPKGTestUtils assertEqualWithValue:expectedProjectionTileBoundingBox andValue2:[geoPackage boundingBoxOfTable:contents.tableName inProjection:projection andManual:YES]];
                            
                            GPKGBoundingBox *expectedTileBoundingBox = [[tileDao boundingBox] union:[contents boundingBox]];
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

+(void)testVacuum: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory manager];
    int size = [manager size:geoPackage.name];
    
    for(NSString *table in [geoPackage tables]){
        
        [geoPackage deleteTable:table];
        
        [geoPackage vacuum];
        
        int newSize = [manager size:geoPackage.name];
        [GPKGTestUtils assertTrue:size > newSize];
        size = newSize;
        
    }
    
}

+(void) testTableTypes: (GPKGGeoPackage *) geoPackage{
    
    NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> *types = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSString *> *tables = [NSMutableDictionary dictionary];
    
    for(int i = 0; i <= GPKG_CDT_ATTRIBUTES; i++){
        enum GPKGContentsDataType type = i;
        [types setObject:[NSMutableSet set] forKey:[GPKGContentsDataTypes name:type]];
    }
    
    GPKGContentsDao *dao = [geoPackage contentsDao];
    GPKGResultSet *contentsResults = [dao queryForAll];
    while([contentsResults moveToNext]){
        GPKGContents *contents = (GPKGContents *) [dao object:contentsResults];
        
        NSString *tableName = contents.tableName;
        NSString *dataTypeNameString = contents.dataType;
        
        NSMutableSet<NSString *> *typeTables = [types objectForKey:dataTypeNameString];
        if(typeTables == nil){
            typeTables = [NSMutableSet set];
            [types setObject:typeTables forKey:dataTypeNameString];
        }
        [typeTables addObject:tableName];
        
        [tables setObject:dataTypeNameString forKey:tableName];
    }
    [contentsResults close];
    
    NSString *previousType = nil;
    
    for(NSString *type in [types allKeys]){
        
        NSSet<NSString *> *typeTables = [types objectForKey:type];
        
        NSArray<NSString *> *tablesByType = [geoPackage tablesByTypeName:type];
        [GPKGTestUtils assertEqualIntWithValue:(int)typeTables.count andValue2:(int)tablesByType.count];
        for(NSString *tableByType in tablesByType){
            [GPKGTestUtils assertTrue:[typeTables containsObject:tableByType]];
        }

        enum GPKGContentsDataType coreDataType = [GPKGContentsDataTypes fromCoreName:type];
        if((int)coreDataType != -1){
            NSArray<NSString *> *coreTablesByType = [geoPackage tablesByType:coreDataType];
            [GPKGTestUtils assertEqualIntWithValue:(int)typeTables.count andValue2:(int)coreTablesByType.count];
            for(NSString *coreTableByType in coreTablesByType){
                [GPKGTestUtils assertTrue:[typeTables containsObject:coreTableByType]];
            }
        }

        if (previousType != nil) {

            NSSet<NSString *> *previousTypeTables = [types objectForKey:previousType];

            NSArray<NSString *> *tablesByMultiType = [geoPackage tablesByTypeNames:[NSArray arrayWithObjects:type, previousType, nil]];
            [GPKGTestUtils assertEqualIntWithValue:(int)typeTables.count + (int)previousTypeTables.count andValue2:(int)tablesByMultiType.count];
            for(NSString *tableByMultiType in tablesByMultiType){
                [GPKGTestUtils assertTrue:[typeTables containsObject:tableByMultiType] || [previousTypeTables containsObject:tableByMultiType]];
            }

            if ((int)coreDataType != -1) {
                enum GPKGContentsDataType previousCoreDataType = [GPKGContentsDataTypes fromCoreName:previousType];
                if ((int)previousCoreDataType != -1) {
                    NSArray<NSString *> *coreTablesByMultiType = [geoPackage tablesByTypes:[NSArray arrayWithObjects:[NSNumber numberWithInt:coreDataType], [NSNumber numberWithInt:previousCoreDataType], nil]];
                    [GPKGTestUtils assertEqualIntWithValue:(int)typeTables.count + (int)previousTypeTables.count andValue2:(int)coreTablesByMultiType.count];
                    for(NSString *coreTableByMultiType in coreTablesByMultiType){
                        [GPKGTestUtils assertTrue:[typeTables containsObject:coreTableByMultiType] || [previousTypeTables containsObject:coreTableByMultiType]];
                    }

                }
            }

        }

        previousType = type;
    }
    
    previousType = nil;

    for(NSString *table in [tables allKeys]){
        NSString *type = [tables objectForKey:table];

        [GPKGTestUtils assertTrue:[geoPackage isTableOrView:table]];
        [GPKGTestUtils assertTrue:[geoPackage isContentsTable:table]];
        [GPKGTestUtils assertTrue:[geoPackage isTable:table ofTypeName:type]];

        enum GPKGContentsDataType dataType = [GPKGContentsDataTypes fromName:type];
        if ((int)dataType != -1) {
            [GPKGTestUtils assertTrue:[GPKGContentsDataTypes isType:type]];
            [GPKGTestUtils assertTrue:[geoPackage isTable:table ofType:dataType]];
            BOOL attributes = dataType == GPKG_CDT_ATTRIBUTES;
            BOOL features = dataType == GPKG_CDT_FEATURES;
            BOOL tiles = dataType == GPKG_CDT_TILES;

            [GPKGTestUtils assertTrue:attributes || features || tiles];
            [GPKGTestUtils assertEqualBoolWithValue:attributes andValue2:[geoPackage isAttributeTable:table]];
            [GPKGTestUtils assertEqualBoolWithValue:features andValue2:[geoPackage isFeatureTable:table]];
            [GPKGTestUtils assertEqualBoolWithValue:tiles andValue2:[geoPackage isTileTable:table]];
        }

        if(previousType != nil && ![type isEqual:previousType]){
            [GPKGTestUtils assertTrue:[geoPackage isTable:table ofTypeNames:[NSArray arrayWithObjects:type, previousType, nil]]];

            if ((int)dataType != -1) {
                enum GPKGContentsDataType previousDataType = [GPKGContentsDataTypes fromName:previousType];
                if ((int)previousDataType != -1) {
                    BOOL sameCoreType = dataType == previousDataType;
                    [GPKGTestUtils assertEqualBoolWithValue:sameCoreType andValue2:[geoPackage isTable:table ofType:previousDataType]];
                    [GPKGTestUtils assertTrue:[geoPackage isTable:table ofTypes:[NSArray arrayWithObjects:[NSNumber numberWithInt:dataType], [NSNumber numberWithInt:previousDataType], nil]]];
                }
            }
        }

        previousType = type;
    }
    
}

@end
