//
//  GPKGTileColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserColumns.h"
#import "GPKGTileColumn.h"

/**
 *  Tile Table constants
 */
extern NSString * const GPKG_TC_COLUMN_ID;
extern NSString * const GPKG_TC_COLUMN_ZOOM_LEVEL;
extern NSString * const GPKG_TC_COLUMN_TILE_COLUMN;
extern NSString * const GPKG_TC_COLUMN_TILE_ROW;
extern NSString * const GPKG_TC_COLUMN_TILE_DATA;

/**
 * Collection of tile columns
 */
@interface GPKGTileColumns : GPKGUserColumns

/**
 *  Zoom level column index
 */
@property (nonatomic) int zoomLevelIndex;

/**
 *  Tile column column index
 */
@property (nonatomic) int tileColumnIndex;

/**
 *  Tile row column index
 */
@property (nonatomic) int tileRowIndex;

/**
 *  Tile data column index
 */
@property (nonatomic) int tileDataIndex;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns     columns
 *
 *  @return new tile columns
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns     columns
 *  @param custom       custom column specification
 *
 *  @return new tile columns
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andCustom: (BOOL) custom;

/**
 * Initialize
 *
 * @param tileColumns
 *            tile columns
 *
 *  @return new tile columns
 */
-(instancetype) initWithTileColumns: (GPKGTileColumns *) tileColumns;

/**
 *  Check if has a zoom level column
 *
 *  @return true if has a zoom level column
 */
-(BOOL) hasZoomLevelColumn;

/**
 *  Get the zoom level column
 *
 *  @return zoom level tile column
 */
-(GPKGTileColumn *) zoomLevelColumn;

/**
 *  Check if has a tile column column
 *
 *  @return true if has a tile column column
 */
-(BOOL) hasTileColumnColumn;

/**
 *  Get the tile column column
 *
 *  @return tile column column
 */
-(GPKGTileColumn *) tileColumnColumn;

/**
 *  Check if has a tile row column
 *
 *  @return true if has a tile row column
 */
-(BOOL) hasTileRowColumn;

/**
 *  Get the tile row column
 *
 *  @return tile row column
 */
-(GPKGTileColumn *) tileRowColumn;

/**
 *  Check if has a tile data column
 *
 *  @return true if has a tile data column
 */
-(BOOL) hasTileDataColumn;

/**
 *  Get the tile data column
 *
 *  @return tile data column
 */
-(GPKGTileColumn *) tileDataColumn;

@end
