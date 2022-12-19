//
//  GPKGAttributesTableMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserTableMetadata.h"
#import "GPKGAttributesColumn.h"
#import "GPKGAttributesTable.h"

@interface GPKGAttributesTableMetadata : GPKGUserTableMetadata

/**
 * Create metadata
 *
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) create;

/**
 * Create metadata
 *
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns;

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
+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

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
+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns;

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
+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

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
 * @param constraints
 *            constraints
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

/**
 * Create metadata
 *
 * @param columns
 *            columns
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithColumns: (GPKGAttributesColumns *) columns;

/**
 * Create metadata
 *
 * @param columns
 *            columns
 * @param constraints
 *            constraints
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithColumns: (GPKGAttributesColumns *) columns andConstraints: (GPKGConstraints *) constraints;

/**
 * Create metadata
 *
 * @param table
 *            attributes table
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithAttributesTable: (GPKGAttributesTable *) table;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
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
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param columns
 *            columns
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andColumns: (GPKGAttributesColumns *) columns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param columns
 *            columns
 * @param constraints
 *            constraints
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andColumns: (GPKGAttributesColumns *) columns andConstraints: (GPKGConstraints *) constraints;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param table
 *            attributes table
 * @return metadata
 */
+(GPKGAttributesTableMetadata *) createWithDataType: (NSString *) dataType andAttributesTable: (GPKGAttributesTable *) table;

/**
 *  Constraints
 */
@property (nonatomic, strong) GPKGConstraints *constraints;

/**
 * Initialize
 *
 * @return new attributes table metadata
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 *
 * @return new attributes table metadata
 */
-(instancetype) initWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

/**
 * Initialize
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 *
 * @return new attributes table metadata
 */
 -(instancetype) initWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

/**
 * Initialize
 *
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 *
 * @return new attributes table metadata
 */
-(instancetype) initWithTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

/**
 * Initialize
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param constraints
 *            constraints
 *
 * @return new attributes table metadata
 */
 -(instancetype) initWithDataType: (NSString *) dataType andTable: (NSString *) tableName andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGAttributesColumn *> *) additionalColumns andConstraints: (GPKGConstraints *) constraints;

/**
 * Initialize
 *
 * @param tableName
 *            table name
 * @param columns
 *            columns
 * @param constraints
 *            constraints
 *
 * @return new attributes table metadata
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray<GPKGAttributesColumn *> *) columns andConstraints: (GPKGConstraints *) constraints;

/**
 * Initialize
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param columns
 *            columns
 * @param constraints
 *            constraints
 *
 * @return new attributes table metadata
 */
-(instancetype) initWithDataType: (NSString *) dataType andTable: (NSString *) tableName andColumns: (NSArray<GPKGAttributesColumn *> *) columns andConstraints: (GPKGConstraints *) constraints;

@end
