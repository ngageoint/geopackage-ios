//
//  GPKGUserColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserColumn.h"

/**
 * Abstract collection of columns from a user table, representing a full set of
 * table columns or a subset from a query
 */
@interface GPKGUserColumns : NSObject <NSMutableCopying>

/**
 *  Table name, null when a pre-ordered subset of columns for a query
 */
@property (nonatomic, strong) NSString *tableName;

/**
 * Custom column specification flag (subset of table columns or different
 * ordering)
 */
@property (nonatomic) BOOL custom;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns     columns
 *  @param custom       custom column specification
 *
 *  @return new user table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andCustom: (BOOL) custom;

/**
 * Initialize
 *
 * @param userColumns
 *            user columns
 *
 *  @return new user table
 */
-(instancetype) initWithUserColumns: (GPKGUserColumns *) userColumns;

/**
 * Update the table columns
 */
-(void) updateColumns;

// TODO

@end
