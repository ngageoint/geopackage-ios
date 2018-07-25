//
//  GPKGPropertiesManager.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/24/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGPropertiesManager.h"

@interface GPKGPropertiesManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, GPKGPropertiesExtension *> *propertiesMap;

@end

@implementation GPKGPropertiesManager

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.propertiesMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [self init];
    if(self != nil){
        [self addGeoPackage:geoPackage];
    }
    return self;
}

-(instancetype) initWithGeoPackages: (NSArray<GPKGGeoPackage *> *) geoPackages{
    self = [self init];
    if(self != nil){
        [self addGeoPackages:geoPackages];
    }
    return self;
}

-(instancetype) initWithCache: (GPKGGeoPackageCache *) cache{
    return [self initWithGeoPackages:[cache getGeoPackages]];
}

-(GPKGPropertiesExtension *) propertiesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [[GPKGPropertiesExtension alloc] initWithGeoPackage:geoPackage];
}

-(NSSet<NSString *> *) geoPackageNames{
    return  [[NSSet alloc] initWithArray:[self.propertiesMap allKeys]];
}

-(int) numGeoPackages{
    return (int)self.propertiesMap.count;
}

-(NSArray<GPKGGeoPackage *> *) geoPackages{
    NSMutableArray *geoPackages = [[NSMutableArray alloc] init];
    for(GPKGPropertiesExtension *properties in [self.propertiesMap allValues]){
        [geoPackages addObject:properties.geoPackage];
    }
    return geoPackages;
}

-(BOOL) hasGeoPackageWithName: (NSString *) name{
    return [self.propertiesMap objectForKey:name] != nil;
}

-(GPKGGeoPackage *) geoPackageWithName: (NSString *) name{
    GPKGGeoPackage *geoPackage = nil;
    GPKGPropertiesExtension *properties = [self.propertiesMap objectForKey:name];
    if(properties != nil){
        geoPackage = properties.geoPackage;
    }
    return geoPackage;
}

-(void) addGeoPackages: (NSArray<GPKGGeoPackage *> *) geoPackages{
    for (GPKGGeoPackage *geoPackage in geoPackages) {
        [self addGeoPackage:geoPackage];
    }
}

-(void) addGeoPackage: (GPKGGeoPackage *) geoPackage{
    GPKGPropertiesExtension *propertiesExtension = [self propertiesExtensionWithGeoPackage:geoPackage];
    [self.propertiesMap setObject:propertiesExtension forKey:geoPackage.name];
}

-(void) closeGeoPackages{
    for(GPKGPropertiesExtension *properties in self.propertiesMap.allValues){
        [properties.geoPackage close];
    }
    [self.propertiesMap removeAllObjects];
}

-(GPKGGeoPackage *) removeGeoPackageWithName: (NSString *) name{
    GPKGGeoPackage *removed = [self geoPackageWithName:name];
    if(removed != nil){
        [self.propertiesMap removeObjectForKey:name];
    }
    return removed;
}

-(void) clearGeoPackages{
    [self.propertiesMap removeAllObjects];
}

-(BOOL) removeAndCloseGeoPackageWithName: (NSString *) name{
    return [self closeGeoPackageWithName:name];
}

-(BOOL) closeGeoPackageWithName: (NSString *) name{
    GPKGGeoPackage *geoPackage = [self removeGeoPackageWithName:name];
    if(geoPackage != nil){
        [geoPackage close];
    }
    return geoPackage != nil;
}

-(void) closeRetainGeoPackages: (NSArray<NSString *> *) retain{
    NSMutableSet<NSString *> *close = [[NSMutableSet alloc] initWithArray:[self.propertiesMap allKeys]];
    for(NSString *retainGeoPackage in retain){
        [close removeObject:retainGeoPackage];
    }
    for (NSString *name in close) {
        [self closeGeoPackageWithName:name];
    }
}

-(void) closeGeoPackages: (NSArray<NSString *> *) names{
    for (NSString *name in names) {
        [self closeGeoPackageWithName:name];
    }
}

-(int) numProperties{
    return (int)[self properties].count;
}

-(NSSet<NSString *> *) properties{
    NSMutableSet<NSString *> *allProperties = [[NSMutableSet alloc] init];
    for(GPKGPropertiesExtension *properties in self.propertiesMap.allValues){
        [allProperties addObjectsFromArray:[properties properties]];
    }
    return allProperties;
}

-(NSArray<GPKGGeoPackage *> *) hasProperty: (NSString *) property{
    NSMutableArray *geoPackages = [[NSMutableArray alloc] init];
    for(GPKGPropertiesExtension *properties in [self.propertiesMap allValues]){
        if([properties hasProperty:property]){
            [geoPackages addObject:properties.geoPackage];
        }
    }
    return geoPackages;
}

-(NSArray<GPKGGeoPackage *> *) missingProperty: (NSString *) property{
    NSMutableArray *geoPackages = [[NSMutableArray alloc] init];
    for(GPKGPropertiesExtension *properties in [self.propertiesMap allValues]){
        if(![properties hasProperty:property]){
            [geoPackages addObject:properties.geoPackage];
        }
    }
    return geoPackages;
}

-(int) numValuesOfProperty: (NSString *) property{
    return (int)[self valuesOfProperty:property].count;
}

-(BOOL) hasValuesWithProperty: (NSString *) property{
    return [self numValuesOfProperty:property] > 0;
}

-(NSSet<NSString *> *) valuesOfProperty: (NSString *) property{
    NSMutableSet<NSString *> *allValues = [[NSMutableSet alloc] init];
    for(GPKGPropertiesExtension *properties in self.propertiesMap.allValues){
        [allValues addObjectsFromArray:[properties valuesOfProperty:property]];
    }
    return allValues;
}

-(NSArray<GPKGGeoPackage *> *) hasValue: (NSString *) value withProperty: (NSString *) property{
    NSMutableArray *geoPackages = [[NSMutableArray alloc] init];
    for(GPKGPropertiesExtension *properties in [self.propertiesMap allValues]){
        if([properties hasValue:value withProperty:property]){
            [geoPackages addObject:properties.geoPackage];
        }
    }
    return geoPackages;
}

-(NSArray<GPKGGeoPackage *> *) missingValue: (NSString *) value withProperty: (NSString *) property{
    NSMutableArray *geoPackages = [[NSMutableArray alloc] init];
    for(GPKGPropertiesExtension *properties in [self.propertiesMap allValues]){
        if(![properties hasValue:value withProperty:property]){
            [geoPackages addObject:properties.geoPackage];
        }
    }
    return geoPackages;
}

-(int) addValue: (NSString *) value withProperty: (NSString *) property{
    int count = 0;
    for(NSString *geoPackage in [self.propertiesMap allKeys]){
        if([self addValue:value withProperty:property inGeoPackage:geoPackage]){
            count++;
        }
    }
    return count;
}

-(int) addValue: (NSString *) value withProperty: (NSString *) property inGeoPackage: (NSString *) geoPackage{
    BOOL added = NO;
    GPKGPropertiesExtension *properties = [self.propertiesMap objectForKey:geoPackage];
    if(properties != nil){
        added = [properties addValue:value withProperty:property];
    }
    return added;
}

-(int) deleteProperty: (NSString *) property{
    int count = 0;
    for (NSString *geoPackage in [self.propertiesMap allKeys]) {
        if([self deleteProperty:property inGeoPackage:geoPackage]){
            count++;
        }
    }
    return count;
}

-(int) deleteProperty: (NSString *) property inGeoPackage: (NSString *) geoPackage{
    BOOL deleted = NO;
    GPKGPropertiesExtension *properties = [self.propertiesMap objectForKey:geoPackage];
    if (properties != nil) {
        deleted = [properties deleteProperty:property] > 0;
    }
    return deleted;
}

-(int) deleteValue: (NSString *) value withProperty: (NSString *) property{
    int count = 0;
    for (NSString *geoPackage in [self.propertiesMap allKeys]) {
        if([self deleteValue:value withProperty:property inGeoPackage:geoPackage]){
            count++;
        }
    }
    return count;
}

-(int) deleteValue: (NSString *) value withProperty: (NSString *) property inGeoPackage: (NSString *) geoPackage{
    BOOL deleted = NO;
    GPKGPropertiesExtension *properties = [self.propertiesMap objectForKey:geoPackage];
    if (properties != nil) {
        deleted = [properties deleteValue:value withProperty:property] > 0;
    }
    return deleted;
}

-(int) deleteAll{
    int count = 0;
    for (NSString *geoPackage in [self.propertiesMap allKeys]) {
        if ([self deleteAllInGeoPackage:geoPackage]) {
            count++;
        }
    }
    return count;
}

-(int) deleteAllInGeoPackage: (NSString *) geoPackage{
    BOOL deleted = NO;
    GPKGPropertiesExtension *properties = [self.propertiesMap objectForKey:geoPackage];
    if (properties != nil) {
        deleted = [properties deleteAll] > 0;
    }
    return deleted;
}

-(void) removeExtension{
    for (NSString *geoPackage in [self.propertiesMap allKeys]) {
        [self removeExtensionInGeoPackage:geoPackage];
    }
}

-(void) removeExtensionInGeoPackage: (NSString *) geoPackage{
    GPKGPropertiesExtension *properties = [self.propertiesMap objectForKey:geoPackage];
    if (properties != nil){
        [properties removeExtension];
    }
}

@end
