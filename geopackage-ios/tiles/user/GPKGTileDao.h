//
//  GPKGTileDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGTileMatrixSet.h"
#import "GPKGTileTable.h"
#import "GPKGTileRow.h"
#import "GPKGTileMatrix.h"
#import "GPKGTileGrid.h"

/**
 *  Tile DAO for reading tile user tables
 */
@interface GPKGTileDao : GPKGUserDao

/**
 *  Tile Matrix Set
 */
@property (nonatomic, strong) GPKGTileMatrixSet * tileMatrixSet;

/**
 *  Tile Matrices
 */
@property (nonatomic, strong) NSArray * tileMatrices;

/**
 *  Mapping between zoom levels and the tile matrix
 */
@property (nonatomic, strong) NSDictionary * zoomLevelToTileMatrix;

/**
 *  Min zoom
 */
@property (nonatomic) int minZoom;

/**
 *  Max zoom
 */
@property (nonatomic) int maxZoom;

/**
 *  Array of widths of the tiles at each zoom level in meters
 */
@property (nonatomic, strong) NSArray * widths;

/**
 *  Array of heights of the tiles at each zoom level in meters
 */
@property (nonatomic, strong) NSArray * heights;

/**
 *  Initialize
 *
 *  @param database      database connection
 *  @param table         tile table
 *  @param tileMatrixSet tile matrix set
 *  @param tileMatrices  tile matrices
 *
 *  @return new tile dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGTileTable *) table andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray *) tileMatrices;

/**
 *  Get the bounding box of tiles at the zoom level
 *
 *  @param zoomLevel zoom level
 *
 *  @return bounding box of zoom level, or nil if no tiles
 */
-(GPKGBoundingBox *) getBoundingBoxWithZoomLevel: (int) zoomLevel;

/**
 *  Get the tile grid of the zoom level
 *
 *  @param zoomLevel zoom level
 *
 *  @return tile grid at zoom level, nil if no tile matrix at zoom level
 */
-(GPKGTileGrid *) getTileGridWithZoomLevel: (int) zoomLevel;

/**
 *  Get the tile table
 *
 *  @return tile table
 */
-(GPKGTileTable *) getTileTable;

/**
 *  Get the tile row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return tile row
 */
-(GPKGTileRow *) getTileRow: (GPKGResultSet *) results;

/**
 *  Create a new tile row with the column types and values
 *
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return tile row as user row
 */
-(GPKGUserRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Create a new tile row
 *
 *  @return tile row
 */
-(GPKGTileRow *) newRow;

/**
 * Adjust the tile matrix lengths if needed. Check if the tile matrix width
 * and height need to expand to account for pixel * number of pixels fitting
 * into the tile matrix lengths
 */
-(void) adjustTileMatrixLengths;

/**
 *  Get the tile matrix at the zoom level
 *
 *  @param zoomLevel zoom level
 *
 *  @return tile matrix
 */
-(GPKGTileMatrix *) getTileMatrixWithZoomLevel: (int) zoomLevel;

/**
 *  Query for a Tile
 *
 *  @param column    column
 *  @param row       row
 *  @param zoomLevel zoom level
 *
 *  @return tile row
 */
-(GPKGTileRow *) queryForTileWithColumn: (int) column andRow: (int) row andZoomLevel: (int) zoomLevel;

/**
 *  Query for a Tiles at a zoom level
 *
 *  @param zoomLevel zoom level
 *
 *  @return result set
 */
-(GPKGResultSet *) queryforTileWithZoomLevel: (int) zoomLevel;

/**
 *  Query for Tiles at a zoom level in descending row and column order
 *
 *  @param zoomLevel zoom level
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForTileDescending: (int) zoomLevel;

/**
 *  Query for Tiles at a zoom level and column
 *
 *  @param column    column
 *  @param zoomLevel zoom level
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForTilesInColumn: (int) column andZoomLevel: (int) zoomLevel;

/**
 *  Query for Tiles at a zoom level and row
 *
 *  @param row       row
 *  @param zoomLevel zoom level
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForTilesInRow: (int) row andZoomLevel: (int) zoomLevel;

/**
 *  Get the zoom level for the provided width and height in the default units
 *
 *  @param length length in meters
 *
 *  @return zoom level
 */
-(NSNumber *) getZoomLevelWithLength: (double) length;

/**
 *  Query by tile grid and zoom level
 *
 *  @param tileGrid  tile grid
 *  @param zoomLevel zoom level
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByTileGrid: (GPKGTileGrid *) tileGrid andZoomLevel: (int) zoomLevel;

/**
 *  Query for the bounding tile grid with tiles at the zoom level
 *
 *  @param zoomLevel zoom level
 *
 *  @return tile grid of tiles at the zoom level
 */
-(GPKGTileGrid *) queryForTileGridWithZoomLevel: (int) zoomLevel;

/**
 *  Delete a Tile
 *
 *  @param column    column
 *  @param row       row
 *  @param zoomLevel zoom level
 *
 *  @return number deleted, should be 0 or 1
 */
-(int) deleteTileWithColumn: (int) column andRow: (int) row andZoomLevel: (int) zoomLevel;

/**
 *  Count of Tiles at a zoom level
 *
 *  @param zoomLevel zoom level
 *
 *  @return count
 */
-(int) countWithZoomLevel: (int) zoomLevel;

/**
 *  Determine if the tiles are in the standard web mercator coordinate tile format
 *
 *  @return true if standard web mercator format
 */
-(BOOL) isStandardWebMercatorFormat;

@end
