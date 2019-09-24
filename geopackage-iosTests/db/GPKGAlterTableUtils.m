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

@implementation GPKGAlterTableUtils

+(void) testColumns: (GPKGGeoPackage *) geoPackage{
    // TODO
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
