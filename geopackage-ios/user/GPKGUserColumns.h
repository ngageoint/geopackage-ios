//
//  GPKGUserColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserColumn.h"

/**
 * Abstract collection of columns from a user table, representing a full set of
 * table columns or a subset from a query
 */
@interface GPKGUserColumns : NSObject <NSMutableCopying>

/**
 *  Table name, null when a pre-ordered subset of columns for a query
 */
@property (nonatomic, strong) NSString *tableName;

/**
 * Custom column specification flag (subset of table columns or different
 * ordering)
 */
@property (nonatomic) BOOL custom;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns     columns
 *  @param custom       custom column specification
 *
 *  @return new user columns
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andCustom: (BOOL) custom;

/**
 * Initialize
 *
 * @param userColumns
 *            user columns
 *
 *  @return new user columns
 */
-(instancetype) initWithUserColumns: (GPKGUserColumns *) userColumns;

/**
 * Update the table columns
 */
-(void) updateColumns;

/**
 *  Check for duplicate column names
 *
 *  @param index         index
 *  @param previousIndex previous index
 *  @param column        column
 */
-(void) duplicateCheckWithIndex: (int) index andPreviousIndex: (NSNumber *) previousIndex andColumn: (NSString *) column;

/**
 *  Check for the expected data type
 *
 *  @param expected expected data type
 *  @param column   column
 */
-(void) typeCheckWithExpected: (enum GPKGDataType) expected andColumn: (GPKGUserColumn *) column;

/**
 *  Check for missing columns
 *
 *  @param index  index
 *  @param column column
 */
-(void) missingCheckWithIndex: (NSNumber *) index andColumn: (NSString *) column;

/**
 *  Get the column index of the column name
 *
 *  @param columnName column name
 *
 *  @return index
 */
-(int) columnIndexWithColumnName: (NSString *) columnName;

/**
 *  Get the column index of the column name
 *
 *  @param columnName column name
 *  @param required     column existence is required
 *
 *  @return index
 */
-(NSNumber *) columnIndexWithColumnName: (NSString *) columnName andRequired: (BOOL) required;

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
 * Get the list of columns
 *
 * @return columns
 */
-(NSArray<GPKGUserColumn *> *) columns;

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
 *  Get the primary key column index
 *
 *  @return pk index
 */
-(GPKGUserColumn *) pkColumn;

/**
 *  Get the primary key column name
 *
 *  @return primary key column name
 */
-(NSString *) pkColumnName;

/**
 * Get the columns with the provided data type
 *
 * @param type
 *            data type
 * @return columns
 */
-(NSArray *) columnsOfType: (enum GPKGDataType) type;

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
