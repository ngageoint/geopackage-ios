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
 *  @param maxX max x
 *  @param minY min y
 *  @param maxY max y
 *
 *  @return new tile grid
 */
-(instancetype) initWithMinX: (int) minX andMaxX: (int) maxX andMinY: (int) minY andMaxY: (int) maxY;

/**
 *  Get the count of tiles in the grid
 *
 *  @return tile count
 */
-(int) count;

/**
 *  Determine if equal to the provided tile grid
 *
 *  @param tileGrid tile grid
 *
 *  @return true if equal, false if not
 */
-(BOOL) equals: (GPKGTileGrid *) tileGrid;

@end
