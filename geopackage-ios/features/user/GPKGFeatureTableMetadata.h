//
//  GPKGFeatureTableMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserTableMetadata.h"
#import "GPKGFeatureTable.h"

/**
 * Default geometry column name
 */
extern NSString * const GPKG_FTM_DEFAULT_COLUMN_NAME;

/**
 * Feature Table Metadata for defining table creation information
 */
@interface GPKGFeatureTableMetadata : GPKGUserTableMetadata

/**
 * Create metadata
 *
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) create;

/**
 * Create metadata
 *
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param autoincrement
 *            autoincrement ids
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param columns
 *            feature columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andColumns: (GPKGFeatureColumns *) columns;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param boundingBox
 *            bounding box
 * @param columns
 *            feature columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andColumns: (GPKGFeatureColumns *) columns;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param table
 *            feature table
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andTable: (GPKGFeatureTable *) table;

/**
 * Create metadata
 *
 * @param geometryColumns
 *            geometry columns
 * @param boundingBox
 *            bounding box
 * @param table
 *            feature table
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andTable: (GPKGFeatureTable *) table;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param autoincrement
 *            autoincrement ids bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param autoincrement
 *            autoincrement ids
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param columns
 *            feature columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andColumns: (GPKGFeatureColumns *) columns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param boundingBox
 *            bounding box
 * @param columns
 *            feature columns
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andColumns: (GPKGFeatureColumns *) columns;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param table
 *            feature table
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andTable: (GPKGFeatureTable *) table;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param boundingBox
 *            bounding box
 * @param table
 *            feature table
 * @return metadata
 */
+(GPKGFeatureTableMetadata *) createWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andTable: (GPKGFeatureTable *) table;

/**
 * Bounding box
 */
@property (nonatomic, strong) GPKGBoundingBox *boundingBox;

/**
 * Geometry columns
 */
@property (nonatomic, strong) GPKGGeometryColumns *geometryColumns;

/**
 * Initialize
 *
 * @return new feature table metadata
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 *
 * @return new feature table metadata
 */
-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Initialize
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 *
 * @return new feature table metadata
 */
-(instancetype) initWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Initialize
 *
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 *
 * @return new feature table metadata
 */
-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Initialize
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param idColumnName
 *            id column name
 * @param autoincrement
 *            autoincrement ids
 * @param additionalColumns
 *            additional columns
 * @param boundingBox
 *            bounding box
 *
 * @return new feature table metadata
 */
-(instancetype) initWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumnName andAutoincrement: (BOOL) autoincrement andAdditionalColumns: (NSArray<GPKGFeatureColumn *> *) additionalColumns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Initialize
 *
 * @param geometryColumns
 *            geometry columns
 * @param boundingBox
 *            bounding box
 * @param columns
 *            columns
 *
 * @return new feature table metadata
 */
-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andColumns: (NSArray<GPKGFeatureColumn *> *) columns;

/**
 * Initialize
 *
 * @param dataType
 *            data type
 * @param geometryColumns
 *            geometry columns
 * @param boundingBox
 *            bounding box
 * @param columns
 *            columns
 *
 * @return new feature table metadata
 */
-(instancetype) initWithDataType: (NSString *) dataType andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andBoundingBox: (GPKGBoundingBox *) boundingBox andColumns: (NSArray<GPKGFeatureColumn *> *) columns;

/**
 * Get the column name
 *
 * @return column name
 */
-(NSString *) columnName;

/**
 * Get the geometry type
 *
 * @return geometry type
 */
-(enum SFGeometryType) geometryType;

@end
