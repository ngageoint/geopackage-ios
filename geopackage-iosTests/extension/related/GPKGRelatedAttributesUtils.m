//
//  GPKGRelatedAttributesUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/7/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGRelatedAttributesUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGRelatedTablesUtils.h"

@implementation GPKGRelatedAttributesUtils

+(void) testAttributesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
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
    NSString *baseTableName = [attributesTables objectAtIndex:[GPKGTestUtils randomIntLessThan:(int)attributesTables.count]];
    NSString *relatedTableName = [attributesTables objectAtIndex:[GPKGTestUtils randomIntLessThan:(int)attributesTables.count]];
    
    // Create and validate a mapping table
    NSArray<GPKGUserCustomColumn *> *additionalMappingColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    NSString *mappingTableName = @"attributes_attributes";
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

    // Create the relationship between the attributes table and attributes
    // table
    GPKGExtendedRelation *extendedRelation = [rte addAttributesRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andUserMappingTable:userMappingTable];
    [GPKGTestUtils assertTrue:[rte has]];
    [GPKGTestUtils assertTrue:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertNotNil:extendedRelation];
    NSArray<GPKGExtendedRelation *> *extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertTrue:[geoPackage isTable:mappingTableName]];
    
    // Build the Attributes ids
    GPKGAttributesDao *attributesDao = [geoPackage getAttributesDaoWithTableName:baseTableName];
    GPKGResultSet *attributesResultSet = [attributesDao queryForAll];
    int attributesCount = attributesResultSet.count;
    NSMutableArray<NSNumber *> *attributeIds = [[NSMutableArray alloc] init];
    while([attributesResultSet moveToNext]){
        [attributeIds addObject:[[attributesDao getAttributesRow:attributesResultSet] getId]];
    }
    [attributesResultSet close];
    
    // Build the Attribute related ids
    GPKGAttributesDao *attributesDao2 = [geoPackage getAttributesDaoWithTableName:relatedTableName];
    GPKGResultSet *attributesResultSet2 = [attributesDao2 queryForAll];
    int attributesCount2 = attributesResultSet2.count;
    NSMutableArray<NSNumber *> *attributeIds2 = [[NSMutableArray alloc] init];
    while([attributesResultSet2 moveToNext]){
        [attributeIds2 addObject:[[attributesDao2 getAttributesRow:attributesResultSet2] getId]];
    }
    [attributesResultSet2 close];

    // Insert user mapping rows between attribute ids and attribute ids
    GPKGUserMappingDao *dao = [rte mappingDaoForTableName:mappingTableName];
    GPKGUserMappingRow *userMappingRow = nil;
    for (int i = 0; i < 10; i++) {
        userMappingRow = [dao newRow];
        [userMappingRow setBaseId:[[attributeIds objectAtIndex:[GPKGTestUtils randomIntLessThan:attributesCount]] intValue]];
        [userMappingRow setRelatedId:[[attributeIds2 objectAtIndex:[GPKGTestUtils randomIntLessThan:attributesCount2]] intValue]];
        [GPKGRelatedTablesUtils populateUserRowWithTable:userMappingTable andRow:userMappingRow andSkipColumns:[GPKGUserMappingTable requiredColumns]];
        [GPKGTestUtils assertTrue:[dao create:userMappingRow] > 0];
    }
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:[dao count]];
    
    // Validate the user mapping rows
    userMappingTable = [dao table];
    NSArray<NSString *> *mappingColumns = [userMappingTable columnNames];
    GPKGResultSet *resultSet = [dao queryForAll];
    int count = resultSet.count;
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:count];
    int manualCount = 0;
    while([resultSet moveToNext]){
        
        GPKGUserMappingRow *resultRow = [dao row:resultSet];
        [GPKGTestUtils assertFalse:[resultRow hasId]];
        [GPKGTestUtils assertTrue:[attributeIds containsObject:[NSNumber numberWithInt:resultRow.baseId]]];
        [GPKGTestUtils assertTrue:[attributeIds2 containsObject:[NSNumber numberWithInt:resultRow.relatedId]]];
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
    
    // Test the attributes table relations
    while([attributesExtendedRelations moveToNext]){
        
        GPKGExtendedRelation *attributesRelation = [extendedRelationsDao relation:attributesExtendedRelations];
        
        if(attributesExtendedRelations2 != nil){
            
            [attributesExtendedRelations2 moveToNext];
            GPKGExtendedRelation *attributesRelation2 = [extendedRelationsDao relation:attributesExtendedRelations2];
            
            [GPKGTestUtils assertEqualWithValue:attributesRelation.id andValue2:attributesRelation2.id];
            
            [attributesExtendedRelations2 close];
            attributesExtendedRelations2 = nil;
        }
        
        // Test the relation
        [GPKGTestUtils assertTrue:[attributesRelation.id intValue] >= 0];
        [GPKGTestUtils assertEqualWithValue:attributesDao.tableName andValue2:attributesRelation.baseTableName];
        [GPKGTestUtils assertEqualWithValue:[attributesDao.table getPkColumn].name andValue2:attributesRelation.basePrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:attributesDao2.tableName andValue2:attributesRelation.relatedTableName];
        [GPKGTestUtils assertEqualWithValue:[attributesDao2.table getPkColumn].name andValue2:attributesRelation.relatedPrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:GPKG_RT_ATTRIBUTES] andValue2:attributesRelation.relationName];
        [GPKGTestUtils assertEqualWithValue:mappingTableName andValue2:attributesRelation.mappingTableName];
        
        // Test the user mappings from the relation
        GPKGUserMappingDao *userMappingDao = [rte mappingDaoForRelation:attributesRelation];
        GPKGResultSet *mappingResultSet = [userMappingDao queryForAll];
        while([mappingResultSet moveToNext]){
            userMappingRow = [userMappingDao row:mappingResultSet];
            [GPKGTestUtils assertTrue:[attributeIds containsObject:[NSNumber numberWithInt:userMappingRow.baseId]]];
            [GPKGTestUtils assertTrue:[attributeIds2 containsObject:[NSNumber numberWithInt:userMappingRow.relatedId]]];
            [GPKGRelatedTablesUtils validateUserRow:userMappingRow withColumns:mappingColumns];
            [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:userMappingRow];
        }
        [mappingResultSet close];
        
    }
    [attributesExtendedRelations close];
    
    // Get the relations starting from the attributes table
    GPKGResultSet *relatedExtendedRelations = [extendedRelationsDao relationsToRelatedTable:relatedTableName];
    GPKGResultSet *extendedRelations2 = [extendedRelationsDao relationsToTable:relatedTableName];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:relatedExtendedRelations.count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:extendedRelations2.count];
    
    // Test the attributes table relations
    while([relatedExtendedRelations moveToNext]){
        
        GPKGExtendedRelation *relation = [extendedRelationsDao relation:relatedExtendedRelations];
        
        if(extendedRelations2 != nil){
            
            [extendedRelations2 moveToNext];
            GPKGExtendedRelation *relation2 = [extendedRelationsDao relation:extendedRelations2];
            
            [GPKGTestUtils assertEqualWithValue:relation.id andValue2:relation2.id];
            
            [extendedRelations2 close];
            extendedRelations2 = nil;
        }
        
        // Test the relation
        [GPKGTestUtils assertTrue:[relation.id intValue] >= 0];
        [GPKGTestUtils assertEqualWithValue:attributesDao.tableName andValue2:relation.baseTableName];
        [GPKGTestUtils assertEqualWithValue:[attributesDao.table getPkColumn].name andValue2:relation.basePrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:attributesDao2.tableName andValue2:relation.relatedTableName];
        [GPKGTestUtils assertEqualWithValue:[attributesDao2.table getPkColumn].name andValue2:relation.relatedPrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:GPKG_RT_ATTRIBUTES] andValue2:relation.relationName];
        [GPKGTestUtils assertEqualWithValue:mappingTableName andValue2:relation.mappingTableName];
        
        // Test the user mappings from the relation
        GPKGUserMappingDao *userMappingDao = [rte mappingDaoForRelation:relation];
        int totalMappedCount = userMappingDao.count;
        GPKGResultSet *mappingResultSet = [userMappingDao queryForAll];
        while([mappingResultSet moveToNext]){
            userMappingRow = [userMappingDao row:mappingResultSet];
            [GPKGTestUtils assertTrue:[attributeIds containsObject:[NSNumber numberWithInt:userMappingRow.baseId]]];
            [GPKGTestUtils assertTrue:[attributeIds2 containsObject:[NSNumber numberWithInt:userMappingRow.relatedId]]];
            [GPKGRelatedTablesUtils validateUserRow:userMappingRow withColumns:mappingColumns];
            [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:userMappingRow];
        }
        [mappingResultSet close];
        
        // Get and test the attributes DAO
        attributesDao = [geoPackage getAttributesDaoWithTableName:attributesDao.tableName];
        [GPKGTestUtils assertNotNil:attributesDao];
        GPKGAttributesTable *attributesTable = [attributesDao getAttributesTable];
        [GPKGTestUtils assertNotNil:attributesTable];
        GPKGContents *attributesContents = attributesTable.contents;
        [GPKGTestUtils assertNotNil:attributesContents];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_CDT_ATTRIBUTES andValue2:[attributesContents getContentsDataType]];
        [GPKGTestUtils assertEqualWithValue:[GPKGContentsDataTypes name:GPKG_CDT_ATTRIBUTES] andValue2:attributesContents.dataType];
        [GPKGTestUtils assertEqualWithValue:attributesTable.tableName andValue2:attributesContents.tableName];
        [GPKGTestUtils assertNotNil:attributesContents.lastChange];
        
        // Get and test the Attributes Rows mapped to each Attributes Row
        attributesResultSet2 = [attributesDao2 queryForAll];
        int totalMapped = 0;
        while([attributesResultSet2 moveToNext]){
            GPKGAttributesRow *attributes2Row = [attributesDao2 getAttributesRow:attributesResultSet2];
            NSArray<NSNumber *> *mappedIds = [rte mappingsForRelation:relation withRelatedId:[[attributes2Row getId] intValue]];
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
        [attributesResultSet2 close];
        [GPKGTestUtils assertEqualIntWithValue:totalMappedCount andValue2:totalMapped];
    }
    [relatedExtendedRelations close];
     
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
    
    // Delete the related tables extension
    [rte removeExtension];
    [GPKGTestUtils assertFalse:[rte has]];
    
}

@end
