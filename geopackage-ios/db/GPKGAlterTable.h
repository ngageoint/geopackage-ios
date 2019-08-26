//
//  GPKGAlterTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/21/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"
#import "GPKGUserTable.h"
#import "GPKGUserCustomColumn.h"
#import "GPKGTableMapping.h"

/**
 * Builds and performs alter table statements
 */
@interface GPKGAlterTable : NSObject

/**
 * Create the ALTER TABLE SQL command prefix
 *
 * @param table
 *            table name
 * @return alter table SQL prefix
 */
+(NSString *) alterTable: (NSString *) table;

/**
 * Rename a table
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 */
+(void) renameTable: (NSString *) tableName toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db;

/**
 * Create the rename table SQL
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 * @return rename table SQL
 */
+(NSString *) renameTableSQL: (NSString *) tableName toTable: (NSString *) newTableName;

/**
 * Rename a column
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @param newColumnName
 *            new column name
 */
+(void) renameColumn: (NSString *) columnName inTable: (NSString *) tableName toColumn: (NSString *) newColumnName withConnection: (GPKGConnection *) db;

/**
 * Create the rename column SQL
 *
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @param newColumnName
 *            new column name
 * @return rename table SQL
 */
+(NSString *) renameColumnSQL: (NSString *) columnName inTable: (NSString *) tableName toColumn: (NSString *) newColumnName;

/**
 * Add a column
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @param columnDef
 *            column definition
 */
+(void) addColumn: (NSString *) columnName withDefinition: (NSString *) columnDef toTable: (NSString *) tableName withConnection: (GPKGConnection *) db;

/**
 * Create the add column SQL
 *
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @param columnDef
 *            column definition
 * @return add column SQL
 */
+(NSString *) addColumnSQL: (NSString *) columnName withDefinition: (NSString *) columnDef toTable: (NSString *) tableName;

/**
 * Drop a column
 *
 * @param db
 *            connection
 * @param table
 *            table
 * @param columnName
 *            column name
 */
+(void) dropColumn: (NSString *) columnName fromTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db;

/**
 * Drop columns
 *
 * @param db
 *            connection
 * @param table
 *            table
 * @param columnNames
 *            column names
 */
+(void) dropColumns: (NSArray<NSString *> *) columnNames fromTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db;

/**
 * Drop a column
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 */
+(void) dropColumn: (NSString *) columnName fromTableName: (NSString *) tableName withConnection: (GPKGConnection *) db;

/**
 * Drop columns
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @param columnNames
 *            column names
 */
+(void) dropColumns: (NSArray<NSString *> *) columnNames fromTableName: (NSString *) tableName withConnection: (GPKGConnection *) db;

/**
 * Alter a column
 *
 * @param db
 *            connection
 * @param table
 *            table
 * @param column
 *            column
 */
+(void) alterColumn: (GPKGUserColumn *) column inTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db;

/**
 * Alter columns
 *
 * @param db
 *            connection
 * @param table
 *            table
 * @param columns
 *            columns
 * @param <T>
 *            user column type
 */
+(void) alterColumns: (NSArray<GPKGUserColumn *> *) columns inTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db;

/**
 * Alter a column
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @param column
 *            column
 */
+(void) alterColumn: (GPKGUserCustomColumn *) column inTableName: (NSString *) tableName withConnection: (GPKGConnection *) db;

/**
 * Alter columns
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @param columns
 *            columns
 * @param <T>
 *            user column type
 */
+(void) alterColumns: (NSArray<GPKGUserCustomColumn *> *) columns inTableName: (NSString *) tableName withConnection: (GPKGConnection *) db;

/**
 * Copy the table and row content
 *
 * @param db
 *            connection
 * @param table
 *            table
 * @param newTableName
 *            new table name
 */
+(void) copyTable: (GPKGUserTable *) table toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db;

/**
 * Copy the table
 *
 * @param db
 *            connection
 * @param table
 *            table
 * @param newTableName
 *            new table name
 * @param transferContent
 *            transfer row content to the new table
 */
+(void) copyTable: (GPKGUserTable *) table toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent withConnection: (GPKGConnection *) db;

/**
 * Copy the table and row content
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 */
+(void) copyTableName: (NSString *) tableName toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db;

/**
 * Copy the table
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 * @param transferContent
 *            transfer row content to the new table
 */
+(void) copyTableName: (NSString *) tableName toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent withConnection: (GPKGConnection *) db;

/**
 * Alter a table with a new table schema assuming a default table mapping.
 *
 * This removes views on the table, creates a new table, transfers the old
 * table data to the new, drops the old table, and renames the new table to
 * the old. Indexes, triggers, and views that reference deleted columns are
 * not recreated. An attempt is made to recreate the others including any
 * modifications for renamed columns.
 *
 * Making Other Kinds Of Table Schema Changes:
 * https://www.sqlite.org/lang_altertable.html
 *
 * @param db
 *            connection
 * @param newTable
 *            new table schema
 */
+(void) alterTable: (GPKGUserTable *) newTable withConnection: (GPKGConnection *) db;

/**
 * Alter a table with a new table schema and table mapping.
 *
 * Altering a table: Removes views on the table, creates a new table,
 * transfers the old table data to the new, drops the old table, and renames
 * the new table to the old. Indexes, triggers, and views that reference
 * deleted columns are not recreated. An attempt is made to recreate the
 * others including any modifications for renamed columns.
 *
 * Creating a new table: Creates a new table and transfers the table data to
 * the new. Triggers are not created on the new table. Indexes and views
 * that reference deleted columns are not recreated. An attempt is made to
 * create the others on the new table.
 *
 * Making Other Kinds Of Table Schema Changes:
 * https://www.sqlite.org/lang_altertable.html
 *
 * @param db
 *            connection
 * @param newTable
 *            new table schema
 * @param tableMapping
 *            table mapping
 */
+(void) alterTable: (GPKGUserTable *) newTable withMapping: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db;

/**
 * Alter a table with a new table SQL creation statement and table mapping.
 *
 * Altering a table: Removes views on the table, creates a new table,
 * transfers the old table data to the new, drops the old table, and renames
 * the new table to the old. Indexes, triggers, and views that reference
 * deleted columns are not recreated. An attempt is made to recreate the
 * others including any modifications for renamed columns.
 *
 * Creating a new table: Creates a new table and transfers the table data to
 * the new. Triggers are not created on the new table. Indexes and views
 * that reference deleted columns are not recreated. An attempt is made to
 * create the others on the new table.
 *
 * Making Other Kinds Of Table Schema Changes:
 * https://www.sqlite.org/lang_altertable.html
 *
 * @param db
 *            connection
 * @param sql
 *            new table SQL
 * @param tableMapping
 *            table mapping
 */
+(void) alterTableSQL: (NSString *) sql withMapping: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db;

@end
