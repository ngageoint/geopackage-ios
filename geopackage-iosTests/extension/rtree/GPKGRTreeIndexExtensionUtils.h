//
//  GPKGRTreeIndexExtensionUtils.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/18/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGGeoPackage.h"

/**
 * RTree Extension Utility test methods
 */
@interface GPKGRTreeIndexExtensionUtils : NSObject

/**
 * Test RTree
 *
 * @param geoPackage GeoPackage
 */
+(void) testRTreeWithGeoPackage: (GPKGGeoPackage *) geoPackage andGeodesic: (BOOL) geodesic;

@end
