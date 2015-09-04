//
//  GPKGMetadataReference.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGMetadata.h"

/**
 *  Metadata Reference table constants
 */
extern NSString * const GPKG_MR_TABLE_NAME;
extern NSString * const GPKG_MR_COLUMN_REFERENCE_SCOPE;
extern NSString * const GPKG_MR_COLUMN_TABLE_NAME;
extern NSString * const GPKG_MR_COLUMN_COLUMN_NAME;
extern NSString * const GPKG_MR_COLUMN_ROW_ID_VALUE;
extern NSString * const GPKG_MR_COLUMN_TIMESTAMP;
extern NSString * const GPKG_MR_COLUMN_FILE_ID;
extern NSString * const GPKG_MR_COLUMN_PARENT_ID;

/**
 *  Reference Scope Type enumeration
 */
enum GPKGReferenceScopeType{
    GPKG_RST_GEOPACKAGE,
    GPKG_RST_TABLE,
    GPKG_RST_COLUMN,
    GPKG_RST_ROW,
    GPKG_RST_ROW_COL
};

/**
 *  Reference Scope Type enumeration names
 */
extern NSString * const GPKG_RST_GEOPACKAGE_NAME;
extern NSString * const GPKG_RST_TABLE_NAME;
extern NSString * const GPKG_RST_COLUMN_NAME;
extern NSString * const GPKG_RST_ROW_NAME;
extern NSString * const GPKG_RST_ROW_COL_NAME;

/**
 * Links metadata in the gpkg_metadata table to data in the feature, and tiles
 * tables
 */
@interface GPKGMetadataReference : NSObject

/**
 * Lowercase metadata reference scope; one of ‘geopackage’,
 * ‘table’,‘column’, ’row’, ’row/col’
 */
@property (nonatomic, strong) NSString *referenceScope;

/**
 * Name of the table to which this metadata reference applies, or NULL for
 * reference_scope of ‘geopackage’.
 */
@property (nonatomic, strong) NSString *tableName;

/**
 * Name of the column to which this metadata reference applies; NULL for
 * reference_scope of ‘geopackage’,‘table’ or ‘row’, or the name of a column
 * in the table_name table for reference_scope of ‘column’ or ‘row/col’
 */
@property (nonatomic, strong) NSString *columnName;

/**
 * NULL for reference_scope of ‘geopackage’, ‘table’ or ‘column’, or the
 * rowed of a row record in the table_name table for reference_scope of
 * ‘row’ or ‘row/col’
 */
@property (nonatomic, strong) NSNumber *rowIdValue;

/**
 * timestamp value in ISO 8601 format as defined by the strftime function
 * '%Y-%m-%dT%H:%M:%fZ' format string applied to the current time
 */
@property (nonatomic, strong) NSDate *timestamp;

/**
 * gpkg_metadata table id column value for the metadata to which this
 * gpkg_metadata_reference applies
 */
@property (nonatomic, strong) NSNumber *fileId;

/**
 * gpkg_metadata table id column value for the hierarchical parent
 * gpkg_metadata for the gpkg_metadata to which this gpkg_metadata_reference
 * applies, or NULL if md_file_id forms the root of a metadata hierarchy
 */
@property (nonatomic, strong) NSNumber *parentId;

/**
 *  Get the reference scope type
 *
 *  @return reference scope type
 */
-(enum GPKGReferenceScopeType) getReferenceScopeType;

/**
 *  Set the reference scope type
 *
 *  @param referenceScopeType reference scope type
 */
-(void) setReferenceScopeType: (enum GPKGReferenceScopeType) referenceScopeType;

/**
 *  Set the table name
 *
 *  @param tableName table name
 */
-(void) setTableName:(NSString *)tableName;

/**
 *  Set the column name
 *
 *  @param columnName column name
 */
-(void) setColumnName:(NSString *)columnName;

/**
 *  Set the row id value
 *
 *  @param rowIdValue row id value
 */
-(void) setRowIdValue:(NSNumber *)rowIdValue;

/**
 *  Set the metadata
 *
 *  @param metadata metadata
 */
-(void) setMetadata:(GPKGMetadata *) metadata;

/**
 *  Set the parent metadata
 *
 *  @param metadata parent metadata
 */
-(void) setParentMetadata:(GPKGMetadata *) metadata;

@end
