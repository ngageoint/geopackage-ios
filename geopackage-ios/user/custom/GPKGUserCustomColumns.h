//
//  GPKGUserCustomColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserColumns.h"

/**
 * Collection of user custom columns
 */
@interface GPKGUserCustomColumns : GPKGUserColumns

/**
 *  Required columns
 */
@property (nonatomic, strong) NSArray<NSString *> *requiredColumns;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns     columns
 *
 *  @return new user custom columns
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns     columns
 *  @param requiredColumns list of required columns
 *
 *  @return new user custom columns
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andRequiredColumns: (NSArray<NSString *> *) requiredColumns;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns     columns
 *  @param custom       custom column specification
 *
 *  @return new user custom columns
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andCustom: (BOOL) custom;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns     columns
 *  @param custom       custom column specification
 *  @param requiredColumns list of required columns  
 *
 *  @return new user custom columns
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andRequiredColumns: (NSArray<NSString *> *) requiredColumns andCustom: (BOOL) custom;

/**
 * Initialize
 *
 * @param userCustomColumns
 *            user custom columns
 *
 *  @return new user custom columns
 */
-(instancetype) initWithUserCustomColumns: (GPKGUserCustomColumns *) userCustomColumns;

@end
