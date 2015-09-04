//
//  GPKGTileTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTable.h"
#import "GPKGTileColumn.h"

/**
 *  Tile Table constants
 */
extern NSString * const GPKG_TT_COLUMN_ID;
extern NSString * const GPKG_TT_COLUMN_ZOOM_LEVEL;
extern NSString * const GPKG_TT_COLUMN_TILE_COLUMN;
extern NSString * const GPKG_TT_COLUMN_TILE_ROW;
extern NSString * const GPKG_TT_COLUMN_TILE_DATA;

/**
 *  Represents a user tile table
 */
@interface GPKGTileTable : GPKGUserTable

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
 *  @param columns   columns
 *
 *  @return new tile table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

/**
 *  Get the zoom level column
 *
 *  @return zoom level tile column
 */
-(GPKGTileColumn *) getZoomLevelColumn;

/**
 *  Get the tile column column
 *
 *  @return tile column column
 */
-(GPKGTileColumn *) getTileColumnColumn;

/**
 *  Get the tile row column
 *
 *  @return tile row column
 */
-(GPKGTileColumn *) getTileRowColumn;

/**
 *  Get the tile data column
 *
 *  @return tile data column
 */
-(GPKGTileColumn *) getTileDataColumn;

/**
 *  Create the required table columns, starting at index 0
 *
 *  @return columns
 */
+(NSArray *) createRequiredColumns;

/**
 *  Create the required table columns, starting at the provided index
 *
 *  @param startingIndex starting column index
 *
 *  @return columns
 */
+(NSArray *) createRequiredColumnsWithStartingIndex: (int) startingIndex;

@end
