//
//  GPKGFeatureCacheUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureCacheUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGFeatureIndexTypes.h"
#import "GPKGFeatureCacheTables.h"
#import "GPKGFeatureIndexManager.h"

@implementation GPKGFeatureCacheUtils

+(void) testCacheWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    [self testCacheWithGeoPackage:geoPackage andType:GPKG_FIT_GEOPACKAGE];
    [self testCacheWithGeoPackage:geoPackage andType:GPKG_FIT_METADATA];
    [self testCacheWithGeoPackage:geoPackage andType:GPKG_FIT_RTREE];
}

+(void) testCacheWithGeoPackage: (GPKGGeoPackage *) geoPackage andType: (enum GPKGFeatureIndexType) type{
    
    int maxResults = 0;
    
    int cacheSize = 1 + [GPKGTestUtils randomIntLessThan:10];
    GPKGFeatureCacheTables *featureCache = [[GPKGFeatureCacheTables alloc] initWithMaxCacheSize:cacheSize];
    
    NSArray<NSString *> *featureTables = [geoPackage getFeatureTables];
    for(NSString *featureTable in featureTables){
        
        GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager *featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager prioritizeQueryLocationWithType:type];
        
        GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager query];
        int resultsCount = [featureIndexResults count];
        maxResults = MAX(maxResults, resultsCount);
        featureIndexResults.ids = YES;
        for(NSNumber *featureRowId in featureIndexResults){
            GPKGFeatureRow *featureRow = [featureCache rowByTable:featureTable andId:[featureRowId intValue]];
            [GPKGTestUtils assertNil:featureRow];
            featureRow = (GPKGFeatureRow *)[featureDao queryForIdObject:featureRowId];
            [GPKGTestUtils assertNotNil:featureRow];
            [featureCache putRow:featureRow];
            GPKGFeatureRow *featureRow2 = [featureCache rowByTable:featureTable andId:[featureRowId intValue]];
            [GPKGTestUtils assertNotNil:featureRow2];
            [GPKGTestUtils assertEqualWithValue:featureRow andValue2:featureRow2];
        }
        [featureIndexResults close];
        [featureIndexManager close];
    }
    
    GPKGFeatureCacheTables *featureCache2 = [[GPKGFeatureCacheTables alloc] init];
    
    for(NSString *featureTable in featureTables){
        
        GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager *featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager prioritizeQueryLocationWithType:type];
        
        GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager query];
        int count = 0;
        int resultsCount = [featureIndexResults count];
        featureIndexResults.ids = YES;
        for(NSNumber *featureRowId in featureIndexResults){
            GPKGFeatureRow *featureRow = [featureCache rowByTable:featureTable andId:[featureRowId intValue]];
            if(count++ >= resultsCount - cacheSize){
                [GPKGTestUtils assertNotNil:featureRow];
            }else{
                [GPKGTestUtils assertNil:featureRow];
                featureRow = (GPKGFeatureRow *)[featureDao queryForIdObject:featureRowId];
                [GPKGTestUtils assertNotNil:featureRow];
            }
            [featureCache2 putRow:featureRow];
            GPKGFeatureRow *featureRow2 = [featureCache2 rowByTable:featureTable andId:[featureRowId intValue]];
            [GPKGTestUtils assertNotNil:featureRow2];
            [GPKGTestUtils assertEqualWithValue:featureRow andValue2:featureRow2];
        }
        [featureIndexResults close];
        [featureIndexManager close];
    }
    
    [featureCache resizeWithMaxCacheSize:featureCache2.maxCacheSize];
    
    for(NSString *featureTable in featureTables){
        
        GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager *featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager prioritizeQueryLocationWithType:type];
        
        GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager query];
        int resultsCount = [featureIndexResults count];
        [GPKGTestUtils assertEqualIntWithValue:resultsCount andValue2:[featureCache2 sizeForTable:featureTable]];
        featureIndexResults.ids = YES;
        for(NSNumber *featureRowId in featureIndexResults){
            GPKGFeatureRow *featureRow = [featureCache2 rowByTable:featureTable andId:[featureRowId intValue]];
            [GPKGTestUtils assertNotNil:featureRow];
            [featureCache putRow:featureRow];
        }
        [featureIndexResults close];
        [featureIndexManager close];
        
    }
    
    [GPKGTestUtils assertEqualUnsignedLongWithValue:featureTables.count andValue2:[featureCache tables].count];
    [GPKGTestUtils assertEqualUnsignedLongWithValue:featureTables.count andValue2:[featureCache2 tables].count];
    for(NSString *featureTable in featureTables){
        
        [GPKGTestUtils assertEqualIntWithValue:[featureCache sizeForTable:featureTable] andValue2:[featureCache2 sizeForTable:featureTable]];
        
        GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager *featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager prioritizeQueryLocationWithType:type];
        
        GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager query];
        int resultsCount = [featureIndexResults count];
        [GPKGTestUtils assertEqualIntWithValue:resultsCount andValue2:[featureCache sizeForTable:featureTable]];
        [GPKGTestUtils assertEqualIntWithValue:resultsCount andValue2:[featureCache2 sizeForTable:featureTable]];
        featureIndexResults.ids = YES;
        for(NSNumber *featureRowId in featureIndexResults){
            [GPKGTestUtils assertNotNil:[featureCache rowByTable:featureTable andId:[featureRowId intValue]]];
            [GPKGTestUtils assertNotNil:[featureCache2 rowByTable:featureTable andId:[featureRowId intValue]]];
        }
        [featureIndexResults close];
        [featureIndexManager close];
        
        [featureCache clearForTable:featureTable];
        [featureCache2 clearForTable:featureTable];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[featureCache sizeForTable:featureTable]];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[featureCache2 sizeForTable:featureTable]];
    }
    
    [featureCache clear];
    [featureCache2 clear];
    [GPKGTestUtils assertEqualUnsignedLongWithValue:0 andValue2:[featureCache tables].count];
    [GPKGTestUtils assertEqualUnsignedLongWithValue:0 andValue2:[featureCache2 tables].count];
     
}

@end
