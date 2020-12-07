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
#import "GPKGTileMatrixSetDao.h"
#import "GPKGTileMatrixDao.h"

/**
 *  Tile DAO for reading tile user tables
 */
@interface GPKGTileDao : GPKGUserDao

/**
 *  Tile Matrix Set
 */
@property (nonatomic, strong) GPKGTileMatrixSet *tileMatrixSet;

/**
 *  Tile Matrices
 */
@property (nonatomic, strong) NSArray<GPKGTileMatrix *> *tileMatrices;

/**
 *  Mapping between zoom levels and the tile matrix
 */
@property (nonatomic, strong) NSDictionary<NSNumber *, GPKGTileMatrix *> *zoomLevelToTileMatrix;

/**
 *  Zoom levels
 */
@property (nonatomic, strong) NSArray<NSNumber *> *zoomLevels;

/**
 *  Min zoom
 */
@property (nonatomic) int minZoom;

/**
 *  Max zoom
 */
@property (nonatomic) int maxZoom;

/**
 *  Array of widths of the tiles at each zoom level in default units
 */
@property (nonatomic, strong) NSArray *widths;

/**
 *  Array of heights of the tiles at each zoom level in default units
 */
@property (nonatomic, strong) NSArray *heights;

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
-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGTileTable *) table andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices;

/**
 *  Get the bounding box of tiles at the zoom level
 *
 *  @param zoomLevel zoom level
 *
 *  @return bounding box of zoom level, or nil if no tiles
 */
-(GPKGBoundingBox *) boundingBoxWithZoomLevel: (int) zoomLevel;

/**
 *  Get the bounding box of tiles at the zoom level
 *
 *  @param zoomLevel zoom level
 *  @param projection desired projection
 *
 *  @return bounding box of zoom level, or nil if no tiles
 */
-(GPKGBoundingBox *) boundingBoxWithZoomLevel: (int) zoomLevel inProjection: (SFPProjection *) projection;

/**
 *  Get the tile grid of the zoom level
 *
 *  @param zoomLevel zoom level
 *
 *  @return tile grid at zoom level, nil if no tile matrix at zoom level
 */
-(GPKGTileGrid *) tileGridWithZoomLevel: (int) zoomLevel;

/**
 *  Get the tile table
 *
 *  @return tile table
 */
-(GPKGTileTable *) tileTable;

/**
 *  Get the tile row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return tile row
 */
-(GPKGTileRow *) tileRow: (GPKGResultSet *) results;

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
-(GPKGTileMatrix *) tileMatrixWithZoomLevel: (int) zoomLevel;

/**
 *  Get the tile matrix at the min (first) zoom
 *
 *  @return tile matrix
 */
-(GPKGTileMatrix *) tileMatrixAtMinZoom;

/**
 * Get the Spatial Reference System
 *
 * @return srs
 */
-(GPKGSpatialReferenceSystem *) srs;

/**
 * Get the Spatial Reference System id
 *
 * @return srs id
 */
-(NSNumber *) srsId;

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
 *  @param length length in default units
 *
 *  @return zoom level
 */
-(NSNumber *) zoomLevelWithLength: (double) length;

/**
 * Get the zoom level for the provided width and height in the default units
 *
 * @param width
 *            in default units
 * @param height
 *            in default units
 * @return zoom level
 */
-(NSNumber *) zoomLevelWithWidth: (double) width andHeight: (double) height;

/**
 * Get the closest zoom level for the provided width and height in the
 * default units
 *
 * @param length
 *            in default units
 * @return zoom level
 */
-(NSNumber *) closestZoomLevelWithLength: (double) length;

/**
 * Get the closest zoom level for the provided width and height in the
 * default units
 *
 * @param width
 *            in default units
 * @param height
 *            in default units
 * @return zoom level
 */
-(NSNumber *) closestZoomLevelWithWidth: (double) width andHeight: (double) height;

/**
 * Get the approximate zoom level for the provided length in the default
 * units. Tiles may or may not exist for the returned zoom level. The
 * approximate zoom level is determined using a factor of 2 from the zoom
 * levels with tiles.
 *
 * @param length length in default units
 * @return approximate zoom level
 */
-(NSNumber *) approximateZoomLevelWithLength: (double) length;

/**
 * Get the approximate zoom level for the provided width and height in the
 * default units. Tiles may or may not exist for the returned zoom level.
 * The approximate zoom level is determined using a factor of 2 from the
 * zoom levels with tiles.
 *
 * @param width  width in default units
 * @param height height in default units
 * @return approximate zoom level
 */
-(NSNumber *) approximateZoomLevelWithWidth: (double) width andHeight: (double) height;

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
 *  Query by tile grid and zoom level
 *
 *  @param tileGrid  tile grid
 *  @param zoomLevel zoom level
 *  @param orderBy   order by
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByTileGrid: (GPKGTileGrid *) tileGrid andZoomLevel: (int) zoomLevel andOrderBy: (NSString *) orderBy;

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
 *  Get the max length in default units that contains tiles
 *
 *  @return max distance length with tiles
 */
-(double) maxLength;

/**
 *  Get the min length in default units that contains tiles
 *
 *  @return min distance length with tiles
 */
-(double) minLength;

/**
 *  Determine if the tiles are in the XYZ tile coordinate format
 *
 *  @return true if XYZ tile format
 */
-(BOOL) isXYZTiles;

/**
 * Get the map zoom level range
 *
 * @return map zoom level range, min at index 0, max at index 1
 */
-(int *) mapZoomRange;

/**
 * Get the map min zoom level
 *
 * @return map min zoom level
 */
-(int) mapMinZoom;

/**
 * Get the map max zoom level
 *
 * @return map max zoom level
 */
-(int) mapMaxZoom;

/**
 * Get the map zoom level from the tile matrix
 *
 * @param tileMatrix
 *            tile matrix
 * @return map zoom level
 */
-(int) mapZoomWithTileMatrix: (GPKGTileMatrix *) tileMatrix;

/**
 * Get the map zoom level from the tile matrix zoom level
 *
 * @param zoomLevel
 *            tile matrix zoom level
 * @return map zoom level
 */
-(int) mapZoomWithZoomLevel: (int) zoomLevel;

/**
 * Get a tile matrix set DAO
 *
 * @return tile matrix set DAO
 */
-(GPKGTileMatrixSetDao *) tileMatrixSetDao;

/**
 * Get a tile matrix DAO
 *
 * @return tile matrix DAO
 */
-(GPKGTileMatrixDao *) tileMatrixDao;

@end
