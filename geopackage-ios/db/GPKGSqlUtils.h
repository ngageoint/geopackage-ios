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
#import "GPKGUserTable.h"
#import "GPKGConnection.h"
#import "GPKGTableMapping.h"

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
 *  Execute statement on the SQLite connection
 *
 *  @param connection  connection
 *  @param statement statement
 */
+(void) execWithSQLiteConnection: (GPKGSqliteConnection *) connection andStatement: (NSString *) statement;

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
                            andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit;

/**
 *  Build Query SQL
 *
 *  @param distinct  distinct flag
 *  @param table     table
 *  @param columns   columns
 *  @param where     where clause
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *  @param limit     limit clause
 *
 *  @return result set
 */
+(NSString *) querySQLWithDistinct: (BOOL) distinct
                            andTable: (NSString *) table
                            andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
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
 *
 *  @return count
 */
+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table;

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
 * Get a count of table results
 *
 * @param connection
 *            connection
 * @param table
 *            table name
 * @param column
 *            column name
 * @return count
 */
+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column;

/**
 * Get a count of table results
 *
 * @param connection
 *            connection
 * @param table
 *            table name
 * @param distinct
 *            distinct column flag
 * @param column
 *            column name
 * @return count
 */
+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andDistinct: (BOOL) distinct andColumn: (NSString *) column;

/**
 * Get a count of table results
 *
 * @param connection
 *            connection
 * @param table
 *            table name
 * @param column
 *            column name
 * @param where
 *            where clause
 * @param whereArgs
 *            arguments
 * @return count
 */
+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Get a count of table results
 *
 * @param connection
 *            connection
 * @param table
 *            table name
 * @param distinct
 *            distinct column flag
 * @param column
 *            column name
 * @param where
 *            where clause
 * @param whereArgs
 *            arguments
 * @return count
 */
+(int) countWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
+(NSArray<GPKGRow *> *) queryResultsWithDatabase: (GPKGDbConnection *) connection andSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes andLimit: (NSNumber *) limit;

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
 * Get the value from the result set from the provided column
 *
 * @param result
 *            result
 * @param index
 *            index
 * @param type
 *            sqlite3 column type: SQLITE_INTEGER, SQLITE_FLOAT, SQLITE_STRING, SQLITE_BLOB, or SQLITE_NULL
 * @return value
 */
+(NSObject *) valueInResult: (GPKGResultSet *) result atIndex: (int) index withType: (int) type;

/**
 * Get the value from the result set from the provided column
 *
 * @param result
 *            result
 * @param index
 *            index
 * @param type
 *            sqlite3 column type: SQLITE_INTEGER, SQLITE_FLOAT, SQLITE_STRING, SQLITE_BLOB, or SQLITE_NULL
 * @param dataType
 *            data type
 * @return value
 */
+(NSObject *) valueInResult: (GPKGResultSet *) result atIndex: (int) index withType: (int) type andDataType: (enum GPKGDataType) dataType;

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
 * Get the converted value from the value and data type
 *
 * @param value
 *            object value
 * @param dataType
 *            data type
 * @return object
 */
+(NSObject *) value: (NSObject *) value asDataType: (enum GPKGDataType) dataType;

/**
*  Min on the database table column where
*
*  @param connection  connection
*  @param table     table
*  @param column    column
*
*  @return min or nil
*/
+(NSNumber *) minWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column;

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
*
*  @return max or nil
*/
+(NSNumber *) maxWithDatabase: (GPKGDbConnection *) connection andTable: (NSString *) table andColumn: (NSString *) column;

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
+(NSString *) sqlValueString: (NSObject *) value;

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

/**
 * Remove double quotes from the name
 *
 * @param name
 *            name
 * @return unquoted names
 */
+(NSString *) quoteUnwrapName: (NSString *) name;

/**
 * Create the user defined table SQL
 *
 * @param table
 *            user table
 * @return create table SQL
 */
+(NSString *) createTableSQL: (GPKGUserTable *) table;

/**
 * Create the column SQL in the format:
 *
 * "column_name" column_type[(max)] [NOT NULL] [PRIMARY KEY AUTOINCREMENT]
 *
 * @param column
 *            user column
 * @return column SQL
 */
+(NSString *) columnSQL: (GPKGUserColumn *) column;

/**
 * Create the column definition SQL in the format:
 *
 * column_type[(max)] [NOT NULL] [PRIMARY KEY AUTOINCREMENT]
 *
 * @param column
 *            user column
 * @return column definition SQL
 */
+(NSString *) columnDefinition: (GPKGUserColumn *) column;

/**
 * Get the column default value as a string
 *
 * @param column
 *            user column
 * @return default value
 */
+(NSString *) columnDefaultValue: (GPKGUserColumn *) column;

/**
 * Get the column default value as a string
 *
 * @param defaultValue
 *            default value
 * @param dataType
 *            data type
 * @return default value
 */
+(NSString *) columnDefaultValue: (NSObject *) defaultValue withType: (enum GPKGDataType) dataType;

/**
 * Add a column to a table
 *
 * @param column
 *            user column
 * @param tableName
 *            table name
 * @param db
 *            connection
 */
+(void) addColumn: (GPKGUserColumn *) column toTable: (NSString *) tableName withConnection: (GPKGConnection *) db;

/**
 * Query for the foreign keys value
 *
 * @param db
 *            connection
 * @return true if enabled, false if disabled
 */
+(BOOL) foreignKeysWithConnection: (GPKGConnection *) db;

/**
 * Change the foreign keys state
 *
 *
 * @param on
 *            true to turn on, false to turn off
 * @param db
 *            connection
 * @return previous foreign keys value
 */
+(BOOL) foreignKeysAsOn: (BOOL) on withConnection: (GPKGConnection *) db;

/**
 * Create the foreign keys SQL
 *
 * @param on
 *            true to turn on, false to turn off
 * @return foreign keys SQL
 */
+(NSString *) foreignKeysSQLAsOn: (BOOL) on;

/**
 * Perform a foreign key check
 *
 * @param db
 *            connection
 * @return empty list if valid or violation errors, 4 column values for each
 *         violation. see SQLite PRAGMA foreign_key_check
 */
+(NSArray<GPKGRow *> *) foreignKeyCheckWithConnection: (GPKGConnection *) db;

/**
 * Perform a foreign key check
 *
 * @param tableName
 *            table name
 * @param db
 *            connection
 * @return empty list if valid or violation errors, 4 column values for each
 *         violation. see SQLite PRAGMA foreign_key_check
 */
+(NSArray<GPKGRow *> *) foreignKeyCheckOnTable: (NSString *) tableName withConnection: (GPKGConnection *) db;

/**
 * Create the foreign key check SQL
 *
 * @return foreign key check SQL
 */
+(NSString *) foreignKeyCheckSQL;

/**
 * Create the foreign key check SQL
 *
 * @param tableName
 *            table name
 * @return foreign key check SQL
 */
+(NSString *) foreignKeyCheckSQLOnTable: (NSString *) tableName;

/**
 * Create the integrity check SQL
 *
 * @return integrity check SQL
 */
+(NSString *) integrityCheckSQL;

/**
 * Create the quick check SQL
 *
 * @return quick check SQL
 */
+(NSString *) quickCheckSQL;

/**
 * Drop the table if it exists
 *
 * @param tableName
 *            table name
 * @param db
 *            connection
 */
+(void) dropTable: (NSString *) tableName withConnection: (GPKGConnection *) db;

/**
 * Create the drop table if exists SQL
 *
 * @param tableName
 *            table name
 * @return drop table SQL
 */
+(NSString *) dropTableSQL: (NSString *) tableName;

/**
 * Drop the view if it exists
 *
 * @param viewName
 *            view name
 * @param db
 *            connection
 */
+(void) dropView: (NSString *) viewName withConnection: (GPKGConnection *) db;

/**
 * Create the drop view if exists SQL
 *
 * @param viewName
 *            view name
 * @return drop view SQL
 */
+(NSString *) dropViewSQL: (NSString *) viewName;

/**
 * Transfer table content from one table to another
 *
 * @param tableMapping
 *            table mapping
 * @param db
 *            connection
 */
+(void) transferTableContent: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db;

/**
 * Create insert SQL to transfer table content from one table to another
 *
 * @param tableMapping
 *            table mapping
 * @return transfer SQL
 */
+(NSString *) transferTableContentSQL: (GPKGTableMapping *) tableMapping;

/**
 * Transfer table content to itself with new rows containing a new column
 * value. All rows containing the current column value are inserted as new
 * rows with the new column value.
 *
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @param newColumnValue
 *            new column value for new rows
 * @param currentColumnValue
 *            column value for rows to insert as new rows
 * @param db
 *            connection
 */
+(void) transferContentInTable: (NSString *) tableName inColumn: (NSString *) columnName withNewValue: (NSObject *) newColumnValue andCurrentValue: (NSObject *) currentColumnValue withConnection: (GPKGConnection *) db;

/**
 * Transfer table content to itself with new rows containing a new column
 * value. All rows containing the current column value are inserted as new
 * rows with the new column value.
 *
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @param newColumnValue
 *            new column value for new rows
 * @param currentColumnValue
 *            column value for rows to insert as new rows
 * @param idColumnName
 *            id column name
 * @param db
 *            connection
 */
+(void) transferContentInTable: (NSString *) tableName inColumn: (NSString *) columnName withNewValue: (NSObject *) newColumnValue andCurrentValue: (NSObject *) currentColumnValue andIdColumn: (NSString *) idColumnName withConnection: (GPKGConnection *) db;

/**
 * Get an available temporary table name. Starts with prefix_baseName and
 * then continues with prefix#_baseName starting at 1 and increasing.
 *
 * @param prefix
 *            name prefix
 * @param baseName
 *            base name
 * @param db
 *            connection
 * @return unused table name
 */
+(NSString *) tempTableNameWithPrefix: (NSString *) prefix andBaseName: (NSString *) baseName withConnection: (GPKGConnection *) db;

/**
 * Modify the SQL with a name change and the table mapping modifications
 *
 * @param name
 *            statement name
 * @param sql
 *            SQL statement
 * @param tableMapping
 *            table mapping
 * @return updated SQL, null if SQL contains a deleted column
 */
+(NSString *) modifySQL: (NSString *) sql withName: (NSString *) name andTableMapping: (GPKGTableMapping *) tableMapping;

/**
 * Modify the SQL with a name change and the table mapping modifications
 *
 * @param name
 *            statement name
 * @param sql
 *            SQL statement
 * @param tableMapping
 *            table mapping
 * @param db
 *            optional connection, used for SQLite Master name conflict
 *            detection
 * @return updated SQL, null if SQL contains a deleted column
 */
+(NSString *) modifySQL: (NSString *) sql withName: (NSString *) name andTableMapping: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db;

/**
 * Modify the SQL with table mapping modifications
 *
 * @param sql
 *            SQL statement
 * @param tableMapping
 *            table mapping
 * @return updated SQL, null if SQL contains a deleted column
 */
+(NSString *) modifySQL: (NSString *) sql withTableMapping: (GPKGTableMapping *) tableMapping;

/**
 * Replace the name (table, column, etc) in the SQL with the replacement.
 * The name must be surrounded by non word characters (i.e. not a subset of
 * another name).
 *
 * @param name
 *            name
 * @param sql
 *            SQL statement
 * @param replacement
 *            replacement value
 * @return null if not modified, SQL value if replaced at least once
 */
+(NSString *) replaceName: (NSString *) name inSQL: (NSString *) sql withReplacement: (NSString *) replacement;

/**
 * Create a new name by replacing a case insensitive value with a new value.
 * If no replacement is done, create a new name in the form name_#, where #
 * is either 2 or one greater than an existing name number suffix.
 *
 * @param name
 *            current name
 * @param replace
 *            value to replace
 * @param replacement
 *            replacement value
 * @return new name
 */
+(NSString *) createName: (NSString *) name andReplace: (NSString *) replace withReplacement: (NSString *) replacement;

/**
 * Create a new name by replacing a case insensitive value with a new value.
 * If no replacement is done, create a new name in the form name_#, where #
 * is either 2 or one greater than an existing name number suffix. When a db
 * connection is provided, check for conflicting SQLite Master names and
 * increment # until an available name is found.
 *
 * @param name
 *            current name
 * @param replace
 *            value to replace
 * @param replacement
 *            replacement value
 * @param db
 *            optional connection, used for SQLite Master name conflict
 *            detection
 * @return new name
 */
+(NSString *) createName: (NSString *) name andReplace: (NSString *) replace withReplacement: (NSString *) replacement withConnection: (GPKGConnection *) db;

/**
 * Rebuild the GeoPackage, repacking it into a minimal amount of disk space
 *
 * @param db
 *            connection
 */
+(void) vacuumWithConnection: (GPKGConnection *) db;

/**
 * Get the BOOL value of the number
 *
 * @param number
 *            BOOL number
 */
+(BOOL) boolValueOfNumber: (NSNumber *) number;

@end
