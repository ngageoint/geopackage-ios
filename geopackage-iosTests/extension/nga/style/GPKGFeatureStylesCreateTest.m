//
//  GPKGFeatureStylesCreateTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureStylesCreateTest.h"
#import "GPKGFeatureStylesUtils.h"

@implementation GPKGFeatureStylesCreateTest

/**
 * Test feature styles
 */
- (void)testFeatureStyles {
    [GPKGFeatureStylesUtils testFeatureStylesWithGeoPackage:self.geoPackage];
}

/**
 * Test shared feature styles
 */
- (void)testSharedFeatureStyles {
    [GPKGFeatureStylesUtils testSharedFeatureStylesWithGeoPackage:self.geoPackage];
}

@end
