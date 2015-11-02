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
#import "GPKGProjection.h"

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
@property (nonatomic, strong) NSArray *idColumns;

/**
 *  Columns
 */
@property (nonatomic, strong) NSArray *columns;

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
 *  Does the table exist?
 *
 *  @return true if exists
 */
-(BOOL) tableExists;

/**
 *  Get the projection of the object
 *
 *  @param object object
 *
 *  @return projection
 */
-(GPKGProjection *) getProjection: (NSObject *) object;

/**
 *  Drop the table
 */
-(void) dropTable;

/**
 *  Query for id
 *
 *  @param idValue id value
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForId: (NSObject *) idValue;

/**
 *  Query for id object, first object in the result set
 *
 *  @param idValue id value
 *
 *  @return object
 */
-(NSObject *) queryForIdObject: (NSObject *) idValue;

/**
 *  Query for a multiple id where more than one primary key exists
 *
 *  @param idValues id values
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForMultiId: (NSArray *) idValues;

/**
 *  Query for a multiple id object where more than one primary key exists, first object in the result set
 *
 *  @param idValues id values
 *
 *  @return object
 */
-(NSObject *) queryForMultiIdObject: (NSArray *) idValues;

/**
 *  Query for all results
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForAll;

/**
 *  Get the current object from the result set
 *
 *  @param results result set
 *
 *  @return object
 */
-(NSObject *) getObject: (GPKGResultSet *) results;

/**
 *  Get the first object from the result set
 *
 *  @param results result set
 *
 *  @return object
 */
-(NSObject *) getFirstObject: (GPKGResultSet *)results;

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
 *  Query for field equality
 *
 *  @param field field
 *  @param value column value
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForEqWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

/**
 *  Query for field values
 *
 *  @param fieldValues field values
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForFieldValues: (GPKGColumnValues *) fieldValues;

/**
 *  Query for column value field values
 *
 *  @param fieldValues column value field values
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForColumnValueFieldValues: (GPKGColumnValues *) fieldValues;

/**
 *  Query where
 *
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return result set
 */
-(GPKGResultSet *) queryWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Query where
 *
 *  @param where     where clause
 *  @param whereArgs where args
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *
 *  @return result set
 */
-(GPKGResultSet *) queryWhere: (NSString *) where
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
 *  Query columns where
 *
 *  @param columns   columns
 *  @param where     where caluse
 *  @param whereArgs where args
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *
 *  @return result set
 */
-(GPKGResultSet *) queryColumns: (NSArray *) columns
                       andWhere: (NSString *) where
                   andWhereArgs: (NSArray *) whereArgs
                     andGroupBy: (NSString *) groupBy
                      andHaving: (NSString *) having
                     andOrderBy: (NSString *) orderBy;

/**
 *  Query columns where
 *
 *  @param columns   columns
 *  @param where     where caluse
 *  @param whereArgs where args
 *  @param groupBy   group by clause
 *  @param having    having clause
 *  @param orderBy   order by clause
 *  @param limit     limit clause
 *
 *  @return result set
 */
-(GPKGResultSet *) queryColumns: (NSArray *) columns
                       andWhere: (NSString *) where
                   andWhereArgs: (NSArray *) whereArgs
                     andGroupBy: (NSString *) groupBy
                      andHaving: (NSString *) having
                     andOrderBy: (NSString *) orderBy
                       andLimit: (NSString *) limit;

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
 *  Get the id of the object
 *
 *  @param object object
 *
 *  @return id value
 */
-(NSObject *) getId: (NSObject *) object;

/**
 *  Get the multiple id values of the object
 *
 *  @param object object
 *
 *  @return id values in an array
 */
-(NSArray *) getMultiId: (NSObject *) object;

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
 *  Build where clause with column value fields
 *
 *  @param fields column values
 *
 *  @return where clause
 */
-(NSString *) buildWhereWithColumnValueFields: (GPKGColumnValues *) fields;

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

@end
