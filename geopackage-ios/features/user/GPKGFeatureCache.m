//
//  GPKGFeatureCache.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/25/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureCache.h"
#import "LruCache.h"

@interface GPKGFeatureCache ()

@property (nonatomic, strong) LruCache *cache;

@end

@implementation GPKGFeatureCache

-(instancetype) init{
    self = [self initWithMaxSize:DEFAULT_FEATURE_CACHE_MAX_SIZE];
    return self;
}

-(instancetype) initWithMaxSize: (int) maxSize{
    self = [super init];
    if(self != nil){
        self.cache = [[LruCache alloc] initWithMaxSize:maxSize];
    }
    return self;
}

-(int) maxSize{
    return (int)self.cache.maxSize;
}

-(int) size{
    return (int)self.cache.size;
}

-(GPKGFeatureRow *) rowById: (int) featureId{
    return [self.cache get:[self idKey:featureId]];
}

-(GPKGFeatureRow *) putRow: (GPKGFeatureRow *) featureRow{
    return [self.cache put:[self rowKey:featureRow] value:featureRow];
}

-(GPKGFeatureRow *) removeRow: (GPKGFeatureRow *) featureRow{
    return [self.cache remove:[self rowKey:featureRow]];
}

-(GPKGFeatureRow *) removeById: (int) featureId{
    return [self.cache remove:[self idKey:featureId]];
}

-(void) clear{
    [self.cache evictAll];
}

-(void) resizeWithMaxSize: (int) maxSize{
    [self.cache resize:maxSize];
}

-(void) clearAndResizeWithMaxSize: (int) maxSize{
    [self clear];
    [self resizeWithMaxSize:maxSize];
}

-(NSString *) rowKey: (GPKGFeatureRow *) featureRow{
    return [self idKey:[[featureRow getId] intValue]];
}

-(NSString *) idKey: (int) featureId{
    return [NSString stringWithFormat:@"%d", featureId];
}

@end
