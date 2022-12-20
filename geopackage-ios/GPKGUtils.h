//
//  GPKGUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/28/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <UIKit/UIKit.h>

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
 *  Add an object to a set, supports nil to NSNull translations
 *
 *  @param object object
 *  @param set  set
 */
+(void) addObject: (id) object toSet: (NSMutableSet *) set;

/**
 *  Contains object in set, supports NSNull to nil transations
 *
 *  @param object object
 *  @param set set
 *
 *  @return YES if contains
 */
+(BOOL) containsObject: (id) object inSet: (NSMutableSet *) set;

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

/**
 *  Get the color for the color dictionary. The dictionary should contain the keys for:
 *
 *       red, green, blue, alpha     OR    white, alpha
 *
 *  Each value should be a float between 0.0 and 1.0
 *
 *  @param color color dictionary
 *
 *  @return color
 */
+(UIColor *) color: (NSDictionary *) color;

/**
 *  Get a decimal number from the number
 *
 *  @param number number value
 *
 *  @return decimal number
 */
+(NSDecimalNumber *) decimalNumberFromNumber: (NSNumber *) number;

/**
 *  Compare two doubles
 *
 *  @param value first double value
 *  @param value2 second double value
 *
 *  @return true if equal within epsilon
 */
+(BOOL) compareDouble: (double) value withDouble: (double) value2;

/**
 *  Compare two doubles
 *
 *  @param value first double value
 *  @param value2 second double value
 *  @param delta delta comparison
 *
 *  @return true if equal within epsilon
 */
+(BOOL) compareDouble: (double) value withDouble: (double) value2 andDelta: (double) delta;

/**
 *  Compare two number doubles
 *
 *  @param value first number double
 *  @param value2 second number double
 *
 *  @return true if equal within epsilon
 */
+(BOOL) compareNumberDouble: (NSNumber *) value withNumberDouble: (NSNumber *) value2;

/**
 *  Compare two number doubles
 *
 *  @param value first number double
 *  @param value2 second number double
 *  @param delta delta comparison
 *
 *  @return true if equal within epsilon
 */
+(BOOL) compareNumberDouble: (NSNumber *) value withNumberDouble: (NSNumber *) value2 andDelta: (double) delta;

@end
