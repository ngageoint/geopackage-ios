//
//  GPKGAttributesUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGAttributesUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGAttributesColumn.h"
#import "GPKGDateTimeUtils.h"
#import "GPKGGeoPackageGeometryDataUtils.h"
#import "GPKGPropertiesExtension.h"
#import "GPKGMetadataExtension.h"
#import "GPKGUtils.h"

@implementation GPKGAttributesUtils

+(void) testReadWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    NSArray * tables = [geoPackage attributesTables];
    
    if(tables.count > 0){
        
        for (NSString * tableName in tables) {
            
            // Test the get attributes DAO methods
            GPKGContentsDao * contentsDao = [geoPackage contentsDao];
            GPKGContents * contents = (GPKGContents *)[contentsDao queryForIdObject:tableName];
            GPKGAttributesDao * dao = [geoPackage attributesDaoWithContents:contents];
            [GPKGTestUtils assertNotNil:dao];
            dao = [geoPackage attributesDaoWithTableName:tableName];
            [GPKGTestUtils assertNotNil:dao];
            
            [GPKGTestUtils assertNotNil:dao.database];
            [GPKGTestUtils assertEqualWithValue:tableName andValue2:dao.tableName];
            
            GPKGAttributesTable * attributesTable = (GPKGAttributesTable *) dao.table;
            NSArray * columns = attributesTable.columnNames;
            
            // Query for all
            GPKGResultSet * results = [dao queryForAll];
            int count = results.count;
            int manualCount = 0;
            while ([results moveToNext]) {
                
                GPKGAttributesRow *attributesRow = [dao row:results];
                [self validateAttributesRowWithColumns:columns andRow:attributesRow];
                
                manualCount++;
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:manualCount];
            [results close];
            
            // Manually query for all and compare
            results = [dao.database queryWithTable:dao.tableName andColumns:nil andWhere:nil andWhereArgs:nil andGroupBy:nil andHaving:nil andOrderBy:nil];

            count = results.count;
            manualCount = 0;
            while ([results moveToNext]) {
                manualCount++;
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:manualCount];
            
            [GPKGTestUtils assertTrue:count > 0];
            
            // Choose random attribute
            int random = (int) ([GPKGTestUtils randomDouble] * count);
            [results moveToFirst];
            [results moveToPosition:random];
            GPKGAttributesRow *attributesRow = [dao row:results];
            
            [results close];
            
            // Query by id
            GPKGAttributesRow * queryAttributesRow = (GPKGAttributesRow *)[dao queryForIdObject:[attributesRow id]];
            [GPKGTestUtils assertNotNil:queryAttributesRow];
            [GPKGTestUtils assertEqualWithValue:[attributesRow id] andValue2:[queryAttributesRow id]];
            
            // Find two non id columns
            GPKGAttributesColumn * column1 = nil;
            GPKGAttributesColumn * column2 = nil;
            for (GPKGAttributesColumn * column in attributesRow.table.columns){
                if (!column.primaryKey) {
                    if (column1 == nil) {
                        column1 = column;
                    } else {
                        column2 = column;
                        break;
                    }
                }
            }
            
            // Query for equal
            if (column1 != nil) {
                
                NSObject * column1Value = [attributesRow valueWithColumnName:column1.name];
                enum GPKGDataType column1ClassType = column1.dataType;
                BOOL column1Decimal = column1ClassType == GPKG_DT_DOUBLE || column1ClassType == GPKG_DT_FLOAT;
                GPKGColumnValue * column1AttributesValue = nil;
                if(column1Decimal){
                    column1AttributesValue = [[GPKGColumnValue alloc] initWithValue:column1Value andTolerance:[[NSDecimalNumber alloc] initWithDouble:.000001]];
                }else{
                    column1AttributesValue = [[GPKGColumnValue alloc] initWithValue:column1Value];
                }
                results = [dao queryForEqWithField:column1.name andColumnValue:column1AttributesValue];
                
                [GPKGTestUtils assertTrue:results.count > 0];
                BOOL found = NO;
                while([results moveToNext]){
                    queryAttributesRow = [dao row:results];
                    [GPKGTestUtils assertEqualWithValue:column1Value andValue2:[queryAttributesRow valueWithColumnName:column1.name]];
                    if(!found){
                        found = [attributesRow idValue] == [queryAttributesRow idValue];
                    }
                }
                [GPKGTestUtils assertTrue:found];
                [results close];
                
                // Query for field values
                GPKGColumnValues * fieldValues = [[GPKGColumnValues alloc] init];
                [fieldValues addColumn:column1.name withValue:column1AttributesValue];
                NSObject * column2Value = nil;
                
                if (column2 != nil) {
                    column2Value = [attributesRow valueWithColumnName:column2.name];
                    enum GPKGDataType column2ClassType = column2.dataType;
                    BOOL column2Decimal = column2ClassType == GPKG_DT_DOUBLE || column1ClassType == GPKG_DT_FLOAT;
                    GPKGColumnValue * column2AttributesValue = nil;
                    if(column2Decimal){
                        column2AttributesValue = [[GPKGColumnValue alloc] initWithValue:column2Value andTolerance:[[NSDecimalNumber alloc] initWithDouble:.000001]];
                    }else{
                        column2AttributesValue = [[GPKGColumnValue alloc] initWithValue:column2Value];
                    }
                    [fieldValues addColumn:column2.name withValue:column2AttributesValue];
                }
                results = [dao queryForColumnValueFieldValues:fieldValues];
                [GPKGTestUtils assertTrue:results.count > 0];
                found = NO;
                while ([results moveToNext]) {
                    queryAttributesRow = [dao row:results];
                    [GPKGTestUtils assertEqualWithValue:column1Value andValue2:[queryAttributesRow valueWithColumnName:column1.name]];
                    if (column2 != nil) {
                        [GPKGTestUtils assertEqualWithValue:column2Value andValue2:[queryAttributesRow valueWithColumnName:column2.name]];
                    }
                    if (!found) {
                        found = [attributesRow idValue] == [queryAttributesRow idValue];
                    }
                }
                [GPKGTestUtils assertTrue:found];
                [results close];
            }
            
            GPKGMetadataReferenceDao *referenceDao = [GPKGMetadataExtension metadataReferenceDaoWithGeoPackage:geoPackage];
            GPKGResultSet *references = [referenceDao queryForEqWithField:GPKG_MR_COLUMN_TABLE_NAME andValue:attributesTable.tableName];
            if (references != nil && references.count > 0) {
                GPKGMetadata *metadata = nil;
                while([references moveToNext]){
                    
                    GPKGMetadataReference *reference = (GPKGMetadataReference *) [referenceDao object:references];
                    
                    if(metadata == nil){
                        GPKGMetadataDao *metadataDao = [GPKGMetadataExtension metadataDaoWithGeoPackage:geoPackage];
                        metadata = (GPKGMetadata *)[metadataDao queryForIdObject:reference.fileId];
                        [GPKGTestUtils assertEqualIntWithValue:GPKG_MST_ATTRIBUTE_TYPE andValue2:[metadata metadataScopeType]];
                    }
                    
                    [GPKGTestUtils assertTrue:[reference referenceScopeType] == GPKG_RST_ROW
                     || [reference referenceScopeType] == GPKG_RST_ROW_COL];
                    NSNumber *rowId = reference.rowIdValue;
                    [GPKGTestUtils assertNotNil:rowId];
                    
                    GPKGAttributesRow *queryRow = (GPKGAttributesRow *)[dao queryForIdObject:rowId];
                    [GPKGTestUtils assertNotNil:queryRow];
                    [GPKGTestUtils assertNotNil:queryRow.table];
                    [GPKGTestUtils assertEqualWithValue:attributesTable.tableName andValue2:queryRow.table.tableName];
                }
            }
            
            NSString *previousColumn = nil;
            for (NSString *column in columns) {

                int expectedDistinctCount = [(NSNumber *)[dao querySingleResultWithSql:[NSString stringWithFormat:@"SELECT COUNT(DISTINCT %@) FROM %@", column, dao.tableName] andArgs:nil] intValue];
                int distinctCount = [dao countWithDistinct:YES andColumn:column];
                [GPKGTestUtils assertEqualIntWithValue:expectedDistinctCount andValue2:distinctCount];
                if([dao countWhere:[NSString stringWithFormat:@"%@ IS NULL", column]] > 0){
                    distinctCount++;
                }
                GPKGResultSet *expectedResults = [dao rawQuery:[NSString stringWithFormat:@"SELECT DISTINCT %@ FROM %@", column, dao.tableName]];
                int expectedDistinctCursorCount = expectedResults.count;
                int expectedDistinctManualCursorCount = 0;
                while([expectedResults moveToNext]){
                    expectedDistinctManualCursorCount++;
                }
                [expectedResults close];
                [GPKGTestUtils assertEqualIntWithValue:expectedDistinctManualCursorCount andValue2:expectedDistinctCursorCount];
                results = [dao queryWithDistinct:YES andColumns:[NSArray arrayWithObject:column]];
                [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[results columnCount]];
                [GPKGTestUtils assertEqualIntWithValue:expectedDistinctCursorCount andValue2:results.count];
                [GPKGTestUtils assertEqualIntWithValue:distinctCount andValue2:results.count];
                [results close];
                results = [dao queryWithColumns:[NSArray arrayWithObject:column]];
                [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[results columnCount]];
                [GPKGTestUtils assertEqualIntWithValue:count andValue2:results.count];
                NSMutableSet<NSObject *> *distinctValues = [NSMutableSet set];
                while([results moveToNext]){
                    NSObject *value = [results valueWithColumnName:column];
                    [GPKGUtils addObject:value toSet:distinctValues];
                }
                [results close];
                [GPKGTestUtils assertEqualIntWithValue:distinctCount andValue2:(int)distinctValues.count];

                if(previousColumn != nil){

                    results = [dao queryWithDistinct:YES andColumns:[NSArray arrayWithObjects:previousColumn, column, nil]];
                    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[results columnCount]];
                    distinctCount = results.count;
                    if(distinctCount < 0){
                        distinctCount = 0;
                        while([results moveToNext]){
                            distinctCount++;
                        }
                    }
                    [results close];
                    results = [dao queryWithColumns:[NSArray arrayWithObjects:previousColumn, column, nil]];
                    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[results columnCount]];
                    [GPKGTestUtils assertEqualIntWithValue:count andValue2:results.count];
                    NSMutableDictionary<NSObject *, NSMutableSet<NSObject *> *> *distinctPairs = [NSMutableDictionary dictionary];
                    while([results moveToNext]){
                        NSObject<NSCopying> *previousValue = (NSObject<NSCopying> *)[results valueWithColumnName:previousColumn];
                        NSObject *value = [results valueWithColumnName:column];
                        distinctValues = [GPKGUtils objectForKey:previousValue inDictionary:distinctPairs];
                        if(distinctValues == nil){
                            distinctValues = [NSMutableSet set];
                            [GPKGUtils setObject:distinctValues forKey:previousValue inDictionary:distinctPairs];
                        }
                        [GPKGUtils addObject:value toSet:distinctValues];
                    }
                    [results close];
                    int distinctPairsCount = 0;
                    for(NSSet<NSObject *> *values in [distinctPairs allValues]){
                        distinctPairsCount += values.count;
                    }
                    [GPKGTestUtils assertEqualIntWithValue:distinctCount andValue2:distinctPairsCount];

                }

                previousColumn = column;
            }
        }
    }
    
}

/**
 * Validate an attributes row
 *
 * @param columns
 * @param attributesRow
 */
+(void) validateAttributesRowWithColumns: (NSArray *) columns andRow: (GPKGAttributesRow *) attributesRow{
    
    [GPKGTestUtils assertEqualIntWithValue:(int)columns.count andValue2:[attributesRow columnCount]];
    
    for (int i = 0; i < [attributesRow columnCount]; i++) {
        GPKGAttributesColumn * column = (GPKGAttributesColumn *) [attributesRow.table.columns objectAtIndex:i];
        enum GPKGDataType dataType = column.dataType;
        [GPKGTestUtils assertEqualIntWithValue:i andValue2:column.index];
        [GPKGTestUtils assertEqualWithValue:[columns objectAtIndex:i] andValue2:[attributesRow columnNameWithIndex:i]];
        [GPKGTestUtils assertEqualIntWithValue:i andValue2:[attributesRow columnIndexWithColumnName:[columns objectAtIndex:i]]];
        int sqliteType = [attributesRow sqliteTypeWithIndex:i];
        NSObject * value = [attributesRow valueWithIndex:i];
        
        if(value != nil){
            switch (sqliteType) {
                    
                case SQLITE_INTEGER:
                    [GPKGTestUtils validateIntegerValue:value andDataType:column.dataType];
                    break;
                    
                case SQLITE_FLOAT:
                    [GPKGTestUtils validateFloatValue:value andDataType:column.dataType];
                    break;
                    
                case SQLITE_TEXT:
                    {
                        if(dataType == GPKG_DT_DATE || dataType == GPKG_DT_DATETIME){
                            [GPKGTestUtils assertTrue:[value isKindOfClass:[NSDate class]]];
                            NSDate *date = (NSDate *) value;
                            NSString *dateString = [GPKGDateTimeUtils convertToStringWithDate:date andType:dataType];
                            [GPKGTestUtils assertTrue:[date compare:[GPKGDateTimeUtils convertToDateWithString:dateString]] == NSOrderedSame];
                        }else{
                            [GPKGTestUtils assertTrue:[value isKindOfClass:[NSString class]]];
                        }
                    }
                    break;
                    
                case SQLITE_BLOB:
                    [GPKGTestUtils assertTrue:[value isKindOfClass:[NSData class]]];
                    break;

            }
        }
    }
    
    [GPKGTestUtils assertTrue:[attributesRow idValue] >= 0];
    
}

+(void) testUpdateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    NSArray * tables = [geoPackage attributesTables];
    
    if (tables.count > 0) {
        
        for (NSString * tableName in tables) {
            
            if([tableName isEqualToString:GPKG_EXTENSION_PROPERTIES_TABLE_NAME]){
                continue;
            }
            
            GPKGAttributesDao * dao = [geoPackage attributesDaoWithTableName:tableName];
            [self testUpdateWithDao:dao];
            
        }
    }
    
}

+(void) testUpdateAddColumnsWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    NSArray * tables = [geoPackage attributesTables];
    
    if (tables.count > 0) {
        
        for (NSString * tableName in tables) {
            
            if([tableName isEqualToString:GPKG_EXTENSION_PROPERTIES_TABLE_NAME]){
                continue;
            }
            
            GPKGAttributesDao * dao = [geoPackage attributesDaoWithTableName:tableName];

            int rowCount = [dao count];
            
            GPKGAttributesTable *table = [dao attributesTable];
            int existingColumns = [table columnCount];
            GPKGAttributesColumn *pk = (GPKGAttributesColumn *)[table pkColumn];
            
            int newColumns = 0;
            NSString *newColumnName = @"new_column";
            
            [dao addColumn:[GPKGAttributesColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:@""]];
            [dao addColumn:[GPKGAttributesColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_REAL]];
            [dao addColumn:[GPKGAttributesColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_BOOLEAN]];
            [dao addColumn:[GPKGAttributesColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_BLOB]];
            [dao addColumn:[GPKGAttributesColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_INTEGER]];
            [dao addColumn:[GPKGAttributesColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_TEXT andMax:[NSNumber numberWithUnsignedInteger:[[NSProcessInfo processInfo] globallyUniqueString].length]]];
            [dao addColumn:[GPKGAttributesColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_BLOB andMax:[NSNumber numberWithUnsignedInteger:[[[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding] length]]]];
            [dao addColumn:[GPKGAttributesColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_DATE]];
            [dao addColumn:[GPKGAttributesColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_DATETIME]];

            [GPKGTestUtils assertEqualIntWithValue:existingColumns + newColumns andValue2:[table columnCount]];
            [GPKGTestUtils assertEqualIntWithValue:rowCount andValue2:[dao count]];
            
            for (int index = existingColumns; index < [table columnCount]; index++) {
                NSString *name = [NSString stringWithFormat:@"%@%d", newColumnName, index - existingColumns + 1];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table columnNameWithIndex:index]];
                [GPKGTestUtils assertEqualIntWithValue:index andValue2:[table columnIndexWithColumnName:name]];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table columnWithIndex:index].name];
                [GPKGTestUtils assertEqualIntWithValue:index andValue2:[table columnWithIndex:index].index];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table.columnNames objectAtIndex:index]];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table.columns objectAtIndex:index].name];
                @try {
                    [[table columnWithIndex:index] setIndex:index - 1];
                    [GPKGTestUtils fail:@"Changed index on a created table column"];
                } @catch (NSException *exception) {
                }
                [[table columnWithIndex:index] setIndex:index];
            }
            
            [GPKGTestUtils assertEqualWithValue:tableName andValue2:table.tableName];
            [GPKGTestUtils assertEqualWithValue:pk andValue2:[table pkColumn]];
            
            [self testUpdateWithDao:dao];
            
            NSString *newerColumnName = @"newer_column";
            for (int newColumn = 1; newColumn <= newColumns; newColumn++) {
                [dao renameColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, newColumn] toColumn:[NSString stringWithFormat:@"%@%d", newerColumnName, newColumn]];
            }
            for (int index = existingColumns; index < [table columnCount]; index++) {
                NSString *name = [NSString stringWithFormat:@"%@%d", newerColumnName, index - existingColumns + 1];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table columnNameWithIndex:index]];
                [GPKGTestUtils assertEqualIntWithValue:index andValue2:[table columnIndexWithColumnName:name]];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table columnWithIndex:index].name];
                [GPKGTestUtils assertEqualIntWithValue:index andValue2:[table columnWithIndex:index].index];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table.columnNames objectAtIndex:index]];
                [GPKGTestUtils assertEqualWithValue:name andValue2:[table.columns objectAtIndex:index].name];
            }
            
            [GPKGTestUtils assertEqualIntWithValue:existingColumns + newColumns andValue2:[table columnCount]];
            [GPKGTestUtils assertEqualIntWithValue:rowCount andValue2:[dao count]];
            [GPKGTestUtils assertEqualWithValue:tableName andValue2:table.tableName];
            [GPKGTestUtils assertEqualWithValue:pk andValue2:[table pkColumn]];
            
            [self testUpdateWithDao:dao];
            
            for (int newColumn = 1; newColumn <= newColumns; newColumn++) {
                [dao dropColumnWithName:[NSString stringWithFormat:@"%@%d", newerColumnName, newColumn]];
            }
            
            [GPKGTestUtils assertEqualIntWithValue:existingColumns andValue2:[table columnCount]];
            [GPKGTestUtils assertEqualIntWithValue:rowCount andValue2:[dao count]];
            
            for (int index = 0; index < existingColumns; index++) {
                [GPKGTestUtils assertEqualIntWithValue:index andValue2:[table columnWithIndex:index].index];
            }
            
            [GPKGTestUtils assertEqualWithValue:tableName andValue2:table.tableName];
            [GPKGTestUtils assertEqualWithValue:pk andValue2:[table pkColumn]];
            
        }
    }
    
}

+(void) testUpdateWithDao: (GPKGAttributesDao *) dao{
    
    [GPKGTestUtils assertNotNil:dao];
    
    // Query for all
    GPKGResultSet * results = [dao queryForAll];
    int count = results.count;
    if (count > 0) {
        
        // // Choose random attribute
        // int random = (int) (Math.random() * count);
        // results.moveToPosition(random);
        [results moveToFirst];
        [results moveToNext];
        
        NSString * updatedString = nil;
        NSString * updatedLimitedString = nil;
        NSDate *updatedDate = nil;
        NSNumber * updatedBoolean = nil;
        NSNumber * updatedByte = nil;
        NSNumber * updatedShort = nil;
        NSNumber * updatedInteger = nil;
        NSNumber * updatedLong = nil;
        NSDecimalNumber * updatedFloat = nil;
        NSDecimalNumber * updatedDouble = nil;
        NSData * updatedBytes = nil;
        NSData * updatedLimitedBytes = nil;
        
        GPKGAttributesRow * originalRow = [dao row:results];
        GPKGAttributesRow * attributesRow = [dao row:results];
        
        @try {
            [attributesRow setValueWithIndex:[attributesRow pkIndex] andValue:[NSNumber numberWithInt:9]];
            [GPKGTestUtils fail:@"Updated the primary key value"];
        } @catch (NSException *exception) {
            // expected
        }
        
        for (GPKGAttributesColumn * attributesColumn in dao.table.columns) {
            if (!attributesColumn.primaryKey) {
                
                enum GPKGDataType dataType = attributesColumn.dataType;
                int sqliteColumnType  = [attributesRow sqliteTypeWithIndex:attributesColumn.index];
                
                switch(dataType){
                        
                    case GPKG_DT_TEXT:
                    {
                        if([self validateSQLiteColumnType:sqliteColumnType withExpected:SQLITE_TEXT]){
                            break;
                        }
                        if (updatedString == nil) {
                            updatedString = [[NSProcessInfo processInfo] globallyUniqueString];
                        }
                        if(attributesColumn.max != nil){
                            if(updatedLimitedString == nil){
                                if(updatedString.length > [attributesColumn.max intValue]){
                                    updatedLimitedString = [updatedString substringToIndex:[attributesColumn.max intValue]];
                                } else{
                                    updatedLimitedString = updatedString;
                                }
                            }
                            [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedLimitedString];
                        }else{
                            [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedString];
                        }
                    }
                        break;
                    case GPKG_DT_DATE:
                    case GPKG_DT_DATETIME:
                    {
                        if([self validateSQLiteColumnType:sqliteColumnType withExpected:SQLITE_TEXT]){
                            break;
                        }
                        if (updatedDate == nil) {
                            updatedDate = [NSDate date];
                            updatedDate = [GPKGDateTimeUtils convertToDateWithString:[GPKGDateTimeUtils convertToStringWithDate:updatedDate andType:dataType]];
                        }
                        if ([GPKGTestUtils randomDouble] < .5) {
                            [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedDate];
                        } else {
                            [attributesRow setValueWithIndex:attributesColumn.index andValue:[GPKGDateTimeUtils convertToStringWithDate:updatedDate andType:dataType]];
                        }
                    }
                        break;
                    case GPKG_DT_BOOLEAN:
                    {
                        if([self validateSQLiteColumnType:sqliteColumnType withExpected:SQLITE_INTEGER]){
                            break;
                        }
                        if (updatedBoolean == nil) {
                            updatedBoolean = [NSNumber numberWithBool:![((NSNumber *)[attributesRow valueWithIndex:attributesColumn.index]) boolValue]];
                        }
                        [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedBoolean];
                    }
                        break;
                    case GPKG_DT_TINYINT:
                    {
                        if([self validateSQLiteColumnType:sqliteColumnType withExpected:SQLITE_INTEGER]){
                            break;
                        }
                        if (updatedByte == nil) {
                            updatedByte = [NSNumber numberWithChar:((char)([GPKGTestUtils randomDouble] * (CHAR_MAX + 1))) * ([GPKGTestUtils randomDouble]  < .5 ? 1 : -1)];
                        }
                        [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedByte];
                    }
                        break;
                    case GPKG_DT_SMALLINT:
                    {
                        if([self validateSQLiteColumnType:sqliteColumnType withExpected:SQLITE_INTEGER]){
                            break;
                        }
                        if (updatedShort == nil) {
                            updatedShort = [NSNumber numberWithShort:((short)([GPKGTestUtils randomDouble] * (SHRT_MAX + 1))) * ([GPKGTestUtils randomDouble]  < .5 ? 1 : -1)];
                        }
                        [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedShort];
                    }
                        break;
                    case GPKG_DT_MEDIUMINT:
                    {
                        if([self validateSQLiteColumnType:sqliteColumnType withExpected:SQLITE_INTEGER]){
                            break;
                        }
                        if (updatedInteger == nil) {
                            updatedInteger = [NSNumber numberWithInt:((int)([GPKGTestUtils randomDouble] * (INT_MAX + 1))) * ([GPKGTestUtils randomDouble]  < .5 ? 1 : -1)];
                        }
                        [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedInteger];
                    }
                        break;
                    case GPKG_DT_INT:
                    case GPKG_DT_INTEGER:
                    {
                        if([self validateSQLiteColumnType:sqliteColumnType withExpected:SQLITE_INTEGER]){
                            break;
                        }
                        if (updatedLong == nil) {
                            updatedLong = [NSNumber numberWithLongLong:((long long)([GPKGTestUtils randomDouble] * (LLONG_MAX + 1))) * ([GPKGTestUtils randomDouble]  < .5 ? 1 : -1)];
                        }
                        [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedLong];
                    }
                        break;
                    case GPKG_DT_FLOAT:
                    {
                        if([self validateSQLiteColumnType:sqliteColumnType withExpected:SQLITE_FLOAT]){
                            break;
                        }
                        if(updatedFloat == nil){
                            updatedFloat = [[NSDecimalNumber alloc] initWithFloat:[GPKGTestUtils randomDouble] * FLT_MAX];
                        }
                        [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedFloat];
                    }
                        break;
                    case GPKG_DT_DOUBLE:
                    case GPKG_DT_REAL:
                    {
                        if([self validateSQLiteColumnType:sqliteColumnType withExpected:SQLITE_FLOAT]){
                            break;
                        }
                        if(updatedDouble == nil){
                            updatedDouble = [[NSDecimalNumber alloc] initWithDouble:[GPKGTestUtils randomDouble] * DBL_MAX];
                        }
                        [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedDouble];
                    }
                        break;
                    case GPKG_DT_BLOB:
                    {
                        if([self validateSQLiteColumnType:sqliteColumnType withExpected:SQLITE_BLOB]){
                            break;
                        }
                        if (updatedBytes == nil) {
                            updatedBytes = [[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding];
                        }
                        if (attributesColumn.max != nil) {
                            if (updatedLimitedBytes == nil) {
                                if (updatedBytes.length > [attributesColumn.max intValue]) {
                                    updatedLimitedBytes = [NSData dataWithBytes:updatedBytes.bytes length:[attributesColumn.max intValue]];
                                } else {
                                    updatedLimitedBytes = updatedBytes;
                                }
                            }
                            [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedLimitedBytes];
                        } else {
                            [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedBytes];
                        }
                    }
                        break;
                    default:
                        break;
                }
                
            }
        }
        
        [results close];
        
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[dao update:attributesRow]];
        
        NSNumber * id = [attributesRow id];
        GPKGResultSet * readRowResults = [dao queryForId:id];
        [readRowResults moveToNext];
        GPKGAttributesRow * readRow = [dao row:readRowResults];
        [readRowResults close];
        [GPKGTestUtils assertNotNil:readRow];
        [GPKGTestUtils assertEqualWithValue:[originalRow id] andValue2:[readRow id]];
        
        for (NSString * readColumnName in [readRow columnNames ]) {
            
            GPKGAttributesColumn * readAttributesColumn = (GPKGAttributesColumn *)[readRow columnWithColumnName:readColumnName];
            if (!readAttributesColumn.primaryKey) {
                
                enum GPKGDataType dataType = readAttributesColumn.dataType;
                
                switch ([readRow sqliteTypeWithColumnName:readColumnName]) {
                    case SQLITE_TEXT:
                    {
                        if(dataType == GPKG_DT_DATE || dataType == GPKG_DT_DATETIME){
                            
                            NSObject *value = [readRow valueWithIndex:readAttributesColumn.index];
                            NSDate *date = nil;
                            if([value isKindOfClass:[NSDate class]]){
                                date = (NSDate *) value;
                            } else {
                                date = [GPKGDateTimeUtils convertToDateWithString:(NSString *)value];
                            }
                            NSDate *compareDate = updatedDate;
                            if (dataType == GPKG_DT_DATE) {
                                compareDate = [GPKGDateTimeUtils convertToDateWithString:[GPKGDateTimeUtils convertToStringWithDate:compareDate andType:dataType]];
                            }
                            [GPKGTestUtils assertTrue:[compareDate compare:date] == NSOrderedSame];
                        }else{
                            if (readAttributesColumn.max != nil) {
                                [GPKGTestUtils assertEqualWithValue:updatedLimitedString andValue2:[readRow valueWithIndex:readAttributesColumn.index]];
                            } else {
                                [GPKGTestUtils assertEqualWithValue:updatedString andValue2:[readRow valueWithIndex:readAttributesColumn.index]];
                            }
                        }
                    }
                        break;
                    case SQLITE_INTEGER:
                    {
                        switch (readAttributesColumn.dataType) {
                            case GPKG_DT_BOOLEAN:
                                [GPKGTestUtils assertEqualWithValue:updatedBoolean andValue2:[readRow valueWithIndex:readAttributesColumn.index]];
                                break;
                            case GPKG_DT_TINYINT:
                                [GPKGTestUtils assertEqualWithValue:updatedByte andValue2:[readRow valueWithIndex:readAttributesColumn.index]];
                                break;
                            case GPKG_DT_SMALLINT:
                                [GPKGTestUtils assertEqualWithValue:updatedShort andValue2:[readRow valueWithIndex:readAttributesColumn.index]];
                                break;
                            case GPKG_DT_MEDIUMINT:
                                [GPKGTestUtils assertEqualWithValue:updatedInteger andValue2:[readRow valueWithIndex:readAttributesColumn.index]];
                                break;
                            case GPKG_DT_INT:
                            case GPKG_DT_INTEGER:
                                [GPKGTestUtils assertEqualWithValue:updatedLong andValue2:[readRow valueWithIndex:readAttributesColumn.index]];
                                break;
                            default:
                                [GPKGTestUtils fail:@"Unexpected integer type"];
                        }
                    }
                        break;
                    case SQLITE_FLOAT:
                    {
                        switch (readAttributesColumn.dataType) {
                            case GPKG_DT_FLOAT:
                                [GPKGTestUtils assertEqualDoubleWithValue:[updatedFloat floatValue] andValue2:[((NSDecimalNumber *)[readRow valueWithIndex:readAttributesColumn.index]) floatValue] andPercentage:.0000000001];
                                break;
                            case GPKG_DT_DOUBLE:
                            case GPKG_DT_REAL:
                                [GPKGTestUtils assertEqualDoubleWithValue:[updatedDouble doubleValue] andValue2:[((NSDecimalNumber *)[readRow valueWithIndex:readAttributesColumn.index]) doubleValue] andPercentage:.0000000001];
                                break;
                            default:
                                [GPKGTestUtils fail:@"Unexpected float type"];
                        }
                    }
                        break;
                    case SQLITE_BLOB:
                    {
                        if (readAttributesColumn.max != nil) {
                            [GPKGTestUtils assertEqualDataWithValue:updatedLimitedBytes andValue2:(NSData *)[readRow valueWithIndex:readAttributesColumn.index]];
                        } else {
                            [GPKGTestUtils assertEqualDataWithValue:updatedBytes andValue2:(NSData *)[readRow valueWithIndex:readAttributesColumn.index]];
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
            
        }
        
    }
    [results close];
}

/**
 * Validate the SQLite type. If a null value, randomly decide if the value
 * should be updated.
 *
 * @param sqliteColumnType      sqlite column type
 * @param expectedColumnType expected column type
 * @return true to skip setting value
 */
+(BOOL) validateSQLiteColumnType: (int) sqliteColumnType withExpected: (int) expectedColumnType{
    BOOL skip = NO;
    if (sqliteColumnType == SQLITE_NULL) {
        if ([GPKGTestUtils randomDouble] < .5) {
            skip = YES;
        }
    } else {
        [GPKGTestUtils assertEqualIntWithValue:expectedColumnType andValue2:sqliteColumnType];
    }
    return skip;
}

+(void) testCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    NSArray * tables = [geoPackage attributesTables];
    
    if (tables.count > 0) {
        
        for (NSString * tableName in tables) {
            
            if([tableName isEqualToString:GPKG_EXTENSION_PROPERTIES_TABLE_NAME]){
                continue;
            }
            
            GPKGAttributesDao * dao = [geoPackage attributesDaoWithTableName:tableName];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet * results = [dao queryForAll];
            int count = results.count;
            if (count > 0) {
                
                // Choose random attribute
                int random = (int) ([GPKGTestUtils randomDouble] * count);
                [results moveToPosition:random];
                
                GPKGAttributesRow * attributesRow = [dao row:results];
                [results close];
                
                // Create new row from existing
                NSNumber * id = [attributesRow id];
                [attributesRow resetId];
                int newRowId = (int)[dao create:attributesRow];
                
                [GPKGTestUtils assertEqualIntWithValue:newRowId andValue2:[attributesRow idValue]];
                
                // Verify original still exists and new was created
                GPKGResultSet * attributesRowResults = [dao queryForId:id];
                [attributesRowResults moveToNext];
                attributesRow = [dao row:attributesRowResults];
                [attributesRowResults close];
                [GPKGTestUtils assertNotNil:attributesRow];
                
                GPKGResultSet * queryAttributesRowResults = [dao queryForId:[NSNumber numberWithInt:newRowId]];
                [queryAttributesRowResults moveToNext];
                GPKGAttributesRow * queryAttributesRow = [dao row:queryAttributesRowResults];
                [queryAttributesRowResults close];
                [GPKGTestUtils assertNotNil:queryAttributesRow];
                
                results = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count + 1 andValue2:results.count];
                [results close];
                
                // Create new row with copied values from another
                GPKGAttributesRow * newRow = [dao newRow];
                for (GPKGAttributesColumn * column in dao.table.columns) {
                    
                    if (column.primaryKey) {
                        @try {
                            [newRow setValueWithColumnName:column.name andValue:[NSNumber numberWithInt:10]];
                            [GPKGTestUtils fail:@"Set primary key on new row"];
                        } @catch (NSException *exception) {
                            // Expected
                        }
                    } else {
                        [newRow setValueWithColumnName:column.name andValue:[attributesRow valueWithColumnName:column.name]];
                    }
                }
                
                int newRowId2 = (int)[dao create:newRow];
                
                [GPKGTestUtils assertEqualIntWithValue:newRowId2 andValue2:[newRow idValue]];
                
                // Verify new was created
                GPKGResultSet * queryAttributesRow2Results = [dao queryForId:[NSNumber numberWithInt:newRowId2]];
                [queryAttributesRow2Results moveToNext];
                GPKGAttributesRow * queryAttributesRow2 = [dao row:queryAttributesRow2Results];
                [queryAttributesRow2Results close];
                [GPKGTestUtils assertNotNil:queryAttributesRow2];
                
                results = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count + 2 andValue2:results.count];
                [results close];
                
                // Test copied row
                GPKGAttributesRow *copyRow = [queryAttributesRow2 mutableCopy];
                for (GPKGAttributesColumn *column in dao.table.columns) {
                    if (column.dataType == GPKG_DT_BLOB) {
                        NSData *blob1 = (NSData *) [queryAttributesRow2 valueWithColumnName:column.name];
                        NSData *blob2 = (NSData *) [copyRow valueWithColumnName:column.name];
                        if(blob1 == nil){
                            [GPKGTestUtils assertNil:blob2];
                        }else{
                            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:blob1 andActual:blob2];
                        }
                    } else {
                        [GPKGTestUtils assertEqualWithValue:[queryAttributesRow2 valueWithColumnName:column.name] andValue2:[copyRow valueWithColumnName:column.name]];
                    }
                }
                
                [copyRow resetId];
                
                NSNumber *newRowId3 = [NSNumber numberWithLongLong:[dao create:copyRow]];
                
                [GPKGTestUtils assertEqualIntWithValue:[newRowId3 intValue] andValue2:[copyRow idValue]];
                
                // Verify new was created
                GPKGAttributesRow *queryAttributesRow3 = (GPKGAttributesRow *)[dao queryForIdObject:newRowId3];
                [GPKGTestUtils assertNotNil:queryAttributesRow3];
                GPKGResultSet *results = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count + 3 andValue2:results.count];
                [results close];
                
                for(GPKGAttributesColumn *column in dao.table.columns){
                    if(column.primaryKey){
                        [GPKGTestUtils assertFalse:[[queryAttributesRow2 valueWithColumnName:column.name] isEqual:[queryAttributesRow3 valueWithColumnName:column.name]]];
                    } else if(column.dataType == GPKG_DT_BLOB){
                        NSData *blob1 = (NSData *) [queryAttributesRow2 valueWithColumnName:column.name];
                        NSData *blob2 = (NSData *) [queryAttributesRow3 valueWithColumnName:column.name];
                        if (blob1 == nil) {
                            [GPKGTestUtils assertNil:blob2];
                        } else {
                            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:blob1 andActual:blob2];
                        }
                    }else{
                        [GPKGTestUtils assertEqualWithValue:[queryAttributesRow2 valueWithColumnName:column.name] andValue2:[queryAttributesRow3 valueWithColumnName:column.name]];
                    }
                }
                
            }
            [results close];
        }
    }

}

+(void) testDeleteWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    NSArray * tables = [geoPackage attributesTables];
    
    if (tables.count > 0) {
        
        for (NSString * tableName in tables) {
            
            GPKGAttributesDao * dao = [geoPackage attributesDaoWithTableName:tableName];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet * results = [dao queryForAll];
            int count = results.count;
            if (count > 0) {
                
                // Choose random attribute
                int random = (int) ([GPKGTestUtils randomDouble] * count);
                [results moveToPosition:random];
                
                GPKGAttributesRow * attributesRow = [dao row:results];
                [results close];
                
                // Delete row
                [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[dao delete:attributesRow]];
                
                // Verify deleted
                GPKGAttributesRow * queryAttributesRow = (GPKGAttributesRow *) [dao queryForIdObject:[attributesRow id]];
                [GPKGTestUtils assertNil:queryAttributesRow];
                results = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count - 1 andValue2:results.count];
                [results close];
            }
            [results close];
        }
    }
    
}

@end
