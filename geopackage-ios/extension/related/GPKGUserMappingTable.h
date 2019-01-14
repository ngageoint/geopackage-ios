//
//  GPKGUserMappingTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserCustomTable.h"

/**
 *  User Mapping Table constants
 */
extern NSString * const GPKG_UMT_COLUMN_BASE_ID;
extern NSString * const GPKG_UMT_COLUMN_RELATED_ID;

/**
 * Contains user mapping table factory and utility methods
 */
@interface GPKGUserMappingTable : GPKGUserCustomTable

/**
 * Create a user mapping table with the minimum required columns
 *
 * @param tableName
 *            table name
 * @return user mapping table
 */
+(GPKGUserMappingTable *) createWithName: (NSString *) tableName;

/**
 * Create a user mapping table with the minimum required columns followed by
 * the additional columns
 *
 * @param tableName
 *            table name
 * @param additionalColumns
 *            additional columns
 * @return user mapping table
 */
+(GPKGUserMappingTable *) createWithName: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGUserCustomColumn *> *) additionalColumns;

/**
 * Create the required table columns, starting at index 0
 *
 * @return user custom columns
 */
+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumns;

/**
 * Create the required table columns, starting at the provided index
 *
 * @param startingIndex
 *            starting index
 * @return user custom columns
 */
+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex;

/**
 * Create a base id column
 *
 * @param index
 *            column index
 * @return base id column
 */
+(GPKGUserCustomColumn *) createBaseIdColumnWithIndex: (int) index;

/**
 * Create a related id column
 *
 * @param index
 *            column index
 * @return related id column
 */
+(GPKGUserCustomColumn *) createRelatedIdColumnWithIndex: (int) index;

/**
 * Get the number of required columns
 *
 * @return required columns count
 */
+(int) numRequiredColumns;

/**
 * Get the required columns
 *
 * @return required columns
 */
+(NSArray<NSString *> *) requiredColumns;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns   list of columns
 *
 *  @return new user mapping table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

/**
 * Initialize
 *
 * @param table
 *            user custom table
 *
 *  @return new user mapping table
 */
-(instancetype) initWithTable: (GPKGUserCustomTable *) table;

/**
 * Get the base id column index
 *
 * @return base id column index
 */
-(int) baseIdColumnIndex;

/**
 * Get the base id column
 *
 * @return base id column
 */
-(GPKGUserCustomColumn *) baseIdColumn;

/**
 * Get the related id column index
 *
 * @return related id column index
 */
-(int) relatedIdColumnIndex;

/**
 * Get the related id column
 *
 * @return related id column
 */
-(GPKGUserCustomColumn *) relatedIdColumn;

@end
