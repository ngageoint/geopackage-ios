//
//  GPKGSimpleAttributesTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserRelatedTable.h"
#import "GPKGRelationTypes.h"
#import "GPKGSimpleAttributesTableMetadata.h"

/**
 *  Simple Attributes constants
 */
extern NSString * const GPKG_RSAT_COLUMN_ID;

/**
 * Simple Attributes Requirements Class User-Defined Related Data Table
 */
@interface GPKGSimpleAttributesTable : GPKGUserRelatedTable

/**
 * User-Defined Simple Attributes Table relation name
 *
 * @return relation type
 */
+(enum GPKGRelationType) relationType;

/**
 * Create a simple attributes table with the metadata
 *
 * @param metadata
 *            simple attributes table metadata
 * @return simple attributes table
 */
+(GPKGSimpleAttributesTable *) createWithMetadata: (GPKGSimpleAttributesTableMetadata *) metadata;

/**
 * Create the required table columns
 *
 * @return user custom columns
 */
+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumns;

/**
 * Create the required table columns
 *
 * @param autoincrement
 *            autoincrement id values
 * @return user custom columns
 */
+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithAutoincrement: (BOOL) autoincrement;

/**
 * Create the required table columns with the id column name
 *
 * @param idColumnName
 *            id column name
 * @return user custom columns
 */
+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIdColumnName: (NSString *) idColumnName;
/**
 * Create the required table columns with the id column name
 *
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement id values
 * @return user custom columns
 */
+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement;

/**
 * Create the required table columns, starting at the provided index
 *
 * @param startingIndex
 *            starting index
 * @return user custom columns
 */
+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex;

/**
 * Create the required table columns, starting at the provided index
 *
 * @param startingIndex
 *            starting index
 * @param autoincrement
 *            autoincrement id values
 * @return user custom columns
 */
+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex andAutoincrement: (BOOL) autoincrement;

/**
 * Create the required table columns with id column name, starting at the provided index
 *
 * @param startingIndex
 *            starting index
 * @param idColumnName
 *            id column name
 * @return user custom columns
 */
+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex andIdColumnName: (NSString *) idColumnName;

/**
 * Create the required table columns with id column name, starting at the
 * provided index
 *
 * @param startingIndex
 *            starting index
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement id values
 * @return user custom columns
 */
+(NSArray<GPKGUserCustomColumn *> *) createRequiredColumnsWithIndex: (int) startingIndex andIdColumnName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement;

/**
 * Create the primary key id column
 *
 * @param idColumnName
 *            id column name
 * @return id column
 */
+(GPKGUserCustomColumn *) createIdColumnWithName: (NSString *) idColumnName;

/**
 * Create the primary key id column
 *
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement id values
 * @return id column
 */
+(GPKGUserCustomColumn *) createIdColumnWithName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement;

/**
 * Create the primary key id column
 *
 * @param index
 *            column index
 * @param idColumnName
 *            id column name
 * @return id column
 */
+(GPKGUserCustomColumn *) createIdColumnWithIndex: (int) index andName: (NSString *) idColumnName;

/**
 * Create the primary key id column
 *
 * @param index
 *            column index
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement id values
 * @return id column
 */
+(GPKGUserCustomColumn *) createIdColumnWithIndex: (int) index andName: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement;

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
 * Get the required columns
 *
 * @param idColumnName
 *            id column name
 * @return required columns
 */
+(NSArray<NSString *> *) requiredColumnsWithIdColumnName: (NSString *) idColumnName;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns   list of columns
 *
 *  @return new simple attributes table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns   list of columns
 *  @param idColumnName  id column name
 *
 *  @return new simple attributes table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andIdColumnName: (NSString *) idColumnName;

/**
 * Initialize
 *
 * @param table
 *            user custom table
 *
 *  @return new simple attributes table
 */
-(instancetype) initWithTable: (GPKGUserCustomTable *) table;

/**
 * Get the id column index
 *
 * @return id column index
 */
-(int) idColumnIndex;

/**
 * Get the id column
 *
 * @return id column
 */
-(GPKGUserCustomColumn *) idColumn;

/**
 * Determine if the column is a non nullable simple type: TEXT, INTEGER, or REAL
 *
 * @param column
 *            user column
 * @return true if a simple column
 */
+(BOOL) isSimpleColumn: (GPKGUserColumn *) column;

/**
 * Determine if the data type is a simple type: TEXT, INTEGER, or REAL storage classes
 *
 * @param dataType
 *            data type
 * @return true if a simple column
 */
+(BOOL) isSimpleDataType: (enum GPKGDataType) dataType;

@end
