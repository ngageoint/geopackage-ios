//
//  GPKGFeatureStylesUtils.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

/**
 * Test Feature Styles Utils
 */
@interface GPKGFeatureStylesUtils : NSObject

/**
 * Test Feature Styles extension
 *
 * @param geoPackage GeoPackage
 */
+(void) testFeatureStylesWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end

