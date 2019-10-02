//
//  GPKGAlterTableUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGAlterTableUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGFeatureIndexManager.h"
#import "GPKGSqlUtils.h"
#import "GPKGSQLiteMaster.h"
#import "GPKGSQLiteMasterQuery.h"
#import "GPKGFeatureUtils.h"
#import "GPKGFeatureTileTableLinker.h"
#import "GPKGContentsIdExtension.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGFeatureTableStyles.h"

@implementation GPKGAlterTableUtils

+(void) testColumns: (GPKGGeoPackage *) geoPackage{

    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        
        NSArray *featureTables = [geoPackage getFeatureTables];
        
        for(NSString *featureTable in featureTables){
            GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao queryForTableName:featureTable];
            
            GPKGConnection *db = geoPackage.database;
            GPKGFeatureDao *dao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
            
            GPKGFeatureIndexManager *indexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:dao];
            int indexGeoPackageCount;
            if([indexManager isIndexedWithFeatureIndexType:GPKG_FIT_GEOPACKAGE]){
                [indexManager prioritizeQueryLocationWithType:GPKG_FIT_GEOPACKAGE];
                indexGeoPackageCount = [indexManager count];
            }else{
                indexGeoPackageCount = [indexManager indexWithFeatureIndexType:GPKG_FIT_GEOPACKAGE];
            }
            [GPKGTestUtils assertTrue:[indexManager isIndexedWithFeatureIndexType:GPKG_FIT_GEOPACKAGE]];
            
            int indexRTreeCount;
            if([indexManager isIndexedWithFeatureIndexType:GPKG_FIT_RTREE]){
                [indexManager prioritizeQueryLocationWithType:GPKG_FIT_RTREE];
                indexRTreeCount = [indexManager count];
            }else{
                indexRTreeCount = [indexManager indexWithFeatureIndexType:GPKG_FIT_RTREE];
            }
            [GPKGTestUtils assertTrue:[indexManager isIndexedWithFeatureIndexType:GPKG_FIT_RTREE]];
            
            GPKGFeatureTable *featureTable = [dao getFeatureTable];
            NSString *tableName = featureTable.tableName;
            
            for (GPKGFeatureColumn *column in [featureTable columns]) {
                [self indexColumnWithConnection:db andTable:tableName andColumn:column];
            }
            
            [self createViewWithConnection:db andTable:featureTable andPrefix:@"v_" andQuoteWrap:YES];
            [self createViewWithConnection:db andTable:featureTable andPrefix:@"v2_" andQuoteWrap:NO];
            
            int rowCount = [dao count];
            int tableCount = [GPKGSQLiteMaster countWithConnection:db andType:GPKG_SMT_TABLE andTable:tableName];
            int indexCount = [self indexCountWithConnection:db andTable:tableName];
            int triggerCount = [GPKGSQLiteMaster countWithConnection:db andType:GPKG_SMT_TRIGGER andTable:tableName];
            int viewCount = [GPKGSQLiteMaster countViewsWithConnection:db andTable:tableName];
            
            [GPKGTestUtils assertEqualIntWithValue:1 andValue2:tableCount];
            [GPKGTestUtils assertTrue:indexCount >= [featureTable columnCount] - 2];
            [GPKGTestUtils assertTrue:triggerCount >= 6];
            [GPKGTestUtils assertTrue:viewCount >= 2];
            
            GPKGFeatureTable *table = [dao getFeatureTable];
            int existingColumns = (int)[table columns].count;
            GPKGFeatureColumn *pk = (GPKGFeatureColumn *)[table getPkColumn];
            GPKGFeatureColumn *geometry = [table getGeometryColumn];
            
            int newColumns = 0;
            NSString *newColumnName = @"new_column";
            
            [dao addColumn:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:@""]];
            [dao addColumn:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_REAL]];
            [dao addColumn:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_BOOLEAN]];
            [dao addColumn:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_BLOB]];
            [dao addColumn:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_INTEGER]];
            [dao addColumn:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_TEXT andMax:[NSNumber numberWithUnsignedInteger:[[NSProcessInfo processInfo] globallyUniqueString].length]]];
            [dao addColumn:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_BLOB andMax:[NSNumber numberWithUnsignedInteger:[[[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding] length]]]];
            [dao addColumn:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_DATE]];
            [dao addColumn:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_DATETIME]];
                  
            [GPKGTestUtils assertEqualIntWithValue:existingColumns + newColumns andValue2:(int)[table columns].count];
            [GPKGTestUtils assertEqualIntWithValue:rowCount andValue2:[dao count]];
            [self testTableCountsWithConnection:db andTable:tableName andTableCount:tableCount andIndexCount:indexCount andTriggerCount:triggerCount andViewCount:viewCount];
            
            for (int index = existingColumns; index < [table columns].count; index++) {
                
                [self indexColumnWithConnection:db andTable:tableName andColumn:(GPKGFeatureColumn *)[table getColumnWithIndex:index]];
                
                NSString *name = [NSString stringWithFormat:@"%@%d", newColumnName, index - existingColumns + 1];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table getColumnNameWithIndex:index]];
                [GPKGTestUtils assertEqualIntWithValue:index andValue2:[table getColumnIndexWithColumnName:name]];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table getColumnWithIndex:index].name];
                [GPKGTestUtils assertEqualIntWithValue:index andValue2:[table getColumnWithIndex:index].index];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[[table columnNames] objectAtIndex:index]];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[[table columns] objectAtIndex:index].name];
                @try {
                    [[table getColumnWithIndex:index] setIndex:index - 1];
                    [GPKGTestUtils fail:@"Changed index on a created table column"];
                } @catch (NSException *exception) {
                }
                [[table getColumnWithIndex:index] setIndex:index];
            }
            
            [self testTableCountsWithConnection:db andTable:tableName andTableCount:tableCount andIndexCount:indexCount + newColumns andTriggerCount:triggerCount andViewCount:viewCount];
            
            [GPKGTestUtils assertEqualWithValue:geometryColumns.tableName andValue2:table.tableName];
            [GPKGTestUtils assertEqualWithValue:pk andValue2:[table getPkColumn]];
            [GPKGTestUtils assertEqualWithValue:geometry andValue2:[table getGeometryColumn]];
            
            [self testIndexWithManager:indexManager andGeoPackageCount:indexGeoPackageCount andRTreeCount:indexRTreeCount];
            
            //[GPKGFeatureUtils testUpdate:dao];
            
            NSString *newerColumnName = @"newer_column";
            for (int newColumn = 2; newColumn <= newColumns; newColumn++) {
                [dao renameColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, newColumn] toColumn:[NSString stringWithFormat:@"%@%d", newerColumnName, newColumn]];
            }
            
            [dao alterColumn:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newerColumnName, 3] andDataType:GPKG_DT_BOOLEAN andNotNull:YES andDefaultValue:[NSNumber numberWithInt:0]]];
            
            NSMutableArray<GPKGFeatureColumn *> *alterColumns = [[NSMutableArray alloc] init];
            [alterColumns addObject:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newerColumnName, 5] andDataType:GPKG_DT_FLOAT andNotNull:YES andDefaultValue:[NSNumber numberWithFloat:1.5]]];
            [alterColumns addObject:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newerColumnName, 8] andDataType:GPKG_DT_TEXT andNotNull:YES andDefaultValue:@"date_to_text"]];
            [alterColumns addObject:[GPKGFeatureColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newerColumnName, 9] andDataType:GPKG_DT_DATETIME andNotNull:YES andDefaultValue:@"(strftime('%Y-%m-%dT%H:%M:%fZ','now'))"]];
            [dao alterColumns:alterColumns];
            
            for (int index = existingColumns + 1; index < [table columns].count; index++) {
                NSString *name = [NSString stringWithFormat:@"%@%d", newerColumnName, index - existingColumns + 1];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table getColumnNameWithIndex:index]];
                [GPKGTestUtils assertEqualIntWithValue:index andValue2:[table getColumnIndexWithColumnName:name]];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table getColumnWithIndex:index].name];
                [GPKGTestUtils assertEqualIntWithValue:index andValue2:[table getColumnWithIndex:index].index];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[[table columnNames] objectAtIndex:index]];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[[table columns] objectAtIndex:index].name];
            }
            
            [GPKGTestUtils assertEqualIntWithValue:existingColumns + newColumns andValue2:(int)[table columns].count];
            [GPKGTestUtils assertEqualIntWithValue:rowCount andValue2:[dao count]];
            [self testTableCountsWithConnection:db andTable:tableName andTableCount:tableCount andIndexCount:indexCount + newColumns andTriggerCount:triggerCount andViewCount:viewCount];
            [GPKGTestUtils assertEqualWithValue:geometryColumns.tableName andValue2:table.tableName];
            [GPKGTestUtils assertEqualWithValue:pk andValue2:[table getPkColumn]];
            [GPKGTestUtils assertEqualWithValue:geometry andValue2:[table getGeometryColumn]];
            
            [self testIndexWithManager:indexManager andGeoPackageCount:indexGeoPackageCount andRTreeCount:indexRTreeCount];
            
            //[GPKGFeatureUtils testUpdate:dao];
            
            [dao dropColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, 1]];
            [self testTableCountsWithConnection:db andTable:tableName andTableCount:tableCount andIndexCount:indexCount + newColumns - 1 andTriggerCount:triggerCount andViewCount:viewCount];
            [dao dropColumnNames:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@%d", newerColumnName, 2], [NSString stringWithFormat:@"%@%d", newerColumnName, 3], [NSString stringWithFormat:@"%@%d", newerColumnName, 4], nil]];
            for (int newColumn = 5; newColumn <= newColumns; newColumn++) {
                [dao dropColumnWithName:[NSString stringWithFormat:@"%@%d", newerColumnName, newColumn]];
            }
            
            [GPKGTestUtils assertEqualIntWithValue:existingColumns andValue2:(int)[table columns].count];
            [GPKGTestUtils assertEqualIntWithValue:rowCount andValue2:[dao count]];
            [self testTableCountsWithConnection:db andTable:tableName andTableCount:tableCount andIndexCount:indexCount andTriggerCount:triggerCount andViewCount:viewCount];
            
            for (int index = 0; index < existingColumns; index++) {
                [GPKGTestUtils assertEqualIntWithValue:index andValue2:[table getColumnWithIndex:index].index];
            }
            
            [GPKGTestUtils assertEqualWithValue:geometryColumns.tableName andValue2:table.tableName];
            [GPKGTestUtils assertEqualWithValue:pk andValue2:[table getPkColumn]];
            [GPKGTestUtils assertEqualWithValue:geometry andValue2:[table getGeometryColumn]];
            
            [self testIndexWithManager:indexManager andGeoPackageCount:indexGeoPackageCount andRTreeCount:indexRTreeCount];
            
            //[GPKGFeatureUtils testUpdate:dao];
            
            [indexManager close];
        }
    }
}

/**
 * Index the column
 *
 * @param db        connection
 * @param tableName table name
 * @param column    feature column
 */
+(void) indexColumnWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName andColumn: (GPKGFeatureColumn *) column{
    if(!column.primaryKey && !column.isGeometry){
        NSMutableString *index = [NSMutableString stringWithString:@"CREATE INDEX IF NOT EXISTS "];
        [index appendString:[GPKGSqlUtils quoteWrapName:[NSString stringWithFormat:@"idx_%@_%@", tableName, column.name]]];
        [index appendString:@" ON "];
        [index appendString:[GPKGSqlUtils quoteWrapName:tableName]];
        [index appendString:@" ( "];
        NSString *columnName = column.name;
        if([columnName containsString:@" "]){
            columnName = [GPKGSqlUtils quoteWrapName:columnName];
        }
        [index appendString:columnName];
        [index appendString:@" )"];
        
        [db exec:index];
    }
}

/**
 * Create a table view
 *
 * @param db
 *            connection
 * @param featureTable
 *            feature column
 * @param namePrefix
 *            view name prefix
 * @param quoteWrap
 */
+(void) createViewWithConnection: (GPKGConnection *) db andTable: (GPKGFeatureTable *) featureTable andPrefix: (NSString *) namePrefix andQuoteWrap: (BOOL) quoteWrap{
    NSString *viewName = [NSString stringWithFormat:@"%@%@", namePrefix, featureTable.tableName];
    [self createViewWithConnection:db andTable:featureTable andName:viewName andQuoteWrap:quoteWrap];
}

/**
 * Create a table view
 *
 * @param db
 *            connection
 * @param featureTable
 *            feature column
 * @param viewName
 *            view name
 * @param quoteWrap
 */
+(void) createViewWithConnection: (GPKGConnection *) db andTable: (GPKGFeatureTable *) featureTable andName: (NSString *) viewName andQuoteWrap: (BOOL) quoteWrap{
    
    NSMutableString *view = [NSMutableString stringWithString:@"CREATE VIEW "];
    if(quoteWrap){
        viewName = [GPKGSqlUtils quoteWrapName:viewName];
    }
    [view appendString:viewName];
    [view appendString:@" AS SELECT "];
    for (int i = 0; i < [featureTable columnCount]; i++) {
        if (i > 0) {
            [view appendString:@", "];
        }
        [view appendString:[GPKGSqlUtils quoteWrapName:[featureTable getColumnNameWithIndex:i]]];
        [view appendString:@" AS "];
        NSString *columnName = [NSString stringWithFormat:@"column%d", i+1];
        if (quoteWrap) {
            columnName = [GPKGSqlUtils quoteWrapName:columnName];
        }
        [view appendString:columnName];
    }
    [view appendString:@" FROM "];
    NSString *tableName = featureTable.tableName;
    if(quoteWrap){
        tableName = [GPKGSqlUtils quoteWrapName:tableName];
    }
    [view appendString:tableName];
    
    [db exec:view];
}

/**
 * Get the expected index count
 *
 * @param db        connection
 * @param tableName table name
 * @return index count
 */
+(int) indexCountWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName{
    GPKGSQLiteMasterQuery *indexQuery = [GPKGSQLiteMasterQuery createAnd];
    [indexQuery addColumn:GPKG_SMC_TBL_NAME withValue:tableName];
    [indexQuery addIsNotNullColumn:GPKG_SMC_SQL];
    int count = [GPKGSQLiteMaster countWithConnection:db andType:GPKG_SMT_INDEX andQuery:indexQuery];
    return count;
}

/**
 * Test the table schema counts
 *
 * @param db           connection
 * @param tableName    table name
 * @param tableCount   table count
 * @param indexCount   index count
 * @param triggerCount trigger count
 * @param viewCount    view count
 */
+(void) testTableCountsWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName andTableCount: (int) tableCount andIndexCount: (int) indexCount andTriggerCount: (int) triggerCount andViewCount: (int) viewCount{
    [GPKGTestUtils assertEqualIntWithValue:tableCount andValue2:[GPKGSQLiteMaster countWithConnection:db andType:GPKG_SMT_TABLE andTable:tableName]];
    [GPKGTestUtils assertEqualIntWithValue:indexCount andValue2:[self indexCountWithConnection:db andTable:tableName]];
    [GPKGTestUtils assertEqualIntWithValue:triggerCount andValue2:[GPKGSQLiteMaster countWithConnection:db andType:GPKG_SMT_TRIGGER andTable:tableName]];
    [GPKGTestUtils assertEqualIntWithValue:viewCount andValue2:[GPKGSQLiteMaster countViewsWithConnection:db andTable:tableName]];
}

/**
 * Test the feature indexes
 *
 * @param indexManager    index manager
 * @param geoPackageCount GeoPackage index count
 * @param rTreeCount      RTree index count
 */
+(void) testIndexWithManager: (GPKGFeatureIndexManager *) indexManager andGeoPackageCount: (int) geoPackageCount andRTreeCount: (int) rTreeCount{

    [GPKGTestUtils assertTrue:[indexManager isIndexedWithFeatureIndexType:GPKG_FIT_GEOPACKAGE]];
    [indexManager prioritizeQueryLocationWithType:GPKG_FIT_GEOPACKAGE];
    [GPKGTestUtils assertEqualIntWithValue:geoPackageCount andValue2:[indexManager count]];
    
    [GPKGTestUtils assertTrue:[indexManager isIndexedWithFeatureIndexType:GPKG_FIT_RTREE]];
    [indexManager prioritizeQueryLocationWithType:GPKG_FIT_RTREE];
    [GPKGTestUtils assertEqualIntWithValue:rTreeCount andValue2:[indexManager count]];
    
}

+(void) testCopyFeatureTable: (GPKGGeoPackage *) geoPackage{

    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        
        NSArray *featureTables = [geoPackage getFeatureTables];
        
        int viewNameCount = 0;
        
        for(NSString *featureTable in featureTables){
            GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao queryForTableName:featureTable];
            
            GPKGConnection *db = geoPackage.database;
            GPKGFeatureDao *dao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
            GPKGFeatureTable *table = [dao getFeatureTable];
            NSString *tableName = table.tableName;
            NSString *newTableName = [NSString stringWithFormat:@"%@_copy", tableName];
            
            int existingColumns = [table columnCount];
            GPKGFeatureColumn *pk = (GPKGFeatureColumn *)[table getPkColumn];
            GPKGFeatureColumn *geometry = [table getGeometryColumn];
            
            GPKGFeatureIndexManager *indexManager= [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:dao];
            
            int indexGeoPackageCount = 0;
            if ([indexManager isIndexedWithFeatureIndexType:GPKG_FIT_GEOPACKAGE]) {
                [indexManager prioritizeQueryLocationWithType:GPKG_FIT_GEOPACKAGE];
                indexGeoPackageCount = [indexManager count];
            }
            
            int indexRTreeCount = 0;
            if ([indexManager isIndexedWithFeatureIndexType:GPKG_FIT_RTREE]) {
                [indexManager prioritizeQueryLocationWithType:GPKG_FIT_RTREE];
                indexRTreeCount = [indexManager count];
            }
            
            GPKGFeatureTileTableLinker *linker = [[GPKGFeatureTileTableLinker alloc] initWithGeoPackage:geoPackage];
            NSArray<NSString *> *tileTables = [linker getTileTablesForFeatureTable:tableName];
            
            GPKGContentsIdExtension *contentsIdExtension = [[GPKGContentsIdExtension alloc] initWithGeoPackage:geoPackage];
            GPKGContentsId *contentsId = [contentsIdExtension getForTableName:tableName];
            
            NSMutableArray<GPKGMetadataReference *> *metadataReference = [NSMutableArray array];
            GPKGMetadataReferenceDao *metadataReferenceDao = [geoPackage getMetadataReferenceDao];
            if([metadataReferenceDao tableExists]){
                GPKGResultSet *metadataReferenceResults = [metadataReferenceDao queryByTable:tableName];
                while([metadataReferenceResults moveToNext]){
                    [metadataReference addObject:(GPKGMetadataReference *)[metadataReferenceDao getObject:metadataReferenceResults]];
                }
                [metadataReferenceResults close];
            }
            
            NSMutableArray<GPKGDataColumns *> *dataColumns = [NSMutableArray array];
            GPKGDataColumnsDao *dataColumnsDao = [geoPackage getDataColumnsDao];
            if([dataColumnsDao tableExists]){
                GPKGResultSet *dataColumnsResults = [dataColumnsDao queryByTable:tableName];
                while([dataColumnsResults moveToNext]){
                    [dataColumns addObject:(GPKGDataColumns *)[dataColumnsDao getObject:dataColumnsResults]];
                }
                [dataColumnsResults close];
            }
            
            NSMutableArray<GPKGExtendedRelation *> *extendedRelations = [NSMutableArray array];
            GPKGRelatedTablesExtension *relatedTablesExtension = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
            if([relatedTablesExtension has]){
                GPKGResultSet *extendedRelationsResults = [[relatedTablesExtension getExtendedRelationsDao] relationsToBaseTable:tableName];
                while([extendedRelationsResults moveToNext]){
                    [extendedRelations addObject:(GPKGExtendedRelation *)[[relatedTablesExtension getExtendedRelationsDao] getObject:extendedRelationsResults]];
                }
                [extendedRelationsResults close];
            }
            
            GPKGFeatureTableStyles *featureTableStyles = [[GPKGFeatureTableStyles alloc] initWithGeoPackage:geoPackage andTable:table];
            BOOL featureStyle = [featureTableStyles has];
            NSArray<NSNumber *> *styleIds = nil;
            NSArray<NSNumber *> *iconIds = nil;
            NSArray<NSNumber *> *tableStyleIds = nil;
            NSArray<NSNumber *> *tableIconIds = nil;
            if(featureStyle){
                styleIds = [featureTableStyles allStyleIds];
                iconIds = [featureTableStyles allIconIds];
                tableStyleIds = [featureTableStyles allTableStyleIds];
                tableIconIds = [featureTableStyles allTableIconIds];
            }
            
            NSString *viewName = [NSString stringWithFormat:@"v_my_%d_view", ++viewNameCount];
            [self createViewWithConnection:db andTable:table andName:viewName andQuoteWrap:YES];
            [self createViewWithConnection:db andTable:table andName:[NSString stringWithFormat:@"%@_2", viewName] andQuoteWrap:NO];
            
            int rowCount = [dao count];
            int tableCount = [GPKGSQLiteMaster countWithConnection:geoPackage.database andType:GPKG_SMT_TABLE andTable:tableName];
            int indexCount = [self indexCountWithConnection:geoPackage.database andTable:tableName];
            int triggerCount = [GPKGSQLiteMaster countWithConnection:geoPackage.database andType:GPKG_SMT_TRIGGER andTable:tableName];
            int viewCount = [GPKGSQLiteMaster countViewsWithConnection:geoPackage.database andTable:tableName];
            
            [geoPackage copyTable:tableName toTable:newTableName];
            
            //[GPKGFeatureUtils testUpdate:dao];
            
            GPKGFeatureDao *copyDao = [geoPackage getFeatureDaoWithTableName:newTableName];
            GPKGGeometryColumns *copyGeometryColumns = copyDao.geometryColumns;
            
            //[GPKGFeatureUtils testUpdate:copyDao];
            
            GPKGFeatureTable *copyTable = [copyDao getFeatureTable];
            
            [GPKGTestUtils assertEqualIntWithValue:existingColumns andValue2:[table columnCount]];
            [GPKGTestUtils assertEqualIntWithValue:existingColumns andValue2:[copyTable columnCount]];
            [GPKGTestUtils assertEqualIntWithValue:rowCount andValue2:[dao count]];
            [GPKGTestUtils assertEqualIntWithValue:rowCount andValue2:[copyDao count]];
            [self testTableCountsWithConnection:db andTable:tableName andTableCount:tableCount andIndexCount:indexCount andTriggerCount:triggerCount andViewCount:viewCount];
            [self testTableCountsWithConnection:db andTable:newTableName andTableCount:tableCount andIndexCount:indexCount andTriggerCount:triggerCount andViewCount:viewCount];
            
            [GPKGTestUtils assertEqualWithValue:geometryColumns.tableName andValue2:table.tableName];
            [GPKGTestUtils assertEqualWithValue:newTableName andValue2:copyGeometryColumns.tableName];
            [GPKGTestUtils assertEqualWithValue:newTableName andValue2:copyTable.tableName];
            [GPKGTestUtils assertEqualWithValue:pk andValue2:[table getPkColumn]];
            [GPKGTestUtils assertEqualWithValue:pk.name andValue2:[copyTable getPkColumn].name];
            [GPKGTestUtils assertEqualIntWithValue:pk.index andValue2:[copyTable getPkColumn].index];
            [GPKGTestUtils assertEqualWithValue:geometry andValue2:[table getGeometryColumn]];
            [GPKGTestUtils assertEqualWithValue:geometry.name andValue2:[copyTable getGeometryColumn].name];
            [GPKGTestUtils assertEqualIntWithValue:geometry.index andValue2:[copyTable getGeometryColumn].index];
            
            GPKGFeatureIndexManager *copyIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:copyDao];
            
            if([indexManager isIndexedWithFeatureIndexType:GPKG_FIT_GEOPACKAGE]){
                [indexManager prioritizeQueryLocationWithType:GPKG_FIT_GEOPACKAGE];
                [GPKGTestUtils assertEqualIntWithValue:indexGeoPackageCount andValue2:[indexManager count]];
                [GPKGTestUtils assertTrue:[copyIndexManager isIndexedWithFeatureIndexType:GPKG_FIT_GEOPACKAGE]];
                [copyIndexManager prioritizeQueryLocationWithType:GPKG_FIT_GEOPACKAGE];
                [GPKGTestUtils assertEqualIntWithValue:indexGeoPackageCount andValue2:[copyIndexManager count]];
            }else{
                [GPKGTestUtils assertFalse:[copyIndexManager isIndexedWithFeatureIndexType:GPKG_FIT_GEOPACKAGE]];
            }
            
            if([indexManager isIndexedWithFeatureIndexType:GPKG_FIT_RTREE]){
                [indexManager prioritizeQueryLocationWithType:GPKG_FIT_RTREE];
                [GPKGTestUtils assertEqualIntWithValue:indexRTreeCount andValue2:[indexManager count]];
                [GPKGTestUtils assertTrue:[copyIndexManager isIndexedWithFeatureIndexType:GPKG_FIT_RTREE]];
                [copyIndexManager prioritizeQueryLocationWithType:GPKG_FIT_RTREE];
                [GPKGTestUtils assertEqualIntWithValue:indexRTreeCount andValue2:[copyIndexManager count]];
            }else{
                [GPKGTestUtils assertFalse:[copyIndexManager isIndexedWithFeatureIndexType:GPKG_FIT_RTREE]];
            }
            
            NSArray<NSString *> *copyTileTables = [linker getTileTablesForFeatureTable:newTableName];
            [GPKGTestUtils assertEqualIntWithValue:(int)tileTables.count andValue2:(int)copyTileTables.count];
            for(NSString *tileTable in tileTables){
                [GPKGTestUtils assertTrue:[copyTileTables containsObject:tileTable]];
            }
            
            GPKGContentsId *copyContentsId = [contentsIdExtension getForTableName:newTableName];
            if(contentsId != nil){
                [GPKGTestUtils assertNotNil:copyContentsId];
                [GPKGTestUtils assertEqualWithValue:newTableName andValue2:copyContentsId.tableName];
                [GPKGTestUtils assertTrue:[copyContentsId.id intValue] >= 0];
                [GPKGTestUtils assertTrue:[copyContentsId.id intValue] > [contentsId.id intValue]];
            }else{
                [GPKGTestUtils assertNil:copyContentsId];
            }
            
            if(metadataReference.count > 0){
                GPKGResultSet *copyMetadataReferenceResults = [metadataReferenceDao queryByTable:newTableName];
                [GPKGTestUtils assertEqualIntWithValue:(int)metadataReference.count andValue2:copyMetadataReferenceResults.count];
                int i = 0;
                while([copyMetadataReferenceResults moveToNext]){
                    GPKGMetadataReference *copyMetadataReference = (GPKGMetadataReference *)[metadataReferenceDao getObject:copyMetadataReferenceResults];
                    [GPKGTestUtils assertEqualWithValue:tableName andValue2:[metadataReference objectAtIndex:i++].tableName];
                    [GPKGTestUtils assertEqualWithValue:newTableName andValue2:copyMetadataReference.tableName];
                }
                [copyMetadataReferenceResults close];
            }
            
            if(dataColumns.count > 0){
                GPKGResultSet *copyDataColumnsResults = [dataColumnsDao queryByTable:newTableName];
                [GPKGTestUtils assertEqualIntWithValue:(int)dataColumns.count andValue2:copyDataColumnsResults.count];
                int i = 0;
                while([copyDataColumnsResults moveToNext]){
                    GPKGDataColumns *copyDataColumns = (GPKGDataColumns *)[dataColumnsDao getObject:copyDataColumnsResults];
                    [GPKGTestUtils assertEqualWithValue:tableName andValue2:[dataColumns objectAtIndex:i++].tableName];
                    [GPKGTestUtils assertEqualWithValue:newTableName andValue2:copyDataColumns.tableName];
                }
                [copyDataColumnsResults close];
            }
            
            if (extendedRelations.count > 0) {
                GPKGResultSet *copyExtendedRelationsResults = [[relatedTablesExtension getExtendedRelationsDao] relationsToBaseTable:newTableName];
                [GPKGTestUtils assertEqualIntWithValue:(int)extendedRelations.count andValue2:copyExtendedRelationsResults.count];
                NSMutableDictionary<NSString *, GPKGExtendedRelation *> *mappingTableToRelations = [NSMutableDictionary dictionary];
                while([copyExtendedRelationsResults moveToNext]){
                    GPKGExtendedRelation *copyExtendedRelation = (GPKGExtendedRelation *) [[relatedTablesExtension getExtendedRelationsDao] getObject:copyExtendedRelationsResults];
                    [mappingTableToRelations setObject:copyExtendedRelation forKey:copyExtendedRelation.mappingTableName];
                }
                [copyExtendedRelationsResults close];
                for (GPKGExtendedRelation *extendedRelation in extendedRelations) {
                    NSString *mappingTableName = extendedRelation.mappingTableName;
                    NSString *copyMappingTableName = [GPKGSqlUtils createName:mappingTableName andReplace:tableName withReplacement:newTableName withConnection:geoPackage.database];
                    GPKGExtendedRelation *copyExtendedRelation = [mappingTableToRelations objectForKey:copyMappingTableName];
                    [GPKGTestUtils assertNotNil:copyExtendedRelation];
                    [GPKGTestUtils assertTrue:[extendedRelation.id intValue] < [copyExtendedRelation.id intValue]];
                    [GPKGTestUtils assertEqualWithValue:tableName andValue2:extendedRelation.baseTableName];
                    [GPKGTestUtils assertEqualWithValue:newTableName andValue2:copyExtendedRelation.baseTableName];
                    [GPKGTestUtils assertEqualWithValue:extendedRelation.basePrimaryColumn andValue2:copyExtendedRelation.basePrimaryColumn];
                    [GPKGTestUtils assertEqualWithValue:extendedRelation.relatedTableName andValue2:copyExtendedRelation.relatedTableName];
                    [GPKGTestUtils assertEqualWithValue:extendedRelation.relatedPrimaryColumn andValue2:copyExtendedRelation.relatedPrimaryColumn];
                    [GPKGTestUtils assertEqualWithValue:extendedRelation.relationName andValue2:copyExtendedRelation.relationName];
                    [GPKGTestUtils assertTrue:[geoPackage isTable:mappingTableName]];
                    [GPKGTestUtils assertTrue:[geoPackage isTable:copyMappingTableName]];
                    int mappingTableCount = [geoPackage.database countWithTable:mappingTableName andWhere:nil andWhereArgs:nil];
                    int copyMappingTableCount = [geoPackage.database countWithTable:copyMappingTableName andWhere:nil andWhereArgs:nil];
                    [GPKGTestUtils assertEqualIntWithValue:mappingTableCount andValue2:copyMappingTableCount];
                }
            }
            
            GPKGFeatureTableStyles *copyFeatureTableStyles = [[GPKGFeatureTableStyles alloc] initWithGeoPackage:geoPackage andTable:copyTable];
            [GPKGTestUtils assertEqualBoolWithValue:featureStyle andValue2:[copyFeatureTableStyles has]];
            if (featureStyle) {
                [self compareIds:styleIds withIds:[copyFeatureTableStyles allStyleIds]];
                [self compareIds:iconIds withIds:[copyFeatureTableStyles allIconIds]];
                [self compareIds:tableStyleIds withIds:[copyFeatureTableStyles allTableStyleIds]];
                [self compareIds:tableIconIds withIds:[copyFeatureTableStyles allTableIconIds]];
                if([featureTableStyles hasStyleRelationship]){
                    GPKGStyleMappingDao *styleMappingDao = [featureTableStyles styleMappingDao];
                    GPKGStyleMappingDao *copyStyleMappingDao = [copyFeatureTableStyles styleMappingDao];
                    [GPKGTestUtils assertEqualIntWithValue:[styleMappingDao count] andValue2:[copyStyleMappingDao count]];
                }
                if([featureTableStyles hasIconRelationship]){
                    GPKGStyleMappingDao *iconMappingDao = [featureTableStyles iconMappingDao];
                    GPKGStyleMappingDao *copyIconMappingDao = [copyFeatureTableStyles iconMappingDao];
                    [GPKGTestUtils assertEqualIntWithValue:[iconMappingDao count] andValue2:[copyIconMappingDao count]];
                }
                if([featureTableStyles hasTableStyleRelationship]){
                    GPKGStyleMappingDao *tableStyleMappingDao = [featureTableStyles tableStyleMappingDao];
                    GPKGStyleMappingDao *copyTableStyleMappingDao = [copyFeatureTableStyles tableStyleMappingDao];
                    [GPKGTestUtils assertEqualIntWithValue:[tableStyleMappingDao count] andValue2:[copyTableStyleMappingDao count]];
                }
                if([featureTableStyles hasTableIconRelationship]){
                    GPKGStyleMappingDao *tableIconMappingDao = [featureTableStyles tableIconMappingDao];
                    GPKGStyleMappingDao *copyTableIconMappingDao = [copyFeatureTableStyles tableIconMappingDao];
                    [GPKGTestUtils assertEqualIntWithValue:[tableIconMappingDao count] andValue2:[copyTableIconMappingDao count]];
                }
            }
            
            [indexManager close];
            [copyIndexManager close];
            
            NSString *newTableName2 = [NSString stringWithFormat:@"%@_copy2", tableName];
            [geoPackage copyTableAsEmpty:tableName toTable:newTableName2];
            GPKGFeatureDao *copyDao2 = [geoPackage getFeatureDaoWithTableName:newTableName2];
            [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[copyDao2 count]];
            
        }
    }
}

/**
 * Compare two lists of ids
 *
 * @param ids  ids
 * @param ids2 ids 2
 */
+(void) compareIds: (NSArray<NSNumber *> *) ids withIds: (NSArray<NSNumber *> *) ids2{
    if (ids == nil) {
        [GPKGTestUtils assertNil:ids2];
    } else {
        [GPKGTestUtils assertNotNil:ids2];
        [GPKGTestUtils assertEqualIntWithValue:(int)ids.count andValue2:(int)ids2.count];
        for(NSNumber *id in ids){
            [GPKGTestUtils assertTrue:[ids2 containsObject:id]];
        }
    }
}

+(void) testCopyTileTable: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) testCopyAttributesTable: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) testCopyUserTable: (GPKGGeoPackage *) geoPackage{
    // TODO
}

@end
