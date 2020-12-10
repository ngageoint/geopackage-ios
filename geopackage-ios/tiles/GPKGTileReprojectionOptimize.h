//
//  GPKGTileReprojectionOptimize.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/10/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Enumeration of optimize types
 */
enum GPKGTileReprojectionOptimizeType{
    GPKG_TRO_WEB_MERCATOR,
    GPKG_TRO_PLATTE_CARRE
};

/**
 *  Tile Reprojection Optimizations
 */
@interface GPKGTileReprojectionOptimize : NSObject

/**
 *  Optimize type
 */
@property (nonatomic) enum GPKGTileReprojectionOptimizeType type;

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
 *  @param type optimize type
 *
 *  @return new tile reprojection optimize
 */
-(instancetype) initWithType: (enum GPKGTileReprojectionOptimizeType) type;

/**
 *  Initialize
 *
 *  @param type optimize type
 *  @param world world coordinate bounds
 *
 *  @return new tile reprojection optimize
 */
-(instancetype) initWithType: (enum GPKGTileReprojectionOptimizeType) type andWorld: (BOOL) world;

@end
