//
//  GPKGRelatedMediaUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedMediaUtils.h"
#import "GPKGMediaTable.h"
#import "GPKGTestUtils.h"
#import "GPKGMediaRow.h"
#import "GPKGRelatedTablesUtils.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGTestConstants.h"
#import "GPKGImageConverter.h"
#import "GPKGGeoPackageGeometryDataUtils.h"

@implementation GPKGRelatedMediaUtils

+(void) testMedia: (GPKGGeoPackage *) geoPackage{

    // Create a related tables extension
    GPKGRelatedTablesExtension *rte = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    
    if([rte has]){
        [rte removeExtension];
    }
    
    [GPKGTestUtils assertFalse:[rte has]];
    [GPKGTestUtils assertTrue:[rte relationships].count == 0];
    
    // Choose a random feature table
    NSArray<NSString *> *featureTables = [geoPackage featureTables];
    if(featureTables.count == 0){
        return; // pass with no testing
    }
    NSString *baseTableName = [featureTables objectAtIndex:(int)([GPKGTestUtils randomDouble] * featureTables.count)];
    
    // Populate and validate a media table
    NSArray<GPKGUserCustomColumn *> *additionalMediaColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    GPKGMediaTable *mediaTable = [GPKGMediaTable createWithMetadata:[GPKGMediaTableMetadata createWithTable:@"media_table" andAdditionalColumns:additionalMediaColumns]];
    NSArray<NSString *> *mediaColumns = mediaTable.columnNames;
    [GPKGTestUtils assertEqualIntWithValue:[GPKGMediaTable numRequiredColumns] + (int)additionalMediaColumns.count andValue2:(int)mediaTable.columns.count];
    GPKGUserCustomColumn *idColumn = [mediaTable idColumn];
    [GPKGTestUtils assertNotNil:idColumn];
    [GPKGTestUtils assertTrue:[idColumn isNamed:GPKG_UTM_DEFAULT_ID_COLUMN_NAME]];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_DT_INTEGER andValue2:idColumn.dataType];
    [GPKGTestUtils assertTrue:idColumn.notNull];
    [GPKGTestUtils assertTrue:idColumn.primaryKey];
    GPKGUserCustomColumn *dataColumn = [mediaTable dataColumn];
    [GPKGTestUtils assertNotNil:dataColumn];
    [GPKGTestUtils assertTrue:[dataColumn isNamed:GPKG_RMT_COLUMN_DATA]];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_DT_BLOB andValue2:dataColumn.dataType];
    [GPKGTestUtils assertTrue:dataColumn.notNull];
    [GPKGTestUtils assertFalse:dataColumn.primaryKey];
    GPKGUserCustomColumn *contentTypeColumn = [mediaTable contentTypeColumn];
    [GPKGTestUtils assertNotNil:contentTypeColumn];
    [GPKGTestUtils assertTrue:[contentTypeColumn isNamed:GPKG_RMT_COLUMN_CONTENT_TYPE]];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_DT_TEXT andValue2:contentTypeColumn.dataType];
    [GPKGTestUtils assertTrue:contentTypeColumn.notNull];
    [GPKGTestUtils assertFalse:contentTypeColumn.primaryKey];
    
    // Create and validate a mapping table
    NSArray<GPKGUserCustomColumn *> *additionalMappingColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    NSString *mappingTableName = @"features_media";
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
    
    // Create the media table, content row, and relationship between the
    // feature table and media table
    GPKGContentsDao *contentsDao = [geoPackage contentsDao];
    [GPKGTestUtils assertFalse:[[contentsDao tables] containsObject:mediaTable.tableName]];
    GPKGExtendedRelation *extendedRelation = [rte addMediaRelationshipWithBaseTable:baseTableName andMediaTable:mediaTable andUserMappingTable:userMappingTable];
    [self validateContents:mediaTable.contents withTable:mediaTable];
    [GPKGTestUtils assertTrue:[rte has]];
    [GPKGTestUtils assertTrue:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertNotNil:extendedRelation];
    NSArray<GPKGExtendedRelation *> *extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertTrue:[geoPackage isTable:mappingTableName]];
    [GPKGTestUtils assertTrue:[geoPackage isTable:mediaTable.tableName]];
    [GPKGTestUtils assertTrue:[[contentsDao tables] containsObject:mediaTable.tableName]];
    [self validateContents:(GPKGContents *)[contentsDao queryForIdObject:mediaTable.tableName] withTable:mediaTable];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes dataType:[GPKGMediaTable relationType]] andValue2:[geoPackage typeOfTable:mediaTable.tableName]];
    [GPKGTestUtils assertTrue:[geoPackage isTable:mediaTable.tableName ofTypeName:[GPKGRelationTypes dataType:[GPKGMediaTable relationType]]]];
    
    // Validate the media DAO
    GPKGMediaDao *mediaDao = [rte mediaDaoForTable:mediaTable];
    [GPKGTestUtils assertNotNil:mediaDao];
    mediaTable = [mediaDao mediaTable];
    [GPKGTestUtils assertNotNil:mediaTable];
    [self validateContents:mediaTable.contents withTable:mediaTable];

    // Insert media table rows
    NSString *mediaPath  = [[[NSBundle bundleForClass:[GPKGRelatedMediaUtils class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_TILE_FILE_NAME];
    NSData *mediaData = [[NSFileManager defaultManager] contentsAtPath:mediaPath];
    NSString *contentType = @"image/png";
    UIImage *mediaImage = [GPKGImageConverter toImage:mediaData];
    int imageWidth = mediaImage.size.width;
    int imageHeight = mediaImage.size.height;
    int mediaCount = 2 + [GPKGTestUtils randomIntLessThan:9];
    int mediaRowId = 0;
    // Create and insert the first mediaCount - 1 rows
    for (int i = 0; i < mediaCount - 1; i++) {
        GPKGMediaRow *mediaRow = [mediaDao newRow];
        [mediaRow setData:mediaData];
        [mediaRow setContentType:contentType];
        [GPKGRelatedTablesUtils populateUserRowWithTable:mediaTable andRow:mediaRow andSkipColumns:[GPKGMediaTable requiredColumns]];
        mediaRowId = (int)[mediaDao create:mediaRow];
        [GPKGTestUtils assertTrue:mediaRowId > 0];
    }
    // Copy the last row insert and insert the final media row
    GPKGMediaRow *mediaRowToCopy = (GPKGMediaRow *)[mediaDao queryForIdObject:[NSNumber numberWithInt:mediaRowId]];
    GPKGMediaRow *mediaRowCopy = [mediaRowToCopy mutableCopy];
    int copyMediaRowId = (int)[mediaDao create:mediaRowCopy];
    [GPKGTestUtils assertTrue:copyMediaRowId > 0];
    [GPKGTestUtils assertEqualIntWithValue:mediaRowId + 1 andValue2:copyMediaRowId];
    [GPKGTestUtils assertEqualIntWithValue:mediaCount andValue2:(int)mediaDao.count];
    
    // Build the Feature ids
    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:baseTableName];
    GPKGResultSet *featureResultSet = [featureDao queryForAll];
    int featureCount = featureResultSet.count;
    NSMutableArray<NSNumber *> *featureIds = [NSMutableArray array];
    while([featureResultSet moveToNext]){
        [featureIds addObject:[[featureDao featureRow:featureResultSet] id]];
    }
    [featureResultSet close];
    
    // Build the Media ids
    GPKGResultSet *mediaResultSet = [mediaDao queryForAll];
    mediaCount = mediaResultSet.count;
    NSMutableArray<NSNumber *> *mediaIds = [NSMutableArray array];
    while([mediaResultSet moveToNext]){
        [mediaIds addObject:[[mediaDao row:mediaResultSet] id]];
    }
    [mediaResultSet close];
    
    // Insert user mapping rows between feature ids and media ids
    GPKGUserMappingDao *dao = [rte mappingDaoForTableName:mappingTableName];
    GPKGUserMappingRow *userMappingRow = nil;
    for (int i = 0; i < 10; i++) {
        userMappingRow = [dao newRow];
        [userMappingRow setBaseId:[[featureIds objectAtIndex:(int)([GPKGTestUtils randomDouble] * featureCount)] intValue]];
        [userMappingRow setRelatedId:[[mediaIds objectAtIndex:(int)([GPKGTestUtils randomDouble] * mediaCount)] intValue]];
        [GPKGRelatedTablesUtils populateUserRowWithTable:userMappingTable andRow:userMappingRow andSkipColumns:[GPKGUserMappingTable requiredColumns]];
        [GPKGTestUtils assertTrue:[dao create:userMappingRow] > 0];
    }
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:[dao count]];
    
    // Validate the user mapping rows
    userMappingTable = [dao userMappingTable];
    NSArray<NSString *> *mappingColumns = userMappingTable.columnNames;
    GPKGResultSet *resultSet = [dao queryForAll];
    int count = resultSet.count;
    [GPKGTestUtils assertEqualIntWithValue:10 andValue2:count];
    int manualCount = 0;
    while([resultSet moveToNext]){
        
        GPKGUserMappingRow *resultRow = [dao row:resultSet];
        [GPKGTestUtils assertFalse:[resultRow hasId]];
        [GPKGTestUtils assertTrue:[featureIds containsObject:[NSNumber numberWithInt:[resultRow baseId]]]];
        [GPKGTestUtils assertTrue:[mediaIds containsObject:[NSNumber numberWithInt:[resultRow relatedId]]]];
        [GPKGRelatedTablesUtils validateUserRow:resultRow withColumns:mappingColumns];
        [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:resultRow];
        
        manualCount++;
    }
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:manualCount];
    [resultSet close];
    
    GPKGExtendedRelationsDao *extendedRelationsDao = [rte extendedRelationsDao];
    
    GPKGResultSet *featureExtendedRelations = [extendedRelationsDao relationsToBaseTable:featureDao.tableName];
    GPKGResultSet *featureExtendedRelations2 = [extendedRelationsDao relationsToTable:featureDao.tableName];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:featureExtendedRelations.count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:featureExtendedRelations2.count];
    GPKGExtendedRelation *extendedRelation1 = [extendedRelationsDao firstRelation:[extendedRelationsDao relationsToBaseTable:featureDao.tableName]];
    GPKGExtendedRelation *extendedRelation2 = [extendedRelationsDao firstRelation:featureExtendedRelations2];
    [GPKGTestUtils assertEqualWithValue:extendedRelation1.id andValue2:extendedRelation2.id];
    [featureExtendedRelations2 close];
    GPKGResultSet *featureExtendedRelations3 = [extendedRelationsDao relationsToRelatedTable:featureDao.tableName];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:featureExtendedRelations3.count];
    [featureExtendedRelations3 close];
    
    // Test the feature table relations
    while([featureExtendedRelations moveToNext]){
        GPKGExtendedRelation *featureRelation = [extendedRelationsDao relation:featureExtendedRelations];
        
        // Test the relation
        [GPKGTestUtils assertTrue:[featureRelation.id intValue] >= 0];
        [GPKGTestUtils assertEqualWithValue:featureDao.tableName andValue2:featureRelation.baseTableName];
        [GPKGTestUtils assertEqualWithValue:[featureDao.table pkColumnName] andValue2:featureRelation.basePrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:mediaDao.tableName andValue2:featureRelation.relatedTableName];
        [GPKGTestUtils assertEqualWithValue:[[mediaDao table] pkColumnName] andValue2:featureRelation.relatedPrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:[GPKGMediaTable relationType]] andValue2:featureRelation.relationName];
        [GPKGTestUtils assertEqualWithValue:mappingTableName andValue2:featureRelation.mappingTableName];
        
        // Test the user mappings from the relation
        GPKGUserMappingDao *userMappingDao = [rte mappingDaoForRelation:featureRelation];
        int totalMappedCount = userMappingDao.count;
        GPKGResultSet *mappingResultSet = [userMappingDao queryForAll];
        while([mappingResultSet moveToNext]){
            userMappingRow = [userMappingDao row:mappingResultSet];
            [GPKGTestUtils assertTrue:[featureIds containsObject:[NSNumber numberWithInt:userMappingRow.baseId]]];
            [GPKGTestUtils assertTrue:[mediaIds containsObject:[NSNumber numberWithInt:userMappingRow.relatedId]]];
            [GPKGRelatedTablesUtils validateUserRow:userMappingRow withColumns:mappingColumns];
            [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:userMappingRow];
        }
        [mappingResultSet close];
        
        // Get and test the media DAO
        mediaDao = [rte mediaDaoForRelation:featureRelation];
        [GPKGTestUtils assertNotNil:mediaDao];
        mediaTable = [mediaDao mediaTable];
        [GPKGTestUtils assertNotNil:mediaTable];
        [self validateContents:mediaTable.contents withTable:mediaTable];
        
        // Get and test the Media Rows mapped to each Feature Row
        featureResultSet = [featureDao queryForAll];
        int totalMapped = 0;
        while([featureResultSet moveToNext]){
            GPKGFeatureRow *featureRow = [featureDao featureRow:featureResultSet];
            NSArray<NSNumber *> *mappedIds = [rte mappingsForRelation:featureRelation withBaseId:[featureRow idValue]];
            NSArray<GPKGMediaRow *> *mediaRows = [mediaDao rowsWithIds:mappedIds];
            [GPKGTestUtils assertEqualIntWithValue:(int)mappedIds.count andValue2:(int)mediaRows.count];
            
            for(GPKGMediaRow *mediaRow in mediaRows){
                [GPKGTestUtils assertTrue:[mediaRow hasId]];
                [GPKGTestUtils assertTrue:[mediaRow idValue] >= 0];
                [GPKGTestUtils assertTrue:[mediaIds containsObject:[mediaRow id]]];
                [GPKGTestUtils assertTrue:[mappedIds containsObject:[mediaRow id]]];
                [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:mediaData andActual:[mediaRow data]];
                [GPKGTestUtils assertEqualWithValue:contentType andValue2:[mediaRow contentType]];
                [GPKGRelatedTablesUtils validateUserRow:mediaRow withColumns:mediaColumns];
                [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:mediaRow];
                [self validateDublinCoreColumnsInRow:mediaRow];
                UIImage *image = [mediaRow dataImage];
                [GPKGTestUtils assertNotNil:image];
                [GPKGTestUtils assertEqualIntWithValue:imageWidth andValue2:image.size.width];
                [GPKGTestUtils assertEqualIntWithValue:imageHeight andValue2:image.size.height];
            }
            
            totalMapped += mappedIds.count;
        }
        [featureResultSet close];
        [GPKGTestUtils assertEqualIntWithValue:totalMappedCount andValue2:totalMapped];
    }
    [featureExtendedRelations close];
    
    // Get the relations starting from the media table
    GPKGResultSet *mediaExtendedRelations = [extendedRelationsDao relationsToRelatedTable:mediaTable.tableName];
    GPKGResultSet *mediaExtendedRelations2 = [extendedRelationsDao relationsToTable:mediaTable.tableName];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:mediaExtendedRelations.count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:mediaExtendedRelations2.count];
    extendedRelation1 = [extendedRelationsDao firstRelation:[extendedRelationsDao relationsToRelatedTable:mediaTable.tableName]];
    extendedRelation2 = [extendedRelationsDao firstRelation:mediaExtendedRelations2];
    [GPKGTestUtils assertEqualWithValue:extendedRelation1.id andValue2:extendedRelation2.id];
    [mediaExtendedRelations2 close];
    GPKGResultSet *mediaExtendedRelations3 = [extendedRelationsDao relationsToBaseTable:mediaTable.tableName];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:mediaExtendedRelations3.count];
    [mediaExtendedRelations3 close];
    
    // Test the media table relations
    while([mediaExtendedRelations moveToNext]){
        GPKGExtendedRelation *mediaRelation = [extendedRelationsDao relation:mediaExtendedRelations];
        
        // Test the relation
        [GPKGTestUtils assertTrue:[mediaRelation.id intValue] >= 0];
        [GPKGTestUtils assertEqualWithValue:featureDao.tableName andValue2:mediaRelation.baseTableName];
        [GPKGTestUtils assertEqualWithValue:[featureDao.table pkColumnName] andValue2:mediaRelation.basePrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:mediaDao.tableName andValue2:mediaRelation.relatedTableName];
        [GPKGTestUtils assertEqualWithValue:[[mediaDao table] pkColumnName] andValue2:mediaRelation.relatedPrimaryColumn];
        [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:[GPKGMediaTable relationType]] andValue2:mediaRelation.relationName];
        [GPKGTestUtils assertEqualWithValue:mappingTableName andValue2:mediaRelation.mappingTableName];
        
        // Test the user mappings from the relation
        GPKGUserMappingDao *userMappingDao = [rte mappingDaoForRelation:mediaRelation];
        int totalMappedCount = userMappingDao.count;
        GPKGResultSet *mappingResultSet = [userMappingDao queryForAll];
        while([mappingResultSet moveToNext]){
            userMappingRow = [userMappingDao row:mappingResultSet];
            [GPKGTestUtils assertTrue:[featureIds containsObject:[NSNumber numberWithInt:userMappingRow.baseId]]];
            [GPKGTestUtils assertTrue:[mediaIds containsObject:[NSNumber numberWithInt:userMappingRow.relatedId]]];
            [GPKGRelatedTablesUtils validateUserRow:userMappingRow withColumns:mappingColumns];
            [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:userMappingRow];
        }
        [mappingResultSet close];
        
        // Get and test the feature DAO
        featureDao = [geoPackage featureDaoWithTableName:featureDao.tableName];
        [GPKGTestUtils assertNotNil: featureDao];
        GPKGFeatureTable *featureTable = [featureDao featureTable];
        [GPKGTestUtils assertNotNil: featureTable];
        GPKGContents *featureContents = [featureDao contents];
        [GPKGTestUtils assertNotNil: featureContents];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_CDT_FEATURES andValue2:[featureContents contentsDataType]];
        [GPKGTestUtils assertEqualWithValue:[GPKGContentsDataTypes name:GPKG_CDT_FEATURES] andValue2:featureContents.dataType];
        [GPKGTestUtils assertEqualWithValue:featureTable.tableName andValue2:featureContents.tableName];
        [GPKGTestUtils assertNotNil:featureContents.lastChange];
        
        // Get and test the Feature Rows mapped to each Media Row
        mediaResultSet = [mediaDao queryForAll];
        int totalMapped = 0;
        while([mediaResultSet moveToNext]){
            GPKGMediaRow *mediaRow = [mediaDao row:mediaResultSet];
            NSArray<NSNumber *> *mappedIds = [rte mappingsForRelation:mediaRelation withRelatedId:[mediaRow idValue]];
            for(NSNumber *mappedId in mappedIds){
                GPKGFeatureRow *featureRow = (GPKGFeatureRow *)[featureDao queryForIdObject:mappedId];
                [GPKGTestUtils assertNotNil:featureRow];
                
                [GPKGTestUtils assertTrue:[featureRow hasId]];
                [GPKGTestUtils assertTrue:[featureRow idValue] >= 0];
                [GPKGTestUtils assertTrue:[featureIds containsObject:[featureRow id]]];
                [GPKGTestUtils assertTrue:[mappedIds containsObject:[featureRow id]]];
                if([featureRow valueWithIndex:[featureRow geometryColumnIndex]] != nil){
                    GPKGGeometryData *geometryData = [featureRow geometry];
                    [GPKGTestUtils assertNotNil:geometryData];
                    if(!geometryData.empty){
                        [GPKGTestUtils assertNotNil:geometryData.geometry];
                    }
                }
            }
            
            totalMapped += mappedIds.count;
        }
        [mediaResultSet close];
        [GPKGTestUtils assertEqualIntWithValue:totalMappedCount andValue2:totalMapped];
    }
    [mediaExtendedRelations close];
    
    // Add more columns to the media table
    int existingColumns = (int)[mediaTable columns].count;
    GPKGUserCustomColumn *mediaIdColumn = [mediaTable idColumn];
    GPKGUserCustomColumn *mediaDataColumn = [mediaTable dataColumn];
    GPKGUserCustomColumn *mediaContentTypeColumn = [mediaTable contentTypeColumn];
    int newColumns = 0;
    NSString *newColumnName = @"new_column";
    [mediaDao addColumn:[GPKGUserCustomColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_TEXT]];
    [mediaDao addColumn:[GPKGUserCustomColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", newColumnName, ++newColumns] andDataType:GPKG_DT_BLOB]];
    [GPKGTestUtils assertEqualIntWithValue:existingColumns + 2 andValue2:(int)[mediaTable columns].count];
    for (int index = existingColumns; index < [mediaTable columns].count; index++) {
        NSString *name = [NSString stringWithFormat:@"%@%d", newColumnName, index - existingColumns + 1];
        [GPKGTestUtils assertEqualWithValue:name andValue2:[mediaTable columnNameWithIndex:index]];
        [GPKGTestUtils assertEqualIntWithValue:index andValue2:[mediaTable columnIndexWithColumnName:name]];
        [GPKGTestUtils assertEqualWithValue:name andValue2:[mediaTable columnWithIndex:index].name];
        [GPKGTestUtils assertEqualIntWithValue:index andValue2:[mediaTable columnWithIndex:index].index];
        [GPKGTestUtils assertEqualWithValue:name andValue2:[mediaTable.columnNames objectAtIndex:index]];
        [GPKGTestUtils assertEqualWithValue:name andValue2:[mediaTable.columns objectAtIndex:index].name];
        @try {
            [[mediaTable columnWithIndex:index] setIndex:index - 1];
            [GPKGTestUtils fail:@"Changed index on a created table column"];
        } @catch (NSException *exception) {
        }
        [[mediaTable columnWithIndex:index] setIndex:index];
    }
    [GPKGTestUtils assertEqualWithValue:mediaIdColumn andValue2:[mediaTable idColumn]];
    [GPKGTestUtils assertEqualWithValue:mediaDataColumn andValue2:[mediaTable dataColumn]];
    [GPKGTestUtils assertEqualWithValue:mediaContentTypeColumn andValue2:[mediaTable contentTypeColumn]];
    
    // Add another row with the new columns and read it
    GPKGMediaRow *mediaRow = [mediaDao newRow];
    [mediaRow setData:mediaData];
    [mediaRow setContentType:contentType];
    [GPKGRelatedTablesUtils populateUserRowWithTable:mediaTable andRow:mediaRow andSkipColumns:[GPKGMediaTable requiredColumns]];
    NSString *newValue = [[NSProcessInfo processInfo] globallyUniqueString];
    [mediaRow setValueWithIndex:existingColumns andValue:newValue];
    [mediaRow setValueWithIndex:existingColumns + 1 andValue:[mediaRow data]];
    mediaRowId = (int)[mediaDao create:mediaRow];
    [GPKGTestUtils assertTrue:mediaRowId > 0];
    GPKGMediaRow *newMediaRow = (GPKGMediaRow *)[mediaDao queryForIdObject:[NSNumber numberWithInt:mediaRowId]];
    [GPKGTestUtils assertNotNil:newMediaRow];
    [GPKGTestUtils assertEqualWithValue:newValue andValue2:[newMediaRow valueWithIndex:existingColumns]];
    [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:[mediaRow data] andActual:(NSData *)[newMediaRow valueWithIndex:existingColumns + 1]];
    
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
    
    // Delete the media table and contents row
    [GPKGTestUtils assertTrue:[geoPackage isTable:mediaTable.tableName]];
    [GPKGTestUtils assertNotNil:[contentsDao queryForIdObject:mediaTable.tableName]];
    [geoPackage deleteTable:mediaTable.tableName];
    [GPKGTestUtils assertFalse:[geoPackage isTable:mediaTable.tableName]];
    [GPKGTestUtils assertNil:[contentsDao queryForIdObject:mediaTable.tableName]];
    
    // Delete the related tables extension
    [rte removeExtension];
    [GPKGTestUtils assertFalse:[rte has]];
    
}

/**
 * Validate contents
 *
 * @param contents
 *            contents
 * @param mediaTable
 *            media table
 */
+(void) validateContents: (GPKGContents *) contents withTable: (GPKGMediaTable *) mediaTable{
    [GPKGTestUtils assertNotNil:contents];
    [GPKGTestUtils assertTrue:(int)[contents contentsDataType] >= 0];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes dataType:[GPKGMediaTable relationType]] andValue2:[GPKGContentsDataTypes name:[contents contentsDataType]]];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes dataType:[GPKGMediaTable relationType]] andValue2:contents.dataType];
    [GPKGTestUtils assertEqualWithValue:mediaTable.tableName andValue2:contents.tableName];
    [GPKGTestUtils assertNotNil:contents.lastChange];
}

/**
 * Validate a media row for expected Dublin Core Columns
 *
 * @param mediaRow
 *            media row
 */
+(void) validateDublinCoreColumnsInRow: (GPKGMediaRow *) mediaRow{
    
    [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:mediaRow andType:GPKG_DCM_IDENTIFIER];
    [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:mediaRow andType:GPKG_DCM_FORMAT];
    
}

@end
