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
    
    // TODO
    /*
    
    List<String> featureTables = geoPackage.getFeatureTables();
    for (String featureTable : featureTables) {
        
        FeatureDao featureDao = geoPackage.getFeatureDao(featureTable);
        FeatureIndexManager featureIndexManager = new FeatureIndexManager(activity,
                                                                          geoPackage, featureDao);
        featureIndexManager.prioritizeQueryLocation(type);
        
        FeatureIndexResults featureIndexResults = featureIndexManager
        .query();
        long resultsCount = featureIndexResults.count();
        maxResults = Math.max(maxResults, (int) resultsCount);
        for (long featureRowId : featureIndexResults.ids()) {
            FeatureRow featureRow = featureCache.get(featureTable, featureRowId);
            TestCase.assertNull(featureRow);
            featureRow = featureDao.queryForIdRow(featureRowId);
            TestCase.assertNotNull(featureRow);
            featureCache.put(featureRow);
            FeatureRow featureRow2 = featureCache.get(featureTable, featureRowId);
            TestCase.assertNotNull(featureRow2);
            TestCase.assertEquals(featureRow, featureRow2);
        }
        featureIndexResults.close();
        featureIndexManager.close();
    }
    
    FeatureCacheTables featureCache2 = new FeatureCacheTables(maxResults);
    
    for (String featureTable : featureTables) {
        
        FeatureDao featureDao = geoPackage.getFeatureDao(featureTable);
        FeatureIndexManager featureIndexManager = new FeatureIndexManager(activity,
                                                                          geoPackage, featureDao);
        featureIndexManager.prioritizeQueryLocation(type);
        
        FeatureIndexResults featureIndexResults = featureIndexManager
        .query();
        int count = 0;
        long resultsCount = featureIndexResults.count();
        for (long featureRowId : featureIndexResults.ids()) {
            FeatureRow featureRow = featureCache.get(featureTable, featureRowId);
            if (count++ >= resultsCount - cacheSize) {
                TestCase.assertNotNull(featureRow);
            } else {
                TestCase.assertNull(featureRow);
                featureRow = featureDao.queryForIdRow(featureRowId);
                TestCase.assertNotNull(featureRow);
            }
            featureCache2.put(featureRow);
            FeatureRow featureRow2 = featureCache2.get(featureTable, featureRowId);
            TestCase.assertNotNull(featureRow2);
            TestCase.assertEquals(featureRow, featureRow2);
        }
        featureIndexResults.close();
        featureIndexManager.close();
    }
    
    featureCache.resize(featureCache2.getMaxCacheSize());
    
    for (String featureTable : featureTables) {
        
        FeatureDao featureDao = geoPackage.getFeatureDao(featureTable);
        FeatureIndexManager featureIndexManager = new FeatureIndexManager(activity,
                                                                          geoPackage, featureDao);
        featureIndexManager.prioritizeQueryLocation(type);
        
        FeatureIndexResults featureIndexResults = featureIndexManager
        .query();
        long resultsCount = featureIndexResults.count();
        TestCase.assertEquals(resultsCount, featureCache2.getSize(featureTable));
        for (long featureRowId : featureIndexResults.ids()) {
            FeatureRow featureRow = featureCache2.get(featureTable, featureRowId);
            TestCase.assertNotNull(featureRow);
            featureCache.put(featureRow);
        }
        featureIndexResults.close();
        featureIndexManager.close();
        
    }
    
    TestCase.assertEquals(featureTables.size(), featureCache.getTables().size());
    TestCase.assertEquals(featureTables.size(), featureCache2.getTables().size());
    for (String featureTable : featureTables) {
        
        TestCase.assertEquals(featureCache.getSize(featureTable), featureCache2.getSize(featureTable));
        
        FeatureDao featureDao = geoPackage.getFeatureDao(featureTable);
        FeatureIndexManager featureIndexManager = new FeatureIndexManager(activity,
                                                                          geoPackage, featureDao);
        featureIndexManager.prioritizeQueryLocation(type);
        
        FeatureIndexResults featureIndexResults = featureIndexManager
        .query();
        long resultsCount = featureIndexResults.count();
        TestCase.assertEquals(resultsCount, featureCache.getSize(featureTable));
        TestCase.assertEquals(resultsCount, featureCache2.getSize(featureTable));
        for (long featureRowId : featureIndexResults.ids()) {
            TestCase.assertNotNull(featureCache.get(featureTable, featureRowId));
            TestCase.assertNotNull(featureCache2.get(featureTable, featureRowId));
        }
        featureIndexResults.close();
        featureIndexManager.close();
        
        featureCache.clear(featureTable);
        featureCache2.clear(featureTable);
        TestCase.assertEquals(0, featureCache.getSize(featureTable));
        TestCase.assertEquals(0, featureCache2.getSize(featureTable));
    }
    
    featureCache.clear();
    featureCache2.clear();
    TestCase.assertEquals(0, featureCache.getTables().size());
    TestCase.assertEquals(0, featureCache2.getTables().size());
     
     */
}

@end
