//
//  GPKGUserCustomDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGUserCustomRow.h"

/**
 * User Custom DAO for reading user custom data tables
 */
@interface GPKGUserCustomDao : GPKGUserDao

/**
 * Initializer
 *
 * @param database        database connection
 * @param table           user custom table
 * @return new user custom dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGUserCustomTable *) table;

/**
 * Initializer
 *
 * @param dao        user custom dao
 * @return new user custom dao
 */
-(instancetype) initWithDao: (GPKGUserCustomDao *) dao;

/**
 * Initializer
 *
 * @param dao        user custom dao
 * @param table           user custom table
 * @return new user custom dao
 */
-(instancetype) initWithDao: (GPKGUserCustomDao *) dao andTable: (GPKGUserCustomTable *) table;

/**
 *  Get the user custom table
 *
 *  @return user custom table
 */
-(GPKGUserCustomTable *) userCustomTable;

/**
 *  Get the user custom row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return user custom row
 */
-(GPKGUserCustomRow *) row: (GPKGResultSet *) results;

/**
 *  Get a user custom row from the row
 *
 *  @param row result row
 *
 *  @return user custom row
 */
-(GPKGUserCustomRow *) rowWithRow: (GPKGRow *) row;

/**
 *  Create a new user custom row
 *
 *  @return user custom row
 */
-(GPKGUserCustomRow *) newRow;

/**
 * Get the count of the result set and close it
 *
 * @param resultSet
 *            result set
 * @return count
 */
-(int) countOfResultSet: (GPKGResultSet *) resultSet;

/**
 * Read the database table and create a DAO
 *
 * @param database
 *            database name
 * @param connection
 *            db connection
 * @param tableName
 *            table name
 * @return user custom DAO
 */
+(GPKGUserCustomDao *) readTableWithDatabase: (NSString *) database andConnection: (GPKGConnection *) connection andTable: (NSString *) tableName;

@end
