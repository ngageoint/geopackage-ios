//
//  GPKGRowResultSet.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGUserDao.h"

@class GPKGUserDao;

/**
 *  User Row wrapped Result set
 */
@interface GPKGRowResultSet : GPKGObjectResultSet

/**
 *  Create
 *
 *  @param dao user dao
 *  @param resultSet result set
 *
 *  @return new row result set
 */
+(GPKGRowResultSet *) createWithDao: (GPKGUserDao *) dao andResults: (GPKGResultSet *) resultSet;

/**
 *  Initialize
 *
 *  @param dao user dao
 *  @param resultSet result set
 *
 *  @return new row result set
 */
-(instancetype) initWithDao: (GPKGUserDao *) dao andResults: (GPKGResultSet *) resultSet;

/**
 *  Get the DAO
 *
 *  @return DAO
 */
-(GPKGUserDao *) dao;

/**
 *  Get a user row from the current result
 *
 *  @return user row
 */
-(GPKGUserRow *) row;

@end
