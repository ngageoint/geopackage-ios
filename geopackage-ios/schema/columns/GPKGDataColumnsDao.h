//
//  GPKGDataColumnsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGDataColumns.h"
#import "GPKGContents.h"

/**
 *  Data Columns Data Access Object
 */
@interface GPKGDataColumnsDao : GPKGBaseDao

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
-(GPKGContents *) getContents: (GPKGDataColumns *) dataColumns;

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
-(GPKGDataColumns *) getDataColumnByTableName: tableName andColumnName: columnName;

@end
