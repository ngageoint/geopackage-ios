//
//  GPKGUserTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserColumn.h"
#import "GPKGContents.h"
#import "GPKGUserColumns.h"
#import "GPKGConstraints.h"

/**
 * Default id autoincrement setting
 */
static BOOL DEFAULT_AUTOINCREMENT = YES;

/**
 * Default primary key not null setting
 */
static BOOL DEFAULT_PK_NOT_NULL = YES;

/**
 *  Abstract user table
 */
@interface GPKGUserTable : NSObject <NSMutableCopying>

/**
 * Foreign key to Contents
 */
@property (nonatomic, strong) GPKGContents *contents;

/**
 *  Initialize
 *
 *  @param columns   user columns
 *
 *  @return new user table
 */
-(instancetype) initWithColumns: (GPKGUserColumns *) columns;

/**
 * Initialize
 *
 * @param userTable
 *            user table
 *
 *  @return new user table
 */
-(instancetype) initWithUserTable: (GPKGUserTable *) userTable;

/**
 * Get the contents data type
 *
 * @return data type
 */
-(NSString *) dataType;

/**
 * Get the contents data type from the contents or use the default
 *
 * @param defaultType
 *            default data type
 * @return contents or default data type
 */
-(NSString *) dataTypeWithDefault: (NSString *) defaultType;

/**
 * Create user columns for a subset of table columns
 *
 * @param columns
 *            columns
 * @return user columns
 */
-(GPKGUserColumns *) createUserColumnsWithColumns: (NSArray<GPKGUserColumn *> *) columns;

/**
 * Create user columns for a subset of table columns
 *
 * @param columnNames
 *            column names
 * @return user columns
 */
-(GPKGUserColumns *) createUserColumnsWithNames: (NSArray<NSString *> *) columnNames;

/**
 * Get the user columns
 *
 * @return user columns
 */
-(GPKGUserColumns *) userColumns;

/**
 *  Get the column index of the column name
 *
 *  @param columnName column name
 *
 *  @return index
 */
-(int) columnIndexWithColumnName: (NSString *) columnName;

/**
 * Get the array of column names
 *
 * @return column names
 */
-(NSArray<NSString *> *) columnNames;

/**
 *  Get the column name at the index
 *
 *  @param index index
 *
 *  @return column name
 */
-(NSString *) columnNameWithIndex: (int) index;

/**
 * Get the columns
 *
 * @return columns
 */
-(NSArray<GPKGUserColumn *> *) columns;

/**
 * Get the columns from the column names
 *
  * @param columnNames
 *            column names
 * @return columns
 */
-(NSArray<GPKGUserColumn *> *) columnsWithNames: (NSArray<NSString *> *) columnNames;

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
 * Check if the table has the column
 *
 * @param columnName
 *            column name
 * @return true if has the column
 */
-(BOOL) hasColumnWithColumnName: (NSString *) columnName;

/**
 *  Get the column count
 *
 *  @return column count
 */
-(int) columnCount;

/**
 * Get the table name
 *
 * @return table name
 */
-(NSString *) tableName;

/**
 * Set the table name
 *
 * @param tableName
 *            table name
 */
-(void) setTableName: (NSString *) tableName;

/**
 *  Check if the row has an id column
 *
 *  @return true if has an id column
 */
-(BOOL) hasIdColumn;

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
 * Check if the table has a primary key column
 *
 * @return true if has a primary key
 */
-(BOOL) hasPkColumn;

/**
 * Get the primary key column index
 *
 * @return primary key column index
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
 *  Add constraint
 *
 *  @param constraint constraint
 */
-(void) addConstraint: (GPKGConstraint *) constraint;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addConstraintArray: (NSArray<GPKGConstraint *> *) constraints;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addConstraints: (GPKGConstraints *) constraints;

/**
 * Check if has constraints
 *
 * @return true if has constraints
 */
-(BOOL) hasConstraints;

/**
 * Check if has constraints of the provided type
 *
 * @param type
 *            constraint type
 * @return true if has constraints
 */
-(BOOL) hasConstraintsOfType: (enum GPKGConstraintType) type;

/**
 * Get the constraints
 *
 * @return constraints
 */
-(GPKGConstraints *) constraints;

/**
 * Get the constraints of the provided type
 *
 * @param type
 *            constraint type
 * @return constraints
 */
-(NSArray<GPKGConstraint *> *) constraintsOfType: (enum GPKGConstraintType) type;

/**
 * Clear the constraints
 *
 * @return cleared constraints
 */
-(NSArray<GPKGConstraint *> *) clearConstraints;

/**
 * Get the columns with the provided data type
 *
 * @param type
 *            data type
 * @return columns
 */
-(NSArray *) columnsOfType: (enum GPKGDataType) type;

/**
 * Is the primary key modifiable
 *
 * @return true if the primary key is modifiable
 */
-(BOOL) isPkModifiable;

/**
 * Set if the primary key can be modified
 *
 * @param pkModifiable
 *            primary key modifiable flag
 */
-(void) setPkModifiable: (BOOL) pkModifiable;

/**
 * Is value validation against column types enabled
 *
 * @return true if values are validated against column types
 */
-(BOOL) isValueValidation;

/**
 * Set if values should validated against column types
 *
 * @param valueValidation
 *            value validation flag
 */
-(void) setValueValidation: (BOOL) valueValidation;

/**
 * Add a new column
 *
 * @param column
 *            new column
 */
-(void) addColumn: (GPKGUserColumn *) column;

/**
 * Rename a column
 *
 * @param column
 *            column
 * @param newColumnName
 *            new column name
 */
-(void) renameColumn: (GPKGUserColumn *) column toColumn: (NSString *) newColumnName;

/**
 * Rename a column
 *
 * @param columnName
 *            column name
 * @param newColumnName
 *            new column name
 */
-(void) renameColumnWithName: (NSString *) columnName toColumn: (NSString *) newColumnName;

/**
 * Rename a column
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
 * @param column
 *            column to drop
 */
-(void) dropColumn: (GPKGUserColumn *) column;

/**
 * Drop a column
 *
 * @param columnName
 *            column name
 */
-(void) dropColumnWithName: (NSString *) columnName;

/**
 * Drop a column
 *
 * @param index
 *            column index
 */
-(void) dropColumnWithIndex: (int) index;

/**
 * Alter a column
 *
 * @param column
 *            altered column
 */
-(void) alterColumn: (GPKGUserColumn *) column;

@end
