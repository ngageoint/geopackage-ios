//
//  GPKGFeatureCacheCreateTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureCacheCreateTest.h"
#import "GPKGFeatureCacheUtils.h"

@implementation GPKGFeatureCacheCreateTest

/**
 * Test cache
 */
- (void)testCache {
    [GPKGFeatureCacheUtils testCacheWithGeoPackage:self.geoPackage];
}

@end
