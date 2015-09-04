//
//  GPKGDataColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGContents.h"
#import "GPKGDataColumnConstraints.h"

/**
 *  Data Columns table constants
 */
extern NSString * const GPKG_DC_TABLE_NAME;
extern NSString * const GPKG_DC_COLUMN_PK1;
extern NSString * const GPKG_DC_COLUMN_PK2;
extern NSString * const GPKG_DC_COLUMN_TABLE_NAME;
extern NSString * const GPKG_DC_COLUMN_COLUMN_NAME;
extern NSString * const GPKG_DC_COLUMN_NAME;
extern NSString * const GPKG_DC_COLUMN_TITLE;
extern NSString * const GPKG_DC_COLUMN_DESCRIPTION;
extern NSString * const GPKG_DC_COLUMN_MIME_TYPE;
extern NSString * const GPKG_DC_COLUMN_CONSTRAINT_NAME;

/**
 * Stores minimal application schema identifying, descriptive and MIME type
 * information about columns in user vector feature and tile matrix data tables
 * that supplements the data available from the SQLite sqlite_master table and
 * pragma table_info(table_name) SQL function. The gpkg_data_columns data CAN be
 * used to provide more specific column data types and value ranges and
 * application specific structural and semantic information to enable more
 * informative user menu displays and more effective user decisions on the
 * suitability of GeoPackage contents for specific purposes.
 */
@interface GPKGDataColumns : NSObject

/**
 *  Name of the tiles or feature table
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  Name of the table column
 */
@property (nonatomic, strong) NSString *columnName;

/**
 *  A human-readable identifier (e.g. short name) for the column_name content
 */
@property (nonatomic, strong) NSString *name;

/**
 *  A human-readable formal title for the column_name content
 */
@property (nonatomic, strong) NSString *title;

/**
 *  A human-readable description for the table_name content
 */
@property (nonatomic, strong) NSString *theDescription;

/**
 *  MIME type of column_name if BLOB type, or NULL for other types
 */
@property (nonatomic, strong) NSString *mimeType;

/**
 *  Case sensitive column value constraint name specified by reference to
 *  gpkg_data_column_constraints.constraint name
 */
@property (nonatomic, strong) NSString *constraintName;

/**
 *  Set the Contents
 *
 *  @param contents contents
 */
-(void) setContents: (GPKGContents *) contents;

/**
 *  Set the Data Column Constraints
 *
 *  @param constraint constraints
 */
-(void) setConstraint: (GPKGDataColumnConstraints *) constraint;

@end
