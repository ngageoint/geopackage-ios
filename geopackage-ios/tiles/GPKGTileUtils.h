//
//  GPKGTileUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/5/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Displayed device-independent pixels
 */
extern int const GPKG_TU_TILE_DP;

/**
 * Tile pixels for default dpi tiles
 */
extern int const GPKG_TU_TILE_PIXELS_DEFAULT;

/**
 * Tile pixels for high dpi tiles
 */
extern int const GPKG_TU_TILE_PIXELS_HIGH;

/**
 * Default display scale factor
 */
extern float const GPKG_TU_SCALE_FACTOR_DEFAULT;

/**
 * Tile utilities and constants
 */
@interface GPKGTileUtils : NSObject

/**
 *  Get the tile side (width and height) dimension based upon the screen resolution
 *
 *  @return default tile length
 */
+(float) tileLength;

/**
 *  Get the tile side (width and height) dimension based upon the scale
 *
 *  @param scale resolution scale
 *  @return default tile length
 */
+(float) tileLengthWithScale: (float) scale;

@end
