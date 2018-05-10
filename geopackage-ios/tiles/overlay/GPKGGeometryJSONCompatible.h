//
//  GPKGGeometryJSONCompatible.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/10/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFGeometry.h"

/**
 *  JSON compatible object representation of a Geometry
 *  TODO Only for temporary use until simple-features-geojson-ios is implemented
 */
@interface GPKGGeometryJSONCompatible : NSObject

/**
 *  Get a Geometry object that is JSON compatible
 *
 *  @param geometry geometry
 *
 *  @return geometry JSON object
 *  @deprecated for temporary use until simple-features-geojson-ios is implemented
 */
+(NSObject *) jsonCompatibleGeometry: (SFGeometry *) geometry __attribute__((deprecated));

@end
