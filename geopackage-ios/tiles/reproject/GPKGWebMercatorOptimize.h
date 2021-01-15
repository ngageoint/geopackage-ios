//
//  GPKGWebMercatorOptimize.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/14/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojectionOptimize.h"

/**
 *  Web Meractor XYZ tiling optimizations
 */
@interface GPKGWebMercatorOptimize : GPKGTileReprojectionOptimize

/**
 *  Create with minimal bounds
 *
 *  @return web mercator optimize
 */
+(GPKGWebMercatorOptimize *) create;

/**
 *  Create with world bounds
 *
 *  @return web mercator optimize
 */
+(GPKGWebMercatorOptimize *) createWorld;

/**
 *  Initialize
 *
 *  @return new web mercator optimize
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param world world coordinate bounds
 *
 *  @return new web mercator optimize
 */
-(instancetype) initWithWorld: (BOOL) world;

@end
