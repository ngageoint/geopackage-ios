//
//  GPKGTileGrid.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Tile grid with x and y ranges
 */
@interface GPKGTileGrid : NSObject

/**
 *  Min x
 */
@property (nonatomic) int minX;

/**
 *  Max x
 */
@property (nonatomic) int maxX;

/**
 *  Min y
 */
@property (nonatomic) int minY;

/**
 *  Max y
 */
@property (nonatomic) int maxY;

/**
 *  Initialize
 *
 *  @param minX min x
 *  @param minY min y
 *  @param maxX max x
 *  @param maxY max y
 *
 *  @return new tile grid
 */
-(instancetype) initWithMinX: (int) minX andMinY: (int) minY andMaxX: (int) maxX andMaxY: (int) maxY;

/**
 *  Get the count of tiles in the grid
 *
 *  @return tile count
 */
-(int) count;

/**
 *  Get the grid width
 *
 *  @return width
 */
-(int) width;

/**
 *  Get the grid height
 *
 *  @return height
 */
-(int) height;

/**
 *  Determine if equal to the provided tile grid
 *
 *  @param tileGrid tile grid
 *
 *  @return true if equal, false if not
 */
-(BOOL) equals: (GPKGTileGrid *) tileGrid;

@end
