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

@implementation GPKGAttributesUtils

+(void) testReadWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    NSArray * tables = [geoPackage getAttributesTables];
    
    if(tables.count > 0){
        
        for (NSString * tableName in tables) {
            
            // Test the get attributes DAO methods
            GPKGContentsDao * contentsDao = [geoPackage getContentsDao];
            GPKGContents * contents = (GPKGContents *)[contentsDao queryForIdObject:tableName];
            GPKGAttributesDao * dao = [geoPackage getAttributesDaoWithContents:contents];
            [GPKGTestUtils assertNotNil:dao];
            dao = [geoPackage getAttributesDaoWithTableName:tableName];
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
                
                GPKGAttributesRow * attributesRow = (GPKGAttributesRow *)[dao getRow:results];
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
            GPKGAttributesRow * attributesRow = (GPKGAttributesRow *)[dao getRow:results];
            
            [results close];
            
            // Query by id
            GPKGAttributesRow * queryAttributesRow = (GPKGAttributesRow *)[dao queryForIdObject:[attributesRow getId]];
            [GPKGTestUtils assertNotNil:queryAttributesRow];
            [GPKGTestUtils assertEqualWithValue:[attributesRow getId] andValue2:[queryAttributesRow getId]];
            
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
                
                NSObject * column1Value = [attributesRow getValueWithColumnName:column1.name];
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
                BOOL found = false;
                while([results moveToNext]){
                    queryAttributesRow = (GPKGAttributesRow *)[dao getRow:results];
                    [GPKGTestUtils assertEqualWithValue:column1Value andValue2:[queryAttributesRow getValueWithColumnName:column1.name]];
                    if(!found){
                        found = [[attributesRow getId] intValue] == [[queryAttributesRow getId] intValue];
                    }
                }
                [GPKGTestUtils assertTrue:found];
                [results close];
                
                // Query for field values
                GPKGColumnValues * fieldValues = [[GPKGColumnValues alloc] init];
                [fieldValues addColumn:column1.name withValue:column1AttributesValue];
                NSObject * column2Value = nil;
                
                if (column2 != nil) {
                    column2Value = [attributesRow getValueWithColumnName:column2.name];
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
                found = false;
                while ([results moveToNext]) {
                    queryAttributesRow = (GPKGAttributesRow *)[dao getRow:results];
                    [GPKGTestUtils assertEqualWithValue:column1Value andValue2:[queryAttributesRow getValueWithColumnName:column1.name]];
                    if (column2 != nil) {
                        [GPKGTestUtils assertEqualWithValue:column2Value andValue2:[queryAttributesRow getValueWithColumnName:column2.name]];
                    }
                    if (!found) {
                        found = [[attributesRow getId] intValue] == [[queryAttributesRow getId] intValue];
                    }
                }
                [GPKGTestUtils assertTrue:found];
                [results close];
            }
            
            GPKGMetadataReferenceDao * referenceDao = [geoPackage getMetadataReferenceDao];
            GPKGResultSet * references = [referenceDao queryForEqWithField:GPKG_MR_COLUMN_TABLE_NAME andValue:attributesTable.tableName];
            if (references != nil && references.count > 0) {
                GPKGMetadata * metadata = nil;
                while([references moveToNext]){
                    
                    GPKGMetadataReference * reference = (GPKGMetadataReference *) [referenceDao getObject:references];
                    
                    if(metadata == nil){
                        GPKGMetadataDao * metadataDao = [geoPackage getMetadataDao];
                        metadata = (GPKGMetadata *)[metadataDao queryForIdObject:reference.fileId];
                        [GPKGTestUtils assertEqualIntWithValue:GPKG_MST_ATTRIBUTE_TYPE andValue2:[metadata getMetadataScopeType]];
                    }
                    
                    [GPKGTestUtils assertTrue:[reference getReferenceScopeType] == GPKG_RST_ROW
                     || [reference getReferenceScopeType] == GPKG_RST_ROW_COL];
                    NSNumber * rowId = reference.rowIdValue;
                    [GPKGTestUtils assertNotNil:rowId];
                    
                    GPKGAttributesRow * queryRow = (GPKGAttributesRow *)[dao queryForIdObject:rowId];
                    [GPKGTestUtils assertNotNil:queryRow];
                    [GPKGTestUtils assertNotNil:queryRow.table];
                    [GPKGTestUtils assertEqualWithValue:attributesTable.tableName andValue2:queryRow.table.tableName];
                }
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
        GPKGAttributesColumn * column = [attributesRow.table.columns objectAtIndex:i];
        [GPKGTestUtils assertEqualIntWithValue:i andValue2:column.index];
        [GPKGTestUtils assertEqualWithValue:[columns objectAtIndex:i] andValue2:[attributesRow getColumnNameWithIndex:i]];
        [GPKGTestUtils assertEqualIntWithValue:i andValue2:[attributesRow getColumnIndexWithColumnName:[columns objectAtIndex:i]]];
        int rowType = [attributesRow getRowColumnTypeWithIndex:i];
        NSObject * value = [attributesRow getValueWithIndex:i];
        
        switch (rowType) {
                
            case SQLITE_INTEGER:
                [GPKGTestUtils validateIntegerValue:value andDataType:column.dataType];
                break;
                
            case SQLITE_FLOAT:
                [GPKGTestUtils validateFloatValue:value andDataType:column.dataType];
                break;
                
            case SQLITE_TEXT:
                [GPKGTestUtils assertTrue:[value isKindOfClass:[NSString class]]];
                break;
                
            case SQLITE_BLOB:
                [GPKGTestUtils assertTrue:[value isKindOfClass:[NSData class]]];
                break;
                
            case SQLITE_NULL:
                [GPKGTestUtils assertNil:value];
                break;
                
        }
    }
    
    [GPKGTestUtils assertTrue:[[attributesRow getId] intValue] >= 0];
    
}

+(void) testUpdateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    NSArray * tables = [geoPackage getAttributesTables];
    
    if (tables.count > 0) {
        
        for (NSString * tableName in tables) {
            
            GPKGAttributesDao * dao = [geoPackage getAttributesDaoWithTableName:tableName];
            [GPKGTestUtils assertNotNil:dao];
            
            // Query for all
            GPKGResultSet * results = [dao queryForAll];
            int count = results.count;
            if (count > 0) {
                
                // // Choose random attribute
                // int random = (int) (Math.random() * count);
                // cursor.moveToPosition(random);
                [results moveToFirst];
                [results moveToNext];
                
                NSString * updatedString = nil;
                NSString * updatedLimitedString = nil;
                NSNumber * updatedBoolean = nil;
                NSNumber * updatedByte = nil;
                NSNumber * updatedShort = nil;
                NSNumber * updatedInteger = nil;
                NSNumber * updatedLong = nil;
                NSDecimalNumber * updatedFloat = nil;
                NSDecimalNumber * updatedDouble = nil;
                NSData * updatedBytes = nil;
                NSData * updatedLimitedBytes = nil;
                
                GPKGAttributesRow * originalRow = [dao getAttributesRow:results];
                GPKGAttributesRow * attributesRow = [dao getAttributesRow:results];
                
                @try {
                    [attributesRow setValueWithIndex:[attributesRow getPkColumnIndex] andValue:[NSNumber numberWithInt:9]];
                    [GPKGTestUtils fail:@"Updated the primary key value"];
                } @catch (NSException *exception) {
                    // expected
                }
                
                for (GPKGAttributesColumn * attributesColumn in dao.table.columns) {
                    if (!attributesColumn.primaryKey) {
                        
                        switch([attributesRow getRowColumnTypeWithIndex:attributesColumn.index]){
                                
                            case SQLITE_TEXT:
                                {
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
   
                            case SQLITE_INTEGER:
                                {
                                    switch (attributesColumn.dataType) {
                                        case GPKG_DT_BOOLEAN:
                                            {
                                                if (updatedBoolean == nil) {
                                                    updatedBoolean = [NSNumber numberWithBool:![((NSNumber *)[attributesRow getValueWithIndex:attributesColumn.index]) boolValue]];
                                                }
                                                [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedBoolean];
                                            }
                                            break;
                                        case GPKG_DT_TINYINT:
                                            {
                                                if (updatedByte == nil) {
                                                    updatedByte = [NSNumber numberWithChar:((char)([GPKGTestUtils randomDouble] * (CHAR_MAX + 1))) * ([GPKGTestUtils randomDouble]  < .5 ? 1 : -1)];
                                                }
                                                [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedByte];
                                            }
                                            break;
                                        case GPKG_DT_SMALLINT:
                                            {
                                                if (updatedShort == nil) {
                                                    updatedShort = [NSNumber numberWithShort:((short)([GPKGTestUtils randomDouble] * (SHRT_MAX + 1))) * ([GPKGTestUtils randomDouble]  < .5 ? 1 : -1)];
                                                }
                                                [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedShort];
                                            }
                                            break;
                                        case GPKG_DT_MEDIUMINT:
                                            {
                                                if (updatedInteger == nil) {
                                                    updatedInteger = [NSNumber numberWithInt:((int)([GPKGTestUtils randomDouble] * (INT_MAX + 1))) * ([GPKGTestUtils randomDouble]  < .5 ? 1 : -1)];
                                                }
                                                [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedInteger];
                                            }
                                            break;
                                        case GPKG_DT_INT:
                                        case GPKG_DT_INTEGER:
                                            {
                                                if (updatedLong == nil) {
                                                    updatedLong = [NSNumber numberWithLongLong:((long long)([GPKGTestUtils randomDouble] * (LLONG_MAX + 1))) * ([GPKGTestUtils randomDouble]  < .5 ? 1 : -1)];
                                                }
                                                [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedLong];
                                            }
                                            break;
                                        default:
                                            [GPKGTestUtils fail:@"Unexpected integer type"];
                                    }
                                }
                                break;
                            case SQLITE_FLOAT:
                                {
                                    switch (attributesColumn.dataType) {
                                        case GPKG_DT_FLOAT:
                                            {
                                                if(updatedFloat == nil){
                                                    updatedFloat = [[NSDecimalNumber alloc] initWithFloat:[GPKGTestUtils randomDouble] * FLT_MAX];
                                                }
                                                [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedFloat];
                                            }
                                            break;
                                        case GPKG_DT_DOUBLE:
                                        case GPKG_DT_REAL:
                                            {
                                                if(updatedDouble == nil){
                                                    updatedDouble = [[NSDecimalNumber alloc] initWithDouble:[GPKGTestUtils randomDouble] * DBL_MAX];
                                                }
                                                [attributesRow setValueWithIndex:attributesColumn.index andValue:updatedDouble];
                                            }
                                            break;
                                        default:
                                            [GPKGTestUtils fail:@"Unexpected float type"];
                                    }
                                }
                                break;
                            case SQLITE_BLOB:
                                {
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
                
                NSNumber * id = [attributesRow getId];
                GPKGResultSet * readRowResults = [dao queryForId:id];
                [readRowResults moveToNext];
                GPKGAttributesRow * readRow = [dao getAttributesRow:readRowResults];
                [readRowResults close];
                [GPKGTestUtils assertNotNil:readRow];
                [GPKGTestUtils assertEqualWithValue:[originalRow getId] andValue2:[readRow getId]];
                
                for (NSString * readColumnName in [readRow getColumnNames ]) {
                    
                    GPKGAttributesColumn * readAttributesColumn = (GPKGAttributesColumn *)[readRow getColumnWithColumnName:readColumnName];
                    if (!readAttributesColumn.primaryKey) {
                        switch ([readRow getRowColumnTypeWithColumnName:readColumnName]) {
                            case SQLITE_TEXT:
                                {
                                    if (readAttributesColumn.max != nil) {
                                        [GPKGTestUtils assertEqualWithValue:updatedLimitedString andValue2:[readRow getValueWithIndex:readAttributesColumn.index]];
                                    } else {
                                        [GPKGTestUtils assertEqualWithValue:updatedString andValue2:[readRow getValueWithIndex:readAttributesColumn.index]];
                                    }
                                }
                                break;
                            case SQLITE_INTEGER:
                                {
                                    switch (readAttributesColumn.dataType) {
                                        case GPKG_DT_BOOLEAN:
                                            [GPKGTestUtils assertEqualWithValue:updatedBoolean andValue2:[readRow getValueWithIndex:readAttributesColumn.index]];
                                            break;
                                        case GPKG_DT_TINYINT:
                                            [GPKGTestUtils assertEqualWithValue:updatedByte andValue2:[readRow getValueWithIndex:readAttributesColumn.index]];
                                            break;
                                        case GPKG_DT_SMALLINT:
                                            [GPKGTestUtils assertEqualWithValue:updatedShort andValue2:[readRow getValueWithIndex:readAttributesColumn.index]];
                                            break;
                                        case GPKG_DT_MEDIUMINT:
                                            [GPKGTestUtils assertEqualWithValue:updatedInteger andValue2:[readRow getValueWithIndex:readAttributesColumn.index]];
                                            break;
                                        case GPKG_DT_INT:
                                        case GPKG_DT_INTEGER:
                                            [GPKGTestUtils assertEqualWithValue:updatedLong andValue2:[readRow getValueWithIndex:readAttributesColumn.index]];
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
                                            [GPKGTestUtils assertEqualDoubleWithValue:[updatedFloat floatValue] andValue2:[((NSDecimalNumber *)[readRow getValueWithIndex:readAttributesColumn.index]) floatValue] andPercentage:.0000000001];
                                            break;
                                        case GPKG_DT_DOUBLE:
                                        case GPKG_DT_REAL:
                                            [GPKGTestUtils assertEqualDoubleWithValue:[updatedDouble doubleValue] andValue2:[((NSDecimalNumber *)[readRow getValueWithIndex:readAttributesColumn.index]) doubleValue] andPercentage:.0000000001];
                                            break;
                                        default:
                                            [GPKGTestUtils fail:@"Unexpected float type"];
                                    }
                                }
                                break;
                            case SQLITE_BLOB:
                                {
                                    if (readAttributesColumn.max != nil) {
                                        [GPKGTestUtils assertEqualDataWithValue:updatedLimitedBytes andValue2:(NSData *)[readRow getValueWithIndex:readAttributesColumn.index]];
                                    } else {
                                        [GPKGTestUtils assertEqualDataWithValue:updatedBytes andValue2:(NSData *)[readRow getValueWithIndex:readAttributesColumn.index]];
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
    }
    
}

+(void) testCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    /*
    List<String> tables = geoPackage.getAttributesTables();
    
    if (!tables.isEmpty()) {
        
        for (String tableName : tables) {
            
            AttributesDao dao = geoPackage.getAttributesDao(tableName);
            TestCase.assertNotNull(dao);
            
            AttributesCursor cursor = dao.queryForAll();
            int count = cursor.getCount();
            if (count > 0) {
                
                // Choose random attribute
                int random = (int) (Math.random() * count);
                cursor.moveToPosition(random);
                
                AttributesRow attributesRow = cursor.getRow();
                cursor.close();
                
                // Create new row from existing
                long id = attributesRow.getId();
                attributesRow.resetId();
                long newRowId = dao.create(attributesRow);
                
                TestCase.assertEquals(newRowId, attributesRow.getId());
                
                // Verify original still exists and new was created
                attributesRow = dao.queryForIdRow(id);
                TestCase.assertNotNull(attributesRow);
                AttributesRow queryAttributesRow = dao
                .queryForIdRow(newRowId);
                TestCase.assertNotNull(queryAttributesRow);
                cursor = dao.queryForAll();
                TestCase.assertEquals(count + 1, cursor.getCount());
                cursor.close();
                
                // Create new row with copied values from another
                AttributesRow newRow = dao.newRow();
                for (AttributesColumn column : dao.getTable().getColumns()) {
                    
                    if (column.isPrimaryKey()) {
                        try {
                            newRow.setValue(column.getName(), 10);
                            TestCase.fail("Set primary key on new row");
                        } catch (GeoPackageException e) {
                            // Expected
                        }
                    } else {
                        newRow.setValue(column.getName(),
                                        attributesRow.getValue(column.getName()));
                    }
                }
                
                long newRowId2 = dao.create(newRow);
                
                TestCase.assertEquals(newRowId2, newRow.getId());
                
                // Verify new was created
                AttributesRow queryAttributesRow2 = dao
                .queryForIdRow(newRowId2);
                TestCase.assertNotNull(queryAttributesRow2);
                cursor = dao.queryForAll();
                TestCase.assertEquals(count + 2, cursor.getCount());
                cursor.close();
            }
            cursor.close();
        }
    }
    */
}

+(void) testDeleteWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    /*
    List<String> tables = geoPackage.getAttributesTables();
    
    if (!tables.isEmpty()) {
        
        for (String tableName : tables) {
            
            AttributesDao dao = geoPackage.getAttributesDao(tableName);
            TestCase.assertNotNull(dao);
            
            AttributesCursor cursor = dao.queryForAll();
            int count = cursor.getCount();
            if (count > 0) {
                
                // Choose random attribute
                int random = (int) (Math.random() * count);
                cursor.moveToPosition(random);
                
                AttributesRow attributesRow = cursor.getRow();
                cursor.close();
                
                // Delete row
                TestCase.assertEquals(1, dao.delete(attributesRow));
                
                // Verify deleted
                AttributesRow queryAttributesRow = dao
                .queryForIdRow(attributesRow.getId());
                TestCase.assertNull(queryAttributesRow);
                cursor = dao.queryForAll();
                TestCase.assertEquals(count - 1, cursor.getCount());
                cursor.close();
            }
            cursor.close();
        }
    }
     */
}

@end
