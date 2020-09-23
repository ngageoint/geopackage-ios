//
//  GPKGMediaTableMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserTableMetadata.h"
#import "GPKGUserCustomColumn.h"

/**
 * Media Table Metadata for defining table creation information
 */
@interface GPKGMediaTableMetadata : GPKGUserTableMetadata

/**
 * Create metadata
 *
 * @return metadata
 */
+(GPKGMediaTableMetadata *) create;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @return metadata
 */
+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @return metadata
 */
+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGMediaTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns;

/**
 * Initialize
 */
-(instancetype) init;

/**
 * Constructor
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 */
-(instancetype) initWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns;

/**
 * Constructor
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 */
-(instancetype) initWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns;

@end
