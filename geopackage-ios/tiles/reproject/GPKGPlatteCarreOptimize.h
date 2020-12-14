//
//  GPKGPlatteCarreOptimize.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/14/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojectionOptimize.h"

/**
 *  Platte Carre (WGS84) XYZ tiling optimizations
 */
@interface GPKGPlatteCarreOptimize : GPKGTileReprojectionOptimize

/**
 *  Create with minimal bounds
 *
 *  @return platte carre optimize
 */
+(GPKGPlatteCarreOptimize *) create;

/**
 *  Create with world bounds
 *
 *  @return platte carre optimize
 */
+(GPKGPlatteCarreOptimize *) createWorld;

/**
 *  Initialize
 *
 *  @return new platte carre optimize
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param world world coordinate bounds
 *
 *  @return new platte carre optimize
 */
-(instancetype) initWithWorld: (BOOL) world;

@end
