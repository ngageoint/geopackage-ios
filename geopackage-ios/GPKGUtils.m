//
//  GPKGUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/28/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUtils.h"

@implementation GPKGUtils

+(void) addObject: (id) object toArray: (NSMutableArray *) array{
    [array addObject:[self objectToCollection:object]];
}

+(void) replaceObjectAtIndex: (NSUInteger) index withObject: (id) object inArray: (NSMutableArray *) array{
    [array replaceObjectAtIndex:index withObject:[self objectToCollection:object]];
}

+(void) insertObject: (id) object atIndex: (NSUInteger) index inArray: (NSMutableArray *) array{
    [array insertObject:[self objectToCollection:object] atIndex:index];
}

+(id) objectAtIndex: (NSUInteger) index inArray: (NSArray *) array{
    return [self objectFromCollection:[array objectAtIndex:index]];
}

+(void) setObject: (id) object forKey: (id<NSCopying>) key inDictionary: (NSMutableDictionary *) dictionary{
    [dictionary setObject:[self objectToCollection:object] forKey:key];
}

+(id) objectForKey: (id) key inDictionary: (NSDictionary *) dictionary{
    return [self objectFromCollection:[dictionary objectForKey:key]];
}

+(id) objectToCollection: (id) object{
    if(object == nil){
        object = [NSNull null];
    }
    return object;
}

+(id) objectFromCollection: (id) object{
    if(object != nil && [object isEqual:[NSNull null]]){
        object = nil;
    }
    return object;
}

@end
