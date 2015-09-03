//
//  GPKGColumnValues.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/4/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Collection of column values
 */
@interface GPKGColumnValues : NSObject

/**
 *  Mapping between columns and values
 */
@property (nonatomic, strong) NSMutableDictionary *values;

/**
 *  Array of columns
 */
@property (nonatomic, strong) NSMutableArray *columns;

/**
 *  Initialize
 *
 *  @return new column values
 */
-(instancetype) init;

/**
 *  Get the column value count
 *
 *  @return column value count
 */
-(int) count;

/**
 *  Add a column and value
 *
 *  @param column column
 *  @param value  value
 */
-(void) addColumn: (NSString *) column withValue:(NSObject *) value;

/**
 *  Get the value of the column
 *
 *  @param column column
 *
 *  @return value
 */
-(NSObject *) getValue: (NSString *) column;

@end
