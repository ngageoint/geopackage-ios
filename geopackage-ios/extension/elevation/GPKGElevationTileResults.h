//
//  GPKGElevationTileResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTileMatrix.h"

@interface GPKGElevationTileResults : NSObject

/**
 *  Initialize
 *
 *  @param elevations elevation results
 *  @param tileMatrix tile matrix
 *
 *  @return new elevation tile results
 */
-(instancetype) initWithElevations: (NSArray *) elevations andTileMatrix: (GPKGTileMatrix *) tileMatrix;

/**
 * Get the double array of elevations stored as [row][column]
 *
 * @return elevations
 */
-(NSArray *) elevations;

/**
 * Get the tile matrix used to find the elevations
 *
 * @return tile matrix
 */
-(GPKGTileMatrix *) tileMatrix;

/**
 * Get the results height
 *
 * @return height
 */
-(int) height;

/**
 * Get the results width
 *
 * @return width
 */
-(int) width;

/**
 * Get the elevation at the row and column
 *
 * @param row
 *            row index
 * @param column
 *            column index
 * @return elevation
 */
-(NSDecimalNumber *) elevationAtRow: (int) row andColumn: (int) column;

/**
 * Get the zoom level of the results
 *
 * @return zoom level
 */
-(NSNumber *) zoomLevel;

@end
