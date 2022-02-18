//
//  GPKGBaseDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"
#import "GPKGColumnValue.h"
#import "GPKGColumnValues.h"
#import "PROJProjection.h"
#import "GPKGObjectResultSet.h"

@class GPKGObjectResultSet;

/**
 *  Base Data Access Object
 */
@interface GPKGBaseDao : NSObject

/**
 *  Database name
 */
@property (nonatomic, strong) NSString *databaseName;

/**
 *  Database connection
 */
@property (nonatomic) GPKGConnection *database;

/**
 *  id columns
 */
@property (nonatomic, strong) NSArray<NSString *> *idColumns;

/**
 *  auto increment id flag
 */
@property (nonatomic) BOOL autoIncrementId;

/**
 *  Columns
 */
@property (nonatomic, strong) NSArray<NSString *> *columnNames;

/**
 *  Table name
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  Mapping between columns and indices
 */
@property (nonatomic, strong) NSMutableDictionary *columnIndex;

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new base dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Initialize the column index
 */
-(void) initializeColumnIndex;

/**
 *  Get the column count
 *
 *  @return column count
 */
-(int) columnCount;

/**
 *  Get the column name at the index
 *
 *  @param index index
 *
 *  @return column name
 */
-(NSString *) columnNameWithIndex: (int) index;

/**
 *  Check if the DAO is backed by a table or a view
 *
 *  @return true if a table or view exists
 */
-(BOOL) tableExists;

/**
 * Check if the DAO is backed by a table or a view
 *
 * @return true if a table or view exists
 */
-(BOOL) isTableOrView;

/**
 * Check if the DAO is backed by a table
 *
 * @return true if a table exists
 */
-(BOOL) isTable;

/**
 * Check if the DAO is backed by a view
 *
 * @return true if a view exists
 */
-(BOOL) isView;

/**
 * Verify the DAO is backed by a table or view
 */
-(void) verifyExists;

/**
 *  Get a single or first id column name
 *
 *  @return id column name
 */
-(NSString *) idColumnName;

/**
 *  Get the projection of the object
 *
 *  @param object object
 *
 *  @return projection
 */
-(PROJProjection *) projection: (NSObject *) object;

/**
 *  Drop the table
 */
-(void) dropTable;

/**
 * Check if the table exists
 *
 * @param tableName
 *            table name
 * @return true if exists
 */
-(BOOL) tableExistsWithName: (NSString *) tableName;

/**
 * Check if the view exists
 *
 * @param viewName
 *            view name
 * @return true if exists
 */
-(BOOL) viewExistsWithName: (NSString *) viewName;

/**
 * Check if a table or view exists with the name
 *
 * @param name
 *            table or view name
 * @return true if exists
 */
-(BOOL) tableOrViewExists: (NSString *) name;

/**
 * Drop the table
 *
 * @param table
 *            table name
 */
-(void) dropTableWithName: (NSString *) table;

/**
 *  Query for id
 *
 *  @param idValue id value
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForId: (NSObject *) idValue;

/**
 *  Query for id
 *
 *  @param columns columns
 *  @param idValue id value
 *
 *  @return result set
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns forId: (NSObject *) idValue;

/**
 *  Query for id object, first object in the result set
 *
 *  @param idValue id value
 *
 *  @return object
 */
-(NSObject *) queryForIdObject: (NSObject *) idValue;

/**
 *  Query for id object, first object in the result set
 *
 *  @param columns columns
 *  @param idValue id value
 *
 *  @return object
 */
-(NSObject *) queryWithColumns: (NSArray<NSString *> *) columns forIdObject: (NSObject *) idValue;

/**
 *  Query for a multiple id where more than one primary key exists
 *
 *  @param idValues id values
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForMultiId: (NSArray *) idValues;

/**
 *  Query for a multiple id where more than one primary key exists
 *
 *  @param columns columns
 *  @param idValues id values
 *
 *  @return result set
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns forMultiId: (NSArray *) idValues;

/**
 *  Query for a multiple id object where more than one primary key exists, first object in the result set
 *
 *  @param idValues id values
 *
 *  @return object
 */
-(NSObject *) queryForMultiIdObject: (NSArray *) idValues;

/**
 *  Query for a multiple id object where more than one primary key exists, first object in the result set
 *
 *  @param columns columns
 *  @param idValues id values
 *
 *  @return object
 */
-(NSObject *) queryWithColumns: (NSArray<NSString *> *) columns forMultiIdObject: (NSArray *) idValues;

/**
 * Query for the row with the provided id
 *
 * @param id
 *            id
 * @return result
 */
-(GPKGResultSet *) queryForIdInt: (int) id;

/**
 * Query for the row with the provided id
 *
 * @param columns
 *            columns
 * @param id
 *            id
 * @return result
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns forIdInt: (int) id;

/**
 *  Query for all results
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForAll;

/**
 *  Query for all results
 *
 *  @return result set
 */
-(GPKGResultSet *) query;

/**
 * Query for all rows
 *
 * @param distinct
 *            distinct rows
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct;

/**
 * Query for all rows
 *
 * @param columns
 *            columns
 *
 * @return result
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns;

/**
 * Query for all rows
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 *
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns;

/**
 * Query SQL for all rows
 *
 * @return SQL
 */
-(NSString *) querySQL;

/**
 * Query SQL for all rows
 *
 * @param distinct
 *            distinct rows
 * @return SQL
 */
-(NSString *) querySQLWithDistinct: (BOOL) distinct;

/**
 * Query SQL for all row ids
 *
 * @return SQL
 */
-(NSString *) queryIdsSQL;

/**
 * Query SQL for all row ids
 * 
 * @param distinct
 *            distinct rows
 * @return SQL
 */
-(NSString *) queryIdsSQLWithDistinct: (BOOL) distinct;

/**
 * Query SQL for all rows
 *
 * @param columns
 *            columns
 * @return SQL
 */
-(NSString *) querySQLWithColumns: (NSArray<NSString *> *) columns;

/**
 * Query SQL for all rows
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @return SQL
 */
-(NSString *) querySQLWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns;

/**
 *  Get the current object from the result set
 *
 *  @param results result set
 *
 *  @return object
 */
-(NSObject *) object: (GPKGResultSet *) results;

/**
 *  Get the object from the row
 *
 *  @param row result row
 *
 *  @return object
 */
-(NSObject *) objectWithRow: (GPKGRow *) row;

/**
 *  Wrap the result set
 *
 *  @param results result set
 *
 *  @return object result set
 */
-(GPKGObjectResultSet *) results: (GPKGResultSet *) results;

/**
 *  Get the first object from the result set
 *
 *  @param results result set
 *
 *  @return object
 */
-(NSObject *) firstObject: (GPKGResultSet *)results;

/**
 *  Raw query for results
 *
 *  @param query raw query
 *
 *  @return result set
 */
-(GPKGResultSet *) rawQuery: (NSString *) query;

/**
 *  Raw query for results with args
 *
 *  @param query raw query
 *  @param args  args
 *
 *  @return result set
 */
-(GPKGResultSet *) rawQuery: (NSString *) query andArgs: (NSArray *) args;

/**
 *  Get the values from a result set with only one column
 *
 *  @param results result set
 *
 *  @return single column values
 */
-(NSArray *) singleColumnResults: (GPKGResultSet *) results;

/**
 *  Query for field equality
 *
 *  @param field field
 *  @param value value
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForEqWithField: (NSString *) field andValue: (NSObject *) value;

/**
 * Query for the row where the field equals the value
 *
 * @param distinct
 *            distinct rows
 * @param field
 *            field name
 * @param value
 *            value
 * @return result
 */
-(GPKGResultSet *) queryForEqWithDistinct: (BOOL) distinct andField: (NSString *) field andValue: (NSObject *) value;

/**
 * Query for the row where the field equals the value
 *
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            value
 * @return result
 */
-(GPKGResultSet *) queryForEqWithColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andValue: (NSObject *) value;

/**
 * Query for the row where the field equals the value
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            value
 * @return result
 */
-(GPKGResultSet *) queryForEqWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andValue: (NSObject *) value;

/**
 * Count where the field equals the value
 *
 * @param field
 *            field name
 * @param value
 *            value
 * @return count
 */
-(int) countForEqWithField: (NSString *) field andValue: (NSObject *) value;

/**
 * Count where the field equals the value
 *
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            value
 * @return count
 */
-(int) countForEqWithColumn: (NSString *) column andField: (NSString *) field andValue: (NSObject *) value;

/**
 * Count where the field equals the value
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            value
 * @return count
 */
-(int) countForEqWithDistinct: (BOOL) distinct andColumn: (NSString *) column andField: (NSString *) field andValue: (NSObject *) value;

/**
 *  Query for field equality
 *
 *  @param field   field
 *  @param value   value
 *  @param groupBy group by clause
 *  @param having  having clause
 *  @param orderBy order by clause
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForEqWithField: (NSString *) field
                              andValue: (NSObject *) value
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy;

/**
 * Query for the row where the field equals the value
 *
 * @param distinct
 *            distinct rows
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @return result
 */
-(GPKGResultSet *) queryForEqWithDistinct: (BOOL) distinct
                              andField: (NSString *) field
                              andValue: (NSObject *) value
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy;

/**
 * Query for the row where the field equals the value
 *
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @return result
 */
-(GPKGResultSet *) queryForEqWithColumns: (NSArray<NSString *> *) columns
                            andField: (NSString *) field
                            andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 * Query for the row where the field equals the value
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @return result
 */
-(GPKGResultSet *) queryForEqWithDistinct: (BOOL) distinct
                            andColumns: (NSArray<NSString *> *) columns
                            andField: (NSString *) field
                            andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 * Count where the field equals the value
 *
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @return count
 */
-(int) countForEqWithField: (NSString *) field
                            andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 * Count where the field equals the value
 *
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @return count
 */
-(int) countForEqWithColumn: (NSString *) column
                            andField: (NSString *) field
                            andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 * Count where the field equals the value
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @return count
 */
-(int) countForEqWithDistinct: (BOOL) distinct
                            andColumn: (NSString *) column
                            andField: (NSString *) field
                            andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 *  Query for field equality
 *
 *  @param field field
 *  @param value column value
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForEqWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Query for the row where the field equals the value
 *
 * @param distinct
 *            distinct rows
 * @param field
 *            field name
 * @param value
 *            column value
 * @return result
 */
-(GPKGResultSet *) queryForEqWithDistinct: (BOOL) distinct andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Query for the row where the field equals the value
 *
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            column value
 * @return result
 */
-(GPKGResultSet *) queryForEqWithColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Query for the row where the field equals the value
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            column value
 * @return result
 */
-(GPKGResultSet *) queryForEqWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Count where the field equals the value
 *
 * @param field
 *            field name
 * @param value
 *            column value
 * @return count
 */
-(int) countForEqWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Count where the field equals the value
 *
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            column value
 * @return count
 */
-(int) countForEqWithColumn: (NSString *) column andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Count where the field equals the value
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            column value
 * @return count
 */
-(int) countForEqWithDistinct: (BOOL) distinct andColumn: (NSString *) column andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Query for the row where the field is like the value
 *
 * @param field
 *            field name
 * @param value
 *            value
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithField: (NSString *) field andValue: (NSObject *) value;

/**
 * Query for the row where the field is like the value
 *
 * @param distinct
 *            distinct rows
 * @param field
 *            field name
 * @param value
 *            value
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithDistinct: (BOOL) distinct andField: (NSString *) field andValue: (NSObject *) value;

/**
 * Query for the row where the field is like the value
 *
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            value
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andValue: (NSObject *) value;

/**
 * Query for the row where the field is like the value
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            value
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andValue: (NSObject *) value;

/**
 * Count where the field is like the value
 *
 * @param field
 *            field name
 * @param value
 *            value
 * @return count
 */
-(int) countForLikeWithField: (NSString *) field andValue: (NSObject *) value;

/**
 * Count where the field is like the value
 *
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            value
 * @return count
 */
-(int) countForLikeWithColumn: (NSString *) column andField: (NSString *) field andValue: (NSObject *) value;

/**
 * Count where the field is like the value
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            value
 * @return count
 */
-(int) countForLikeWithDistinct: (BOOL) distinct andColumn: (NSString *) column andField: (NSString *) field andValue: (NSObject *) value;

/**
 * Query for the row where the field equals the value
 *
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by statement
 * @param having
 *            having statement
 * @param orderBy
 *            order by statement
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithField: (NSString *) field
                              andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                             andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 * Query for the row where the field equals the value
 *
 * @param distinct
 *            distinct rows
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by statement
 * @param having
 *            having statement
 * @param orderBy
 *            order by statement
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithDistinct: (BOOL) distinct
                            andField: (NSString *) field
                              andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                             andHaving: (NSString *) having
                                 andOrderBy: (NSString *) orderBy;

/**
 * Query for the row where the field equals the value
 *
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by statement
 * @param having
 *            having statement
 * @param orderBy
 *            order by statement
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithColumns: (NSArray<NSString *> *) columns
                            andField: (NSString *) field
                              andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                             andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 * Query for the row where the field equals the value
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by statement
 * @param having
 *            having statement
 * @param orderBy
 *            order by statement
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithDistinct: (BOOL) distinct
                            andColumns: (NSArray<NSString *> *) columns
                            andField: (NSString *) field
                              andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                             andHaving: (NSString *) having
                                 andOrderBy: (NSString *) orderBy;

/**
 * Count where the field equals the value
 *
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by statement
 * @param having
 *            having statement
 * @param orderBy
 *            order by statement
 * @return count
 */
 -(int) countForLikeWithField: (NSString *) field
                               andValue: (NSObject *) value
                             andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                             andOrderBy: (NSString *) orderBy;

/**
 * Count where the field equals the value
 *
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by statement
 * @param having
 *            having statement
 * @param orderBy
 *            order by statement
 * @return count
 */
-(int) countForLikeWithColumn: (NSString *) column
                            andField: (NSString *) field
                              andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                             andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 * Count where the field equals the value
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            value
 * @param groupBy
 *            group by statement
 * @param having
 *            having statement
 * @param orderBy
 *            order by statement
 * @return count
 */
-(int) countForLikeWithDistinct: (BOOL) distinct
                            andColumn: (NSString *) column
                            andField: (NSString *) field
                              andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                             andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 * Query for the row where the field is like the value
 *
 * @param field
 *            field name
 * @param value
 *            column value
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Query for the row where the field is like the value
 *
 * @param distinct
 *            distinct rows
 * @param field
 *            field name
 * @param value
 *            column value
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithDistinct: (BOOL) distinct andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Query for the row where the field is like the value
 *
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            column value
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Query for the row where the field is like the value
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param field
 *            field name
 * @param value
 *            column value
 * @return result
 */
-(GPKGResultSet *) queryForLikeWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Count where the field is like the value
 *
 * @param field
 *            field name
 * @param value
 *            column value
 * @return count
 */
-(int) countForLikeWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Count where the field is like the value
 *
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            column value
 * @return count
 */
-(int) countForLikeWithColumn: (NSString *) column andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Count where the field is like the value
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param field
 *            field name
 * @param value
 *            column value
 * @return count
 */
-(int) countForLikeWithDistinct: (BOOL) distinct andColumn: (NSString *) column andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 * Query for the row where all fields match their values
 *
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryForFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for the row where all fields match their values
 *
 * @param distinct
 *            distinct rows
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct forFieldValues:(GPKGColumnValues *) fieldValues;

/**
 * Query for the row where all fields match their values
 *
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns forFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for the row where all fields match their values
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns forFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count where all fields match their values
 *
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countForFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count where all fields match their values
 *
 * @param column
 *            count column name
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countWithColumn: (NSString *) column forFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count where all fields match their values
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column forFieldValues: (GPKGColumnValues *) fieldValues;

/**
 *  Query for column value field values
 *
 *  @param fieldValues column value field values
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForColumnValueFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for the row where all fields match their values
 *
 * @param distinct
 *            distinct rows
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct forColumnValueFieldValues:(GPKGColumnValues *) fieldValues;

/**
 * Query for the row where all fields match their values
 *
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns forColumnValueFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for the row where all fields match their values
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns forColumnValueFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count where all fields match their values
 *
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countForColumnValueFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count where all fields match their values
 *
 * @param column
 *            count column name
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countWithColumn: (NSString *) column forColumnValueFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count where all fields match their values
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column forColumnValueFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @return result
 */
-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @return result
 */
-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL;

/**
 * Get the count in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @return count
 */
-(int) countInWithNestedSQL: (NSString *) nestedSQL;

/**
 * Get the count in the nested SQL query
 *
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @return count
 */
-(int) countInWithColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL;

/**
 * Get the count in the nested SQL query
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @return count
 */
-(int) countInWithDistinct: (BOOL) distinct andColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @return result
 */
-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @return result
 */
-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs;

/**
 * Get the count in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @return count
 */
-(int) countInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs;

/**
 * Get the count in the nested SQL query
 *
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @return count
 */
-(int) countInWithColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs;

/**
 * Get the count in the nested SQL query
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @return count
 */
-(int) countInWithDistinct: (BOOL) distinct andColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Get the count in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countInWithNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Get the count in the nested SQL query
 *
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countInWithColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Get the count in the nested SQL query
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countInWithDistinct: (BOOL) distinct andColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Get the count in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Get the count in the nested SQL query
 *
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countInWithColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Get the count in the nested SQL query
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @return count
 */
-(int) countInWithDistinct: (BOOL) distinct andColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where;

/**
 * Get the count in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @return count
 */
-(int) countInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where;

/**
 * Get the count in the nested SQL query
 *
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @return count
 */
-(int) countInWithColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where;

/**
 * Get the count in the nested SQL query
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @return count
 */
-(int) countInWithDistinct: (BOOL) distinct andColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where;

/**
 * Get the count in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @return count
 */
-(int) countInWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where;

/**
 * Get the count in the nested SQL query
 *
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @return count
 */
-(int) countInWithColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where;

/**
 * Get the count in the nested SQL query
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @return count
 */
-(int) countInWithDistinct: (BOOL) distinct andColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Get the count in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return count
 */
-(int) countInWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Get the count in the nested SQL query
 *
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return count
 */
-(int) countInWithColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Get the count in the nested SQL query
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return count
 */
-(int) countInWithDistinct: (BOOL) distinct andColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryInWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for rows by ids in the nested SQL query
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param fieldValues
 *            field values
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for id ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimitValue: (NSString *) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimitValue: (NSString *) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimitValue: (NSString *) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimitValue: (NSString *) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimitValue: (NSString *) limit;

/**
 * Query for ordered rows by ids in the nested SQL query, starting at the
 * offset and returning no more than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryInForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimitValue: (NSString *) limit;

/**
 * Get the count in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return count
 */
-(int) countInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Get the count in the nested SQL query
 *
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return count
 */
-(int) countInWithColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Get the count in the nested SQL query
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            count column name
 * @param nestedSQL
 *            nested SQL
 * @param nestedArgs
 *            nested SQL args
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return count
 */
-(int) countInWithDistinct: (BOOL) distinct andColumn: (NSString *) column andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows
 *
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryWhere: (NSString *) where;

/**
 * Query for rows
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andWhere: (NSString *) where;

/**
 * Query for rows
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Query for rows
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Query for rows
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for rows
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query SQL for rows
 *
 * @param where
 *            where clause
 * @return SQL
 */
-(NSString *) querySQLWhere: (NSString *) where;

/**
 * Query SQL for rows
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @return SQL
 */
-(NSString *) querySQLWithDistinct: (BOOL) distinct andWhere: (NSString *) where;

/**
 * Query SQL for row ids
 *
 * @param where
 *            where clause
 * @return SQL
 */
-(NSString *) queryIdsSQLWhere: (NSString *) where;

/**
 * Query SQL for row ids
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @return SQL
 */
-(NSString *) queryIdsSQLWithDistinct: (BOOL) distinct andWhere: (NSString *) where;

/**
 * Query SQL for row multi ids
 *
 * @param where
 *            where clause
 * @return SQL
 */
-(NSString *) queryMultiIdsSQLWhere: (NSString *) where;

/**
 * Query SQL for row multi ids
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @return SQL
 */
-(NSString *) queryMultiIdsSQLWithDistinct: (BOOL) distinct andWhere: (NSString *) where;

/**
 * Query SQL for rows
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @return SQL
 */
-(NSString *) querySQLWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Query SQL for rows
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @return SQL
 */
-(NSString *) querySQLWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Query for rows
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @return result
 */
-(GPKGResultSet *) queryWhere: (NSString *) where
                              andWhereArgs: (NSArray *) whereArgs
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy;

/**
 * Query for rows
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct
                              andWhere: (NSString *) where
                              andWhereArgs: (NSArray *) whereArgs
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy;

/**
 * Query for rows
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @return result
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 * Query for rows
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct
                            andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy;

/**
 *  Query where
 *
 *  @param where     where clause
 *  @param whereArgs where args
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *  @param limit     limit clause
 *
 *  @return result set
 */
-(GPKGResultSet *) queryWhere: (NSString *) where
                              andWhereArgs: (NSArray *) whereArgs
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy
                              andLimit: (NSString *) limit;

/**
 * Query for rows
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            limit
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct
                              andWhere: (NSString *) where
                              andWhereArgs: (NSArray *) whereArgs
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy
                              andLimit: (NSString *) limit;

/**
 * Query for rows
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            limit
 * @return result
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit;

/**
 * Query for rows
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            limit
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct
                            andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit;

/**
 * Query for rows
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            limit
 * @return result
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit;

/**
 * Query for rows
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            limit
 * @return result
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andLimit: (NSString *) limit;

/**
 * Query for rows
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            limit
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct
                            andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit;

/**
 * Query for rows
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            limit
 * @return result
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct
                            andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andLimit: (NSString *) limit;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithLimit: (int) limit;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andLimit: (int) limit;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param columns
 *            columns
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andLimit: (int) limit;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param columns
 *            columns
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andLimit: (int) limit;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for id ordered rows starting at the offset and returning no more
 * than the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimitValue: (NSString *) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimitValue: (NSString *) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimitValue: (NSString *) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimitValue: (NSString *) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimitValue: (NSString *) limit;

/**
 * Query for ordered rows starting at the offset and returning no more than
 * the limit.
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param groupBy
 *            group by
 * @param having
 *            having
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return result
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimitValue: (NSString *) limit;

/**
 * Build a limit String with the limit and offset
 *
 * @param limit
 *            limit
 * @param offset
 *            offset
 * @return limit
 */
-(NSString *) buildLimitWithLimit: (int) limit andOffset: (int) offset;

/**
 *  Check if id exists
 *
 *  @param id id value
 *
 *  @return true if exists
 */
-(BOOL) idExists: (NSObject *) id;

/**
 *  Check if multiple id exists
 *
 *  @param idValues id values
 *
 *  @return true if exists
 */
-(BOOL) multiIdExists: (NSArray *) idValues;

/**
 *  Query for the same id as the object
 *
 *  @param object object
 *
 *  @return object
 */
-(NSObject *) queryForSameId: (NSObject *) object;

/**
 *  Begin an exclusive transaction on the database
 */
-(void) beginTransaction;

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
 *  Update the object
 *
 *  @param object object
 *
 *  @return rows updated
 */
-(int) update: (NSObject *) object;

/**
 *  Update where with values
 *
 *  @param values    content values
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return rows updated
 */
-(int) updateWithValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Delete object
 *
 *  @param object object
 *
 *  @return rows deleted
 */
-(int) delete: (NSObject *) object;

/**
 *  Delete objects
 *
 *  @param objects array of objects
 *
 *  @return rows deleted
 */
-(int) deleteObjects: (NSArray *) objects;

/**
 *  Delete by id
 *
 *  @param idValue id value
 *
 *  @return rows deleted
 */
-(int) deleteById: (NSObject *) idValue;

/**
 *  Delete by multiple id values
 *
 *  @param idValues id values
 *
 *  @return rows deleted
 */
-(int) deleteByMultiId: (NSArray *) idValues;

/**
 *  Delete where
 *
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return rows deleted
 */
-(int) deleteWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Delete by field values
 *
 *  @param fieldValues field values
 *
 *  @return rows deleted
 */
-(int) deleteByFieldValues: (GPKGColumnValues *) fieldValues;

/**
 *  Delete all rows
 *
 *  @return rows deleted
 */
-(int) deleteAll;

/**
 *  Create object, same as calling insert
 *
 *  @param object object
 *
 *  @return insertion id
 */
-(long long) create: (NSObject *) object;

/**
 *  Insert object
 *
 *  @param object object
 *
 *  @return insertion id
 */
-(long long) insert: (NSObject *) object;

/**
 *  Create if does not exist
 *
 *  @param object object
 *
 *  @return insertion id if created
 */
-(long long) createIfNotExists: (NSObject *) object;

/**
 *  Create if does not exist or update if it does
 *
 *  @param object object
 *
 *  @return insertion id if created
 */
-(long long) createOrUpdate: (NSObject *) object;

/**
 *  Determine if the table has an id
 *
 *  @return true if has an id
 */
-(BOOL) hasId;

/**
 *  Get the id of the object
 *
 *  @param object object
 *
 *  @return id value
 */
-(NSObject *) id: (NSObject *) object;

/**
 *  Get the multiple id values of the object
 *
 *  @param object object
 *
 *  @return id values in an array
 */
-(NSArray *) multiId: (NSObject *) object;

/**
 *  Set the object id
 *
 *  @param object object
 *  @param id     id
 */
-(void) setId: (NSObject *) object withIdValue: (NSObject *) id;

/**
 *  Set the object multiple id
 *
 *  @param object   object
 *  @param idValues id values
 */
-(void) setMultiId: (NSObject *) object withIdValues: (NSArray *) idValues;

/**
 *  Get the column values of the object
 *
 *  @param object object
 *
 *  @return column values
 */
-(GPKGColumnValues *) values: (NSObject *) object;

/**
 *  Build primary key where clause with id value
 *
 *  @param idValue id value
 *
 *  @return pk where clause
 */
-(NSString *) buildPkWhereWithValue: (NSObject *) idValue;

/**
 *  Build primary key where args
 *
 *  @param idValue id value
 *
 *  @return pk where args
 */
-(NSArray *) buildPkWhereArgsWithValue: (NSObject *) idValue;

/**
 *  Build primary key where clause with id values
 *
 *  @param idValues id values
 *
 *  @return where clause
 */
-(NSString *) buildPkWhereWithValues: (NSArray *) idValues;

/**
 *  Build where clause with fields
 *
 *  @param fields column values
 *
 *  @return where clause
 */
-(NSString *) buildWhereWithFields: (GPKGColumnValues *) fields;

/**
 *  Build where clause with fields
 *
 *  @param fields column values
 *  @param operation combining operation
 *
 *  @return where clause
 */
-(NSString *) buildWhereWithFields: (GPKGColumnValues *) fields andOperation: (NSString *) operation;

/**
 *  Build where clause with column value fields
 *
 *  @param fields column values
 *
 *  @return where clause
 */
-(NSString *) buildWhereWithColumnValueFields: (GPKGColumnValues *) fields;

/**
 *  Build where clause with column value fields
 *
 *  @param fields column values
 *  @param operation combining operation
 *
 *  @return where clause
 */
-(NSString *) buildWhereWithColumnValueFields: (GPKGColumnValues *) fields andOperation: (NSString *) operation;

/**
 *  Build where clause with field and value
 *
 *  @param field field
 *  @param value value
 *
 *  @return where clause
 */
-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value;

/**
 *  Build where LIKE clause with field and value
 *
 *  @param field field
 *  @param value value
 *
 *  @return where clause
 */
-(NSString *) buildWhereLikeWithField: (NSString *) field andValue: (NSObject *) value;

/**
 *  Build where clause with field, value, and operation
 *
 *  @param field     field
 *  @param value     value
 *  @param operation operation
 *
 *  @return where clause
 */
-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value andOperation: (NSString *) operation;

/**
 *  Build where clause with field and column value
 *
 *  @param field field
 *  @param value column value
 *
 *  @return where clause
 */
-(NSString *) buildWhereWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 *  Build where LIKE clause with field and column value
 *
 *  @param field field
 *  @param value column value
 *
 *  @return where clause
 */
-(NSString *) buildWhereLikeWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 *  Build where args with column values
 *
 *  @param values column values
 *
 *  @return where args
 */
-(NSArray *) buildWhereArgsWithValues: (GPKGColumnValues *) values;

/**
 *  Build where args with values
 *
 *  @param values values
 *
 *  @return where args
 */
-(NSArray *) buildWhereArgsWithValueArray: (NSArray *) values;

/**
 *  Build where args with column values
 *
 *  @param values column values
 *
 *  @return where args
 */
-(NSArray *) buildWhereArgsWithColumnValues: (GPKGColumnValues *) values;

/**
 *  Build where args with value
 *
 *  @param value value
 *
 *  @return where args
 */
-(NSArray *) buildWhereArgsWithValue: (NSObject *) value;

/**
 *  Build where args with column value
 *
 *  @param value column value
 *
 *  @return where args
 */
-(NSArray *) buildWhereArgsWithColumnValue: (GPKGColumnValue *) value;

/**
 * Build where statement for ids in the nested SQL query
 *
 * @param nestedSQL
 *            nested SQL
 * @param where
 *            where clause
 * @return where clause
 */
-(NSString *) buildWhereInWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where;

/**
 * Build where args for ids in the nested SQL query
 *
 * @param nestedArgs
 *            nested SQL args
 * @param whereArgs
 *            where arguments
 * @return where args
 */
-(NSArray<NSString *> *) buildWhereInArgsWithNestedArgs: (NSArray<NSString *> *) nestedArgs andWhereArgs: (NSArray<NSString *> *) whereArgs;

/**
 *  Get the total result count
 *
 *  @return count
 */
-(int) count;

/**
 *  Get the count where
 *
 *  @param where where clause
 *
 *  @return count
 */
-(int) countWhere: (NSString *) where;

/**
 *  Get the count where
 *
 *  @param where where clause
 *  @param args  where args
 *
 *  @return count
 */
-(int) countWhere: (NSString *) where andWhereArgs: (NSArray *) args;

/**
 * Get a count of results
 *
 * @param column
 *            column name
 * @return count
 */
-(int) countWithColumn: (NSString *) column;

/**
 * Get a count of results
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            column name
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column;

/**
 * Get a count of results
 *
 * @param column
 *            column name
 * @param where
 *            where clause
 * @return count
 */
-(int) countWithColumn: (NSString *) column andWhere: (NSString *) where;

/**
 * Get a count of results
 *
 * @param column
 *            column name
 * @param where
 *            where clause
 * @param args
 *            arguments
 * @return count
 */
-(int) countWithColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) args;

/**
 * Get a count of results
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            column name
 * @param where
 *            where clause
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where;

/**
 * Get a count of results
 *
 * @param distinct
 *            distinct column values
 * @param column
 *            column name
 * @param where
 *            where clause
 * @param args
 *            arguments
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) args;

/**
 * Get the min result of the column
 *
 * @param column
 *            column name
 * @return min or null
 */
-(NSNumber *) minOfColumn: (NSString *) column;

/**
 *  Get the min result of the column
 *
 *  @param column column
 *  @param where  where clause
 *  @param args   where args
 *
 *  @return min or nil
 */
-(NSNumber *) minOfColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) args;

/**
 * Get the max result of the column
 *
 * @param column
 *            column name
 * @return max or null
 */
-(NSNumber *) maxOfColumn: (NSString *) column;

/**
 *  Get the max result of the column
 *
 *  @param column column
 *  @param where  where clause
 *  @param args   where args
 *
 *  @return max or nil
 */
-(NSNumber *) maxOfColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) args;

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
 * Rename column
 *
 * @param columnName
 *            column name
 * @param newColumnName
 *            new column name
 */
-(void) renameColumnWithName: (NSString *) columnName toColumn: (NSString *) newColumnName;

/**
 * Rename column
 *
 * @param index
 *            column index
 * @param newColumnName
 *            new column name
 */
-(void) renameColumnWithIndex: (int) index toColumn: (NSString *) newColumnName;

/**
 * Drop a column
 *
 * @param index
 *            column index
 */
-(void) dropColumnWithIndex: (int) index;

/**
 * Drop a column
 *
 * @param columnName
 *            column name
 */
-(void) dropColumnWithName: (NSString *) columnName;

/**
 * Drop columns
 *
 * @param indexes
 *            column indexes
 */
-(void) dropColumnIndexes: (NSArray<NSNumber *> *) indexes;

/**
 * Drop columns
 *
 * @param columnNames
 *            column names
 */
-(void) dropColumnNames: (NSArray<NSString *> *) columnNames;

@end
