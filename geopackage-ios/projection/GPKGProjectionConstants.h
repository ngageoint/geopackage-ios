//
//  GPKGProjectionConstants.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/15/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Projection constants
 */
extern NSString * const PROJ_PROPERTIES;
extern int const PROJ_UNDEFINED_CARTESIAN;
extern int const PROJ_UNDEFINED_GEOGRAPHIC;
extern int const PROJ_EPSG_WORLD_GEODETIC_SYSTEM;
extern int const PROJ_EPSG_WEB_MERCATOR;
extern int const PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D;
extern double const PROJ_WEB_MERCATOR_MAX_LAT_RANGE;
extern double const PROJ_WEB_MERCATOR_MIN_LAT_RANGE;
extern double const PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH;
extern double const PROJ_MERCATOR_RADIUS;
extern double const PROJ_WGS84_HALF_WORLD_LON_WIDTH;
extern double const PROJ_WGS84_HALF_WORLD_LAT_HEIGHT;

@interface GPKGProjectionConstants : NSObject

@end
