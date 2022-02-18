//
//  GPKGRowPaginatedResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGObjectPaginatedResults.h"
#import "GPKGUserDao.h"

@class GPKGUserDao;

/**
 * Paginated Row Results for iterating and querying through chunks
 */
@interface GPKGRowPaginatedResults : GPKGObjectPaginatedResults

/**
 * Create
 *
 * @param dao
 *            base dao
 * @param resultSet
 *            result set
 *
 * @return new row paginated results
 */
+(GPKGRowPaginatedResults *) createWithDao: (GPKGUserDao *) dao andResultSet: (GPKGResultSet *) resultSet;

/**
 * Initialize
 *
 * @param dao
 *            user dao
 * @param resultSet
 *            result set
 *
 * @return new row paginated results
 */
-(instancetype) initWithDao: (GPKGUserDao *) dao andResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the user DAO
 *
 * @return user DAO
 */
-(GPKGUserDao *) dao;

/**
 *  Get a user row from the current result
 *
 *  @return user row
 */
-(GPKGUserRow *) userRow;

@end
