//
//  GPKGGeometryUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 4/18/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFPoint.h"

/**
 *  Geometry Utilities
 */
@interface GPKGGeometryUtils : NSObject

/**
 * Returns the area of a closed path on Earth.
 *
 * Written from the Android SphericalUtil implementation.
 *
 * @param path A closed path in degree units.
 * @return The path's area in square meters.
 */
+(double) computeAreaOfDegreesPath: (NSArray<SFPoint *> *) path;

/**
 * Returns the signed area of a closed path on Earth. The sign of the area may be used to
 * determine the orientation of the path.
 * "inside" is the surface that does not contain the South Pole.
 *
 * Written from the Android SphericalUtil implementation.
 *
 * @param path A closed path in degree units.
 * @return The loop's area in square meters.
 */
+(double) computeSignedAreaOfDegreesPath: (NSArray<SFPoint *> *) path;

/**
 * Check if the polygon points create a closed polygon with the first and last points at the same location
 *
 * @param points polygon points
 * @return true if points create a closed polygon
 */
+(BOOL) isClosedPolygonWithPoints: (NSArray<SFPoint *> *) points;

/**
 * Convert degrees to radians
 *
 * @param degrees value in degrees
 * @return radians
 */
+(double) toRadiansWithDegrees: (double) degrees;

/**
 * Convert radians to degrees
 *
 * @param radians value in radians
 * @return degrees
 */
+(double) toDegreesWithRadians: (double) radians;
    
@end
