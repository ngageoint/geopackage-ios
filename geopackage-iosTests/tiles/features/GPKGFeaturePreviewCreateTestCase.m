//
//  GPKGFeaturePreviewCreateTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 3/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGFeaturePreviewCreateTestCase.h"
#import "GPKGFeaturePreviewTestUtils.h"

@implementation GPKGFeaturePreviewCreateTestCase

- (void)testCreate {
    [GPKGFeaturePreviewTestUtils testDrawWithGeoPackage:self.geoPackage];
}

@end
