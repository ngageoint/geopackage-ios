//
//  GPKGFeatureCacheTables.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/25/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureCacheTables.h"

@interface GPKGFeatureCacheTables ()

/**
 * Mapping between feature table name and a feature row cache
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, GPKGFeatureCache *> *tableCache;

@end

@implementation GPKGFeatureCacheTables

-(instancetype) init{
    self = [self initWithMaxCacheSize:DEFAULT_FEATURE_CACHE_MAX_SIZE];
    return self;
}

-(instancetype) initWithMaxCacheSize: (int) maxCacheSize{
    self = [super init];
    if(self != nil){
        self.maxCacheSize = maxCacheSize;
    }
    return self;
}

-(NSArray<NSString *> *) tables{
    return [self.tableCache allKeys];
}

-(GPKGFeatureCache *) cacheForTable: (NSString *) tableName{
    GPKGFeatureCache *cache = [self.tableCache objectForKey:tableName];
    if (cache == nil) {
        cache = [[GPKGFeatureCache alloc] initWithMaxSize:self.maxCacheSize];
        [self.tableCache setObject:cache forKey:tableName];
    }
    return cache;
}

-(GPKGFeatureCache *) cacheForRow: (GPKGFeatureRow *) featureRow{
    return [self cacheForTable:featureRow.table.tableName];
}

-(int) maxSizeForTable: (NSString *) tableName{
    return [[self cacheForTable:tableName] maxSize];
}

-(int) sizeForTable: (NSString *) tableName{
    return [[self cacheForTable:tableName] size];
}

-(GPKGFeatureRow *) rowByTable: (NSString *) tableName andId: (int) featureId{
    return [[self cacheForTable:tableName] rowById:featureId];
}

-(GPKGFeatureRow *) putRow: (GPKGFeatureRow *) featureRow{
    return [[self cacheForRow:featureRow] putRow:featureRow];
}

-(GPKGFeatureRow *) removeRow: (GPKGFeatureRow *) featureRow{
    return [self removeRowByTable:featureRow.table.tableName andId:[[featureRow getId] intValue]];
}

-(GPKGFeatureRow *) removeRowByTable: (NSString *) tableName andId: (int) featureId{
    return [[self cacheForTable:tableName] removeById:featureId];
}

-(void) clearForTable: (NSString *) tableName{
    [self.tableCache removeObjectForKey:tableName];
}

-(void) clear{
    [self.tableCache removeAllObjects];
}

-(void) resizeForTable: (NSString *) tableName withMaxCacheSize: (int) maxCacheSize{
    [[self cacheForTable:tableName] resizeWithMaxSize:maxCacheSize];
}

-(void) resizeWithMaxCacheSize: (int) maxCacheSize{
    [self setMaxCacheSize:maxCacheSize];
    for(GPKGFeatureCache *cache in [self.tableCache allValues]){
        [cache resizeWithMaxSize:maxCacheSize];
    }
}

-(void) clearAndResizeForTable: (NSString *) tableName withMaxCacheSize: (int) maxCacheSize{
    [[self cacheForTable:tableName] clearAndResizeWithMaxSize:maxCacheSize];
}

-(void) clearAndResizeWithMaxCacheSize: (int) maxCacheSize{
    [self setMaxCacheSize:maxCacheSize];
    for(GPKGFeatureCache *cache in [self.tableCache allValues]){
        [cache clearAndResizeWithMaxSize:maxCacheSize];
    }
}

@end
