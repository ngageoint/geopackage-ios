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
#import "GPKGDbConnection.h"
#import "GPKGSqliteConnection.h"
#import "GPKGDataTypes.h"

/**
 *  SQL utility methods
 */
@interface GPKGSqlUtils : NSObject

/**
 *  Execute statement on the database
 *
 *  @param connection  connection
 *  @param statement statement
 */
+(void) execWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement;

/**
 *  Query statement on the database
 *
 *  @param connection  connection
 *  @param statement statement
 *  @param args      statement args
 *
 *  @return result set
 */
+(GPKGResultSet *) queryWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args;

/**
 *  Query on the database
 *
 *  @param connection  connection
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
+(GPKGResultSet *) queryWithDatabase: (GPKGDbConnection *) connection
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
 *  @param connection  connection
 *  @param statement count statement
 *  @param args      statement args
 *
 *  @return count
 */
+(int) countWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args;

/**
 *  Count on the database table where
 *
 *  @param connection  connection
 *  @param table    table
 *  @param where    where clause
 *
 *  @return count
 */
+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andWhere: (NSString *) where;

/**
 *  Count on the database table where
 *
 *  @param connection  connection
 *  @param table     table
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return count
 */
+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Count on the database
 *
 *  @param connection     database connection
 *  @param countStatement count statement
 *
 *  @return count
 */
+(int) countWithDatabase: (GPKGDbConnection *) connection andCountStatement: (NSString *) countStatement;

/**
 *  Count on the database
 *
 *  @param connection  connection
 *  @param countStatement count statement
 *  @param args           statement args
 *
 *  @return count
 */
+(int) countWithDatabase: (GPKGDbConnection *) connection andCountStatement: (NSString *) countStatement andArgs: (NSArray *) args;

/**
 * Query the SQL for a single result object with the expected data type
 *
 * @param connection
 *            connection
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param column
 *            column index
 * @param dataType
 *            GeoPackage data type
 * @return result, null if no result
 */
+(NSObject *) querySingleResultWithDatabase: (GPKGDbConnection *) connection andSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType;

/**
 * Query for values from a single column up to the limit
 *
 * @param connection
 *            connection
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param column
 *            column index
 * @param dataType
 *            GeoPackage data type
 * @param limit
 *            result row limit
 * @return single column results
 */
+(NSArray<NSObject *> *) querySingleColumnResultsWithDatabase: (GPKGDbConnection *) connection andSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType andLimit: (NSNumber *) limit;

/**
 * Query for values up to the limit
 *
 * @param connection
 *            connection
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param dataTypes
 *            column data types
 * @param limit
 *            result row limit
 * @return results
 */
+(NSArray<NSArray<NSObject *> *> *) queryResultsWithDatabase: (GPKGDbConnection *) connection andSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes andLimit: (NSNumber *) limit;

/**
 * Get the value from the result set from the provided column
 *
 * @param result
 *            result
 * @param index
 *            index
 * @return value
 */
+(NSObject *) valueInResult: (GPKGResultSet *) result atIndex: (int) index;

/**
 * Get the value from the result set from the provided column
 *
 * @param result
 *            result
 * @param index
 *            index
 * @param dataType
 *            data type
 * @return value
 */
+(NSObject *) valueInResult: (GPKGResultSet *) result atIndex: (int) index withDataType: (enum GPKGDataType) dataType;

/**
 * Get the integer value from the result set of the column
 *
 * @param result
 *            result
 * @param index
 *            index
 * @param dataType
 *            data type
 * @return integer value
 */
+(NSObject *) integerValueInResult: (GPKGResultSet *) result atIndex: (int) index withDataType: (enum GPKGDataType) dataType;

/**
 * Get the float value from the result set of the column
 *
 * @param result
 *            result
 * @param index
 *            index
 * @param dataType
 *            data type
 * @return float value
 */
+(NSObject *) floatValueInResult: (GPKGResultSet *) result atIndex: (int) index withDataType: (enum GPKGDataType) dataType;

/**
 *  Min on the database table column where
 *
 *  @param connection  connection
 *  @param table     table
 *  @param column    column
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return min or nil
 */
+(NSNumber *) minWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Max on the database table column where
 *
 *  @param connection  connection
 *  @param table     table
 *  @param column    column
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return max or nil
 */
+(NSNumber *) maxWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Insert into database
 *
 *  @param connection  connection
 *  @param statement insert statement
 *
 *  @return insertion id
 */
+(long long) insertWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement;

/**
 *  Insert into database
 *
 *  @param connection  connection
 *  @param table    table
 *  @param values   values
 *
 *  @return insertion id
 */
+(long long) insertWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andValues: (GPKGContentValues *) values;

/**
 *  Update in the database
 *
 *  @param connection  connection
 *  @param statement update statement
 *
 *  @return updated rows
 */
+(int) updateWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement;

/**
 *  Update in the database
 *
 *  @param connection  connection
 *  @param statement update statement
 *  @param args      statement args
 *
 *  @return updated rows
 */
+(int) updateWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args;

/**
 *  Update in the database
 *
 *  @param connection  connection
 *  @param table    table
 *  @param values   content values
 *  @param where    where clause
 *
 *  @return updated rows
 */
+(int) updateWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where;

/**
 *  Update in the database
 *
 *  @param connection  connection
 *  @param table     table
 *  @param values    content values
 *  @param where     where clause
 *  @param whereArgs wher args
 *
 *  @return updated rows
 */
+(int) updateWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Delete from the database
 *
 *  @param connection  connection
 *  @param statement statement
 *
 *  @return deleted rows
 */
+(int) deleteWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement;

/**
 *  Delete from the database
 *
 *  @param connection  connection
 *  @param statement statement
 *  @param args      statement args
 *
 *  @return deleted rows
 */
+(int) deleteWithDatabase: (GPKGDbConnection *) connection andStatement: (NSString *) statement andArgs: (NSArray *) args;

/**
 *  Delete from the database
 *
 *  @param connection  connection
 *  @param table    table
 *  @param where    where clause
 *
 *  @return deleted rows
 */
+(int) deleteWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andWhere: (NSString *) where;

/**
 *  Delete from the database
 *
 *  @param connection  connection
 *  @param table     table
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return deleted rows
 */
+(int) deleteWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Close the statement
 *
 *  @param statement statement
 */
+(void) closeStatement: (sqlite3_stmt *) statement;

/**
 *  Close the result set
 *
 *  @param resultSet result set
 */
+(void) closeResultSet: (GPKGResultSet *) resultSet;

/**
 *  Close the database
 *
 *  @param connection  connection
 */
+(void) closeDatabase: (GPKGSqliteConnection *) connection;

/**
 *  Get the sql string for the value
 *
 *  @param value value
 *
 *  @return sql string
 */
+(NSString *) getSqlValueString: (NSObject *) value;

/**
 * Wrap the name in double quotes
 *
 * @param name
 *            name
 * @return quoted name
 */
+(NSString *) quoteWrapName: (NSString *) name;

/**
 * Wrap the names in double quotes
 *
 * @param names
 *            names
 * @return quoted names
 */
+(NSArray *) quoteWrapNames: (NSArray *) names;

@end
