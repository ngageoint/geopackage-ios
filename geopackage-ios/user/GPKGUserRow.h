//
//  GPKGUserRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserTable.h"

/**
 *  User Row containing the values from a single result row
 */
@interface GPKGUserRow : NSObject <NSMutableCopying>

/**
 *  User table
 */
@property (nonatomic, strong) GPKGUserTable *table;

/**
 * User columns
 */
@property (nonatomic, strong) GPKGUserColumns *columns;

/**
 *  Column types of this row, based upon the data values
 */
@property (nonatomic, strong) NSArray *columnTypes;

/**
 *  Array of row values
 */
@property (nonatomic, strong) NSMutableArray *values;

// TODO remove?
-(instancetype) initWithTable: (GPKGUserTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table       user table
 *  @param columns   columns
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return new user row
 */
-(instancetype) initWithTable: (GPKGUserTable *) table andColumns: (GPKGUserColumns *) columns andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table user table
 *
 *  @return new user row
 */
-(instancetype) initWithTable: (GPKGUserTable *) table;

/**
 *  Copy Initializer
 *
 *  @param row user row
 *
 *  @return new user row
 */
-(instancetype) initWithRow: (GPKGUserRow *) row;

/**
 *  Get the column count
 *
 *  @return column count
 */
-(int) columnCount;

/**
 *  Get the column names
 *
 *  @return column names
 */
-(NSArray *) columnNames;

/**
 *  Get the column name at the index
 *
 *  @param index index
 *
 *  @return column name
 */
-(NSString *) columnNameWithIndex: (int) index;

/**
 *  Get the column index of the column name
 *
 *  @param columnName column name
 *
 *  @return index
 */
-(int) columnIndexWithColumnName: (NSString *) columnName;

/**
 *  Get the value at the index
 *
 *  @param index index
 *
 *  @return value
 */
-(NSObject *) valueWithIndex: (int) index;

/**
 *  Get the value of the column name
 *
 *  @param columnName column name
 *
 *  @return value
 */
-(NSObject *) valueWithColumnName: (NSString *) columnName;

/**
 * Get the value at the index as a string
 *
 * @param index
 *            index
 * @return value
 */
-(NSString *) valueStringWithIndex: (int) index;

/**
 * Get the value of the column name as a string
 *
 * @param columnName
 *            column name
 * @return value
 */
-(NSString *) valueStringWithColumnName: (NSString *) columnName;

/**
 *  Get the database formatted value at the index
 *
 *  @param index index
 *
 *  @return value
 */
-(NSObject *) databaseValueWithIndex: (int) index;

/**
 *  Get the datbase formatted value of the column name
 *
 *  @param columnName column name
 *
 *  @return value
 */
-(NSObject *) databaseValueWithColumnName: (NSString *) columnName;

/**
 *  Get the row column type at the index
 *
 *  @param index index
 *
 *  @return row column type
 */
-(int) rowColumnTypeWithIndex: (int) index;

/**
 *  Get the row column type of the column name
 *
 *  @param columnName column name
 *
 *  @return row column type
 */
-(int) rowColumnTypeWithColumnName: (NSString *) columnName;

/**
 *  Get the column at the index
 *
 *  @param index index
 *
 *  @return column
 */
-(GPKGUserColumn *) columnWithIndex: (int) index;

/**
 *  Get the column of the column name
 *
 *  @param columnName column name
 *
 *  @return column
 */
-(GPKGUserColumn *) columnWithColumnName: (NSString *) columnName;

/**
 *  Check if the row has the column
 *
 *  @param columnName column name
 *
 *  @return true if has the column
 */
-(BOOL) hasColumnWithColumnName: (NSString *) columnName;

/**
 *  Get the id value, which is the value of the primary key
 *
 *  @return id value
 */
-(NSNumber *) id;

/**
 *  Get the id value, which is the value of the primary key
 *
 *  @return id value
 */
-(int) idValue;

/**
 *  Check if the row has an id column
 *
 *  @return true if has an id column
 */
-(BOOL) hasIdColumn;

/**
 *  Check if the row has an id value
 *
 *  @return true if has an id
 */
-(BOOL) hasId;

/**
 * Get the id column index
 *
 * @return id column index
 */
-(int) idIndex;

/**
 * Get the id column
 *
 * @return id column
 */
-(GPKGUserColumn *) idColumn;

/**
 * Get the id column name
 *
 * @return id column name
 */
-(NSString *) idColumnName;

/**
*  Get the pk value
*
*  @return pk value
*/
-(NSObject *) pk;

/**
 *  Check if the row has an pk column
 *
 *  @return true if has a pk column
 */
-(BOOL) hasPkColumn;

/**
 *  Check if the row has an pk value
 *
 *  @return true if has an pk
 */
-(BOOL) hasPk;

/**
 *  Get the primary key column index
 *
 *  @return pk index
 */
-(int) pkIndex;

/**
 *  Get the primary key column
 *
 *  @return pk column
 */
-(GPKGUserColumn *) pkColumn;

/**
 * Get the primary key column name
 *
 * @return primary key column name
 */
-(NSString *) pkColumnName;

/**
 *  Set the value at the index
 *
 *  @param index index
 *  @param value value
 */
-(void) setValueWithIndex: (int) index andValue: (NSObject *) value;

/**
 *  Set the value at the index without validation
 *
 *  @param index index
 *  @param value value
 */
-(void) setValueNoValidationWithIndex: (int) index andValue: (NSObject *) value;

/**
 *  Set the value of the column name
 *
 *  @param columnName column name
 *  @param value      value
 */
-(void) setValueWithColumnName: (NSString *) columnName andValue: (NSObject *) value;

/**
 *  Set the primary key id value
 *
 *  @param id id value
 */
-(void) setId: (NSNumber *) id;

/**
 *  Clears the id so the row can be used as part of an insert or create
 */
-(void) resetId;

/**
 *  Validate the value and its actual value types against the column data
 *  type class
 *
 *  @param column     column
 *  @param value      value
 *  @param valueTypes value type classes
 */
-(void) validateValueWithColumn: (GPKGUserColumn *) column andValue: (NSObject *) value andValueTypes: (NSArray *) valueTypes;

/**
 * Copy the value of the data type
 *
 * @param column
 *            table column
 * @param value
 *            value
 * @return copy value
 */
-(NSObject *) copyValue: (NSObject *) value forColumn: (GPKGUserColumn *) column;

@end
