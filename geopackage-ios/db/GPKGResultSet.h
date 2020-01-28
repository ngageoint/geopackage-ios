//
//  GPKGResultSet.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "GPKGDbConnection.h"

/**
 *  Result set from a database query
 */
@interface GPKGResultSet : NSObject

/**
 *  SQL statement
 */
@property (nonatomic) sqlite3_stmt *statement;

/**
 *  Result count
 */
@property (nonatomic) int count;

/**
 *  SQL Connection
 */
@property (nonatomic, strong) GPKGDbConnection *connection;

/**
 *  Column Names
 */
@property (nonatomic, strong) NSArray *columnNames;

/**
 *  Column name to index mapping
 */
@property (nonatomic, strong) NSDictionary * columnIndex;

/**
 *  Initialize
 *
 *  @param statement statement
 *  @param count     result count
 *
 *  @return new result set
 */
-(instancetype) initWithStatement:(sqlite3_stmt *) statement andCount: (int) count andConnection: (GPKGDbConnection *) connection;

/**
 *  Move to the next result if one exists
 *
 *  @return true a result found, false if no more results
 */
-(BOOL) moveToNext;

/**
 *  Move to the first result
 *
 *  @return reset code
 */
-(BOOL) moveToFirst;

/**
 *  Move result to index position
 *
 *  @param position index position
 *
 *  @return true if result at position found
 */
-(BOOL) moveToPosition: (int) position;

/**
 *  Close the result set
 */
-(void) close;

/**
 *  Close the result set statement, but leave the connection open
 */
-(void) closeStatement;

/**
 *  Get the row value
 *
 *  @return row value array
 */
-(NSArray *) row;

/**
 *  Get a row and populate with values and types
 *
 *  @param values values
 *  @param types  column types
 */
-(void) rowPopulateValues: (NSMutableArray *) values andColumnTypes: (NSMutableArray *) types;

/**
 *  Get value with column index
 *
 *  @param index column index
 *
 *  @return value
 */
-(NSObject *) valueWithIndex: (int) index;

/**
 * Get the value for the column name
 *
 * @param columnName
 *            column name
 * @return value
 */
-(NSObject *) valueWithColumnName: (NSString *) columnName;

/**
 *  Get column index for column name
 *
 *  @param columnName column name
 *
 *  @return index
 */
-(int) columnIndexWithName: (NSString *) columnName;

/**
 *  Get the column type of the column index
 *
 *  @param columnIndex index
 *
 *  @return column type
 */
-(int) type: (int) columnIndex;

/**
 *  Get the string value at the column index
 *
 *  @param columnIndex column index
 *
 *  @return string value
 */
-(NSString *) stringWithIndex: (int) columnIndex;

/**
 *  Get the int value at the column index
 *
 *  @param columnIndex column index
 *
 *  @return int number
 */
-(NSNumber *) intWithIndex: (int) columnIndex;

/**
 *  Get the blob value at the column index
 *
 *  @param columnIndex column index
 *
 *  @return blob data
 */
-(NSData *) blobWithIndex: (int) columnIndex;

/**
 *  Get the long value at the column index
 *
 *  @param columnIndex column index
 *
 *  @return long number
 */
-(NSNumber *) longWithIndex: (int) columnIndex;

/**
 *  Get the double value at the column index
 *
 *  @param columnIndex column index
 *
 *  @return double number
 */
-(NSNumber *) doubleWithIndex: (int) columnIndex;

/**
 *  Get the result count and close the result set
 *
 *  @return result count
 */
-(int) countAndClose;

@end
