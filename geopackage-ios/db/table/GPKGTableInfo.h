//
//  GPKGTableInfo.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/23/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTableColumn.h"
#import "GPKGConnection.h"

/**
 * Index column
 */
extern NSString * const GPKG_TI_CID;

/**
 * Index column index
 */
extern int const GPKG_TI_CID_INDEX;

/**
 * Name column
 */
extern NSString * const GPKG_TI_NAME;

/**
 * Name column index
 */
extern int const GPKG_TI_NAME_INDEX;

/**
 * Type column
 */
extern NSString * const GPKG_TI_TYPE;

/**
 * Type column index
 */
extern int const GPKG_TI_TYPE_INDEX;

/**
 * Not null column
 */
extern NSString * const GPKG_TI_NOT_NULL;

/**
 * Not null column index
 */
extern int const GPKG_TI_NOT_NULL_INDEX;

/**
 * Default value column
 */
extern NSString * const GPKG_TI_DFLT_VALUE;

/**
 * Default value column index
 */
extern int const GPKG_TI_DFLT_VALUE_INDEX;

/**
 * Primary key column
 */
extern NSString * const GPKG_TI_PK;

/**
 * Primary key column index
 */
extern int const GPKG_TI_PK_INDEX;

/**
 * Default of NULL value
 */
extern NSString * const GPKG_TI_DEFAULT_NULL;

/**
 * Table Info queries (table_info)
 */
@interface GPKGTableInfo : NSObject

/**
 * Get the table name
 *
 * @return table name
 */
-(NSString *) tableName;

/**
 * Number of columns
 *
 * @return column count
 */
-(int) numColumns;

/**
 * Get the columns
 *
 * @return columns
 */
-(NSArray<GPKGTableColumn *> *) columns;

/**
 * Get the column at the index
 *
 * @param index
 *            column index
 * @return column
 */
-(GPKGTableColumn *) columnAtIndex: (int) index;

/**
 * Check if the table has the column
 *
 * @param name
 *            column name
 * @return true if has column
 */
-(BOOL) hasColumn: (NSString *) name;

/**
 * Get the column with the name
 *
 * @param name
 *            column name
 * @return column or null if does not exist
 */
-(GPKGTableColumn *) column: (NSString *) name;

/**
 * Check if the table has one or more primary keys
 *
 * @return true if has at least one primary key
 */
-(BOOL) hasPrimaryKey;

/**
 * Get the primary key columns
 *
 * @return primary key columns
 */
-(NSArray<GPKGTableColumn *> *) primaryKeys;

/**
 * Get the single or first primary key if one exists
 *
 * @return single or first primary key, null if no primary key
 */
-(GPKGTableColumn *) primaryKey;

/**
 * Query for the table_info of the table name
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return table info or null if no table
 */
+(GPKGTableInfo *) infoWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName;

/**
 * Get the data type from the type value
 *
 * @param type
 *            type value
 * @return data type or null
 */
+(enum GPKGDataType) dataType: (NSString *) type;

/**
 * Get the default object value for the string default value and type
 *
 * @param defaultValue
 *            default value
 * @param type
 *            type
 * @return default value
 */
+(NSObject *) defaultValue: (NSString *) defaultValue withType: (NSString *) type;

/**
 * Get the default object value for the string default value with the data
 * type
 *
 * @param defaultValue
 *            default value
 * @param type
 *            data type
 * @return default value
 */
+(NSObject *) defaultValue: (NSString *) defaultValue withDataType: (enum GPKGDataType) type;

@end
