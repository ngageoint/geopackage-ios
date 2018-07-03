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

@implementation GPKGRelatedMediaUtils

+(void) testMedia: (GPKGGeoPackage *) geoPackage{

    // Create a related tables extension
    GPKGRelatedTablesExtension *rte = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    [GPKGTestUtils assertFalse:[rte has]];
    [GPKGTestUtils assertTrue:[rte relationships].count == 0];
    
    // Choose a random feature table
    NSArray<NSString *> *featureTables = [geoPackage getFeatureTables];
    if(featureTables.count == 0){
        return; // pass with no testing
    }
    NSString *baseTableName = [featureTables objectAtIndex:(int)([GPKGTestUtils randomDouble] * featureTables.count)];
    
    // Populate and validate a media table
    NSArray<GPKGUserCustomColumn *> *additionalMediaColumns = [GPKGRelatedTablesUtils createAdditionalUserColumnsAtIndex:[GPKGMediaTable numRequiredColumns]];
    GPKGMediaTable *mediaTable = [GPKGMediaTable createWithName:@"media_table" andAdditionalColumns:additionalMediaColumns];
    NSArray<NSString *> *mediaColumns = mediaTable.columnNames;
    [GPKGTestUtils assertEqualIntWithValue:[GPKGMediaTable numRequiredColumns] + (int)additionalMediaColumns.count andValue2:(int)mediaTable.columns.count];
    GPKGUserCustomColumn *idColumn = [mediaTable idColumn];
    [GPKGTestUtils assertNotNil:idColumn];
    [GPKGTestUtils assertTrue:[idColumn isNamed:GPKG_RMT_COLUMN_ID]];
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
    NSArray<GPKGUserCustomColumn *> *additionalMappingColumns = [GPKGRelatedTablesUtils createAdditionalUserColumnsAtIndex:[GPKGUserMappingTable numRequiredColumns]];
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
    GPKGContentsDao *contentsDao = [geoPackage getContentsDao];
    [GPKGTestUtils assertFalse:[[contentsDao getTables] containsObject:mediaTable.tableName]];
    GPKGExtendedRelation *extendedRelation = [rte addMediaRelationshipWithBaseTable:baseTableName andMediaTable:mediaTable andUserMappingTable:userMappingTable];
    [self validateContents:mediaTable.contents withTable:mediaTable];
    [GPKGTestUtils assertTrue:[rte has]];
    [GPKGTestUtils assertTrue:[rte hasWithMappingTable:userMappingTable.tableName]];
    [GPKGTestUtils assertNotNil:extendedRelation];
    NSArray<GPKGExtendedRelation *> *extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertTrue:[geoPackage.database tableExists:mappingTableName]];
    [GPKGTestUtils assertTrue:[geoPackage.database tableExists:mediaTable.tableName]];
    [GPKGTestUtils assertTrue:[[contentsDao getTables] containsObject:mediaTable.tableName]];
    [self validateContents:(GPKGContents *)[contentsDao queryForIdObject:mediaTable.tableName] withTable:mediaTable];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:[GPKGMediaTable relationType]] andValue2:[geoPackage typeOfTable:mediaTable.tableName]];
    [GPKGTestUtils assertTrue:[geoPackage isTable:mediaTable.tableName ofTypeName:[GPKGRelationTypes name:[GPKGMediaTable relationType]]]];
    
    // Validate the media DAO
    GPKGMediaDao *mediaDao = [rte mediaDaoForTable:mediaTable];
    [GPKGTestUtils assertNotNil:mediaDao];
    mediaTable = [mediaDao table];
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
    GPKGMediaRow *mediaRowToCopy = [[GPKGMediaRow alloc] initWithUserCustomRow:(GPKGMediaRow *)[mediaDao queryForIdObject:[NSNumber numberWithInt:mediaRowId]]];
    GPKGMediaRow *mediaRowCopy = [mediaRowToCopy mutableCopy];
    int copyMediaRowId = (int)[mediaDao create:mediaRowCopy];
    [GPKGTestUtils assertTrue:copyMediaRowId > 0];
    [GPKGTestUtils assertEqualIntWithValue:mediaRowId + 1 andValue2:copyMediaRowId];
    [GPKGTestUtils assertEqualIntWithValue:mediaCount andValue2:(int)mediaDao.count];
    
    // Build the Feature ids
    GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:baseTableName];
    GPKGResultSet *featureResultSet = [featureDao queryForAll];
    int featureCount = featureResultSet.count;
    NSMutableArray<NSNumber *> *featureIds = [[NSMutableArray alloc] init];
    while([featureResultSet moveToNext]){
        [featureIds addObject:[[featureDao getFeatureRow:featureResultSet] getId]];
    }
    [featureResultSet close];
    
    // Build the Media ids
    GPKGResultSet *mediaResultSet = [mediaDao queryForAll];
    mediaCount = mediaResultSet.count;
    NSMutableArray<NSNumber *> *mediaIds = [[NSMutableArray alloc] init];
    while([mediaResultSet moveToNext]){
        [mediaIds addObject:[NSNumber numberWithInt:[[mediaDao row:mediaResultSet] id]]];
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
    userMappingTable = [dao table];
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
    
    GPKGExtendedRelationsDao *extendedRelationsDao = [rte getExtendedRelationsDao];
    
     /*
    
    // Get the relations starting from the feature table
    List<ExtendedRelation> featureExtendedRelations = extendedRelationsDao
    .getBaseTableRelations(featureDao.getTableName());
    List<ExtendedRelation> featureExtendedRelations2 = extendedRelationsDao
    .getTableRelations(featureDao.getTableName());
    TestCase.assertEquals(1, featureExtendedRelations.size());
    TestCase.assertEquals(1, featureExtendedRelations2.size());
    TestCase.assertEquals(featureExtendedRelations.get(0).getId(),
                          featureExtendedRelations2.get(0).getId());
    TestCase.assertTrue(extendedRelationsDao.getRelatedTableRelations(
                                                                      featureDao.getTableName()).isEmpty());
    
    // Test the feature table relations
    for (ExtendedRelation featureRelation : featureExtendedRelations) {
        
        // Test the relation
        TestCase.assertTrue(featureRelation.getId() >= 0);
        TestCase.assertEquals(featureDao.getTableName(),
                              featureRelation.getBaseTableName());
        TestCase.assertEquals(
                              featureDao.getTable().getPkColumn().getName(),
                              featureRelation.getBasePrimaryColumn());
        TestCase.assertEquals(mediaDao.getTableName(),
                              featureRelation.getRelatedTableName());
        TestCase.assertEquals(mediaDao.getTable().getPkColumn().getName(),
                              featureRelation.getRelatedPrimaryColumn());
        TestCase.assertEquals(MediaTable.RELATION_TYPE.getName(),
                              featureRelation.getRelationName());
        TestCase.assertEquals(mappingTableName,
                              featureRelation.getMappingTableName());
        
        // Test the user mappings from the relation
        UserMappingDao userMappingDao = rte.getMappingDao(featureRelation);
        int totalMappedCount = userMappingDao.count();
        UserCustomResultSet mappingResultSet = userMappingDao.queryForAll();
        while (mappingResultSet.moveToNext()) {
            userMappingRow = userMappingDao.getRow(mappingResultSet);
            TestCase.assertTrue(featureIds.contains(userMappingRow
                                                    .getBaseId()));
            TestCase.assertTrue(mediaIds.contains(userMappingRow
                                                  .getRelatedId()));
            RelatedTablesUtils.validateUserRow(mappingColumns,
                                               userMappingRow);
            RelatedTablesUtils.validateDublinCoreColumns(userMappingRow);
        }
        mappingResultSet.close();
        
        // Get and test the media DAO
        mediaDao = rte.getMediaDao(featureRelation);
        TestCase.assertNotNull(mediaDao);
        mediaTable = mediaDao.getTable();
        TestCase.assertNotNull(mediaTable);
        validateContents(mediaTable, mediaTable.getContents());
        
        // Get and test the Media Rows mapped to each Feature Row
        featureResultSet = featureDao.queryForAll();
        int totalMapped = 0;
        while (featureResultSet.moveToNext()) {
            FeatureRow featureRow = featureResultSet.getRow();
            List<Long> mappedIds = rte.getMappingsForBase(featureRelation,
                                                          featureRow.getId());
            List<MediaRow> mediaRows = mediaDao.getRows(mappedIds);
            TestCase.assertEquals(mappedIds.size(), mediaRows.size());
            
            for (MediaRow mediaRow : mediaRows) {
                TestCase.assertTrue(mediaRow.hasId());
                TestCase.assertTrue(mediaRow.getId() >= 0);
                TestCase.assertTrue(mediaIds.contains(mediaRow.getId()));
                TestCase.assertTrue(mappedIds.contains(mediaRow.getId()));
                GeoPackageGeometryDataUtils.compareByteArrays(mediaData,
                                                              mediaRow.getData());
                TestCase.assertEquals(contentType,
                                      mediaRow.getContentType());
                RelatedTablesUtils.validateUserRow(mediaColumns, mediaRow);
                RelatedTablesUtils.validateDublinCoreColumns(mediaRow);
                validateDublinCoreColumns(mediaRow);
                BufferedImage image = ImageUtils.getImage(mediaRow
                                                          .getData());
                TestCase.assertNotNull(image);
                TestCase.assertEquals(imageWidth, image.getWidth());
                TestCase.assertEquals(imageHeight, image.getHeight());
            }
            
            totalMapped += mappedIds.size();
        }
        featureResultSet.close();
        TestCase.assertEquals(totalMappedCount, totalMapped);
    }
    
    // Get the relations starting from the media table
    List<ExtendedRelation> mediaExtendedRelations = extendedRelationsDao
    .getRelatedTableRelations(mediaTable.getTableName());
    List<ExtendedRelation> mediaExtendedRelations2 = extendedRelationsDao
    .getTableRelations(mediaTable.getTableName());
    TestCase.assertEquals(1, mediaExtendedRelations.size());
    TestCase.assertEquals(1, mediaExtendedRelations2.size());
    TestCase.assertEquals(mediaExtendedRelations.get(0).getId(),
                          mediaExtendedRelations2.get(0).getId());
    TestCase.assertTrue(extendedRelationsDao.getBaseTableRelations(
                                                                   mediaTable.getTableName()).isEmpty());
    
    // Test the media table relations
    for (ExtendedRelation mediaRelation : mediaExtendedRelations) {
        
        // Test the relation
        TestCase.assertTrue(mediaRelation.getId() >= 0);
        TestCase.assertEquals(featureDao.getTableName(),
                              mediaRelation.getBaseTableName());
        TestCase.assertEquals(
                              featureDao.getTable().getPkColumn().getName(),
                              mediaRelation.getBasePrimaryColumn());
        TestCase.assertEquals(mediaDao.getTableName(),
                              mediaRelation.getRelatedTableName());
        TestCase.assertEquals(mediaDao.getTable().getPkColumn().getName(),
                              mediaRelation.getRelatedPrimaryColumn());
        TestCase.assertEquals(MediaTable.RELATION_TYPE.getName(),
                              mediaRelation.getRelationName());
        TestCase.assertEquals(mappingTableName,
                              mediaRelation.getMappingTableName());
        
        // Test the user mappings from the relation
        UserMappingDao userMappingDao = rte.getMappingDao(mediaRelation);
        int totalMappedCount = userMappingDao.count();
        UserCustomResultSet mappingResultSet = userMappingDao.queryForAll();
        while (mappingResultSet.moveToNext()) {
            userMappingRow = userMappingDao.getRow(mappingResultSet);
            TestCase.assertTrue(featureIds.contains(userMappingRow
                                                    .getBaseId()));
            TestCase.assertTrue(mediaIds.contains(userMappingRow
                                                  .getRelatedId()));
            RelatedTablesUtils.validateUserRow(mappingColumns,
                                               userMappingRow);
            RelatedTablesUtils.validateDublinCoreColumns(userMappingRow);
        }
        mappingResultSet.close();
        
        // Get and test the feature DAO
        featureDao = geoPackage.getFeatureDao(featureDao.getTableName());
        TestCase.assertNotNull(featureDao);
        FeatureTable featureTable = featureDao.getTable();
        TestCase.assertNotNull(featureTable);
        Contents featureContents = featureDao.getGeometryColumns()
        .getContents();
        TestCase.assertNotNull(featureContents);
        TestCase.assertEquals(ContentsDataType.FEATURES,
                              featureContents.getDataType());
        TestCase.assertEquals(ContentsDataType.FEATURES.getName(),
                              featureContents.getDataTypeString());
        TestCase.assertEquals(featureTable.getTableName(),
                              featureContents.getTableName());
        TestCase.assertNotNull(featureContents.getLastChange());
        
        // Get and test the Feature Rows mapped to each Media Row
        mediaResultSet = mediaDao.queryForAll();
        int totalMapped = 0;
        while (mediaResultSet.moveToNext()) {
            MediaRow mediaRow = mediaDao.getRow(mediaResultSet);
            List<Long> mappedIds = rte.getMappingsForRelated(mediaRelation,
                                                             mediaRow.getId());
            for (long mappedId : mappedIds) {
                FeatureRow featureRow = featureDao.queryForIdRow(mappedId);
                TestCase.assertNotNull(featureRow);
                
                TestCase.assertTrue(featureRow.hasId());
                TestCase.assertTrue(featureRow.getId() >= 0);
                TestCase.assertTrue(featureIds.contains(featureRow.getId()));
                TestCase.assertTrue(mappedIds.contains(featureRow.getId()));
                if (featureRow
                    .getValue(featureRow.getGeometryColumnIndex()) != null) {
                    GeoPackageGeometryData geometryData = featureRow
                    .getGeometry();
                    TestCase.assertNotNull(geometryData);
                    if (!geometryData.isEmpty()) {
                        TestCase.assertNotNull(geometryData.getGeometry());
                    }
                }
            }
            
            totalMapped += mappedIds.size();
        }
        mediaResultSet.close();
        TestCase.assertEquals(totalMappedCount, totalMapped);
    }
    
    */
    
    // Delete a single mapping
    int countOfIds = [dao countByIdsFromRow:userMappingRow];
    [GPKGTestUtils assertEqualIntWithValue:countOfIds andValue2:[dao deleteByIdsFromRow:userMappingRow]];
    [GPKGTestUtils assertEqualIntWithValue:10 - countOfIds andValue2:[dao count]];
    
    // Delete the relationship and user mapping table
    [rte removeRelationship:extendedRelation];
    [GPKGTestUtils assertFalse:[rte hasWithMappingTable:userMappingTable.tableName]];
    extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)extendedRelations.count];
    [GPKGTestUtils assertFalse:[geoPackage.database tableExists:mappingTableName]];
    
    // Delete the media table and contents row
    [GPKGTestUtils assertTrue:[geoPackage isTable:mediaTable.tableName]];
    [GPKGTestUtils assertNotNil:[contentsDao queryForIdObject:mediaTable.tableName]];
    [geoPackage deleteUserTable:mediaTable.tableName];
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
    [GPKGTestUtils assertEqualIntWithValue:-1 andValue2:(int)[contents getContentsDataType]];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:[GPKGMediaTable relationType]] andValue2:contents.dataType];
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
