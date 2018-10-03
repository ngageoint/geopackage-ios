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
        self.cache = [[NSMutableDictionary alloc] init];
        self.closeQuietly = YES;
    }
    return self;
}

-(GPKGGeoPackage *) getOrOpen: (NSString *) name{
    return [self getOrOpen:name andCache:YES];
}

-(GPKGGeoPackage *) getOrNoCacheOpen: (NSString *) name{
    return [self getOrOpen:name andCache:NO];
}

-(GPKGGeoPackage *) getOrOpen: (NSString *) name andCache: (BOOL) cache{
    GPKGGeoPackage * geoPackage = [self get:name];
    if(geoPackage == nil){
        geoPackage = [self.manager open:name];
        if(cache){
            [self add:geoPackage];
        }
    }
    return geoPackage;
}

-(NSArray<NSString*> *) getNames{
    return [self.cache allKeys];
}

-(NSArray<GPKGGeoPackage*> *) getGeoPackages{
    return [self.cache allValues];
}

-(BOOL) has: (NSString *) name{
    return [self get:name] != nil;
}

-(GPKGGeoPackage *) get: (NSString *) name{
    return [self.cache objectForKey:name];
}

-(BOOL) exists: (NSString *) name{
    return [self get:name] != nil;
}

-(void) closeAll{
    for(GPKGGeoPackage * geoPackage in [self.cache allValues]){
        [self closeGeoPackage:geoPackage];
    }
    [self clear];
}

-(void) add: (GPKGGeoPackage *) geoPackage{
    [self.cache setObject:geoPackage forKey:geoPackage.name];
}

-(void) addAll: (NSArray<GPKGGeoPackage *> *) geoPackages{
    for(GPKGGeoPackage *geoPackage in geoPackages){
        [self add:geoPackage];
    }
}

-(GPKGGeoPackage *) remove: (NSString *) name{
    GPKGGeoPackage * geoPackage = [self get:name];
    if(geoPackage != nil){
        [self.cache removeObjectForKey:name];
    }
    return geoPackage;
}

-(void) clear{
    [self.cache removeAllObjects];
}

-(BOOL) close: (NSString *) name{
    GPKGGeoPackage * geoPackage = [self remove:name];
    if(geoPackage != nil){
        [self closeGeoPackage:geoPackage];
    }
    return geoPackage != nil;
}

-(void) closeRetain: (NSArray *) retain{
    NSMutableArray * close = [[NSMutableArray alloc] initWithArray:[self.cache allKeys]];
    [close removeObjectsInArray:retain];
    for(NSString * name in close){
        [self close:name];
    }
}

-(void) closeNames: (NSArray *) names{
    for(NSString * name in names){
        [self close:name];
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
        GPKGGeoPackage *cached = [self get:geoPackage.name];
        if(cached != nil && cached == geoPackage){
            closed = [self close:geoPackage.name];
        }
    }
    return closed;
}

-(BOOL) closeGeoPackageIfNotCached: (GPKGGeoPackage *) geoPackage{
    BOOL closed = NO;
    if (geoPackage != nil) {
        GPKGGeoPackage *cached = [self get:geoPackage.name];
        if(cached == nil || cached != geoPackage){
            [self closeGeoPackage:geoPackage];
            closed = YES;
        }
    }
    return closed;
}

@end
