//
//  GPKGConnection.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/7/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGResultSet.h"
#import "GPKGContentValues.h"

/**
 *  GeoPackage database connection
 */
@interface GPKGConnection : NSObject

/**
 *  GeoPackage name
 */
@property (nonatomic, strong) NSString *name;

/**
 *  GeoPackage filename
 */
@property (nonatomic, strong) NSString *filename;

/**
 *  Initialize
 *
 *  @param filename GeoPackage filename
 *
 *  @return new connection
 */
-(instancetype)initWithDatabaseFilename:(NSString *) filename;

/**
 *  Initialize
 *
 *  @param filename GeoPackage filename
 *  @param name GeoPackage name
 *
 *  @return new connection
 */
-(instancetype)initWithDatabaseFilename:(NSString *) filename andName:(NSString *) name;

/**
 *  Close the connection
 */
-(void)close;

/**
 *  Raw query
 *
 *  @param statement query statement
 *
 *  @return result set
 */
-(GPKGResultSet *) rawQuery:(NSString *) statement;

/**
 *  Raw query
 *
 *  @param statement query statement
 *  @param args      query args
 *
 *  @return result set
 */
-(GPKGResultSet *) rawQuery:(NSString *) statement andArgs: (NSArray *) args;

/**
 *  Query table columns where
 *
 *  @param table     table
 *  @param columns   columns
 *  @param where     where clause
 *  @param whereArgs where args
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *
 *  @return result set
 */
-(GPKGResultSet *) queryWithTable: (NSString *) table
                       andColumns: (NSArray<NSString *> *) columns
                       andWhere: (NSString *) where
                       andWhereArgs: (NSArray *) whereArgs
                       andGroupBy: (NSString *) groupBy
                       andHaving: (NSString *) having
                       andOrderBy: (NSString *) orderBy;

/**
 *  Query table columns where
 *
 *  @param distinct  distinct flag
 *  @param table     table
 *  @param columns   columns
 *  @param where     where clause
 *  @param whereArgs where args
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *
 *  @return result set
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct
                    andTable: (NSString *) table
                  andColumns: (NSArray<NSString *> *) columns
                    andWhere: (NSString *) where
                  andWhereArgs: (NSArray *) whereArgs
                  andGroupBy: (NSString *) groupBy
                   andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy;

/**
 *  Query table columns where
 *
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
-(GPKGResultSet *) queryWithTable: (NSString *) table
                       andColumns: (NSArray<NSString *> *) columns
                       andWhere: (NSString *) where
                       andWhereArgs: (NSArray *) whereArgs
                       andGroupBy: (NSString *) groupBy
                       andHaving: (NSString *) having
                       andOrderBy: (NSString *) orderBy
                       andLimit: (NSString *) limit;

/**
 *  Query table columns where
 *
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
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct
                            andTable: (NSString *) table
                          andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                          andWhereArgs: (NSArray *) whereArgs
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit;

/**
 *  Build query SQL
 *
 *  @param table     table
 *  @param columns   columns
 *  @param where     where clause
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *
 *  @return SQL
 */
-(NSString *) querySQLWithTable: (NSString *) table
                  andColumns: (NSArray<NSString *> *) columns
                    andWhere: (NSString *) where
                  andGroupBy: (NSString *) groupBy
                   andHaving: (NSString *) having
                     andOrderBy: (NSString *) orderBy;

/**
 *  Build query SQL
 *
 *  @param distinct  distinct flag
 *  @param table     table
 *  @param columns   columns
 *  @param where     where clause
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *
 *  @return SQL
 */
-(NSString *) querySQLWithDistinct: (BOOL) distinct
                    andTable: (NSString *) table
                  andColumns: (NSArray<NSString *> *) columns
                    andWhere: (NSString *) where
                  andGroupBy: (NSString *) groupBy
                   andHaving: (NSString *) having
                        andOrderBy: (NSString *) orderBy;

/**
 *  Build query SQL
 *
 *  @param table     table
 *  @param columns   columns
 *  @param where     where clause
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *  @param limit     limit clause
 *
 *  @return SQL
 */
-(NSString *) querySQLWithTable: (NSString *) table
                          andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                       andLimit: (NSString *) limit;

/**
 *  Build query SQL
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
 *  @return SQL
 */
-(NSString *) querySQLWithDistinct: (BOOL) distinct
                          andTable: (NSString *) table
                          andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                          andLimit: (NSString *) limit;

/**
 *  Count statement
 *
 *  @param statement count statement
 *
 *  @return count
 */
-(int) count:(NSString *) statement;

/**
 *  Count statement
 *
 *  @param statement count statement
 *  @param args      statement args
 *
 *  @return count
 */
-(int) count:(NSString *) statement andArgs: (NSArray *) args;

/**
 * Count with table
 *
 * @param table
 *            table name
 *
 * @return count
 */
-(int) countWithTable: (NSString *) table;

/**
 *  Count with table where
 *
 *  @param table table
 *  @param where where clause
 *
 *  @return count
 */
-(int) countWithTable: (NSString *) table andWhere: (NSString *) where;

/**
 *  Count with table where
 *
 *  @param table     table
 *  @param where     where
 *  @param whereArgs where args
 *
 *  @return count
 */
-(int) countWithTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Get a count of table results
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @return count
 */
-(int) countWithTable: (NSString *) table andColumn: (NSString *) column;

/**
 * Get a count of table results
 *
 * @param table
 *            table name
 * @param distinct
 *            distinct column flag
 * @param column
 *            column name
 * @return count
 */
-(int) countWithTable: (NSString *) table andDistinct: (BOOL) distinct andColumn: (NSString *) column;

/**
 * Get a count of table results
 *
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
-(int) countWithTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Get a count of table results
 *
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
-(int) countWithTable: (NSString *) table andDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Get the min result of the column
 *
 *  @param table     table
 *  @param column    column
 *
 *  @return min or nil
 */
-(NSNumber *) minWithTable: (NSString *) table andColumn: (NSString *) column;

/**
 *  Get the min result of the column
 *
 *  @param table     table
 *  @param column    column
 *  @param where     where
 *  @param whereArgs where args
 *
 *  @return min or nil
 */
-(NSNumber *) minWithTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Get the max result of the column
 *
 *  @param table     table
 *  @param column    column
 *
 *  @return max or nil
 */
-(NSNumber *) maxWithTable: (NSString *) table andColumn: (NSString *) column;

/**
 *  Get the max result of the column
 *
 *  @param table     table
 *  @param column    column
 *  @param where     where
 *  @param whereArgs where args
 *
 *  @return max or nil
 */
-(NSNumber *) maxWithTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Begin an exclusive transaction on the database
 */
-(void) beginTransaction;

/**
 *  Begin an exclusive transaction on the database, resetting other open connections upon commit
 */
-(void) beginResettableTransaction;

/**
 *  Commit an active transaction
 */
-(void) commitTransaction;

/**
 *  Rollback an active transaction
 */
-(void) rollbackTransaction;

/**
 * Determine if currently within a transaction
 *
 * @return true if in transaction
 */
-(BOOL) inTransaction;

/**
 * If foreign keys is disabled and there are no foreign key violations,
 * enables foreign key checks, else logs violations
 *
 * @return true if enabled or already enabled, false if foreign key
 *         violations and not enabled
 */
-(BOOL) enableForeignKeys;

/**
 * Query for the foreign keys value
 *
 * @return true if enabled, false if disabled
 */
-(BOOL) foreignKeys;

/**
 * Change the foreign keys state
 *
 * @param on
 *            true to turn on, false to turn off
 * @return previous foreign keys value
 */
-(BOOL) foreignKeysAsOn: (BOOL) on;

/**
 * Perform a foreign key check
 *
 * @return empty list if valid or violation errors, 4 column values for each
 *         violation. see SQLite PRAGMA foreign_key_check
 */
-(NSArray<GPKGRow *> *) foreignKeyCheck;

/**
 * Perform a foreign key check
 *
 * @param tableName
 *            table name
 * @return empty list if valid or violation errors, 4 column values for each
 *         violation. see SQLite PRAGMA foreign_key_check
 */
-(NSArray<GPKGRow *> *) foreignKeyCheckOnTable: (NSString *) tableName;

/**
 *  Insert statement
 *
 *  @param statement insert statement
 *
 *  @return insertion id
 */
-(long long) insert:(NSString *) statement;

/**
 *  Update statement
 *
 *  @param statement update statement
 *
 *  @return updated rows
 */
-(int) update:(NSString *) statement;

/**
 *  Update table where
 *
 *  @param table  table
 *  @param values content values
 *  @param where  where clause
 *
 *  @return updated rows
 */
-(int) updateWithTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where;

/**
 *  Update table where
 *
 *  @param table     table
 *  @param values    content values
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return updated rows
 */
-(int) updateWithTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Insert into table
 *
 *  @param table  table
 *  @param values content values
 *
 *  @return insertion id
 */
-(long long) insertWithTable: (NSString *) table andValues: (GPKGContentValues *) values;

/**
 *  Delete statement
 *
 *  @param statement delete statement
 *
 *  @return deleted rows
 */
-(int) delete:(NSString *) statement;

/**
 *  Delete from table where
 *
 *  @param table table
 *  @param where where clause
 *
 *  @return deleted rows
 */
-(int) deleteWithTable: (NSString *) table andWhere: (NSString *) where;

/**
 *  Delete from table where
 *
 *  @param table     table
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return deleted rows
 */
-(int) deleteWithTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Execute statement
 *
 *  @param statement execute statement
 */
-(void) exec:(NSString *) statement;

/**
 *  Execute statement, resetting other open connections
 *
 *  @param statement execute statement
 */
-(void) execResettable:(NSString *) statement;

/**
 *  Execute the statement once on all open connections, waiting for used connections
 *
 *  @param statement SQL statement
 */
-(void) execAllConnectionStatement: (NSString *) statement;

/**
 *  Execute the statement on all open and new connections, waiting for used connections
 *
 *  @param statement SQL statement
 *  @param name      unique statement key name
 */
-(void) execPersistentAllConnectionStatement: (NSString *) statement asName: (NSString *) name;

/**
 *  Remove a persistent statement
 *
 *  @param name SQL statement key name
 *
 *  @return removed statement or nil if not found
 */
-(NSString *) removePersistentAllConnectionStatementWithName: (NSString *) name;

/**
 *  Check if a table exists
 *
 *  @param table table name
 *
 *  @return true if exists
 */
-(BOOL) tableExists: (NSString *) table;

/**
 *  Check if a view exists
 *
 *  @param view view name
 *
 *  @return true if exists
 */
-(BOOL) viewExists: (NSString *) view;

/**
 *  Check if a table or view exists with the name
 *
 *  @param name table or view name
 *
 *  @return true if exists
 */
-(BOOL) tableOrViewExists: (NSString *) name;

/**
 *  Check if the table column exists
 *
 *  @param tableName  table name
 *  @param columnName column name
 *
 *  @return true if column exists
 */
-(BOOL) columnExistsWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName;

/**
 *  Add a new column to the table
 *
 *  @param tableName  table name
 *  @param columnName column name
 *  @param columndef  column definition
 */
-(void) addColumnWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName andColumnDef: (NSString *) columndef;

/**
 *  Query the SQL for a single result object in the first column
 *
 *  @param sql  sql statement
 *  @param args sql arguments
 *
 *  @return single result object
 */
-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args;

/**
 * Query the SQL for a single result object in the first column with the
 * expected data type
 *
 * @param sql
 *            sql statement
 * @param args
 *            sql arguments
 * @param dataType
 *            GeoPackage data type
 * @return single result object
 */
-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args andDataType: (enum GPKGDataType) dataType;

/**
 * Query the SQL for a single result object
 *
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param column
 *            column index
 * @return result, null if no result
 */
-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column;

/**
 * Query the SQL for a single result object with the expected data type
 *
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
-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType;

/**
 *  Query for values from the first column
 *
 *  @param sql  sql statement
 *  @param args sql arguments
 *
 *  @return single column result strings
 */
-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args;

/**
 * Query for values from the first column
 *
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param dataType
 *            GeoPackage data type
 * @return single column results
 */
-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataType: (enum GPKGDataType) dataType;

/**
 * Query for values from a single column
 *
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param column
 *            column index
 * @return single column results
 */
-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column;

/**
 * Query for values from a single column
 *
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param column
 *            column index
 * @param dataType
 *            GeoPackage data type
 * @return single column results
 */
-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType;

/**
 * Query for values from a single column up to the limit
 *
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param column
 *            column index
 * @param limit
 *            result row limit
 * @return single column results
 */
-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andLimit: (NSNumber *) limit;

/**
 * Query for values from a single column up to the limit
 *
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
-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType andLimit: (NSNumber *) limit;

/**
 * Query for values
 *
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @return results
 */
-(NSArray<GPKGRow *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args;

/**
 * Query for values
 *
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param dataTypes
 *            column data types
 * @return results
 */
-(NSArray<GPKGRow *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes;

/**
 * Query for values in a single (first) row
 *
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @return single row results
 */
-(GPKGRow *) querySingleRowResultsWithSql: (NSString *) sql andArgs: (NSArray *) args;

/**
 * Query for values in a single (first) row
 *
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param dataTypes
 *            column data types
 * @return single row results
 */
-(GPKGRow *) querySingleRowResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes;

/**
 * Query for values
 *
 * @param sql
 *            sql statement
 * @param args
 *            arguments
 * @param limit
 *            result row limit
 * @return results
 */
-(NSArray<GPKGRow *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andLimit: (NSNumber *) limit;

/**
 * Query for values up to the limit
 *
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
-(NSArray<GPKGRow *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes andLimit: (NSNumber *) limit;

/**
 *  Set the GeoPackage application id
 */
-(void) setApplicationId;

/**
 *  Set the application id
 *
 *  @param applicationId application id
 */
-(void) setApplicationId: (NSString *) applicationId;

/**
 *  Get the application id
 *
 *  @return application id
 */
-(NSString *) applicationId;

/**
 * Get the application id integer
 *
 * @return application id integer
 */
-(NSNumber *) applicationIdNumber;

/**
 * Get the application id as a hex string prefixed with 0x
 *
 * @return application id hex string
 */
-(NSString *) applicationIdHex;

/**
 * Get the application id string value for the application id integer
 *
 * @param applicationId
 *            application id integer
 * @return application id
 */
+(NSString *) applicationIdOfNumber: (NSNumber *) applicationId;

/**
 *  Set the GeoPackage user version
 */
-(void) setUserVersion;

/**
 *  Set the user version
 *
 *  @param userVersion user version
 */
-(void) setUserVersion: (int) userVersion;

/**
 *  Get the user version
 *
 *  @return user version
 */
-(NSNumber *) userVersion;

/**
 * Get the user version major
 *
 * @return user version major
 */
-(NSNumber *) userVersionMajor;

/**
 * Get the user version minor
 *
 * @return user version minor
 */
-(NSNumber *) userVersionMinor;

/**
 * Get the user version patch
 *
 * @return user version patch
 */
-(NSNumber *) userVersionPatch;

/**
 *  Drop the table
 *
 *  @param table table name
 */
-(void) dropTable: (NSString *) table;

/**
 *  Add a custom function to be created on write connections
 *
 *  @param function write connection function
 *  @param name function name
 *  @param numArgs number of function arguments
 */
-(void) addWriteFunction: (void *) function withName: (NSString *) name andNumArgs: (int) numArgs;

/**
 *  Add a custom function to be created on write connections
 *
 *  @param function write connection function
 */
-(void) addWriteFunction: (GPKGConnectionFunction *) function;

/**
 *  Add a custom function to be created on write connections
 *
 *  @param functions write connection functions
 */
-(void) addWriteFunctions: (NSArray<GPKGConnectionFunction *> *) functions;

@end
