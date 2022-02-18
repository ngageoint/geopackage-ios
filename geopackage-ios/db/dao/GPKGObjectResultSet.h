//
//  GPKGObjectResultSet.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGBaseDao.h"
#import "GPKGResultSet.h"

@class GPKGBaseDao;

/**
 *  Object wrapped Result set
 */
@interface GPKGObjectResultSet : NSObject <NSFastEnumeration>

/**
 *  Create
 *
 *  @param dao base dao
 *  @param resultSet result set
 *
 *  @return new object result set
 */
+(GPKGObjectResultSet *) createWithDao: (GPKGBaseDao *) dao andResults: (GPKGResultSet *) resultSet;

/**
 *  Initialize
 *
 *  @param dao base dao
 *  @param resultSet result set
 *
 *  @return new object result set
 */
-(instancetype) initWithDao: (GPKGBaseDao *) dao andResults: (GPKGResultSet *) resultSet;

/**
 *  Get the DAO
 *
 *  @return DAO
 */
-(GPKGBaseDao *) dao;

/**
 *  Get the result set
 *
 *  @return result set
 */
-(GPKGResultSet *) resultSet;

/**
 *  Get the result set count
 *
 *  @return count
 */
-(int) count;

/**
 *  Move to the next result if one exists
 *
 *  @return true if a result found, false if no more results
 */
-(BOOL) moveToNext;

/**
 *  Move to the first result
 *
 *  @return reset code
 */
-(BOOL) moveToFirst;

/**
 *  Move result to index position
 *
 *  @param position index position
 *
 *  @return true if result at position found
 */
-(BOOL) moveToPosition: (int) position;

/**
 *  Get the current object from the result set
 *
 *  @return object
 */
-(NSObject *) object;

/**
 *  Close the result set
 */
-(void) close;

@end
