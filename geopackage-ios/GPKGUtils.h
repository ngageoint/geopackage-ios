//
//  GPKGUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/28/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGUtils : NSObject

+(void) addObject: (id) object toArray: (NSMutableArray *) array;

+(void) replaceObjectAtIndex: (NSUInteger) index withObject: (id) object inArray: (NSMutableArray *) array;

+(void) insertObject: (id) object atIndex: (NSUInteger) index inArray: (NSMutableArray *) array;

+(id) objectAtIndex: (NSUInteger) index inArray: (NSArray *) array;

+(void) setObject: (id) object forKey: (id<NSCopying>) key inDictionary: (NSMutableDictionary *) dictionary;

+(id) objectForKey: (id) key inDictionary: (NSDictionary *) dictionary;

@end
