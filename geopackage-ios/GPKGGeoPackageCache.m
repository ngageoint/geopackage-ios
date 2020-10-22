//
//  GPKGGeoPackageCache.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/3/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageCache.h"

@interface GPKGGeoPackageCache()

@property (nonatomic, strong) GPKGGeoPackageManager *manager;
@property (nonatomic, strong) NSMutableDictionary<NSString*,GPKGGeoPackage*> *cache;

@end

@implementation GPKGGeoPackageCache

-(instancetype) initWithManager: (GPKGGeoPackageManager *) manager{
    self = [super init];
    if(self != nil){
        self.manager = manager;
        self.cache = [NSMutableDictionary dictionary];
        self.closeQuietly = YES;
    }
    return self;
}

-(GPKGGeoPackage *) geoPackageOpenName: (NSString *) name{
    return [self geoPackageOpenName:name andCache:YES];
}

-(GPKGGeoPackage *) geoPackageNoCacheOpenName: (NSString *) name{
    return [self geoPackageOpenName:name andCache:NO];
}

-(GPKGGeoPackage *) geoPackageOpenName: (NSString *) name andCache: (BOOL) cache{
    GPKGGeoPackage * geoPackage = [self geoPackageWithName:name];
    if(geoPackage == nil){
        geoPackage = [self.manager open:name];
        if(cache){
            [self addGeoPackage:geoPackage];
        }
    }
    return geoPackage;
}

-(NSArray<NSString*> *) names{
    return [self.cache allKeys];
}

-(NSArray<GPKGGeoPackage*> *) geoPackages{
    return [self.cache allValues];
}

-(BOOL) hasName: (NSString *) name{
    return [self geoPackageWithName:name] != nil;
}

-(GPKGGeoPackage *) geoPackageWithName: (NSString *) name{
    return [self.cache objectForKey:name];
}

-(BOOL) existsWithName: (NSString *) name{
    return [self geoPackageWithName:name] != nil;
}

-(void) closeAll{
    for(GPKGGeoPackage * geoPackage in [self.cache allValues]){
        [self closeGeoPackage:geoPackage];
    }
    [self clear];
}

-(void) addGeoPackage: (GPKGGeoPackage *) geoPackage{
    [self.cache setObject:geoPackage forKey:geoPackage.name];
}

-(void) addAllGeoPackages: (NSArray<GPKGGeoPackage *> *) geoPackages{
    for(GPKGGeoPackage *geoPackage in geoPackages){
        [self addGeoPackage:geoPackage];
    }
}

-(GPKGGeoPackage *) removeByName: (NSString *) name{
    GPKGGeoPackage * geoPackage = [self geoPackageWithName:name];
    if(geoPackage != nil){
        [self.cache removeObjectForKey:name];
    }
    return geoPackage;
}

-(void) clear{
    [self.cache removeAllObjects];
}

-(BOOL) closeByName: (NSString *) name{
    GPKGGeoPackage * geoPackage = [self removeByName:name];
    if(geoPackage != nil){
        [self closeGeoPackage:geoPackage];
    }
    return geoPackage != nil;
}

-(void) closeRetain: (NSArray *) retain{
    NSMutableArray * close = [NSMutableArray arrayWithArray:[self.cache allKeys]];
    [close removeObjectsInArray:retain];
    for(NSString * name in close){
        [self closeByName:name];
    }
}

-(void) closeNames: (NSArray *) names{
    for(NSString * name in names){
        [self closeByName:name];
    }
}

-(void) closeGeoPackage: (GPKGGeoPackage *) geoPackage{
    @try {
        [geoPackage close];
    } @catch (NSException *exception) {
        NSLog(@"Error closing GeoPackage: %@", geoPackage.name);
        if(!self.closeQuietly){
            [exception raise];
        }
    }
}

-(BOOL) closeGeoPackageIfCached: (GPKGGeoPackage *) geoPackage{
    BOOL closed = NO;
    if (geoPackage != nil) {
        GPKGGeoPackage *cached = [self geoPackageWithName:geoPackage.name];
        if(cached != nil && cached == geoPackage){
            closed = [self closeByName:geoPackage.name];
        }
    }
    return closed;
}

-(BOOL) closeGeoPackageIfNotCached: (GPKGGeoPackage *) geoPackage{
    BOOL closed = NO;
    if (geoPackage != nil) {
        GPKGGeoPackage *cached = [self geoPackageWithName:geoPackage.name];
        if(cached == nil || cached != geoPackage){
            [self closeGeoPackage:geoPackage];
            closed = YES;
        }
    }
    return closed;
}

@end
