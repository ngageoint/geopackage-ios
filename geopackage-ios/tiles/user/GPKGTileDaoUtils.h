//
//  GPKGTileDaoUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileMatrix.h"
#import "GPKGTileMatrixSetDao.h"

/**
 *  Tile Data Access Object utilities
 */
@interface GPKGTileDaoUtils : NSObject

/**
 * Adjust the tile matrix lengths if needed. Check if the tile matrix width
 * and height need to expand to account for pixel * number of pixels fitting
 * into the tile matrix lengths
 *
 *  @param tileMatrixSet tile matrix set
 *  @param tileMatrices  tile matrices
 */
+(void) adjustTileMatrixLengthsWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices;

/**
 *  Get the zoom level for the provided width and height in the default units
 *
 *  @param widths       widths
 *  @param heights      heights
 *  @param tileMatrices tile matrices
 *  @param length       length in default units
 *
 *  @return zoom level
 */
+(NSNumber *) zoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices andLength: (double) length;

/**
 * Get the zoom level for the provided width and height in the default units
 *
 * @param widths
 *            sorted widths
 * @param heights
 *            sorted heights
 * @param tileMatrices
 *            tile matrices
 * @param width
 *            in default units
 * @param height
 *            in default units
 * @return tile matrix zoom level
 */
+(NSNumber *) zoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices andWidth: (double) width andHeight: (double) height;

/**
 * Get the closest zoom level for the provided width and height in the
 * default units
 *
 * @param widths
 *            sorted widths
 * @param heights
 *            sorted heights
 * @param tileMatrices
 *            tile matrices
 * @param length
 *            in default units
 * @return tile matrix zoom level
 */
+(NSNumber *) closestZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices andLength: (double) length;

/**
 * Get the closest zoom level for the provided width and height in the
 * default units
 *
 * @param widths
 *            sorted widths
 * @param heights
 *            sorted heights
 * @param tileMatrices
 *            tile matrices
 * @param width
 *            in default units
 * @param height
 *            in default units
 * @return tile matrix zoom level
 */
+(NSNumber *) closestZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices andWidth: (double) width andHeight: (double) height;

/**
 * Get the approximate zoom level for the provided length in the default
 * units. Tiles may or may not exist for the returned zoom level. The
 * approximate zoom level is determined using a factor of 2 from the zoom
 * levels with tiles.
 *
 * @param widths
 *            sorted widths
 * @param heights
 *            sorted heights
 * @param tileMatrices
 *            tile matrices
 * @param length
 *            length in default units
 * @return actual or approximate tile matrix zoom level
 */
+(NSNumber *) approximateZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices andLength: (double) length;

/**
 * Get the approximate zoom level for the provided width and height in the
 * default units. Tiles may or may not exist for the returned zoom level.
 * The approximate zoom level is determined using a factor of 2 from the
 * zoom levels with tiles.
 *
 * @param widths
 *            sorted widths
 * @param heights
 *            sorted heights
 * @param tileMatrices
 *            tile matrices
 * @param width
 *            width in default units
 * @param height
 *            height in default units
 * @return actual or approximate tile matrix zoom level
 */
+(NSNumber *) approximateZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices andWidth: (double) width andHeight: (double) height;

/**
 *  Get the max distance length that matches the tile widths and heights
 *
 *  @param widths  sorted tile matrix widths
 *  @param heights sorted tile matrix heights
 *
 *  @return max length
 */
+(double) maxLengthWithWidths: (NSArray *) widths andHeights: (NSArray *) heights;

/**
 *  Get the min distance length that matches the tile widths and heights
 *
 *  @param widths  sorted tile matrix widths
 *  @param heights sorted tile matrix heights
 *
 *  @return min length
 */
+(double) minLengthWithWidths: (NSArray *) widths andHeights: (NSArray *) heights;

/**
 * Get the map zoom level range
 *
 * @param tileMatrixSetDao
 *            tile matrix set dao
 * @param tileMatrixSet
 *            tile matrix set
 * @param tileMatrices
 *            tile matrices
 * @return map zoom level range, min at index 0, max at index 1
 */
+(int *) mapZoomRangeWithTileMatrixSetDao: (GPKGTileMatrixSetDao *) tileMatrixSetDao andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices;

/**
 * Get the map min zoom level
 *
 * @param tileMatrixSetDao
 *            tile matrix set dao
 * @param tileMatrixSet
 *            tile matrix set
 * @param tileMatrices
 *            tile matrices
 * @return map min zoom level
 */
+(int) mapMinZoomWithTileMatrixSetDao: (GPKGTileMatrixSetDao *) tileMatrixSetDao andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices;

/**
 * Get the map max zoom level
 *
 * @param tileMatrixSetDao
 *            tile matrix set dao
 * @param tileMatrixSet
 *            tile matrix set
 * @param tileMatrices
 *            tile matrices
 * @return map max zoom level
 */
+(int) mapMaxZoomWithTileMatrixSetDao: (GPKGTileMatrixSetDao *) tileMatrixSetDao andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray<GPKGTileMatrix *> *) tileMatrices;

/**
 * Get the map zoom level
 *
 * @param tileMatrixSetDao
 *            tile matrix set dao
 * @param tileMatrixSet
 *            tile matrix set
 * @param tileMatrix
 *            tile matrix
 * @return map zoom level
 */
+(int) mapZoomWithTileMatrixSetDao: (GPKGTileMatrixSetDao *) tileMatrixSetDao andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrix: (GPKGTileMatrix *) tileMatrix;

@end
