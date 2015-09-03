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
@interface GPKGUserRow : NSObject

/**
 *  User table
 */
@property (nonatomic, strong) GPKGUserTable *table;

/**
 *  Column types of this row, based upon the data values
 */
@property (nonatomic, strong) NSArray *columnTypes;

/**
 *  Array of row values
 */
@property (nonatomic, strong) NSMutableArray *values;

/**
 *  Initialize
 *
 *  @param table       user table
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return new user row
 */
-(instancetype) initWithTable: (GPKGUserTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table user table
 *
 *  @return new user row
 */
-(instancetype) initWithTable: (GPKGUserTable *) table;

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
-(NSArray *) getColumnNames;

/**
 *  Get the column name at the index
 *
 *  @param index index
 *
 *  @return column name
 */
-(NSString *) getColumnNameWithIndex: (int) index;

/**
 *  Get the column index of the column name
 *
 *  @param columnName column name
 *
 *  @return index
 */
-(int) getColumnIndexWithColumnName: (NSString *) columnName;

/**
 *  Get the value at the index
 *
 *  @param index index
 *
 *  @return value
 */
-(NSObject *) getValueWithIndex: (int) index;

/**
 *  Get the value of the column name
 *
 *  @param columnName column name
 *
 *  @return value
 */
-(NSObject *) getValueWithColumnName: (NSString *) columnName;

/**
 *  Get the database formatted value at the index
 *
 *  @param index index
 *
 *  @return value
 */
-(NSObject *) getDatabaseValueWithIndex: (int) index;

/**
 *  Get the datbase formatted value of the column name
 *
 *  @param columnName column name
 *
 *  @return value
 */
-(NSObject *) getDatabaseValueWithColumnName: (NSString *) columnName;

/**
 *  Get the row column type at the index
 *
 *  @param index index
 *
 *  @return row column type
 */
-(int) getRowColumnTypeWithIndex: (int) index;

/**
 *  Get the row column type of the column name
 *
 *  @param columnName column name
 *
 *  @return row column type
 */
-(int) getRowColumnTypeWithColumnName: (NSString *) columnName;

/**
 *  Get the column at the index
 *
 *  @param index index
 *
 *  @return column
 */
-(GPKGUserColumn *) getColumnWithIndex: (int) index;

/**
 *  Get the column of the column name
 *
 *  @param columnName column name
 *
 *  @return column
 */
-(GPKGUserColumn *) getColumnWithColumnName: (NSString *) columnName;

/**
 *  Get the id value, which is the value of the primary key
 *
 *  @return id value
 */
-(NSNumber *) getId;

/**
 *  Get the primary key column index
 *
 *  @return pk index
 */
-(int) getPkColumnIndex;

/**
 *  Get the primary key column
 *
 *  @return pk column
 */
-(GPKGUserColumn *) getPkColumn;

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

@end
