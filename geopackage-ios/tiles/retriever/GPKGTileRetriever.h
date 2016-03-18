//
//  GPKGTileRetriever.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#ifndef GPKGTileRetriever_h
#define GPKGTileRetriever_h

#import "GPKGGeoPackageTile.h"

/**
 *  Interface defining the get tile retrieval method
 */
@protocol GPKGTileRetriever <NSObject>

/**
 *  Check if there is a tile for the x, y, and zoom
 *
 *  @param x    x coordinate
 *  @param y    y coordinate
 *  @param zoom zoom level
 *
 *  @return true if a tile exists
 */
-(BOOL) hasTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom;

/**
 *  Get a tile from the x, y, and zoom
 *
 *  @param x    x coordinate
 *  @param y    y coordinate
 *  @param zoom zoom level
 *
 *  @return tile with dimensions and bytes
 */
-(GPKGGeoPackageTile *) getTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom;

@end

#endif /* GPKGTileRetriever_h */
