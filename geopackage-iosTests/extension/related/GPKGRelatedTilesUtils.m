//
//  GPKGRelatedTilesUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGRelatedTilesUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGRelatedTablesUtils.h"

@implementation GPKGRelatedTilesUtils

+(void) testTilesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Create a related tables extension
    GPKGRelatedTablesExtension *rte = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    
    if([rte has]){
        [rte removeExtension];
    }
    
    [GPKGTestUtils assertFalse:[rte has]];
    [GPKGTestUtils assertTrue:[rte relationships].count == 0];
    
    // Choose a random features table
    NSArray<NSString *> *featuresTables = [geoPackage featureTables];
    if(featuresTables.count == 0){
        return; // pass with no testing
    }
    NSString *baseTableName = [featuresTables objectAtIndex:[GPKGTestUtils randomIntLessThan:(int)featuresTables.count]];
    
    // Choose a random tiles table
    NSArray<NSString *> *tilesTables = [geoPackage tileTables];
    if(tilesTables.count == 0){
        return; // pass with no testing
    }
    NSString *relatedTableName = [tilesTables objectAtIndex:[GPKGTestUtils randomIntLessThan:(int)tilesTables.count]];
    
    // Create and validate a mapping table
    NSArray<GPKGUserCustomColumn *> *additionalMappingColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    NSString *mappingTableName = @"features_tiles";
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
    
    // Create the relationship between the features table and tiles
    // table
    GPKGExtendedRelation *extendedRelation = [rte addTilesRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andUserMappingTable:userMappingTable];
    [GPKGTestUtils assertTrue:[rte has]];
    [GPKGTestUtils assertTrue:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertNotNil:extendedRelation];
    NSArray<GPKGExtendedRelation *> *extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertTrue:[geoPackage isTable:mappingTableName]];
    
    // Build the Features ids
    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:baseTableName];
    GPKGResultSet *featureResultSet = [featureDao queryForAll];
    int featuresCount = featureResultSet.count;
    NSMutableArray<NSNumber *> *featureIds = [NSMutableArray array];
    while([featureResultSet moveToNext]){
        [featureIds addObject:[[featureDao row:featureResultSet] id]];
    }
    [featureResultSet close];
    
    // Build the Tile related ids
    GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:relatedTableName];
    GPKGResultSet *tileResultSet = [tileDao queryForAll];
    int tilesCount = tileResultSet.count;
    NSMutableArray<NSNumber *> *tileIds = [NSMutableArray array];
    while([tileResultSet moveToNext]){
        [tileIds addObject:[[tileDao row:tileResultSet] id]];
    }
    [tileResultSet close];
    
    // Insert user mapping rows between feature ids and tile ids
    GPKGUserMappingDao *dao = [rte mappingDaoForTableName:mappingTableName];
    GPKGUserMappingRow *userMappingRow = nil;
    for (int i = 0; i < 10; i++) {
        userMappingRow = [dao newRow];
        [userMappingRow setBaseId:[[featureIds objectAtIndex:[GPKGTestUtils randomIntLessThan:featuresCount]] intValue]];
        [userMappingRow setRelatedId:[[tileIds objectAtIndex:[GPKGTestUtils randomIntLessThan:tilesCount]] intValue]];
        [GPKGRelatedTablesUtils populateUserRowWithTable:userMappingTable andRow:userMappingRow andSkipColumns:[GPKGUserMappingTable requiredColumns]];
        [GPKGTestUtils assertTrue:[dao create:userMappingRow] > 0];
    }
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:[dao count]];
    
    // Validate the user mapping rows
    userMappingTable = [dao userMappingTable];
    NSArray<NSString *> *mappingColumns = [userMappingTable columnNames];
    GPKGResultSet *resultSet = [dao queryForAll];
    int count = resultSet.count;
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:count];
    int manualCount = 0;
    while([resultSet moveToNext]){
        
        GPKGUserMappingRow *resultRow = [dao row:resultSet];
        [GPKGTestUtils assertFalse:[resultRow hasId]];
        [GPKGTestUtils assertTrue:[featureIds containsObject:[NSNumber numberWithInt:resultRow.baseId]]];
        [GPKGTestUtils assertTrue:[tileIds containsObject:[NSNumber numberWithInt:resultRow.relatedId]]];
        [GPKGRelatedTablesUtils validateUserRow:resultRow withColumns:mappingColumns];
        [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:resultRow];
        
        manualCount++;
    }
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:manualCount];
    [resultSet close];
    
    GPKGExtendedRelationsDao *extendedRelationsDao = [rte extendedRelationsDao];
    
    // Get the relations starting from the features table
    GPKGResultSet *featuresExtendedRelations = [extendedRelationsDao relationsToBaseTable:featureDao.tableName];
    GPKGResultSet *featuresExtendedRelations2 = [extendedRelationsDao relationsToTable:featureDao.tableName];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:featuresExtendedRelations.count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:featuresExtendedRelations2.count];
    
    // Test the features table relations
    while([featuresExtendedRelations moveToNext]){
        
        GPKGExtendedRelation *featuresRelation = [extendedRelationsDao relation:featuresExtendedRelations];
        
        if(featuresExtendedRelations2 != nil){
            
            [featuresExtendedRelations2 moveToNext];
            GPKGExtendedRelation *featuresRelation2 = [extendedRelationsDao relation:featuresExtendedRelations2];
            
            [GPKGTestUtils assertEqualWithValue:featuresRelation.id andValue2:featuresRelation2.id];
            
            [featuresExtendedRelations2 close];
            featuresExtendedRelations2 = nil;
        }
        
        // Test the relation
        [GPKGTestUtils assertTrue:[featuresRelation.id intValue] >= 0];
        [GPKGTestUtils assertEqualWithValue:featureDao.tableName andValue2:featuresRelation.baseTableName];
        [GPKGTestUtils assertEqualWithValue:[featureDao pkColumnName] andValue2:featuresRelation.basePrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:tileDao.tableName andValue2:featuresRelation.relatedTableName];
        [GPKGTestUtils assertEqualWithValue:[tileDao pkColumnName] andValue2:featuresRelation.relatedPrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:GPKG_RT_TILES] andValue2:featuresRelation.relationName];
        [GPKGTestUtils assertEqualWithValue:mappingTableName andValue2:featuresRelation.mappingTableName];
        
        // Test the user mappings from the relation
        GPKGUserMappingDao *userMappingDao = [rte mappingDaoForRelation:featuresRelation];
        GPKGResultSet *mappingResultSet = [userMappingDao queryForAll];
        while([mappingResultSet moveToNext]){
            userMappingRow = [userMappingDao row:mappingResultSet];
            [GPKGTestUtils assertTrue:[featureIds containsObject:[NSNumber numberWithInt:userMappingRow.baseId]]];
            [GPKGTestUtils assertTrue:[tileIds containsObject:[NSNumber numberWithInt:userMappingRow.relatedId]]];
            [GPKGRelatedTablesUtils validateUserRow:userMappingRow withColumns:mappingColumns];
            [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:userMappingRow];
        }
        [mappingResultSet close];
        
    }
    [featuresExtendedRelations close];
    
    // Get the relations starting from the tiles table
    GPKGResultSet *relatedExtendedRelations = [extendedRelationsDao relationsToRelatedTable:relatedTableName];
    GPKGResultSet *extendedRelations2 = [extendedRelationsDao relationsToTable:relatedTableName];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:relatedExtendedRelations.count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:extendedRelations2.count];
    
    // Test the tiles table relations
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
        [GPKGTestUtils assertEqualWithValue:featureDao.tableName andValue2:relation.baseTableName];
        [GPKGTestUtils assertEqualWithValue:[featureDao pkColumnName] andValue2:relation.basePrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:tileDao.tableName andValue2:relation.relatedTableName];
        [GPKGTestUtils assertEqualWithValue:[tileDao pkColumnName] andValue2:relation.relatedPrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:GPKG_RT_TILES] andValue2:relation.relationName];
        [GPKGTestUtils assertEqualWithValue:mappingTableName andValue2:relation.mappingTableName];
        
        // Test the user mappings from the relation
        GPKGUserMappingDao *userMappingDao = [rte mappingDaoForRelation:relation];
        int totalMappedCount = userMappingDao.count;
        GPKGResultSet *mappingResultSet = [userMappingDao queryForAll];
        while([mappingResultSet moveToNext]){
            userMappingRow = [userMappingDao row:mappingResultSet];
            [GPKGTestUtils assertTrue:[featureIds containsObject:[NSNumber numberWithInt:userMappingRow.baseId]]];
            [GPKGTestUtils assertTrue:[tileIds containsObject:[NSNumber numberWithInt:userMappingRow.relatedId]]];
            [GPKGRelatedTablesUtils validateUserRow:userMappingRow withColumns:mappingColumns];
            [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:userMappingRow];
        }
        [mappingResultSet close];
        
        // Get and test the features DAO
        featureDao = [geoPackage featureDaoWithTableName:featureDao.tableName];
        [GPKGTestUtils assertNotNil:featureDao];
        GPKGFeatureTable *featureTable = [featureDao featureTable];
        [GPKGTestUtils assertNotNil:featureTable];
        GPKGContents *featuresContents = featureTable.contents;
        [GPKGTestUtils assertNotNil:featuresContents];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_CDT_FEATURES andValue2:[featuresContents contentsDataType]];
        [GPKGTestUtils assertEqualWithValue:[GPKGContentsDataTypes name:GPKG_CDT_FEATURES] andValue2:featuresContents.dataType];
        [GPKGTestUtils assertEqualWithValue:featureTable.tableName andValue2:featuresContents.tableName];
        [GPKGTestUtils assertNotNil:featuresContents.lastChange];
        
        // Get and test the Tile Rows mapped to each Feature Row
        tileResultSet = [tileDao queryForAll];
        int totalMapped = 0;
        while([tileResultSet moveToNext]){
            GPKGTileRow *tileRow = [tileDao row:tileResultSet];
            NSArray<NSNumber *> *mappedIds = [rte mappingsForRelation:relation withRelatedId:[tileRow idValue]];
            for(NSNumber *mappedId in mappedIds){
                GPKGFeatureRow *featureRow = (GPKGFeatureRow *)[featureDao queryForIdObject:mappedId];
                [GPKGTestUtils assertNotNil:featureRow];
                
                [GPKGTestUtils assertTrue:[featureRow hasId]];
                [GPKGTestUtils assertTrue:[featureRow idValue] >= 0];
                [GPKGTestUtils assertTrue:[featureIds containsObject:[featureRow id]]];
                [GPKGTestUtils assertTrue:[mappedIds containsObject:[featureRow id]]];
            }
            
            totalMapped += mappedIds.count;
        }
        [tileResultSet close];
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
