//
//  GPKGConnectionPoolTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/27/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGConnectionPoolTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGProjectionConstants.h"

@implementation GPKGConnectionPoolTestCase

- (void)testNestedQuery {
    
    NSArray * featureTables = [self.geoPackage getFeatureTables];
    for(NSString * featureTable in featureTables){
        
        GPKGFeatureDao * featureDao = [self.geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGResultSet * featureResults = [featureDao queryForAll];
        NSNumber * connectionId1 = [featureResults.connection getConnectionId];
        
        while([featureResults moveToNext]){
            
            GPKGFeatureRow * featureRow = [featureDao getFeatureRow:featureResults];
            [GPKGTestUtils assertNotNil:featureRow];
            
            NSArray * tileTables = [self.geoPackage getTileTables];
            for(NSString * tileTable in tileTables){
                
                GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTableName:tileTable];
                GPKGResultSet * tileResults = [tileDao queryForAll];
                NSNumber * connectionId2 = [tileResults.connection getConnectionId];
                
                [GPKGTestUtils assertFalse:[connectionId1 intValue] == [connectionId2 intValue]];
                
                while([tileResults moveToNext]){
                    
                    GPKGTileRow * tileRow = [tileDao getTileRow:tileResults];
                    [GPKGTestUtils assertNotNil:tileRow];
                    
                }
                
                [tileResults close];
            }
            
        }
        
        [featureResults close];
    }
    
}

- (void)testMultiThreadedQuery {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray * tileTables = [self.geoPackage getTileTables];
        for(NSString * tileTable in tileTables){
            
            GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTableName:tileTable];
            GPKGResultSet * tileResults = [tileDao queryForAll];
            
            while([tileResults moveToNext]){
                
                GPKGTileRow * tileRow = [tileDao getTileRow:tileResults];
                [GPKGTestUtils assertNotNil:tileRow];
                
                [NSThread sleepForTimeInterval:.1];
            }
            
            [tileResults close];
        }
        
    });
    
    NSArray * featureTables = [self.geoPackage getFeatureTables];
    for(NSString * featureTable in featureTables){
        
        GPKGFeatureDao * featureDao = [self.geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGResultSet * featureResults = [featureDao queryForAll];
        
        while([featureResults moveToNext]){
            
            GPKGFeatureRow * featureRow = [featureDao getFeatureRow:featureResults];
            [GPKGTestUtils assertNotNil:featureRow];
            
            [NSThread sleepForTimeInterval:.1];
        }
        
        [featureResults close];
    }
    
}

- (void)testNestedUpdate {
    
    NSArray * featureTables = [self.geoPackage getFeatureTables];
    for(NSString * featureTable in featureTables){
        
        GPKGFeatureDao * featureDao = [self.geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGResultSet * featureResults = [featureDao queryForAll];
        NSNumber * connectionId1 = [featureResults.connection getConnectionId];
        
        while([featureResults moveToNext]){
            
            GPKGFeatureRow * featureRow = [featureDao getFeatureRow:featureResults];
            [GPKGTestUtils assertNotNil:featureRow];
            
            GPKGGeometryData * geomData = [[GPKGGeometryData alloc] initWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
            [geomData setGeometry:[[WKBPoint alloc] initWithX:[[NSDecimalNumber alloc] initWithDouble:45.1] andY:[[NSDecimalNumber alloc] initWithDouble:23.2]]];
            [featureRow setGeometry:geomData];
            
            int updated = [featureDao update:featureRow];
            [GPKGTestUtils assertEqualIntWithValue:1 andValue2:updated];
            
        }
        
        [featureResults close];
    }
    
}

/**
 *  When multiple result connections are open, updates are not possible due to a database lock
 */
- (void)testNestedQueryAndUpdateFailure {
    
    NSArray * featureTables = [self.geoPackage getFeatureTables];
    for(NSString * featureTable in featureTables){
        
        GPKGFeatureDao * featureDao = [self.geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGResultSet * featureResults = [featureDao queryForAll];
        NSNumber * connectionId1 = [featureResults.connection getConnectionId];
        
        while([featureResults moveToNext]){
            
            GPKGFeatureRow * featureRow = [featureDao getFeatureRow:featureResults];
            [GPKGTestUtils assertNotNil:featureRow];
            
            NSArray * tileTables = [self.geoPackage getTileTables];
            for(NSString * tileTable in tileTables){
                
                GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTableName:tileTable];
                GPKGResultSet * tileResults = [tileDao queryForAll];
                NSNumber * connectionId2 = [tileResults.connection getConnectionId];
                
                [GPKGTestUtils assertFalse:[connectionId1 intValue] == [connectionId2 intValue]];
                
                while([tileResults moveToNext]){
                    
                    GPKGTileRow * tileRow = [tileDao getTileRow:tileResults];
                    [GPKGTestUtils assertNotNil:tileRow];
                    
                    NSString* string = @"garbage";
                    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
                    [tileRow setTileData:data];
                    
                    @try {
                        [tileDao update:tileRow];
                        [NSException raise:@"Unexpected Success" format:@"Did not encounter expected failure, updating the database with multiple open result connections"];
                    }
                    @catch (NSException *exception) {
                        // Expected failure
                    }
                }
                
                [tileResults close];
            }
            
        }
        
        [featureResults close];
    }
    
}

@end
