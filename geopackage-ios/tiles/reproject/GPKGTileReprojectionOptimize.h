//
//  GPKGTileReprojectionOptimize.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/10/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGBoundingBox.h"
#import "GPKGTileGrid.h"

/**
 *  Tile Reprojection Optimizations
 */
@interface GPKGTileReprojectionOptimize : NSObject

/**
 *  World tile coordinate bounds (XYZ), as opposed to minimal tile fitting bounds (default)
 */
@property (nonatomic) BOOL world;

/**
 *  Create a Web Mercator optimization, minimally tile bounded
 *
 *  @return tile reprojection optimize
 */
+(GPKGTileReprojectionOptimize *) webMercator;

/**
 *  Create a Platte Carre (WGS84) optimization, minimally tile bounded
 *
 *  @return tile reprojection optimize
 */
+(GPKGTileReprojectionOptimize *) platteCarre;

/**
 *  Create a Web Mercator optimization, world bounded with XYZ tile coordinates
 *
 *  @return tile reprojection optimize
 */
+(GPKGTileReprojectionOptimize *) webMercatorWorld;

/**
 *  Create a Platte Carre (WGS84) optimization, world bounded with XYZ tile coordinates
 *
 *  @return tile reprojection optimize
 */
+(GPKGTileReprojectionOptimize *) platteCarreWorld;

/**
 *  Initialize
 *
 *  @return new tile reprojection optimize
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param world world coordinate bounds
 *
 *  @return new tile reprojection optimize
 */
-(instancetype) initWithWorld: (BOOL) world;

/**
 *  Get the optimization projection
 *
 *  @return projection
 */
-(PROJProjection *) projection;

/**
 *  Get the world tile grid of the optimization projection
 *
 *  @return tile grid
 */
-(GPKGTileGrid *) tileGrid;

/**
 *  Get the world bounding box of the optimization projection
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) boundingBox;

/**
 *  Get the tile grid of the bounding box at the zoom
 *
 *  @param boundingBox bounding box
 *  @param zoom zoom level
 *
 *  @return tile grid
 */
-(GPKGTileGrid *) tileGridWithBoundingBox: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom;

/**
 *  Get the bounding box of the tile grid at the zoom
 *
 *  @param tileGrid tile grid
 *  @param zoom zoom level
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom;

@end
