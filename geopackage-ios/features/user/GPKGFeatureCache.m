//
//  GPKGFeatureCache.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/25/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureCache.h"

@interface GPKGFeatureCache ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation GPKGFeatureCache

-(instancetype) init{
    self = [self initWithMaxSize:DEFAULT_FEATURE_CACHE_MAX_SIZE];
    return self;
}

-(instancetype) initWithMaxSize: (int) maxSize{
    self = [super init];
    if(self != nil){
        self.cache = [[NSCache alloc] init];
        [self.cache setCountLimit:maxSize];
    }
    return self;
}

-(int) maxSize{
    return (int)self.cache.countLimit;
}

-(GPKGFeatureRow *) rowById: (int) featureId{
    return [self rowByIdNumber:[NSNumber numberWithInt:featureId]];
}

-(GPKGFeatureRow *) rowByIdNumber: (NSNumber *) featureId{
    return [self.cache objectForKey:featureId];
}

-(GPKGFeatureRow *) putRow: (GPKGFeatureRow *) featureRow{
    NSNumber *featureId = [featureRow id];
    GPKGFeatureRow *previous = [self rowByIdNumber:featureId];
    [self.cache setObject:featureRow forKey:featureId];
    return previous;
}

-(GPKGFeatureRow *) removeRow: (GPKGFeatureRow *) featureRow{
    return [self removeByIdNumber:[featureRow id]];
}

-(GPKGFeatureRow *) removeById: (int) featureId{
    return [self removeByIdNumber:[NSNumber numberWithInt:featureId]];
}

-(GPKGFeatureRow *) removeByIdNumber: (NSNumber *) featureId{
    GPKGFeatureRow *removed = [self rowByIdNumber:featureId];
    [self.cache removeObjectForKey:featureId];
    return removed;
}

-(void) clear{
    [self.cache removeAllObjects];
}

-(void) resizeWithMaxSize: (int) maxSize{
    [self.cache setCountLimit:maxSize];
}

-(void) clearAndResizeWithMaxSize: (int) maxSize{
    [self clear];
    [self resizeWithMaxSize:maxSize];
}

@end
