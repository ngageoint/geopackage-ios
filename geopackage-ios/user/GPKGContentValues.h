//
//  GPKGContentValues.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/3/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Content Values mapping between columns and values
 */
@interface GPKGContentValues : NSObject

/**
 *  Mapping between columns and values
 */
@property (nonatomic, strong) NSMutableDictionary *values;

/**
 *  Initializer
 *
 *  @return new content values
 */
-(instancetype) init;

/**
 *  Put a key value pari
 *
 *  @param key   key
 *  @param value value
 */
-(void) putKey: (NSString *) key withValue: (NSObject *) value;

/**
 *  Put a key null value
 *
 *  @param key key
 */
-(void) putNullValueForKey: (NSString *) key;

/**
 *  Get the number of value mappings
 *
 *  @return mapping count
 */
-(int) size;

/**
 *  Get teh value of the key
 *
 *  @param key key
 *
 *  @return value
 */
-(NSObject *) getValueForKey: (NSString *) key;

/**
 *  Get a field key set
 *
 *  @return all keys
 */
-(NSArray *) keySet;

/**
 *  Get the key value as a string
 *
 *  @param key key
 *
 *  @return key string
 */
-(NSString *) getKeyAsString: (NSString *) key;

@end
