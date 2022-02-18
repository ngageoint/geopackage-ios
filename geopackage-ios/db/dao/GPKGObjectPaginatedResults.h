//
//  GPKGObjectPaginatedResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGPaginatedResults.h"
#import "GPKGBaseDao.h"

@class GPKGBaseDao;

/**
 * Paginated Object Results for iterating and querying through chunks
 */
@interface GPKGObjectPaginatedResults : GPKGPaginatedResults

/**
 * Create
 *
 * @param dao
 *            base dao
 * @param resultSet
 *            result set
 *
 * @return new object paginated results
 */
+(GPKGObjectPaginatedResults *) createWithDao: (GPKGBaseDao *) dao andResultSet: (GPKGResultSet *) resultSet;

/**
 * Initialize
 *
 * @param dao
 *            base dao
 * @param resultSet
 *            result set
 *
 * @return new object paginated results
 */
-(instancetype) initWithDao: (GPKGBaseDao *) dao andResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the base DAO
 *
 * @return base DAO
 */
-(GPKGBaseDao *) dao;

/**
 *  Get the current object from the result set
 *
 *  @return object
 */
-(NSObject *) object;

@end
