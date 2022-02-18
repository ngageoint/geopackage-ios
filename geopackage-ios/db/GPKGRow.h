//
//  GPKGRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/17/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Result row
 */
@interface GPKGRow : NSObject

/**
 *  Column names
 */
@property (nonatomic, strong) NSArray<NSString *> *columns;

/**
 *  Column values
 */
@property (nonatomic, strong) NSArray<NSObject *> *values;

/**
 *  Initialize
 *
 *  @return new row
 */
+(GPKGRow *) create;

/**
 *  Initialize
 *
 *  @param values columns values
 *
 *  @return new row
 */
+(GPKGRow *) createWithValues: (NSArray<NSObject *> *) values;

/**
 *  Initialize
 *
 *  @param columns column names
 *  @param values columns values
 *
 *  @return new row
 */
+(GPKGRow *) createWithColumns: (NSArray<NSString *> *) columns andValues: (NSArray<NSObject *> *) values;

/**
 *  Initialize
 *
 *  @return new row
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param values columns values
 *
 *  @return new row
 */
-(instancetype) initWithValues: (NSArray<NSObject *> *) values;

/**
 *  Initialize
 *
 *@param columns column names
 *  @param values columns values
 *
 *  @return new row
 */
-(instancetype) initWithColumns: (NSArray<NSString *> *) columns andValues: (NSArray<NSObject *> *) values;

/**
 *  Get the count of values / columns
 *
 *  @return count
 */
-(int) count;

/**
 * Get the column name at the column index
 *
 * @param index column index
 *
 * @return column name
 */
-(NSString *) columnAtIndex: (int) index;

/**
 * Get the value at the column index
 *
 * @param index column index
 *
 * @return value
 */
-(NSObject *) valueAtIndex: (int) index;

/**
 * Get the value for the column name
 *
 * @param column
 *            column name
 * @return value
 */
-(NSObject *) valueWithColumn: (NSString *) column;

@end
