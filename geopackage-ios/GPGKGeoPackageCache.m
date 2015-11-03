//
//  GPGKGeoPackageCache.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/3/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPGKGeoPackageCache.h"

@interface GPGKGeoPackageCache()

@property (nonatomic, strong) GPKGGeoPackageManager *manager;
@property (nonatomic, strong) NSMutableDictionary<NSString*,GPKGGeoPackage*> *cache;

@end

@implementation GPGKGeoPackageCache

-(instancetype) initWithManager: (GPKGGeoPackageManager *) manager{
    self = [super init];
    if(self != nil){
        self.manager = manager;
        self.cache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(GPKGGeoPackage *) getOrOpen: (NSString *) name{
    GPKGGeoPackage * geoPackage = [self get:name];
    if(geoPackage == nil){
        geoPackage = [self.manager open:name];
        [self add:geoPackage];
    }
    return geoPackage;
}

-(NSArray<NSString*> *) getNames{
    return [self.cache allKeys];
}

-(NSArray<GPKGGeoPackage*> *) getGeoPackages{
    return [self.cache allValues];
}

-(GPKGGeoPackage *) get: (NSString *) name{
    return [self.cache objectForKey:name];
}

-(BOOL) exists: (NSString *) name{
    return [self get:name] != nil;
}

-(void) closeAll{
    for(GPKGGeoPackage * geoPackage in [self.cache allValues]){
        [geoPackage close];
    }
    [self clear];
}

-(void) add: (GPKGGeoPackage *) geoPackage{
    [self.cache setObject:geoPackage forKey:geoPackage.name];
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
        [geoPackage close];
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

@end
