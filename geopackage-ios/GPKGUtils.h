//
//  GPKGUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/28/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  GeoPackage utility methods
 */
@interface GPKGUtils : NSObject

/**
 *  Add an object to an array, supports nil to NSNull translations
 *
 *  @param object object
 *  @param array  array
 */
+(void) addObject: (id) object toArray: (NSMutableArray *) array;

/**
 *  Replace object at index in array with an object, supports nil to NSNull translations
 *
 *  @param index  index
 *  @param object object
 *  @param array  array
 */
+(void) replaceObjectAtIndex: (NSUInteger) index withObject: (id) object inArray: (NSMutableArray *) array;

/**
 *  Insert object in an array, supports nil to NSNull translations
 *
 *  @param object object
 *  @param index  index
 *  @param array  array
 */
+(void) insertObject: (id) object atIndex: (NSUInteger) index inArray: (NSMutableArray *) array;

/**
 *  Get the object at an index, supports NSNull to nil transations
 *
 *  @param index index
 *  @param array array
 *
 *  @return object
 */
+(id) objectAtIndex: (NSUInteger) index inArray: (NSArray *) array;

/**
 *  Set object in dictionary with key, supports nil to NSNull translations
 *
 *  @param object     object
 *  @param key        key
 *  @param dictionary dictionary
 */
+(void) setObject: (id) object forKey: (id<NSCopying>) key inDictionary: (NSMutableDictionary *) dictionary;

/**
 *  Get object in dictionary with key, supports NSNull to nil transations
 *
 *  @param key        key
 *  @param dictionary dictionary
 *
 *  @return object
 */
+(id) objectForKey: (id) key inDictionary: (NSDictionary *) dictionary;

@end
