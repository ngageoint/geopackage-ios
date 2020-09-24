//
//  GPKGSimpleAttributesTableMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserTableMetadata.h"
#import "GPKGUserCustomColumn.h"

/**
 * Simple Attributes Table Metadata for defining table creation information
 */
@interface GPKGSimpleAttributesTableMetadata : GPKGUserTableMetadata

/**
 * Create metadata
 *
 * @return metadata
 */
+(GPKGSimpleAttributesTableMetadata *) create;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @return metadata
 */
+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param columns
 *            columns
 * @return metadata
 */
+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param columns
 *            columns
 * @return metadata
 */
+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andColumns: (NSArray<GPKGUserCustomColumn *> *) columns;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param columns
 *            columns 
 * @return metadata
 */
+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param columns
 *            columns
 * @return metadata
 */
+(GPKGSimpleAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andColumns: (NSArray<GPKGUserCustomColumn *> *) columns;

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
 * @param columns
 *            columns
 */
-(instancetype) initWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns;

/**
 * Constructor
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param columns
 *            columns
 */
-(instancetype) initWithTable: (NSString *) tableName andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andColumns: (NSArray<GPKGUserCustomColumn *> *) columns;

@end
