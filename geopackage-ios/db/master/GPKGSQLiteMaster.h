//
//  GPKGSQLiteMaster.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/26/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGSQLiteMasterTypes.h"
#import "GPKGSQLiteMasterColumns.h"
#import "GPKGTableConstraints.h"
#import "GPKGConnection.h"
#import "GPKGSQLiteMasterQuery.h"

/**
 * Table Name
 */
extern NSString * const GPKG_SM_TABLE_NAME;

/**
 * SQLite Master table queries (sqlite_master)
 */
@interface GPKGSQLiteMaster : NSObject

/**
 * Result count
 *
 * @return count
 */
-(int) count;

/**
 * Get the columns in the result
 *
 * @return columns
 */
-(NSArray<NSNumber *> *) columns;

/**
 * Get the type
 *
 * @param row
 *            row index
 * @return type
 */
-(enum GPKGSQLiteMasterType) typeAtRow: (int) row;

/**
 * Get the type string
 *
 * @param row
 *            row index
 * @return type string
 */
-(NSString *) typeStringAtRow: (int) row;

/**
 * Get the name
 *
 * @param row
 *            row index
 * @return name
 */
-(NSString *) nameAtRow: (int) row;

/**
 * Get the table name
 *
 * @param row
 *            row index
 * @return name
 */
-(NSString *) tableNameAtRow: (int) row;

/**
 * Get the rootpage
 *
 * @param row
 *            row index
 * @return name
 */
-(NSNumber *) rootpageAtRow: (int) row;

/**
 * Get the sql
 *
 * @param row
 *            row index
 * @return name
 */
-(NSString *) sqlAtRow: (int) row;

/**
 * Get the value of the column at the row index
 *
 * @param row
 *            row index
 * @param column
 *            column type
 * @return value
 */
-(NSObject *) valueAtRow: (int) row forColumn: (enum GPKGSQLiteMasterColumn) column;

/**
 * Get the row at the row index
 *
 * @param row
 *            row index
 * @return row column values
 */
-(NSArray<NSObject *> *) row: (int) row;

/**
 * Get the value in the row at the column index
 *
 * @param row
 *            row
 * @param column
 *            column type
 * @return value
 */
-(NSObject *) valueInRow: (NSArray<NSObject *> *) row forColumn: (enum GPKGSQLiteMasterColumn) column;

/**
 * Get the column index of the column type
 *
 * @param column
 *            column type
 * @return column index
 */
-(int) columnIndex: (enum GPKGSQLiteMasterColumn) column;

/**
 * Get the constraints from table SQL
 *
 * @param row
 *            row index
 * @return constraints
 */
-(GPKGTableConstraints *) constraintsAtRow: (int) row;

/**
 * Shortcut to build a column into an array
 *
 * @param column
 *            column
 * @return columns
 */
+(NSArray *) columnsFromColumn: (enum GPKGSQLiteMasterColumn) column;

/**
 * Shortcut to build a type into an array
 *
 * @param type
 *            type
 * @return types
 */
+(NSArray *) typesFromType: (enum GPKGSQLiteMasterType) type;

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @return count
 */
+(int) countWithConnection: (GPKGConnection *) db;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db;

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return count
 */
+(int) countWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andTable: (NSString *) tableName;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andTypes: (NSArray<NSNumber *> *) types;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type andTable: (NSString *) tableName;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andTypes: (NSArray<NSNumber *> *) types andTable: (NSString *) tableName;

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @return count
 */
+(int) countWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param type
 *            result type
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andType: (enum GPKGSQLiteMasterType) type;

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @param tableName
 *            table name
 * @return count
 */
+(int) countWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type andTable: (NSString *) tableName;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param type
 *            result type
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andType: (enum GPKGSQLiteMasterType) type andTable: (NSString *) tableName;

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @return count
 */
+(int) countWithConnection: (GPKGConnection *) db andTypes: (NSArray<NSNumber *> *) types;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param types
 *            result types
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andTypes: (NSArray<NSNumber *> *) types;

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @param tableName
 *            table name
 * @return count
 */
+(int) countWithConnection: (GPKGConnection *) db andTypes: (NSArray<NSNumber *> *) types andTable: (NSString *) tableName;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param types
 *            result types
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andTypes: (NSArray<NSNumber *> *) types andTable: (NSString *) tableName;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param query
 *            query
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andQuery: (GPKGSQLiteMasterQuery *) query;

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param query
 *            query
 * @return count
 */
+(int) countWithConnection: (GPKGConnection *) db andQuery: (GPKGSQLiteMasterQuery *) query;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param query
 *            query
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andQuery: (GPKGSQLiteMasterQuery *) query;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @param query
 *            query
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type andQuery: (GPKGSQLiteMasterQuery *) query;

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @param query
 *            query
 * @return count
 */
+(int) countWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type andQuery: (GPKGSQLiteMasterQuery *) query;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param type
 *            result type
 * @param query
 *            query
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andType: (enum GPKGSQLiteMasterType) type andQuery: (GPKGSQLiteMasterQuery *) query;

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @param query
 *            query
 * @return count
 */
+(int) countWithConnection: (GPKGConnection *) db andTypes: (NSArray<NSNumber *> *) types andQuery: (GPKGSQLiteMasterQuery *) query;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param types
 *            result types
 * @param query
 *            query
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andTypes: (NSArray<NSNumber *> *) types andQuery: (GPKGSQLiteMasterQuery *) query;

/**
 * Query the sqlite_master views on the table
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryViewsWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName;

/**
 * Query the sqlite_master views on the table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
+(GPKGSQLiteMaster *) queryViewsWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andTable: (NSString *) tableName;

/**
 * Count the sqlite_master views on the table
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return count
 */
+(int) countViewsWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName;

/**
 * Query for the table constraints
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return SQL constraints
 */
+(GPKGTableConstraints *) queryForConstraintsWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName;

@end
