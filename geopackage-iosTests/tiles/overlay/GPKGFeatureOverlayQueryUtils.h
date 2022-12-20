//
//  GPKGFeatureOverlayQueryUtils.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 5/3/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGGeoPackage.h"

/**
 * Feature overlay query utils
 */
@interface GPKGFeatureOverlayQueryUtils : NSObject

/**
 * Test Build Map Click Table Data
 *
 * @param geoPackage
 */
+(void) testBuildMapClickTableData: (GPKGGeoPackage *) geoPackage;

@end
