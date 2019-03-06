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
static int TILE_DP = 256;

/**
 * Tile pixels for default dpi tiles
 */
static int TILE_PIXELS_DEFAULT = 256;

/**
 * Tile pixels for high dpi tiles
 */
static int TILE_PIXELS_HIGH = 512;

/**
 * Default display scale factor
 */
static float SCALE_FACTOR_DEFAULT = 2.0f;

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
