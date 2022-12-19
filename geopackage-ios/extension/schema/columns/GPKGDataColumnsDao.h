//
//  GPKGDataColumnsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGDataColumns.h"

/**
 *  Data Columns Data Access Object
 */
@interface GPKGDataColumnsDao : GPKGBaseDao

/**
 * Create the DAO
 *
 * @param database
 *            database connection
 * @return dao
 */
+(GPKGDataColumnsDao *) createWithDatabase: (GPKGConnection *) database;

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new data columns dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Get the Contents from the Data Columns
 *
 *  @param dataColumns data columns
 *
 *  @return contents
 */
-(GPKGContents *) contents: (GPKGDataColumns *) dataColumns;

/**
 *  Query by constraint name
 *
 *  @param constraintName constraint name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByConstraintName: (NSString *) constraintName;

/**
 *  Get DataColumn by column name and table name
 *
 *  @param tableName table name to query for
 *  @param columnName column name to query for
 *
 *  @return GPKGDataColumns
 */
-(GPKGDataColumns *) dataColumnByTableName: tableName andColumnName: columnName;

/**
 *  Query by table name
 *
 *  @param tableName table name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByTable: (NSString *) tableName;

/**
 * Delete by table name
 *
 * @param tableName
 *            table name
 * @return rows deleted
 */
-(int) deleteByTableName: (NSString *) tableName;

@end
