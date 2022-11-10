//
//  GPKGDgiwgValidationKey.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * DGIWG (Defence Geospatial Information Working Group) validation primary key
 * value
 */
@interface GPKGDgiwgValidationKey : NSObject

/**
 *  Column name
 */
@property (nonatomic, strong) NSString *column;

/**
 *  Value
 */
@property (nonatomic, strong) NSString *value;

/**
 * Initialize
 *
 * @param column
 *            column name
 * @param value
 *            column value
 */
-(instancetype) initWithColumn: (NSString *) column andValue: (NSString *) value;

/**
 * Initialize
 *
 * @param column
 *            column name
 * @param value
 *            column value
 */
-(instancetype) initWithColumn: (NSString *) column andNumber: (NSNumber *) value;

@end
