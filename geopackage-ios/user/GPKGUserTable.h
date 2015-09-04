//
//  GPKGUserTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserColumn.h"
#import "GPKGUserUniqueConstraint.h"

/**
 *  Abstract user table
 */
@interface GPKGUserTable : NSObject

/**
 *  Table name
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  Array of column names
 */
@property (nonatomic, strong) NSArray *columnNames;

/**
 *  Array of columns
 */
@property (nonatomic, strong) NSArray *columns;

/**
 *  Mapping between column names and their index
 */
@property (nonatomic, strong) NSDictionary *nameToIndex;

/**
 *  Primary key column index
 */
@property (nonatomic) int pkIndex;

/**
 *  Array of unique constraints
 */
@property (nonatomic, strong) NSMutableArray *uniqueConstraints;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns   columns
 *
 *  @return new user table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

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
-(int) getColumnIndexWithColumnName: (NSString *) columnName;

/**
 *  Get the column name at the index
 *
 *  @param index index
 *
 *  @return column name
 */
-(NSString *) getColumnNameWithIndex: (int) index;

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
 *  Get the column count
 *
 *  @return column count
 */
-(int) columnCount;

/**
 *  Get the primary key column index
 *
 *  @return pk index
 */
-(GPKGUserColumn *) getPkColumn;

/**
 *  Add a unique constraint
 *
 *  @param uniqueConstraint unique constraint
 */
-(void) addUniqueConstraint: (GPKGUserUniqueConstraint *) uniqueConstraint;

@end
