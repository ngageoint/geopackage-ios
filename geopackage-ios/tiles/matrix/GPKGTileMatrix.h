//
//  GPKGTileMatrix.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGContents.h"

/**
 *  Tile Matrix table constants
 */
extern NSString * const GPKG_TM_TABLE_NAME;
extern NSString * const GPKG_TM_COLUMN_PK1;
extern NSString * const GPKG_TM_COLUMN_PK2;
extern NSString * const GPKG_TM_COLUMN_TABLE_NAME;
extern NSString * const GPKG_TM_COLUMN_ZOOM_LEVEL;
extern NSString * const GPKG_TM_COLUMN_MATRIX_WIDTH;
extern NSString * const GPKG_TM_COLUMN_MATRIX_HEIGHT;
extern NSString * const GPKG_TM_COLUMN_TILE_WIDTH;
extern NSString * const GPKG_TM_COLUMN_TILE_HEIGHT;
extern NSString * const GPKG_TM_COLUMN_PIXEL_X_SIZE;
extern NSString * const GPKG_TM_COLUMN_PIXEL_Y_SIZE;

/**
 * Tile Matrix object. Documents the structure of the tile matrix at each zoom
 * level in each tiles table. It allows GeoPackages to contain rectangular as
 * well as square tiles (e.g. for better representation of polar regions). It
 * allows tile pyramids with zoom levels that differ in resolution by factors of
 * 2, irregular intervals, or regular intervals other than factors of 2.
 */
@interface GPKGTileMatrix : NSObject

/**
 *  Tile Pyramid User Data Table Name
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  0 ⇐ zoom_level ⇐ max_level for table_name
 */
@property (nonatomic, strong) NSNumber *zoomLevel;

/**
 *  Number of columns (>= 1) in tile matrix at this zoom level
 */
@property (nonatomic, strong) NSNumber *matrixWidth;

/**
 *  Number of rows (>= 1) in tile matrix at this zoom level
 */
@property (nonatomic, strong) NSNumber *matrixHeight;

/**
 *  Tile width in pixels (>= 1)for this zoom level
 */
@property (nonatomic, strong) NSNumber *tileWidth;

/**
 *  Tile height in pixels (>= 1)for this zoom level
 */
@property (nonatomic, strong) NSNumber *tileHeight;

/**
 *  In t_table_name srid units or default meters for srid 0 (>0)
 */
@property (nonatomic, strong) NSDecimalNumber *pixelXSize;

/**
 *  In t_table_name srid units or default meters for srid 0 (>0)
 */
@property (nonatomic, strong) NSDecimalNumber *pixelYSize;

/**
 *  Set the Contents
 *
 *  @param contents contents
 */
-(void) setContents: (GPKGContents *) contents;

/**
 *  Set the zoom level
 *
 *  @param zoomLevel zoom level
 */
-(void) setZoomLevel:(NSNumber *)zoomLevel;

/**
 *  Set the matrix width
 *
 *  @param matrixWidth matrix width
 */
-(void) setMatrixWidth:(NSNumber *)matrixWidth;

/**
 *  Set the matrix height
 *
 *  @param matrixHeight matrix height
 */
-(void) setMatrixHeight:(NSNumber *)matrixHeight;

/**
 *  Set the tile width
 *
 *  @param tileWidth tile width
 */
-(void) setTileWidth:(NSNumber *)tileWidth;

/**
 *  Set the tile height
 *
 *  @param tileHeight tile height
 */
-(void) setTileHeight:(NSNumber *)tileHeight;

/**
 *  Set the pixel x size
 *
 *  @param pixelXSize pixel x size
 */
-(void) setPixelXSize:(NSDecimalNumber *)pixelXSize;

/**
 *  Set the pixel y size
 *
 *  @param pixelYSize pixel y size
 */
-(void) setPixelYSize:(NSDecimalNumber *)pixelYSize;

@end
