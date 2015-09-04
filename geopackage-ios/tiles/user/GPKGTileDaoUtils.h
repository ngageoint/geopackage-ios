//
//  GPKGTileDaoUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTileMatrixSet.h"

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
+(void) adjustTileMatrixLengthsWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray *) tileMatrices;

/**
 *  Get the zoom level for the provided width and height in the default units
 *
 *  @param widths       widths
 *  @param heights      heights
 *  @param tileMatrices tile matrices
 *  @param length       length
 *
 *  @return zoom level
 */
+(NSNumber *) getZoomLevelWithWidths: (NSArray *) widths andHeights: (NSArray *) heights andTileMatrices: (NSArray *) tileMatrices andLength: (double) length;

@end
