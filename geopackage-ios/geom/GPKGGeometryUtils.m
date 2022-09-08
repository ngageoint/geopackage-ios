//
//  GPKGGeometryUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 4/18/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGGeometryUtils.h"
#import "GPKGGeoPackageConstants.h"
#import "PROJProjectionConstants.h"

@implementation GPKGGeometryUtils

+(double) computeAreaOfDegreesPath: (NSArray<SFPoint *> *) path{
    return fabs([self computeSignedAreaOfDegreesPath:path]);
}

+(double) computeSignedAreaOfDegreesPath: (NSArray<SFPoint *> *) path{
    NSUInteger size = path.count;
    if (size < 3) { return 0; }
    double total = 0;
    SFPoint *prev = [path objectAtIndex:size - 1];

    double prevTanLat = tan((M_PI / 2.0 - [self toRadiansWithDegrees:[prev.y doubleValue]]) / 2.0);
    double prevLng = [self toRadiansWithDegrees:[prev.x doubleValue]];
    // For each edge, accumulate the signed area of the triangle formed by the North Pole
    // and that edge ("polar triangle").
    for (SFPoint *point in path) {
        double tanLat = tan((M_PI / 2.0 - [self toRadiansWithDegrees:[point.y doubleValue]]) / 2.0);
        double lng = [self toRadiansWithDegrees:[point.x doubleValue]];
        total += [self polarTriangleAreaWithTan1:tanLat andLng1:lng andTan2:prevTanLat andLng2:prevLng];
        prevTanLat = tanLat;
        prevLng = lng;
    }
    return total * (GPKG_EARTH_RADIUS * GPKG_EARTH_RADIUS);
}

+(double) polarTriangleAreaWithTan1: (double) tan1 andLng1: (double) lng1 andTan2: (double) tan2 andLng2: (double) lng2{
    double deltaLng = lng1 - lng2;
    double t = tan1 * tan2;
    return 2 * atan2(t * sin(deltaLng), 1 + t * cos(deltaLng));
}

+(BOOL) isClosedPolygonWithPoints: (NSArray<SFPoint *> *) points{
    SFPoint *firstPoint = [points objectAtIndex:0];
    SFPoint *lastPoint = [points objectAtIndex:points.count - 1];
    BOOL closed = [firstPoint.x isEqualToNumber:lastPoint.x] && [firstPoint.y isEqualToNumber:lastPoint.y];
    return closed;
}

+(double) toRadiansWithDegrees: (double) degrees{
    return M_PI * degrees / PROJ_WGS84_HALF_WORLD_LON_WIDTH;
}

+(double) toDegreesWithRadians: (double) radians{
    return radians * PROJ_WGS84_HALF_WORLD_LON_WIDTH / M_PI;
}

@end
