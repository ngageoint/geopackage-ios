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
 *  Columns
 */
@property (nonatomic, strong) NSArray *columns;

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
 *  Get the row value
 *
 *  @return row value array
 */
-(NSArray *) getRow;

/**
 *  Get a row and populate with values and types
 *
 *  @param values values
 *  @param types  column types
 */
-(void) getRowPopulateValues: (NSMutableArray *) values andColumnTypes: (NSMutableArray *) types;

/**
 *  Get value with column index
 *
 *  @param index column index
 *
 *  @return value
 */
-(NSObject *) getValueWithIndex: (int) index;

/**
 *  Get column index for column name
 *
 *  @param columnName column name
 *
 *  @return index
 */
-(int) getColumnIndexWithName: (NSString *) columnName;

/**
 *  Get the column type of the column index
 *
 *  @param columnIndex index
 *
 *  @return column type
 */
-(int) getType: (int) columnIndex;

/**
 *  Get the string value at the column index
 *
 *  @param columnIndex column index
 *
 *  @return string value
 */
-(NSString *) getString: (int) columnIndex;

/**
 *  Get the int value at the column index
 *
 *  @param columnIndex column index
 *
 *  @return int number
 */
-(NSNumber *) getInt: (int) columnIndex;

/**
 *  Get the blob value at the column index
 *
 *  @param columnIndex column index
 *
 *  @return blob data
 */
-(NSData *) getBlob: (int) columnIndex;

/**
 *  Get the long value at the column index
 *
 *  @param columnIndex column index
 *
 *  @return long number
 */
-(NSNumber *) getLong: (int) columnIndex;

/**
 *  Get the double value at the column index
 *
 *  @param columnIndex column index
 *
 *  @return double number
 */
-(NSNumber *) getDouble: (int) columnIndex;

@end
