//
//  GPKGContentsIdDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGContentsId.h"

@interface GPKGContentsIdDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new contents id dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 * Query by table name
 *
 * @param tableName
 *            table name
 * @return contents id
 */
-(GPKGContentsId *) queryForTableName: (NSString *) tableName;

/**
 * Delete by table name
 *
 * @param tableName
 *            table name
 * @return rows deleted
 */
-(int) deleteByTableName: (NSString *) tableName;

@end
