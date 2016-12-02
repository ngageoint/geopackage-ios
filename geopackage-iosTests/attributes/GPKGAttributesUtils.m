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
                GPKGColumnValue * column2AttributesValue = nil;
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
    /*
    TestCase.assertEquals(columns.length, attributesRow.columnCount());
    
    for (int i = 0; i < attributesRow.columnCount(); i++) {
        AttributesColumn column = attributesRow.getTable().getColumns()
        .get(i);
        TestCase.assertEquals(i, column.getIndex());
        TestCase.assertEquals(columns[i], attributesRow.getColumnName(i));
        TestCase.assertEquals(i, attributesRow.getColumnIndex(columns[i]));
        int rowType = attributesRow.getRowColumnType(i);
        Object value = attributesRow.getValue(i);
        
        switch (rowType) {
                
            case UserCoreResultUtils.FIELD_TYPE_INTEGER:
                TestUtils.validateIntegerValue(value, column.getDataType());
                break;
                
            case UserCoreResultUtils.FIELD_TYPE_FLOAT:
                TestUtils.validateFloatValue(value, column.getDataType());
                break;
                
            case UserCoreResultUtils.FIELD_TYPE_STRING:
                TestCase.assertTrue(value instanceof String);
                break;
                
            case UserCoreResultUtils.FIELD_TYPE_BLOB:
                TestCase.assertTrue(value instanceof byte[]);
                break;
                
            case UserCoreResultUtils.FIELD_TYPE_NULL:
                TestCase.assertNull(value);
                break;
                
        }
    }
    
    TestCase.assertTrue(attributesRow.getId() >= 0);
     */
}

+(void) testUpdateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    /*
    List<String> tables = geoPackage.getAttributesTables();
    
    if (!tables.isEmpty()) {
        
        for (String tableName : tables) {
            
            AttributesDao dao = geoPackage.getAttributesDao(tableName);
            TestCase.assertNotNull(dao);
            
            // Query for all
            AttributesCursor cursor = dao.queryForAll();
            int count = cursor.getCount();
            if (count > 0) {
                
                // // Choose random attribute
                // int random = (int) (Math.random() * count);
                // cursor.moveToPosition(random);
                cursor.moveToFirst();
                
                String updatedString = null;
                String updatedLimitedString = null;
                Boolean updatedBoolean = null;
                Byte updatedByte = null;
                Short updatedShort = null;
                Integer updatedInteger = null;
                Long updatedLong = null;
                Float updatedFloat = null;
                Double updatedDouble = null;
                byte[] updatedBytes = null;
                byte[] updatedLimitedBytes = null;
                
                AttributesRow originalRow = cursor.getRow();
                AttributesRow attributesRow = cursor.getRow();
                
                try {
                    attributesRow.setValue(
                                           attributesRow.getPkColumnIndex(), 9);
                    TestCase.fail("Updated the primary key value");
                } catch (GeoPackageException e) {
                    // expected
                }
                
                for (AttributesColumn attributesColumn : dao.getTable()
                     .getColumns()) {
                    if (!attributesColumn.isPrimaryKey()) {
                        
                        switch (attributesRow
                                .getRowColumnType(attributesColumn
                                                  .getIndex())) {
                                        
                                    case UserCoreResultUtils.FIELD_TYPE_STRING:
                                        if (updatedString == null) {
                                            updatedString = UUID.randomUUID()
                                            .toString();
                                        }
                                        if (attributesColumn.getMax() != null) {
                                            if (updatedLimitedString != null) {
                                                if (updatedString.length() > attributesColumn
                                                    .getMax()) {
                                                    updatedLimitedString = updatedString
                                                    .substring(0,
                                                               attributesColumn
                                                               .getMax()
                                                               .intValue());
                                                } else {
                                                    updatedLimitedString = updatedString;
                                                }
                                            }
                                            attributesRow.setValue(
                                                                   attributesColumn.getIndex(),
                                                                   updatedLimitedString);
                                        } else {
                                            attributesRow.setValue(
                                                                   attributesColumn.getIndex(),
                                                                   updatedString);
                                        }
                                        break;
                                    case UserCoreResultUtils.FIELD_TYPE_INTEGER:
                                        switch (attributesColumn.getDataType()) {
                                            case BOOLEAN:
                                                if (updatedBoolean == null) {
                                                    updatedBoolean = !((Boolean) attributesRow
                                                                       .getValue(attributesColumn
                                                                                 .getIndex()));
                                                }
                                                attributesRow.setValue(
                                                                       attributesColumn.getIndex(),
                                                                       updatedBoolean);
                                                break;
                                            case TINYINT:
                                                if (updatedByte == null) {
                                                    updatedByte = (byte) (((int) (Math
                                                                                  .random() * (Byte.MAX_VALUE + 1))) * (Math
                                                                                                                        .random() < .5 ? 1 : -1));
                                                }
                                                attributesRow.setValue(
                                                                       attributesColumn.getIndex(),
                                                                       updatedByte);
                                                break;
                                            case SMALLINT:
                                                if (updatedShort == null) {
                                                    updatedShort = (short) (((int) (Math
                                                                                    .random() * (Short.MAX_VALUE + 1))) * (Math
                                                                                                                           .random() < .5 ? 1 : -1));
                                                }
                                                attributesRow.setValue(
                                                                       attributesColumn.getIndex(),
                                                                       updatedShort);
                                                break;
                                            case MEDIUMINT:
                                                if (updatedInteger == null) {
                                                    updatedInteger = (int) (((int) (Math
                                                                                    .random() * (Integer.MAX_VALUE + 1))) * (Math
                                                                                                                             .random() < .5 ? 1 : -1));
                                                }
                                                attributesRow.setValue(
                                                                       attributesColumn.getIndex(),
                                                                       updatedInteger);
                                                break;
                                            case INT:
                                            case INTEGER:
                                                if (updatedLong == null) {
                                                    updatedLong = (long) (((int) (Math
                                                                                  .random() * (Long.MAX_VALUE + 1))) * (Math
                                                                                                                        .random() < .5 ? 1 : -1));
                                                }
                                                attributesRow.setValue(
                                                                       attributesColumn.getIndex(),
                                                                       updatedLong);
                                                break;
                                            default:
                                                TestCase.fail("Unexpected integer type: "
                                                              + attributesColumn.getDataType());
                                        }
                                        break;
                                    case UserCoreResultUtils.FIELD_TYPE_FLOAT:
                                        switch (attributesColumn.getDataType()) {
                                            case FLOAT:
                                                if (updatedFloat == null) {
                                                    updatedFloat = (float) Math.random()
                                                    * Float.MAX_VALUE;
                                                }
                                                attributesRow.setValue(
                                                                       attributesColumn.getIndex(),
                                                                       updatedFloat);
                                                break;
                                            case DOUBLE:
                                            case REAL:
                                                if (updatedDouble == null) {
                                                    updatedDouble = Math.random()
                                                    * Double.MAX_VALUE;
                                                }
                                                attributesRow.setValue(
                                                                       attributesColumn.getIndex(),
                                                                       updatedDouble);
                                                break;
                                            default:
                                                TestCase.fail("Unexpected float type: "
                                                              + attributesColumn.getDataType());
                                        }
                                        break;
                                    case UserCoreResultUtils.FIELD_TYPE_BLOB:
                                        if (updatedBytes == null) {
                                            updatedBytes = UUID.randomUUID().toString()
                                            .getBytes();
                                        }
                                        if (attributesColumn.getMax() != null) {
                                            if (updatedLimitedBytes != null) {
                                                if (updatedBytes.length > attributesColumn
                                                    .getMax()) {
                                                    updatedLimitedBytes = new byte[attributesColumn
                                                                                   .getMax().intValue()];
                                                    ByteBuffer.wrap(
                                                                    updatedBytes,
                                                                    0,
                                                                    attributesColumn.getMax()
                                                                    .intValue()).get(
                                                                                     updatedLimitedBytes);
                                                } else {
                                                    updatedLimitedBytes = updatedBytes;
                                                }
                                            }
                                            attributesRow.setValue(
                                                                   attributesColumn.getIndex(),
                                                                   updatedLimitedBytes);
                                        } else {
                                            attributesRow.setValue(
                                                                   attributesColumn.getIndex(),
                                                                   updatedBytes);
                                        }
                                        break;
                                    default:
                                }
                        
                    }
                }
                
                cursor.close();
                
                TestCase.assertEquals(1, dao.update(attributesRow));
                
                long id = attributesRow.getId();
                AttributesRow readRow = dao.queryForIdRow(id);
                TestCase.assertNotNull(readRow);
                TestCase.assertEquals(originalRow.getId(), readRow.getId());
                
                for (String readColumnName : readRow.getColumnNames()) {
                    
                    AttributesColumn readAttributesColumn = readRow
                    .getColumn(readColumnName);
                    if (!readAttributesColumn.isPrimaryKey()) {
                        switch (readRow.getRowColumnType(readColumnName)) {
                            case UserCoreResultUtils.FIELD_TYPE_STRING:
                                if (readAttributesColumn.getMax() != null) {
                                    TestCase.assertEquals(
                                                          updatedLimitedString,
                                                          readRow.getValue(readAttributesColumn
                                                                           .getIndex()));
                                } else {
                                    TestCase.assertEquals(
                                                          updatedString,
                                                          readRow.getValue(readAttributesColumn
                                                                           .getIndex()));
                                }
                                break;
                            case UserCoreResultUtils.FIELD_TYPE_INTEGER:
                                switch (readAttributesColumn.getDataType()) {
                                    case BOOLEAN:
                                        TestCase.assertEquals(
                                                              updatedBoolean,
                                                              readRow.getValue(readAttributesColumn
                                                                               .getIndex()));
                                        break;
                                    case TINYINT:
                                        TestCase.assertEquals(updatedByte, readRow
                                                              .getValue(readAttributesColumn
                                                                        .getIndex()));
                                        break;
                                    case SMALLINT:
                                        TestCase.assertEquals(updatedShort, readRow
                                                              .getValue(readAttributesColumn
                                                                        .getIndex()));
                                        break;
                                    case MEDIUMINT:
                                        TestCase.assertEquals(
                                                              updatedInteger,
                                                              readRow.getValue(readAttributesColumn
                                                                               .getIndex()));
                                        break;
                                    case INT:
                                    case INTEGER:
                                        TestCase.assertEquals(updatedLong, readRow
                                                              .getValue(readAttributesColumn
                                                                        .getIndex()));
                                        break;
                                    default:
                                        TestCase.fail("Unexpected integer type: "
                                                      + readAttributesColumn
                                                      .getDataType());
                                }
                                break;
                            case UserCoreResultUtils.FIELD_TYPE_FLOAT:
                                switch (readAttributesColumn.getDataType()) {
                                    case FLOAT:
                                        TestCase.assertEquals(updatedFloat, readRow
                                                              .getValue(readAttributesColumn
                                                                        .getIndex()));
                                        break;
                                    case DOUBLE:
                                    case REAL:
                                        TestCase.assertEquals(
                                                              updatedDouble,
                                                              readRow.getValue(readAttributesColumn
                                                                               .getIndex()));
                                        break;
                                    default:
                                        TestCase.fail("Unexpected integer type: "
                                                      + readAttributesColumn
                                                      .getDataType());
                                }
                                break;
                            case UserCoreResultUtils.FIELD_TYPE_BLOB:
                                if (readAttributesColumn.getMax() != null) {
                                    GeoPackageGeometryDataUtils
                                    .compareByteArrays(
                                                       updatedLimitedBytes,
                                                       (byte[]) readRow
                                                       .getValue(readAttributesColumn
                                                                 .getIndex()));
                                } else {
                                    GeoPackageGeometryDataUtils
                                    .compareByteArrays(
                                                       updatedBytes,
                                                       (byte[]) readRow
                                                       .getValue(readAttributesColumn
                                                                 .getIndex()));
                                }
                                break;
                            default:
                        }
                    }
                    
                }
                
            }
            cursor.close();
        }
    }
    */
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
