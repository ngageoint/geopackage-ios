//
//  GPKGUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/28/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUtils.h"
#import "GPKGPropertyConstants.h"

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

+(UIColor *) getColor: (NSDictionary *) color{
    
    UIColor * createdColor = nil;
    
    NSNumber * alpha = [color objectForKey:GPKG_PROP_COLORS_ALPHA];
    NSNumber * white = [color objectForKey:GPKG_PROP_COLORS_WHITE];
    if(white != nil){
        createdColor = [UIColor colorWithWhite:[white doubleValue] alpha:[alpha doubleValue]];
    }else{
        NSNumber * red = [color objectForKey:GPKG_PROP_COLORS_RED];
        NSNumber * green = [color objectForKey:GPKG_PROP_COLORS_GREEN];
        NSNumber * blue = [color objectForKey:GPKG_PROP_COLORS_BLUE];
        createdColor = [UIColor colorWithRed:[red doubleValue] green:[green doubleValue] blue:[blue doubleValue] alpha:[alpha doubleValue]];
    }
    
    return createdColor;
}

@end
