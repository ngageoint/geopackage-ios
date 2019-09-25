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

@implementation GPKGAlterTableUtils

+(void) testColumns: (GPKGGeoPackage *) geoPackage{

    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet *results = [geometryColumnsDao queryForAll];
        
        while([results moveToNext]){
            GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao getObject:results];
            
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
            
            [dao dropColumnWithName:[NSString stringWithFormat:@"%@%d", newerColumnName, 1]];
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
    // TODO
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
