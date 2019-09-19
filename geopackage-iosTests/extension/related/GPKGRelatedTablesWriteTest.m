//
//  GPKGRelatedTablesWriteTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedTablesWriteTest.h"
#import "GPKGTestConstants.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGTestUtils.h"
#import "GPKGRelatedTablesUtils.h"

@implementation GPKGRelatedTablesWriteTest

- (void)setUp {
    self.dbName = GPKG_TEST_IMPORT_DB_NAME;
    self.file = GPKG_TEST_IMPORT_DB_FILE_NAME;
    [super setUp];
}

/**
 *  Test write relationships
 */
-(void) testWriteRelationships{
    
    GPKGRelatedTablesExtension *rte = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:self.geoPackage];
    
    if([rte has]){
        [rte removeExtension];
    }
    
    // 1. Has extension
    [GPKGTestUtils assertFalse:[rte has]];
    
    // 4. Get relationships
    NSArray<GPKGExtendedRelation *> *extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)extendedRelations.count];
    
    // 2. Add extension
    // 5. Add relationship between "geometry2d" and "geometry3d"
    NSString *baseTableName = @"geometry1";
    NSString *relatedTableName = @"geometry2";
    NSString *mappingTableName = @"g1_g2";
    
    NSArray<GPKGUserCustomColumn *> *additionalColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    
    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:mappingTableName andAdditionalColumns:additionalColumns];
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertEqualIntWithValue:[GPKGUserMappingTable numRequiredColumns] + (int)additionalColumns.count andValue2:(int)userMappingTable.columns.count];
    GPKGUserCustomColumn *baseIdColumn = userMappingTable.baseIdColumn;
    [GPKGTestUtils assertNotNil:baseIdColumn];
    [GPKGTestUtils assertTrue:[baseIdColumn isNamed:GPKG_UMT_COLUMN_BASE_ID]];
    [GPKGTestUtils assertTrue:baseIdColumn.notNull];
    [GPKGTestUtils assertFalse:baseIdColumn.primaryKey];
    GPKGUserCustomColumn *relatedIdColumn = userMappingTable.relatedIdColumn;
    [GPKGTestUtils assertNotNil:relatedIdColumn];
    [GPKGTestUtils assertTrue:[relatedIdColumn isNamed:GPKG_UMT_COLUMN_RELATED_ID]];
    [GPKGTestUtils assertTrue:relatedIdColumn.notNull];
    [GPKGTestUtils assertFalse:relatedIdColumn.primaryKey];
    
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    GPKGExtendedRelation *extendedRelation = [rte addFeaturesRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andUserMappingTable:userMappingTable];
    [GPKGTestUtils assertTrue:[rte has]];
    [GPKGTestUtils assertTrue:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertNotNil:extendedRelation];
    extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertTrue:[self.geoPackage isTable:mappingTableName]];
    
    // 7. Add mappings
    GPKGFeatureDao *baseDao = [self.geoPackage getFeatureDaoWithTableName:baseTableName];
    GPKGFeatureDao *relatedDao = [self.geoPackage getFeatureDaoWithTableName:relatedTableName];
    GPKGResultSet *baseFrs = [baseDao queryForAll];
    int baseCount = baseFrs.count;
    NSMutableArray<NSNumber *> *baseIds = [[NSMutableArray alloc] init];
    while([baseFrs moveToNext]){
        [baseIds addObject:[[baseDao getFeatureRow:baseFrs] getId]];
    }
    [baseFrs close];
    GPKGResultSet *relatedFrs = [relatedDao queryForAll];
    int relatedCount = relatedFrs.count;
    NSMutableArray<NSNumber *> *relatedIds = [[NSMutableArray alloc] init];
    while([relatedFrs moveToNext]){
        [relatedIds addObject:[[relatedDao getFeatureRow:relatedFrs] getId]];
    }
    [relatedFrs close];
    GPKGUserMappingDao *dao = [rte mappingDaoForTableName:mappingTableName];
    GPKGUserMappingRow *userMappingRow = nil;
    for(int i = 0; i < 10; i++){
        userMappingRow = [dao newRow];
        [userMappingRow setBaseId:[[baseIds objectAtIndex:[GPKGTestUtils randomIntLessThan:baseCount]] intValue]];
        [userMappingRow setRelatedId:[[relatedIds objectAtIndex:[GPKGTestUtils randomIntLessThan:relatedCount]] intValue]];
        [GPKGRelatedTablesUtils populateUserRowWithTable:userMappingTable andRow:userMappingRow andSkipColumns:[GPKGUserMappingTable requiredColumns]];
        [GPKGTestUtils assertTrue:[dao create:userMappingRow] > 0];
    }
    
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:dao.count];
    
    userMappingTable = [dao table];
    NSArray *columns = userMappingTable.columnNames;
    GPKGResultSet *resultSet = [dao queryForAll];
    int count = resultSet.count;
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:count];
    int manualCount = 0;
    while([resultSet moveToNext]){
        
        GPKGUserMappingRow *resultRow = [dao row:resultSet];
        [GPKGTestUtils assertFalse:[resultRow hasId]];
        [GPKGRelatedTablesUtils validateUserRow:resultRow withColumns:columns];
        [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:resultRow];
        
        manualCount++;
    }
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:manualCount];
    [resultSet close];
    
    // 8. Remove mappings (note: it is plausible and allowed
    // to have duplicate entries)
    [GPKGTestUtils assertTrue:[dao deleteByIdsFromRow:userMappingRow] > 0];
    
    // 6. Remove relationship
    [rte removeRelationship:extendedRelation];
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertFalse:[self.geoPackage isTable:mappingTableName]];
    
    // 3. Remove extension
    [rte removeExtension];
    [GPKGTestUtils assertFalse:[rte has]];

}

/**
 * Test write relationships to attributes
 */
-(void) testWriteRelationshipsToAttributes{
    
    GPKGRelatedTablesExtension *rte = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:self.geoPackage];
    
    if([rte has]){
        [rte removeExtension];
    }
    
    // 1. Has extension
    [GPKGTestUtils assertFalse:[rte has]];
    
    // 4. Get relationships
    NSArray<GPKGExtendedRelation *> *extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)extendedRelations.count];
    
    // 2. Add extension
    // 5. Add relationship between "geometry2d" and "attributes"
    NSString *baseTableName = @"geometry1";
    NSString *relatedTableName = @"attributes";
    NSString *mappingTableName = @"g1_a";
    
    NSArray<GPKGUserCustomColumn *> *additionalColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    
    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:mappingTableName andAdditionalColumns:additionalColumns];
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertEqualIntWithValue:[GPKGUserMappingTable numRequiredColumns] + (int)additionalColumns.count andValue2:(int)userMappingTable.columns.count];
    GPKGUserCustomColumn *baseIdColumn = userMappingTable.baseIdColumn;
    [GPKGTestUtils assertNotNil:baseIdColumn];
    [GPKGTestUtils assertTrue:[baseIdColumn isNamed:GPKG_UMT_COLUMN_BASE_ID]];
    [GPKGTestUtils assertTrue:baseIdColumn.notNull];
    [GPKGTestUtils assertFalse:baseIdColumn.primaryKey];
    GPKGUserCustomColumn *relatedIdColumn = userMappingTable.relatedIdColumn;
    [GPKGTestUtils assertNotNil:relatedIdColumn];
    [GPKGTestUtils assertTrue:[relatedIdColumn isNamed:GPKG_UMT_COLUMN_RELATED_ID]];
    [GPKGTestUtils assertTrue:relatedIdColumn.notNull];
    [GPKGTestUtils assertFalse:relatedIdColumn.primaryKey];
    
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    GPKGExtendedRelation *extendedRelation = [rte addAttributesRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andUserMappingTable:userMappingTable];
    [GPKGTestUtils assertTrue:[rte has]];
    [GPKGTestUtils assertTrue:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertNotNil:extendedRelation];
    extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertTrue:[self.geoPackage isTable:mappingTableName]];
    
    // 7. Add mappings
    GPKGFeatureDao *baseDao = [self.geoPackage getFeatureDaoWithTableName:baseTableName];
    GPKGAttributesDao *relatedDao = [self.geoPackage getAttributesDaoWithTableName:relatedTableName];
    GPKGResultSet *baseFrs = [baseDao queryForAll];
    int baseCount = baseFrs.count;
    NSMutableArray<NSNumber *> *baseIds = [[NSMutableArray alloc] init];
    while([baseFrs moveToNext]){
        [baseIds addObject:[[baseDao getFeatureRow:baseFrs] getId]];
    }
    [baseFrs close];
    GPKGResultSet *relatedArs = [relatedDao queryForAll];
    int relatedCount = relatedArs.count;
    NSMutableArray<NSNumber *> *relatedIds = [[NSMutableArray alloc] init];
    while([relatedArs moveToNext]){
        [relatedIds addObject:[[relatedDao getAttributesRow:relatedArs] getId]];
    }
    [relatedArs close];
    GPKGUserMappingDao *dao = [rte mappingDaoForTableName:mappingTableName];
    GPKGUserMappingRow *userMappingRow = nil;
    for(int i = 0; i < 10; i++){
        userMappingRow = [dao newRow];
        [userMappingRow setBaseId:[[baseIds objectAtIndex:[GPKGTestUtils randomIntLessThan:baseCount]] intValue]];
        [userMappingRow setRelatedId:[[relatedIds objectAtIndex:[GPKGTestUtils randomIntLessThan:relatedCount]] intValue]];
        [GPKGRelatedTablesUtils populateUserRowWithTable:userMappingTable andRow:userMappingRow andSkipColumns:[GPKGUserMappingTable requiredColumns]];
        [GPKGTestUtils assertTrue:[dao create:userMappingRow] > 0];
    }
    
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:dao.count];
    
    userMappingTable = [dao table];
    NSArray *columns = userMappingTable.columnNames;
    GPKGResultSet *resultSet = [dao queryForAll];
    int count = resultSet.count;
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:count];
    int manualCount = 0;
    while([resultSet moveToNext]){
        
        GPKGUserMappingRow *resultRow = [dao row:resultSet];
        [GPKGTestUtils assertFalse:[resultRow hasId]];
        [GPKGRelatedTablesUtils validateUserRow:resultRow withColumns:columns];
        [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:resultRow];
        
        manualCount++;
    }
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:manualCount];
    [resultSet close];
    
    // 8. Remove mappings (note: it is plausible and allowed
    // to have duplicate entries)
    [GPKGTestUtils assertTrue:[dao deleteByIdsFromRow:userMappingRow] > 0];
    
    // 6. Remove relationship
    [rte removeRelationship:extendedRelation];
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertFalse:[self.geoPackage isTable:mappingTableName]];
    
    // 3. Remove extension
    [rte removeExtension];
    [GPKGTestUtils assertFalse:[rte has]];

}

/**
 * Test write relationships to tiles
 */
-(void) testWriteRelationshipsToTiles{
    
    GPKGRelatedTablesExtension *rte = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:self.geoPackage];
    
    if([rte has]){
        [rte removeExtension];
    }
    
    // 1. Has extension
    [GPKGTestUtils assertFalse:[rte has]];
    
    // 4. Get relationships
    NSArray<GPKGExtendedRelation *> *extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)extendedRelations.count];
    
    // 2. Add extension
    // 5. Add relationship between "geometry2d" and "geometry1_tiles"
    NSString *baseTableName = @"geometry1";
    NSString *relatedTableName = @"geometry1_tiles";
    NSString *mappingTableName = @"g1_g1t";
    
    NSArray<GPKGUserCustomColumn *> *additionalColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    
    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:mappingTableName andAdditionalColumns:additionalColumns];
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertEqualIntWithValue:[GPKGUserMappingTable numRequiredColumns] + (int)additionalColumns.count andValue2:(int)userMappingTable.columns.count];
    GPKGUserCustomColumn *baseIdColumn = userMappingTable.baseIdColumn;
    [GPKGTestUtils assertNotNil:baseIdColumn];
    [GPKGTestUtils assertTrue:[baseIdColumn isNamed:GPKG_UMT_COLUMN_BASE_ID]];
    [GPKGTestUtils assertTrue:baseIdColumn.notNull];
    [GPKGTestUtils assertFalse:baseIdColumn.primaryKey];
    GPKGUserCustomColumn *relatedIdColumn = userMappingTable.relatedIdColumn;
    [GPKGTestUtils assertNotNil:relatedIdColumn];
    [GPKGTestUtils assertTrue:[relatedIdColumn isNamed:GPKG_UMT_COLUMN_RELATED_ID]];
    [GPKGTestUtils assertTrue:relatedIdColumn.notNull];
    [GPKGTestUtils assertFalse:relatedIdColumn.primaryKey];
    
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    GPKGExtendedRelation *extendedRelation = [rte addTilesRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andUserMappingTable:userMappingTable];
    [GPKGTestUtils assertTrue:[rte has]];
    [GPKGTestUtils assertTrue:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertNotNil:extendedRelation];
    extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertTrue:[self.geoPackage isTable:mappingTableName]];
    
    // 7. Add mappings
    GPKGFeatureDao *baseDao = [self.geoPackage getFeatureDaoWithTableName:baseTableName];
    GPKGTileDao *relatedDao = [self.geoPackage getTileDaoWithTableName:relatedTableName];
    GPKGResultSet *baseFrs = [baseDao queryForAll];
    int baseCount = baseFrs.count;
    NSMutableArray<NSNumber *> *baseIds = [[NSMutableArray alloc] init];
    while([baseFrs moveToNext]){
        [baseIds addObject:[[baseDao getFeatureRow:baseFrs] getId]];
    }
    [baseFrs close];
    GPKGResultSet *relatedTrs = [relatedDao queryForAll];
    int relatedCount = relatedTrs.count;
    NSMutableArray<NSNumber *> *relatedIds = [[NSMutableArray alloc] init];
    while([relatedTrs moveToNext]){
        [relatedIds addObject:[[relatedDao getTileRow:relatedTrs] getId]];
    }
    [relatedTrs close];
    GPKGUserMappingDao *dao = [rte mappingDaoForTableName:mappingTableName];
    GPKGUserMappingRow *userMappingRow = nil;
    for(int i = 0; i < 10; i++){
        userMappingRow = [dao newRow];
        [userMappingRow setBaseId:[[baseIds objectAtIndex:[GPKGTestUtils randomIntLessThan:baseCount]] intValue]];
        [userMappingRow setRelatedId:[[relatedIds objectAtIndex:[GPKGTestUtils randomIntLessThan:relatedCount]] intValue]];
        [GPKGRelatedTablesUtils populateUserRowWithTable:userMappingTable andRow:userMappingRow andSkipColumns:[GPKGUserMappingTable requiredColumns]];
        [GPKGTestUtils assertTrue:[dao create:userMappingRow] > 0];
    }
    
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:dao.count];
    
    userMappingTable = [dao table];
    NSArray *columns = userMappingTable.columnNames;
    GPKGResultSet *resultSet = [dao queryForAll];
    int count = resultSet.count;
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:count];
    int manualCount = 0;
    while([resultSet moveToNext]){
        
        GPKGUserMappingRow *resultRow = [dao row:resultSet];
        [GPKGTestUtils assertFalse:[resultRow hasId]];
        [GPKGRelatedTablesUtils validateUserRow:resultRow withColumns:columns];
        [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:resultRow];
        
        manualCount++;
    }
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:manualCount];
    [resultSet close];
    
    // 8. Remove mappings (note: it is plausible and allowed
    // to have duplicate entries)
    [GPKGTestUtils assertTrue:[dao deleteByIdsFromRow:userMappingRow] > 0];
    
    // 6. Remove relationship
    [rte removeRelationship:extendedRelation];
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertFalse:[self.geoPackage isTable:mappingTableName]];
    
    // 3. Remove extension
    [rte removeExtension];
    [GPKGTestUtils assertFalse:[rte has]];
    
}

@end
