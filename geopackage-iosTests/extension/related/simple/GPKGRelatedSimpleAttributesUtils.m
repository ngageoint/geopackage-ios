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
    
    if([rte has]){
        [rte removeExtension];
    }
    
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
    [GPKGTestUtils assertTrue:[geoPackage isTable:mappingTableName]];
    [GPKGTestUtils assertTrue:[geoPackage isTable:simpleTable.tableName]];
    [GPKGTestUtils assertTrue:[[contentsDao getTables] containsObject:simpleTable.tableName]];
    [self validateContents:(GPKGContents *)[contentsDao queryForIdObject:simpleTable.tableName] withTable:simpleTable];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes dataType:[GPKGSimpleAttributesTable relationType]] andValue2:[geoPackage typeOfTable:simpleTable.tableName]];
    [GPKGTestUtils assertTrue:[geoPackage isTable:simpleTable.tableName ofTypeName:[GPKGRelationTypes dataType:[GPKGSimpleAttributesTable relationType]]]];
    
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
    GPKGSimpleAttributesRow *simpleRowToCopy = (GPKGSimpleAttributesRow *)[simpleDao queryForIdObject:[NSNumber numberWithInt:simpleRowId]];
    GPKGSimpleAttributesRow *simpleRowCopy = [simpleRowToCopy mutableCopy];
    int copySimpleRowId = (int)[simpleDao create:simpleRowCopy];
    [GPKGTestUtils assertTrue:copySimpleRowId > 0];
    [GPKGTestUtils assertEqualIntWithValue:simpleRowId + 1 andValue2:copySimpleRowId];
    [GPKGTestUtils assertEqualIntWithValue:simpleCount andValue2:(int)simpleDao.count];
    
    // Build the Attributes ids
    GPKGAttributesDao *attributesDao = [geoPackage getAttributesDaoWithTableName:baseTableName];
    GPKGResultSet *attributesResultSet = [attributesDao queryForAll];
    int attributesCount = attributesResultSet.count;
    NSMutableArray<NSNumber *> *attributeIds = [[NSMutableArray alloc] init];
    while([attributesResultSet moveToNext]){
        [attributeIds addObject:[[attributesDao getAttributesRow:attributesResultSet] getId]];
    }
    [attributesResultSet close];
    
    // Build the Simple Attribute ids
    GPKGResultSet *simpleResultSet = [simpleDao queryForAll];
    simpleCount = simpleResultSet.count;
    NSMutableArray<NSNumber *> *simpleIds = [[NSMutableArray alloc] init];
    while([simpleResultSet moveToNext]){
        [simpleIds addObject:[NSNumber numberWithInt:[[simpleDao row:simpleResultSet] id]]];
    }
    [simpleResultSet close];
    
    // Insert user mapping rows between attribute ids and simple attribute
    // ids
    GPKGUserMappingDao *dao = [rte mappingDaoForTableName:mappingTableName];
    GPKGUserMappingRow *userMappingRow = nil;
    for (int i = 0; i < 10; i++) {
        userMappingRow = [dao newRow];
        [userMappingRow setBaseId:[[attributeIds objectAtIndex:(int)([GPKGTestUtils randomDouble] * attributesCount)] intValue]];
        [userMappingRow setRelatedId:[[simpleIds objectAtIndex:(int)([GPKGTestUtils randomDouble] * simpleCount)] intValue]];
        [GPKGRelatedTablesUtils populateUserRowWithTable:userMappingTable andRow:userMappingRow andSkipColumns:[GPKGUserMappingTable requiredColumns]];
        [GPKGTestUtils assertTrue:[dao create:userMappingRow] > 0];
    }
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:[dao count]];
    
    // Validate the user mapping rows
    userMappingTable = [dao table];
    NSArray<NSString *> *mappingColumns = userMappingTable.columnNames;
    GPKGResultSet *resultSet = [dao queryForAll];
    int count = resultSet.count;
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:count];
    int manualCount = 0;
    while([resultSet moveToNext]){
        
        GPKGUserMappingRow *resultRow = [dao row:resultSet];
        [GPKGTestUtils assertFalse:[resultRow hasId]];
        [GPKGTestUtils assertTrue:[attributeIds containsObject:[NSNumber numberWithInt:[resultRow baseId]]]];
        [GPKGTestUtils assertTrue:[simpleIds containsObject:[NSNumber numberWithInt:[resultRow relatedId]]]];
        [GPKGRelatedTablesUtils validateUserRow:resultRow withColumns:mappingColumns];
        [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:resultRow];
        
        manualCount++;
    }
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:manualCount];
    [resultSet close];
    
    GPKGExtendedRelationsDao *extendedRelationsDao = [rte getExtendedRelationsDao];
    
    // Get the relations starting from the attributes table
    GPKGResultSet *attributesExtendedRelations = [extendedRelationsDao relationsToBaseTable:attributesDao.tableName];
    GPKGResultSet *attributesExtendedRelations2 = [extendedRelationsDao relationsToTable:attributesDao.tableName];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:attributesExtendedRelations.count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:attributesExtendedRelations2.count];
    GPKGExtendedRelation *extendedRelation1 = [extendedRelationsDao firstRelation:[extendedRelationsDao relationsToBaseTable:attributesDao.tableName]];
    GPKGExtendedRelation *extendedRelation2 = [extendedRelationsDao firstRelation:attributesExtendedRelations2];
    [GPKGTestUtils assertEqualWithValue:extendedRelation1.id andValue2:extendedRelation2.id];
    [attributesExtendedRelations2 close];
    GPKGResultSet *attributesExtendedRelations3 = [extendedRelationsDao relationsToRelatedTable:attributesDao.tableName];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:attributesExtendedRelations3.count];
    [attributesExtendedRelations3 close];
    
    // Test the attributes table relations
    while([attributesExtendedRelations moveToNext]){
        GPKGExtendedRelation *attributesRelation = [extendedRelationsDao relation:attributesExtendedRelations];
        
        // Test the relation
        [GPKGTestUtils assertTrue:[attributesRelation.id intValue] >= 0];
        [GPKGTestUtils assertEqualWithValue:attributesDao.tableName andValue2:attributesRelation.baseTableName];
        [GPKGTestUtils assertEqualWithValue:[attributesDao.table getPkColumn].name andValue2:attributesRelation.basePrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:simpleDao.tableName andValue2:attributesRelation.relatedTableName];
        [GPKGTestUtils assertEqualWithValue:[[simpleDao table] getPkColumn].name andValue2:attributesRelation.relatedPrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:[GPKGSimpleAttributesTable relationType]] andValue2:attributesRelation.relationName];
        [GPKGTestUtils assertEqualWithValue:mappingTableName andValue2:attributesRelation.mappingTableName];
        
        // Test the user mappings from the relation
        GPKGUserMappingDao *userMappingDao = [rte mappingDaoForRelation:attributesRelation];
        int totalMappedCount = userMappingDao.count;
        GPKGResultSet *mappingResultSet = [userMappingDao queryForAll];
        while([mappingResultSet moveToNext]){
            userMappingRow = [userMappingDao row:mappingResultSet];
            [GPKGTestUtils assertTrue:[attributeIds containsObject:[NSNumber numberWithInt:userMappingRow.baseId]]];
            [GPKGTestUtils assertTrue:[simpleIds containsObject:[NSNumber numberWithInt:userMappingRow.relatedId]]];
            [GPKGRelatedTablesUtils validateUserRow:userMappingRow withColumns:mappingColumns];
            [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:userMappingRow];
        }
        [mappingResultSet close];
        
        // Get and test the simple attributes DAO
        simpleDao = [rte simpleAttributesDaoForRelation:attributesRelation];
        [GPKGTestUtils assertNotNil:simpleDao];
        simpleTable = [simpleDao table];
        [GPKGTestUtils assertNotNil:simpleTable];
        [self validateContents:simpleTable.contents withTable:simpleTable];
        
        // Get and test the Simple Attributes Rows mapped to each
        // Attributes Row
        attributesResultSet = [attributesDao queryForAll];
        int totalMapped = 0;
        while([attributesResultSet moveToNext]){
            GPKGAttributesRow *attributesRow = [attributesDao getAttributesRow:attributesResultSet];
            NSArray<NSNumber *> *mappedIds = [rte mappingsForRelation:attributesRelation withBaseId:[[attributesRow getId] intValue]];
            NSArray<GPKGSimpleAttributesRow *> *simpleRows = [simpleDao rowsWithIds:mappedIds];
            [GPKGTestUtils assertEqualIntWithValue:(int)mappedIds.count andValue2:(int)simpleRows.count];
            
            for(GPKGSimpleAttributesRow *simpleRow in simpleRows){
                [GPKGTestUtils assertTrue:[simpleRow hasId]];
                [GPKGTestUtils assertTrue:[[simpleRow getId] intValue] >= 0];
                [GPKGTestUtils assertTrue:[simpleIds containsObject:[NSNumber numberWithInt:simpleRow.id]]];
                [GPKGTestUtils assertTrue:[mappedIds containsObject:[NSNumber numberWithInt:simpleRow.id]]];
                [GPKGRelatedTablesUtils validateUserRow:simpleRow withColumns:simpleColumns];
                [GPKGRelatedTablesUtils validateSimpleDublinCoreColumnsWithRow:simpleRow];
            }
            
            totalMapped += mappedIds.count;
        }
        [attributesResultSet close];
        [GPKGTestUtils assertEqualIntWithValue:totalMappedCount andValue2:totalMapped];
    }
    [attributesExtendedRelations close];
    
    // Get the relations starting from the simple attributes table
    GPKGResultSet *simpleExtendedRelations = [extendedRelationsDao relationsToRelatedTable:simpleTable.tableName];
    GPKGResultSet *simpleExtendedRelations2 = [extendedRelationsDao relationsToTable:simpleTable.tableName];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:simpleExtendedRelations.count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:simpleExtendedRelations2.count];
    extendedRelation1 = [extendedRelationsDao firstRelation:[extendedRelationsDao relationsToRelatedTable:simpleTable.tableName]];
    extendedRelation2 = [extendedRelationsDao firstRelation:simpleExtendedRelations2];
    [GPKGTestUtils assertEqualWithValue:extendedRelation1.id andValue2:extendedRelation2.id];
    [simpleExtendedRelations2 close];
    GPKGResultSet *simpleExtendedRelations3 = [extendedRelationsDao relationsToBaseTable:simpleTable.tableName];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:simpleExtendedRelations3.count];
    [simpleExtendedRelations3 close];
    
    // Test the simple attributes table relations
    while([simpleExtendedRelations moveToNext]){
        GPKGExtendedRelation *simpleRelation = [extendedRelationsDao relation:simpleExtendedRelations];
        
        // Test the relation
        [GPKGTestUtils assertTrue:[simpleRelation.id intValue] >= 0];
        [GPKGTestUtils assertEqualWithValue:attributesDao.tableName andValue2:simpleRelation.baseTableName];
        [GPKGTestUtils assertEqualWithValue:[attributesDao.table getPkColumn].name andValue2:simpleRelation.basePrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:simpleDao.tableName andValue2:simpleRelation.relatedTableName];
        [GPKGTestUtils assertEqualWithValue:[[simpleDao table] getPkColumn].name andValue2:simpleRelation.relatedPrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:[GPKGSimpleAttributesTable relationType]] andValue2:simpleRelation.relationName];
        [GPKGTestUtils assertEqualWithValue:mappingTableName andValue2:simpleRelation.mappingTableName];
        
        // Test the user mappings from the relation
        GPKGUserMappingDao *userMappingDao = [rte mappingDaoForRelation:simpleRelation];
        int totalMappedCount = userMappingDao.count;
        GPKGResultSet *mappingResultSet = [userMappingDao queryForAll];
        while([mappingResultSet moveToNext]){
            userMappingRow = [userMappingDao row:mappingResultSet];
            [GPKGTestUtils assertTrue:[attributeIds containsObject:[NSNumber numberWithInt:userMappingRow.baseId]]];
            [GPKGTestUtils assertTrue:[simpleIds containsObject:[NSNumber numberWithInt:userMappingRow.relatedId]]];
            [GPKGRelatedTablesUtils validateUserRow:userMappingRow withColumns:mappingColumns];
            [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:userMappingRow];
        }
        [mappingResultSet close];
        
        // Get and test the attributes DAO
        attributesDao = [geoPackage getAttributesDaoWithTableName:attributesDao.tableName];
        [GPKGTestUtils assertNotNil: attributesDao];
        GPKGAttributesTable *attributesTable = [attributesDao getAttributesTable];
        [GPKGTestUtils assertNotNil: attributesTable];
        GPKGContents *attributesContents = attributesTable.contents;
        [GPKGTestUtils assertNotNil: attributesContents];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_CDT_ATTRIBUTES andValue2:[attributesContents getContentsDataType]];
        [GPKGTestUtils assertEqualWithValue:[GPKGContentsDataTypes name:GPKG_CDT_ATTRIBUTES] andValue2:attributesContents.dataType];
        [GPKGTestUtils assertEqualWithValue:attributesTable.tableName andValue2:attributesContents.tableName];
        [GPKGTestUtils assertNotNil:attributesContents.lastChange];
        
        // Get and test the Attributes Rows mapped to each Simple Attributes
        // Row
        simpleResultSet = [simpleDao queryForAll];
        int totalMapped = 0;
        while([simpleResultSet moveToNext]){
            GPKGSimpleAttributesRow *simpleRow = [simpleDao row:simpleResultSet];
            NSArray<NSNumber *> *mappedIds = [rte mappingsForRelation:simpleRelation withRelatedId:[[simpleRow getId] intValue]];
            for(NSNumber *mappedId in mappedIds){
                GPKGAttributesRow *attributesRow = (GPKGAttributesRow *)[attributesDao queryForIdObject:mappedId];
                [GPKGTestUtils assertNotNil:attributesRow];
                
                [GPKGTestUtils assertTrue:[attributesRow hasId]];
                [GPKGTestUtils assertTrue:[[attributesRow getId] intValue] >= 0];
                [GPKGTestUtils assertTrue:[attributeIds containsObject:[attributesRow getId]]];
                [GPKGTestUtils assertTrue:[mappedIds containsObject:[attributesRow getId]]];
            }
            
            totalMapped += mappedIds.count;
        }
        [simpleResultSet close];
        [GPKGTestUtils assertEqualIntWithValue:totalMappedCount andValue2:totalMapped];
    }
    [simpleExtendedRelations close];
    
    // Delete a single mapping
    int countOfIds = [dao countByIdsFromRow:userMappingRow];
    [GPKGTestUtils assertEqualIntWithValue:countOfIds andValue2:[dao deleteByIdsFromRow:userMappingRow]];
    [GPKGTestUtils assertEqualIntWithValue:10 - countOfIds andValue2:[dao count]];
    
    // Delete the relationship and user mapping table
    [rte removeRelationship:extendedRelation];
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertFalse:[geoPackage isTable:mappingTableName]];
    
    // Delete the simple attributes table and contents row
    [GPKGTestUtils assertTrue:[geoPackage isTable:simpleTable.tableName]];
    [GPKGTestUtils assertNotNil:[contentsDao queryForIdObject:simpleTable.tableName]];
    [geoPackage deleteUserTable:simpleTable.tableName];
    [GPKGTestUtils assertFalse:[geoPackage isTable:simpleTable.tableName]];
    [GPKGTestUtils assertNil:[contentsDao queryForIdObject:simpleTable.tableName]];
    
    // Delete the related tables extension
    [rte removeExtension];
    [GPKGTestUtils assertFalse:[rte has]];

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
    [GPKGTestUtils assertTrue:(int)[contents getContentsDataType] >= 0];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes dataType:[GPKGSimpleAttributesTable relationType]] andValue2:[GPKGContentsDataTypes name:[contents getContentsDataType]]];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes dataType:[GPKGSimpleAttributesTable relationType]] andValue2:contents.dataType];
    [GPKGTestUtils assertEqualWithValue:simpleAttributesTable.tableName andValue2:contents.tableName];
    [GPKGTestUtils assertNotNil:contents.lastChange];
}

@end
