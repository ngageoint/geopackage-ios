//
//  GPKGPaginatedResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/14/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGPagination.h"
#import "GPKGResultSet.h"

/**
 * Paginated Results for iterating and querying through chunks
 */
@interface GPKGPaginatedResults : NSObject

/**
 * Paginated query settings
 */
@property (nonatomic, strong) GPKGPagination *pagination;

/**
 * Initialize
 *
 * @param resultSet
 *            result set
 *
 * @return new paginated results
 */
-(instancetype) initWithResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the DB Connection
 *
 * @return SQL arguments
 */
-(GPKGDbConnection *) connection;

/**
 * Get the current paginated Result Set
 *
 * @return current Result Set
 */
-(GPKGResultSet *) resultSet;

/**
 * Get the initial SQL statement
 *
 * @return SQL statement
 */
-(NSString *) sql;

/**
 * Get the SQL arguments
 *
 * @return SQL arguments
 */
-(NSArray *) args;

/**
 *  Move to the next result if one exists
 *
 *  @return true if a result found, false if no more results
 */
-(BOOL) moveToNext;

/**
 *  Get the row value
 *
 *  @return row value array
 */
-(NSArray<NSObject *> *) row;

/**
 * Close the current results
 */
-(void) close;

@end
