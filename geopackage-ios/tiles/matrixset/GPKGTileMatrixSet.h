//
//  GPKGTileMatrixSet.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGContents.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGBoundingBox.h"

/**
 *  Tile Matrix Set table constants
 */
extern NSString * const GPKG_TMS_TABLE_NAME;
extern NSString * const GPKG_TMS_COLUMN_PK;
extern NSString * const GPKG_TMS_COLUMN_TABLE_NAME;
extern NSString * const GPKG_TMS_COLUMN_SRS_ID;
extern NSString * const GPKG_TMS_COLUMN_MIN_X;
extern NSString * const GPKG_TMS_COLUMN_MIN_Y;
extern NSString * const GPKG_TMS_COLUMN_MAX_X;
extern NSString * const GPKG_TMS_COLUMN_MAX_Y;

/**
 * Tile Matrix Set object. Defines the minimum bounding box (min_x, min_y,
 * max_x, max_y) and spatial reference system (srs_id) for all content in a tile
 * pyramid user data table.
 */
@interface GPKGTileMatrixSet : NSObject

/**
 *  Tile Pyramid User Data Table Name
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  Unique identifier for each Spatial Reference System within a GeoPackage
 */
@property (nonatomic, strong) NSNumber *srsId;

/**
 *  Bounding box minimum easting or longitude for all content in table_name
 */
@property (nonatomic, strong) NSDecimalNumber *minX;

/**
 *  Bounding box minimum northing or latitude for all content in table_name
 */
@property (nonatomic, strong) NSDecimalNumber *minY;

/**
 *  Bounding box maximum easting or longitude for all content in table_name
 */
@property (nonatomic, strong) NSDecimalNumber *maxX;

/**
 *  Bounding box maximum northing or latitude for all content in table_name
 */
@property (nonatomic, strong) NSDecimalNumber *maxY;

/**
 *  Set the Contents
 *
 *  @param contents contents
 */
-(void) setContents: (GPKGContents *) contents;

/**
 *  Set the Spatial Reference System
 *
 *  @param srs srs
 */
-(void) setSrs: (GPKGSpatialReferenceSystem *) srs;

/**
 *  Get a bounding box
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) getBoundingBox;

/**
 *  Set a bounding box
 *
 *  @param boundingBox bounding box
 */
-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox;

@end
