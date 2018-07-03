//
//  GPKGRelatedSimpleAttributesUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedSimpleAttributesUtils.h"
#import "GPKGSimpleAttributesTable.h"
#import "GPKGTestUtils.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGRelatedTablesUtils.h"

@implementation GPKGRelatedSimpleAttributesUtils

+(void) testSimpleAttributes: (GPKGGeoPackage *) geoPackage{

    // Create a related tables extension
    GPKGRelatedTablesExtension *rte = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    [GPKGTestUtils assertFalse:[rte has]];
    [GPKGTestUtils assertTrue:[rte relationships].count == 0];

    // Choose a random attributes table
    NSArray<NSString *> *attributesTables = [geoPackage getAttributesTables];
    if(attributesTables.count == 0){
        return; // pass with no testing
    }
    NSString *baseTableName = [attributesTables objectAtIndex:(int)([GPKGTestUtils randomDouble] * attributesTables.count)];
    
    // Validate nullable non simple columns
    @try {
        [GPKGSimpleAttributesTable createWithName:@"simple_table" andColumns:[GPKGRelatedTablesUtils createAdditionalUserColumnsAtIndex:[GPKGSimpleAttributesTable numRequiredColumns]]];
        [GPKGTestUtils fail:@"Simple Attributes Table created with nullable non simple columns"];
    } @catch (NSException *exception) {
        // pass
    }
    // Validate non nullable non simple columns
    @try {
        [GPKGSimpleAttributesTable createWithName:@"simple_table" andColumns:[GPKGRelatedTablesUtils createAdditionalUserColumnsAtIndex:[GPKGSimpleAttributesTable numRequiredColumns] andNotNil:YES]];
        [GPKGTestUtils fail:@"Simple Attributes Table created with non nullable non simple columns"];
    } @catch (NSException *exception) {
        // pass
    }
    // Validate nullable simple columns
    @try {
        [GPKGSimpleAttributesTable createWithName:@"simple_table" andColumns:[GPKGRelatedTablesUtils createSimpleUserColumnsAtIndex:[GPKGSimpleAttributesTable numRequiredColumns] andNotNil:NO]];
        [GPKGTestUtils fail:@"Simple Attributes Table created with nullable simple columns"];
    } @catch (NSException *exception) {
        // pass
    }
    
    // Populate and validate a simple attributes table
    NSArray<GPKGUserCustomColumn *> *simpleUserColumns = [GPKGRelatedTablesUtils createSimpleUserColumnsAtIndex:[GPKGSimpleAttributesTable numRequiredColumns]];
    GPKGSimpleAttributesTable *simpleTable = [GPKGSimpleAttributesTable createWithName:@"simple_table" andColumns:simpleUserColumns];
    NSArray<NSString *> *simpleColumns = simpleTable.columnNames;
    [GPKGTestUtils assertEqualIntWithValue:[GPKGSimpleAttributesTable numRequiredColumns] + (int)simpleUserColumns.count andValue2:(int)simpleColumns.count];
    GPKGUserCustomColumn *idColumn = [simpleTable idColumn];
    [GPKGTestUtils assertNotNil:idColumn];
    [GPKGTestUtils assertTrue:[idColumn isNamed:GPKG_RSAT_COLUMN_ID]];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_DT_INTEGER andValue2:idColumn.dataType];
    [GPKGTestUtils assertTrue:idColumn.notNull];
    [GPKGTestUtils assertTrue:idColumn.primaryKey];
    
    // Create and validate a mapping table
    NSArray<GPKGUserCustomColumn *> *additionalMappingColumns = [GPKGRelatedTablesUtils createAdditionalUserColumnsAtIndex:[GPKGUserMappingTable numRequiredColumns]];
    NSString *mappingTableName = @"attributes_simple_attributes";
    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:mappingTableName andAdditionalColumns:additionalMappingColumns];
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertEqualIntWithValue:[GPKGUserMappingTable numRequiredColumns] + (int)additionalMappingColumns.count andValue2:(int)userMappingTable.columns.count];
    GPKGUserCustomColumn *baseIdColumn = [userMappingTable baseIdColumn];
    [GPKGTestUtils assertNotNil:baseIdColumn];
    [GPKGTestUtils assertTrue:[baseIdColumn isNamed:GPKG_UMT_COLUMN_BASE_ID]];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_DT_INTEGER andValue2:baseIdColumn.dataType];
    [GPKGTestUtils assertTrue:baseIdColumn.notNull];
    [GPKGTestUtils assertFalse:baseIdColumn.primaryKey];
    GPKGUserCustomColumn *relatedIdColumn = [userMappingTable relatedIdColumn];
    [GPKGTestUtils assertNotNil:relatedIdColumn];
    [GPKGTestUtils assertTrue:[relatedIdColumn isNamed:GPKG_UMT_COLUMN_RELATED_ID]];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_DT_INTEGER andValue2:relatedIdColumn.dataType];
    [GPKGTestUtils assertTrue:relatedIdColumn.notNull];
    [GPKGTestUtils assertFalse:relatedIdColumn.primaryKey];
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    
    // Create the simple attributes table, content row, and relationship
    // between the attributes table and simple attributes table
    GPKGContentsDao *contentsDao = [geoPackage getContentsDao];
    [GPKGTestUtils assertFalse:[[contentsDao getTables] containsObject:simpleTable.tableName]];
    GPKGExtendedRelation *extendedRelation = [rte addSimpleAttributesRelationshipWithBaseTable:baseTableName andSimpleAttributesTable:simpleTable andUserMappingTable:userMappingTable];
    [self validateContents:simpleTable.contents withTable:simpleTable];
    [GPKGTestUtils assertTrue:[rte has]];
    [GPKGTestUtils assertTrue:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertNotNil:extendedRelation];
    NSArray<GPKGExtendedRelation *> *extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertTrue:[geoPackage.database tableExists:mappingTableName]];
    [GPKGTestUtils assertTrue:[geoPackage.database tableExists:simpleTable.tableName]];
    [GPKGTestUtils assertTrue:[[contentsDao getTables] containsObject:simpleTable.tableName]];
    [self validateContents:(GPKGContents *)[contentsDao queryForIdObject:simpleTable.tableName] withTable:simpleTable];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:[GPKGSimpleAttributesTable relationType]] andValue2:[geoPackage typeOfTable:simpleTable.tableName]];
    [GPKGTestUtils assertTrue:[geoPackage isTable:simpleTable.tableName ofTypeName:[GPKGRelationTypes name:[GPKGSimpleAttributesTable relationType]]]];
    
    // Validate the simple attributes DAO
    GPKGSimpleAttributesDao *simpleDao = [rte simpleAttributesDaoForTable:simpleTable];
    [GPKGTestUtils assertNotNil:simpleDao];
    simpleTable = [simpleDao table];
    [GPKGTestUtils assertNotNil:simpleTable];
    [self validateContents:simpleTable.contents withTable:simpleTable];
    
    // Insert simple attributes table rows
    int simpleCount = 2 + [GPKGTestUtils randomIntLessThan:9];
    int simpleRowId = 0;
    // Create and insert the first simpleCount - 1 rows
    for (int i = 0; i < simpleCount - 1; i++) {
        GPKGSimpleAttributesRow *simpleRow = [simpleDao newRow];
        [GPKGRelatedTablesUtils populateUserRowWithTable:simpleTable andRow:simpleRow andSkipColumns:[GPKGSimpleAttributesTable requiredColumns]];
        simpleRowId = (int)[simpleDao create:simpleRow];
        [GPKGTestUtils assertTrue:simpleRowId > 0];
    }
    // Copy the last row insert and insert the final simple attributes row
    GPKGSimpleAttributesRow *simpleRowToCopy = [[GPKGSimpleAttributesRow alloc] initWithUserCustomRow:(GPKGSimpleAttributesRow *)[simpleDao queryForIdObject:[NSNumber numberWithInt:simpleRowId]]];
    GPKGSimpleAttributesRow *simpleRowCopy = [simpleRowToCopy mutableCopy];
    int copySimpleRowId = (int)[simpleDao create:simpleRowCopy];
    [GPKGTestUtils assertTrue:copySimpleRowId > 0];
    [GPKGTestUtils assertEqualIntWithValue:simpleRowId + 1 andValue2:copySimpleRowId];
    [GPKGTestUtils assertEqualIntWithValue:simpleCount andValue2:(int)simpleDao.count];
    
    /*
    // Build the Attributes ids
    AttributesDao attributesDao = geoPackage
    .getAttributesDao(baseTableName);
    AttributesResultSet attributesResultSet = attributesDao.queryForAll();
    int attributesCount = attributesResultSet.getCount();
    List<Long> attributeIds = new ArrayList<>();
    while (attributesResultSet.moveToNext()) {
        attributeIds.add(attributesResultSet.getRow().getId());
    }
    attributesResultSet.close();
    
    // Build the Simple Attribute ids
    UserCustomResultSet simpleResultSet = simpleDao.queryForAll();
    simpleCount = simpleResultSet.getCount();
    List<Long> simpleIds = new ArrayList<>();
    while (simpleResultSet.moveToNext()) {
        simpleIds.add(simpleResultSet.getRow().getId());
    }
    simpleResultSet.close();
    
    // Insert user mapping rows between attribute ids and simple attribute
    // ids
    UserMappingDao dao = rte.getMappingDao(mappingTableName);
    UserMappingRow userMappingRow = null;
    for (int i = 0; i < 10; i++) {
        userMappingRow = dao.newRow();
        userMappingRow
        .setBaseId(attributeIds.get((int) (Math.random() * attributesCount)));
        userMappingRow
        .setRelatedId(simpleIds.get((int) (Math.random() * simpleCount)));
        RelatedTablesUtils.populateUserRow(userMappingTable,
                                           userMappingRow, UserMappingTable.requiredColumns());
        TestCase.assertTrue(dao.create(userMappingRow) > 0);
    }
    TestCase.assertEquals(10, dao.count());
    
    // Validate the user mapping rows
    userMappingTable = dao.getTable();
    String[] mappingColumns = userMappingTable.getColumnNames();
    UserCustomResultSet resultSet = dao.queryForAll();
    int count = resultSet.getCount();
    TestCase.assertEquals(10, count);
    int manualCount = 0;
    while (resultSet.moveToNext()) {
        
        UserMappingRow resultRow = dao.getRow(resultSet);
        TestCase.assertFalse(resultRow.hasId());
        TestCase.assertTrue(attributeIds.contains(resultRow.getBaseId()));
        TestCase.assertTrue(simpleIds.contains(resultRow.getRelatedId()));
        RelatedTablesUtils.validateUserRow(mappingColumns, resultRow);
        RelatedTablesUtils.validateDublinCoreColumns(resultRow);
        
        manualCount++;
    }
    TestCase.assertEquals(count, manualCount);
    resultSet.close();
    
    ExtendedRelationsDao extendedRelationsDao = rte
    .getExtendedRelationsDao();
    
    // Get the relations starting from the attributes table
    List<ExtendedRelation> attributesExtendedRelations = extendedRelationsDao
    .getBaseTableRelations(attributesDao.getTableName());
    List<ExtendedRelation> attributesExtendedRelations2 = extendedRelationsDao
    .getTableRelations(attributesDao.getTableName());
    TestCase.assertEquals(1, attributesExtendedRelations.size());
    TestCase.assertEquals(1, attributesExtendedRelations2.size());
    TestCase.assertEquals(attributesExtendedRelations.get(0).getId(),
                          attributesExtendedRelations2.get(0).getId());
    TestCase.assertTrue(extendedRelationsDao.getRelatedTableRelations(
                                                                      attributesDao.getTableName()).isEmpty());
    
    // Test the attributes table relations
    for (ExtendedRelation attributesRelation : attributesExtendedRelations) {
        
        // Test the relation
        TestCase.assertTrue(attributesRelation.getId() >= 0);
        TestCase.assertEquals(attributesDao.getTableName(),
                              attributesRelation.getBaseTableName());
        TestCase.assertEquals(attributesDao.getTable().getPkColumn()
                              .getName(), attributesRelation.getBasePrimaryColumn());
        TestCase.assertEquals(simpleDao.getTableName(),
                              attributesRelation.getRelatedTableName());
        TestCase.assertEquals(simpleDao.getTable().getPkColumn().getName(),
                              attributesRelation.getRelatedPrimaryColumn());
        TestCase.assertEquals(
                              SimpleAttributesTable.RELATION_TYPE.getName(),
                              attributesRelation.getRelationName());
        TestCase.assertEquals(mappingTableName,
                              attributesRelation.getMappingTableName());
        
        // Test the user mappings from the relation
        UserMappingDao userMappingDao = rte
        .getMappingDao(attributesRelation);
        int totalMappedCount = userMappingDao.count();
        UserCustomResultSet mappingResultSet = userMappingDao.queryForAll();
        while (mappingResultSet.moveToNext()) {
            userMappingRow = userMappingDao.getRow(mappingResultSet);
            TestCase.assertTrue(attributeIds.contains(userMappingRow
                                                      .getBaseId()));
            TestCase.assertTrue(simpleIds.contains(userMappingRow
                                                   .getRelatedId()));
            RelatedTablesUtils.validateUserRow(mappingColumns,
                                               userMappingRow);
            RelatedTablesUtils.validateDublinCoreColumns(userMappingRow);
        }
        mappingResultSet.close();
        
        // Get and test the simple attributes DAO
        simpleDao = rte.getSimpleAttributesDao(attributesRelation);
        TestCase.assertNotNull(simpleDao);
        simpleTable = simpleDao.getTable();
        TestCase.assertNotNull(simpleTable);
        validateContents(simpleTable, simpleTable.getContents());
        
        // Get and test the Simple Attributes Rows mapped to each
        // Attributes Row
        attributesResultSet = attributesDao.queryForAll();
        int totalMapped = 0;
        while (attributesResultSet.moveToNext()) {
            AttributesRow attributesRow = attributesResultSet.getRow();
            List<Long> mappedIds = rte.getMappingsForBase(
                                                          attributesRelation, attributesRow.getId());
            List<SimpleAttributesRow> simpleRows = simpleDao
            .getRows(mappedIds);
            TestCase.assertEquals(mappedIds.size(), simpleRows.size());
            
            for (SimpleAttributesRow simpleRow : simpleRows) {
                TestCase.assertTrue(simpleRow.hasId());
                TestCase.assertTrue(simpleRow.getId() >= 0);
                TestCase.assertTrue(simpleIds.contains(simpleRow.getId()));
                TestCase.assertTrue(mappedIds.contains(simpleRow.getId()));
                RelatedTablesUtils
                .validateUserRow(simpleColumns, simpleRow);
                RelatedTablesUtils
                .validateSimpleDublinCoreColumns(simpleRow);
            }
            
            totalMapped += mappedIds.size();
        }
        attributesResultSet.close();
        TestCase.assertEquals(totalMappedCount, totalMapped);
    }
    
    // Get the relations starting from the simple attributes table
    List<ExtendedRelation> simpleExtendedRelations = extendedRelationsDao
    .getRelatedTableRelations(simpleTable.getTableName());
    List<ExtendedRelation> simpleExtendedRelations2 = extendedRelationsDao
    .getTableRelations(simpleTable.getTableName());
    TestCase.assertEquals(1, simpleExtendedRelations.size());
    TestCase.assertEquals(1, simpleExtendedRelations2.size());
    TestCase.assertEquals(simpleExtendedRelations.get(0).getId(),
                          simpleExtendedRelations2.get(0).getId());
    TestCase.assertTrue(extendedRelationsDao.getBaseTableRelations(
                                                                   simpleTable.getTableName()).isEmpty());
    
    // Test the simple attributes table relations
    for (ExtendedRelation simpleRelation : simpleExtendedRelations) {
        
        // Test the relation
        TestCase.assertTrue(simpleRelation.getId() >= 0);
        TestCase.assertEquals(attributesDao.getTableName(),
                              simpleRelation.getBaseTableName());
        TestCase.assertEquals(attributesDao.getTable().getPkColumn()
                              .getName(), simpleRelation.getBasePrimaryColumn());
        TestCase.assertEquals(simpleDao.getTableName(),
                              simpleRelation.getRelatedTableName());
        TestCase.assertEquals(simpleDao.getTable().getPkColumn().getName(),
                              simpleRelation.getRelatedPrimaryColumn());
        TestCase.assertEquals(
                              SimpleAttributesTable.RELATION_TYPE.getName(),
                              simpleRelation.getRelationName());
        TestCase.assertEquals(mappingTableName,
                              simpleRelation.getMappingTableName());
        
        // Test the user mappings from the relation
        UserMappingDao userMappingDao = rte.getMappingDao(simpleRelation);
        int totalMappedCount = userMappingDao.count();
        UserCustomResultSet mappingResultSet = userMappingDao.queryForAll();
        while (mappingResultSet.moveToNext()) {
            userMappingRow = userMappingDao.getRow(mappingResultSet);
            TestCase.assertTrue(attributeIds.contains(userMappingRow
                                                      .getBaseId()));
            TestCase.assertTrue(simpleIds.contains(userMappingRow
                                                   .getRelatedId()));
            RelatedTablesUtils.validateUserRow(mappingColumns,
                                               userMappingRow);
            RelatedTablesUtils.validateDublinCoreColumns(userMappingRow);
        }
        mappingResultSet.close();
        
        // Get and test the attributes DAO
        attributesDao = geoPackage.getAttributesDao(attributesDao
                                                    .getTableName());
        TestCase.assertNotNull(attributesDao);
        AttributesTable attributesTable = attributesDao.getTable();
        TestCase.assertNotNull(attributesTable);
        Contents attributesContents = attributesTable.getContents();
        TestCase.assertNotNull(attributesContents);
        TestCase.assertEquals(ContentsDataType.ATTRIBUTES,
                              attributesContents.getDataType());
        TestCase.assertEquals(ContentsDataType.ATTRIBUTES.getName(),
                              attributesContents.getDataTypeString());
        TestCase.assertEquals(attributesTable.getTableName(),
                              attributesContents.getTableName());
        TestCase.assertNotNull(attributesContents.getLastChange());
        
        // Get and test the Attributes Rows mapped to each Simple Attributes
        // Row
        simpleResultSet = simpleDao.queryForAll();
        int totalMapped = 0;
        while (simpleResultSet.moveToNext()) {
            SimpleAttributesRow simpleRow = simpleDao
            .getRow(simpleResultSet);
            List<Long> mappedIds = rte.getMappingsForRelated(
                                                             simpleRelation, simpleRow.getId());
            for (long mappedId : mappedIds) {
                AttributesRow attributesRow = attributesDao
                .queryForIdRow(mappedId);
                TestCase.assertNotNull(attributesRow);
                
                TestCase.assertTrue(attributesRow.hasId());
                TestCase.assertTrue(attributesRow.getId() >= 0);
                TestCase.assertTrue(attributeIds.contains(attributesRow
                                                          .getId()));
                TestCase.assertTrue(mappedIds.contains(attributesRow
                                                       .getId()));
            }
            
            totalMapped += mappedIds.size();
        }
        simpleResultSet.close();
        TestCase.assertEquals(totalMappedCount, totalMapped);
    }
    
    // Delete a single mapping
    int countOfIds = dao.countByIds(userMappingRow);
    TestCase.assertEquals(countOfIds, dao.deleteByIds(userMappingRow));
    TestCase.assertEquals(10 - countOfIds, dao.count());
    
    // Delete the relationship and user mapping table
    rte.removeRelationship(extendedRelation);
    TestCase.assertFalse(rte.has(userMappingTable.getTableName()));
    extendedRelations = rte.getRelationships();
    TestCase.assertEquals(0, extendedRelations.size());
    TestCase.assertFalse(geoPackage.getDatabase().tableExists(
                                                              mappingTableName));
    
    // Delete the simple attributes table and contents row
    TestCase.assertTrue(geoPackage.isTable(simpleTable.getTableName()));
    TestCase.assertNotNull(contentsDao.queryForId(simpleTable
                                                  .getTableName()));
    geoPackage.deleteTable(simpleTable.getTableName());
    TestCase.assertFalse(geoPackage.isTable(simpleTable.getTableName()));
    TestCase.assertNull(contentsDao.queryForId(simpleTable.getTableName()));
    
    // Delete the related tables extension
    rte.removeExtension();
    TestCase.assertFalse(rte.has());
    */
}

/**
 * Validate contents
 *
 * @param contents
 *            contents
 * @param simpleAttributesTable
 *            simple attributes table
 */
+(void) validateContents: (GPKGContents *) contents withTable: (GPKGSimpleAttributesTable *) simpleAttributesTable{
    [GPKGTestUtils assertNotNil:contents];
    [GPKGTestUtils assertEqualIntWithValue:-1 andValue2:(int)[contents getContentsDataType]];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:[GPKGSimpleAttributesTable relationType]] andValue2:contents.dataType];
    [GPKGTestUtils assertEqualWithValue:simpleAttributesTable.tableName andValue2:contents.tableName];
    [GPKGTestUtils assertNotNil:contents.lastChange];
}

@end
