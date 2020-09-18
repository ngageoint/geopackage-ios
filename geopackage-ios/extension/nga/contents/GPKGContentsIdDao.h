//
//  GPKGContentsIdDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGGeoPackage.h"
#import "GPKGContentsId.h"

/**
 * Contents Id Data Access Object
 */
@interface GPKGContentsIdDao : GPKGBaseDao

/**
 * Create the DAO
 *
 * @param geoPackage
 *            geoPackage
 * @return dao
 */
+(GPKGContentsIdDao *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Create the DAO
 *
 * @param db
 *            database connection
 * @return dao
 */
+(GPKGContentsIdDao *) createWithDatabase: (GPKGConnection *) database;

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new contents id dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Get the contents id for the current result in the result set
 *
 *  @param results result set
 *
 *  @return contents id
 */
-(GPKGContentsId *) contentsId: (GPKGResultSet *) results;

/**
 *  Query for and set the contents in the contents id
 *
 *  @param contentsId contents id
 */
-(void) setContents: (GPKGContentsId *) contentsId;

/**
 *  Query for the contents for the contents id
 *
 *  @param contentsId contents id
 *
 *  @return contents
 */
-(GPKGContents *) contents: (GPKGContentsId *) contentsId;

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
