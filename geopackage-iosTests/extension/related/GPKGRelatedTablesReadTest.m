//
//  GPKGRelatedTablesReadTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedTablesReadTest.h"
#import "GPKGTestConstants.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGTestUtils.h"

@implementation GPKGRelatedTablesReadTest

- (void)setUp {
    self.dbName = GPKG_TEST_RTE_DB_NAME;
    self.file = GPKG_TEST_RTE_DB_FILE_NAME;
    [super setUp];
}

/**
 *  Test read relationships
 */
-(void) testReadRelationships{
    
    // 1. has
    GPKGRelatedTablesExtension *rte = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:self.geoPackage];
    [GPKGTestUtils assertTrue:[rte has]];
    
    // 4. get relationships
    NSArray<GPKGExtendedRelation *> *extendedRelations = [rte relationships];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)extendedRelations.count];
    
    for (GPKGExtendedRelation *extendedRelation in extendedRelations) {
        
        // 9. get mappings by base ID
        NSMutableDictionary<NSNumber *, NSArray<NSNumber *> *> *baseIdMappings = [NSMutableDictionary dictionary];
        GPKGFeatureDao *baseDao = [self.geoPackage featureDaoWithTableName:extendedRelation.baseTableName];
        GPKGFeatureColumn *pkColumn = (GPKGFeatureColumn *)[baseDao pkColumn];
        GPKGResultSet *frs = [baseDao queryForAll];
        while([frs moveToNext]){
            NSNumber *baseId = [frs longWithIndex:pkColumn.index];
            NSArray<NSNumber *> *relatedIds = [rte mappingsForRelation:extendedRelation withBaseId:[baseId intValue]];
            [GPKGTestUtils assertFalse:relatedIds.count == 0];
            [baseIdMappings setObject:relatedIds forKey:baseId];
        }
        [frs close];
        
        // 10. get mappings by related ID
        NSMutableDictionary<NSNumber *, NSArray<NSNumber *> *> *relatedIdMappings = [NSMutableDictionary dictionary];
        GPKGAttributesDao *relatedDao = [self.geoPackage attributesDaoWithTableName:extendedRelation.relatedTableName];
        GPKGAttributesColumn *pkColumn2 = (GPKGAttributesColumn *)[relatedDao pkColumn];
        GPKGResultSet *ars = [relatedDao queryForAll];
        while([ars moveToNext]){
            NSNumber *relatedId = [ars longWithIndex:pkColumn2.index];
            NSArray<NSNumber *> *baseIds = [rte mappingsForRelation:extendedRelation withRelatedId:[relatedId intValue]];
            [GPKGTestUtils assertFalse:baseIds.count == 0];
            [relatedIdMappings setObject:baseIds forKey:relatedId];
        }
        [ars close];
        
        // Verify the related ids map back to the base ids
        for(NSNumber *baseId in [baseIdMappings allKeys]){
            for(NSNumber *relatedId in [baseIdMappings objectForKey:baseId]){
                [GPKGTestUtils assertTrue:[[relatedIdMappings objectForKey:relatedId] containsObject:baseId]];
            }
        }
        
        // Verify the base ids map back to the related ids
        for(NSNumber *relatedId in [relatedIdMappings allKeys]){
            for(NSNumber *baseId in [relatedIdMappings objectForKey:relatedId]){
                [GPKGTestUtils assertTrue:[[baseIdMappings objectForKey:baseId] containsObject:relatedId]];
            }
        }
        
    }
    
}

@end
