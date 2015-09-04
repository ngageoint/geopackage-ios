//
//  GPKGSqlUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/14/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGResultSet.h"
#import <sqlite3.h>
#import "GPKGContentValues.h"

/**
 *  SQL utility methods
 */
@interface GPKGSqlUtils : NSObject

/**
 *  Execute statement on the database
 *
 *  @param database  database
 *  @param statement statement
 */
+(void) execWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement;

/**
 *  Query statement on the database
 *
 *  @param database  database
 *  @param statement statement
 *  @param args      statement args
 *
 *  @return result set
 */
+(GPKGResultSet *) queryWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement andArgs: (NSArray *) args;

/**
 *  Query on the database
 *
 *  @param database  databaes
 *  @param distinct  distinct flag
 *  @param table     table
 *  @param columns   columns
 *  @param where     where clause
 *  @param whereArgs where args
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *  @param limit     limit clause
 *
 *  @return result set
 */
+(GPKGResultSet *) queryWithDatabase: (sqlite3 *) database
                            andDistinct: (BOOL) distinct
                            andTable: (NSString *) table
                            andColumns: (NSArray *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit;

/**
 *  Count on the database
 *
 *  @param database  database
 *  @param statement count statement
 *  @param args      statement args
 *
 *  @return count
 */
+(int) countWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement andArgs: (NSArray *) args;

/**
 *  Count on the database table where
 *
 *  @param database database
 *  @param table    table
 *  @param where    where clause
 *
 *  @return count
 */
+(int) countWithDatabase: (sqlite3 *) database andTable: (NSString *) table andWhere: (NSString *) where;

/**
 *  Count on the database table where
 *
 *  @param database  database
 *  @param table     table
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return count
 */
+(int) countWithDatabase: (sqlite3 *) database andTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Count on the database
 *
 *  @param database       database
 *  @param countStatement count statement
 *
 *  @return count
 */
+(int) countWithDatabase: (sqlite3 *) database andCountStatement: (NSString *) countStatement;

/**
 *  Count on the database
 *
 *  @param database       database
 *  @param countStatement count statement
 *  @param args           statement args
 *
 *  @return count
 */
+(int) countWithDatabase: (sqlite3 *) database andCountStatement: (NSString *) countStatement andArgs: (NSArray *) args;

/**
 *  Insert into database
 *
 *  @param database  database
 *  @param statement insert statement
 *
 *  @return insertion id
 */
+(long long) insertWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement;

/**
 *  Insert into database
 *
 *  @param database database
 *  @param table    table
 *  @param values   values
 *
 *  @return insertion id
 */
+(long long) insertWithDatabase: (sqlite3 *) database andTable: (NSString *) table andValues: (GPKGContentValues *) values;

/**
 *  Update in the database
 *
 *  @param database  database
 *  @param statement update statement
 *
 *  @return updated rows
 */
+(int) updateWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement;

/**
 *  Update in the database
 *
 *  @param database  database
 *  @param statement update statement
 *  @param args      statement args
 *
 *  @return updated rows
 */
+(int) updateWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement andArgs: (NSArray *) args;

/**
 *  Update in the database
 *
 *  @param database database
 *  @param table    table
 *  @param values   content values
 *  @param where    where clause
 *
 *  @return updated rows
 */
+(int) updateWithDatabase: (sqlite3 *) database andTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where;

/**
 *  Update in the database
 *
 *  @param database  database
 *  @param table     table
 *  @param values    content values
 *  @param where     where clause
 *  @param whereArgs wher args
 *
 *  @return updated rows
 */
+(int) updateWithDatabase: (sqlite3 *) database andTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Delete from the database
 *
 *  @param database  database
 *  @param statement statement
 *
 *  @return deleted rows
 */
+(int) deleteWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement;

/**
 *  Delete from the database
 *
 *  @param database  database
 *  @param statement statement
 *  @param args      statement args
 *
 *  @return deleted rows
 */
+(int) deleteWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement andArgs: (NSArray *) args;

/**
 *  Delete from the database
 *
 *  @param database database
 *  @param table    table
 *  @param where    where clause
 *
 *  @return deleted rows
 */
+(int) deleteWithDatabase: (sqlite3 *) database andTable: (NSString *) table andWhere: (NSString *) where;

/**
 *  Delete from the database
 *
 *  @param database  database
 *  @param table     table
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return deleted rows
 */
+(int) deleteWithDatabase: (sqlite3 *) database andTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Close the statement
 *
 *  @param statment statement
 */
+(void) closeStatement: (sqlite3_stmt *) statment;

/**
 *  Close the result set
 *
 *  @param resultSet result set
 */
+(void) closeResultSet: (GPKGResultSet *) resultSet;

/**
 *  Close the database
 *
 *  @param database database
 */
+(void) closeDatabase: (sqlite3 *) database;

/**
 *  Get the sql string for the value
 *
 *  @param value value
 *
 *  @return sql string
 */
+(NSString *) getSqlValueString: (NSObject *) value;

@end
