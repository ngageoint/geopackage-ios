//
//  GPKGDataColumnsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGDataColumns.h"

/**
 *  Data Columns Data Access Object
 */
@interface GPKGDataColumnsDao : GPKGBaseDao

/**
 * Create the DAO
 *
 * @param database
 *            database connection
 * @return dao
 */
+(GPKGDataColumnsDao *) createWithDatabase: (GPKGConnection *) database;

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new data columns dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Get the Contents from the Data Columns
 *
 *  @param dataColumns data columns
 *
 *  @return contents
 */
-(GPKGContents *) contents: (GPKGDataColumns *) dataColumns;

/**
 *  Query by constraint name
 *
 *  @param constraintName constraint name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByConstraintName: (NSString *) constraintName;

/**
 *  Get DataColumn by column name and table name
 *
 *  @param tableName table name to query for
 *  @param columnName column name to query for
 *
 *  @return GPKGDataColumns
 */
-(GPKGDataColumns *) dataColumnByTableName: tableName andColumnName: columnName;

/**
 *  Query by table name
 *
 *  @param tableName table name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByTable: (NSString *) tableName;

/**
 * Delete by table name
 *
 * @param tableName
 *            table name
 * @return rows deleted
 */
-(int) deleteByTableName: (NSString *) tableName;

/**
 * Delete by table name
 *
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @return rows deleted
 */
-(int) deleteByTableName: (NSString *) tableName andColumnName: (NSString *) columnName;

/**
 * Save the table schema
 *
 * @param table
 *            user table
 */
-(void) saveSchemaWithTable: (GPKGUserTable *) table;

/**
 * Save the columns schema
 *
 * @param columns
 *            user columns
 */
-(void) saveSchemaWithColumns: (GPKGUserColumns *) columns;

/**
 * Save the columns schema
 *
 * @param table
 *            table name
 * @param columns
 *            user columns
 */
-(void) saveSchemaWithTable: (NSString *) table andColumns: (NSArray<GPKGUserColumn *> *) columns;

/**
 * Save the column schema
 *
 * @param table
 *            table name
 * @param column
 *            user column
 */
-(void) saveSchemaWithTable: (NSString *) table andColumn: (GPKGUserColumn *) column;

/**
 * Load the table schema
 *
 * @param table
 *            user table
 */
-(void) loadSchemaWithTable: (GPKGUserTable *) table;

/**
 * Load the columns schema
 *
 * @param columns
 *            user columns
 */
-(void) loadSchemaWithColumns: (GPKGUserColumns *) columns;

/**
 * Load the columns schema
 *
 * @param table
 *            table name
 * @param columns
 *            user columns
 */
-(void) loadSchemaWithTable: (NSString *) table andColumns: (NSArray<GPKGUserColumn *> *) columns;

/**
 * Load the column schema
 *
 * @param table
 *            table name
 * @param column
 *            user column
 */
-(void) loadSchemaWithTable: (NSString *) table andColumn: (GPKGUserColumn *) column;

/**
 * Get the column schema
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @return column schema or null
 */
-(GPKGDataColumns *) schemaByTable: table andColumn: column;

@end
