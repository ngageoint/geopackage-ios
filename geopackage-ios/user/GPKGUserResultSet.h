//
//  GPKGUserResultSet.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/28/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGResultSet.h"
#import "GPKGUserTable.h"

// TODO Delete

/**
 *  User Result Set
 */
@interface GPKGUserResultSet : GPKGResultSet

/**
 *  Initialize
 *
 *  @param table     user table
 *  @param statement statement
 *  @param count     result count
 *  @param connection connection
 *
 *  @return new user result set
 */
-(instancetype) initWithTable: (GPKGUserTable *) table andStatement:(sqlite3_stmt *) statement andCount: (int) count andConnection: (GPKGDbConnection *) connection;

/**
 *  Initialize
 *
 *  @param table     user table
 *  @param columnNames column names
 *  @param statement statement
 *  @param count     result count
 *  @param connection connection
 *
 *  @return new user result set
 */
-(instancetype) initWithTable: (GPKGUserTable *) table andColumnNames: (NSArray<NSString *> *) columnNames andStatement:(sqlite3_stmt *) statement andCount: (int) count andConnection: (GPKGDbConnection *) connection;

/**
 *  Initialize
 *
 *  @param table     user table
 *  @param columns columns
 *  @param statement statement
 *  @param count     result count
 *  @param connection connection
 *
 *  @return new user result set
 */
-(instancetype) initWithTable: (GPKGUserTable *) table andColumns: (GPKGUserColumns *) columns andStatement:(sqlite3_stmt *) statement andCount: (int) count andConnection: (GPKGDbConnection *) connection;

/**
 *  Value with column
 *
 *  @param column     user column
 *
 *  @return value
 */
-(NSObject *) valueWithColumn: (GPKGUserColumn *) column;

/**
 *  Id value
 *
 *  @return id value
 */
-(NSNumber *) id;

/**
 * Get the table
 *
 * @return table
 */
-(GPKGUserTable *) table;

/**
 * Get the columns
 *
 * @return columns
 */
-(GPKGUserColumns *) columns;

@end
