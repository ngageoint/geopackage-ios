//
//  GPKGElevationTileMatrixResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/18/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTileMatrix.h"
#import "GPKGResultSet.h"

/**
 * Elevation Tile Matrix results including the elevation tile results and the
 * tile matrix where found
 */
@interface GPKGElevationTileMatrixResults : NSObject

/**
 *  Initialize
 *
 *  @param tileMatrix tile matrix
 *  @param tileResults tile results
 *
 *  @return new instance
 */
-(instancetype) initWithTileMatrix: (GPKGTileMatrix *) tileMatrix andTileResults: (GPKGResultSet *) tileResults;

/**
 * Get the tile matrix
 *
 * @return tile matrix
 */
-(GPKGTileMatrix *) tileMatrix;

/**
 * Get the tile results
 *
 * @return tile results
 */
-(GPKGResultSet *) tileResults;

@end
