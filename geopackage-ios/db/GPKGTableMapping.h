//
//  GPKGTableMapping.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/21/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGMappedColumn.h"
#import "GPKGUserTable.h"
#import "GPKGTableInfo.h"
#import "GPKGConnection.h"

/**
 * Mapping between column names being mapped to and the mapped column
 * information
 */
@interface GPKGTableMapping : NSObject

/**
 * From table name
 */
@property (nonatomic, strong)  NSString *fromTable;

/**
 * To table name
 */
@property (nonatomic, strong)  NSString *toTable;

/**
 * Transfer row content to new table
 */
@property (nonatomic)  BOOL transferContent;

/**
 * Custom where clause (in addition to column where mappings)
 */
@property (nonatomic, strong)  NSString *where;

/**
 * Initialize
 *
 * @return new table mapping
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param tableName
 *            table name
 * @param columns
 *            user columns
 *
 * @return new table mapping
 */
-(instancetype) initWithTableName: (NSString *) tableName andColumns: (NSArray<GPKGUserColumn *> *) columns;

/**
 * Initialize
 *
 * @param table
 *            user table
 *
 * @return new table mapping
 */
-(instancetype) initWithTable: (GPKGUserTable *) table;

/**
 * Initialize
 *
 * @param table
 *            user table
 * @param droppedColumnNames
 *            dropped column names
 *
 * @return new table mapping
 */
-(instancetype) initWithTable: (GPKGUserTable *) table andDroppedColumns: (NSArray<NSString *> *) droppedColumnNames;

/**
 * Initialize
 *
 * @param table
 *            user table
 * @param newTableName
 *            new table name
 *
 * @return new table mapping
 */
-(instancetype) initWithTable: (GPKGUserTable *) table andNewTable: (NSString *) newTableName;

/**
 * Initialize
 *
 * @param tableInfo
 *            table info
 *
 * @return new table mapping
 */
-(instancetype) initWithTableInfo: (GPKGTableInfo *) tableInfo;

/**
 * Initialize
 *
 * @param tableName
 *            table name
 * @param db
 *            connection
 *
 * @return new table mapping
 */
-(instancetype) initWithTableName: (NSString *) tableName andConnection: (GPKGConnection *) db;

/**
 * Check if the table mapping is to a new table
 *
 * @return true if a new table
 */
-(BOOL) isNewTable;

/**
 * Add a column
 *
 * @param column
 *            mapped column
 */
-(void) addColumn: (GPKGMappedColumn *) column;

/**
 * Add a column
 *
 * @param columnName
 *            column name
 */
-(void) addColumnName: (NSString *) columnName;

/**
 * Remove a column
 *
 * @param columnName
 *            column name
 * @return removed mapped column or null
 */
-(GPKGMappedColumn *) removeColumn: (NSString *) columnName;

/**
 * Get the column names
 *
 * @return column names
 */
-(NSArray<NSString *> *) columnNames;

/**
 * Get the mapped column values
 *
 * @return columns
 */
-(NSArray<GPKGMappedColumn *> *) mappedColumns;

/**
 * Get the mapped column for the column name
 *
 * @param columnName
 *            column name
 * @return mapped column
 */
-(GPKGMappedColumn *) columnForName: (NSString *) columnName;

/**
 * Add a dropped column
 *
 * @param columnName
 *            column name
 */
-(void) addDroppedColumn: (NSString *) columnName;

/**
 * Remove a dropped column
 *
 * @param columnName
 *            column name
 * @return true if removed
 */
-(BOOL) removeDroppedColumn: (NSString *) columnName;

/**
 * Get a set of dropped columns
 *
 * @return dropped columns
 */
-(NSSet<NSString *> *) droppedColumns;

/**
 * Check if the column name is a dropped column
 *
 * @param columnName
 *            column name
 * @return true if a dropped column
 */
-(BOOL) isDroppedColumn: (NSString *) columnName;

/**
 * Check if there is a custom where clause
 *
 * @return true if where clause
 */
-(BOOL) hasWhere;

@end
