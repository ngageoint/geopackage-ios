//
//  GPKGContentsIdCreateTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/6/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGContentsIdCreateTest.h"
#import "GPKGContentsIdUtils.h"

@implementation GPKGContentsIdCreateTest

/**
 * Test contents id
 */
- (void)testContentsId {
    [GPKGContentsIdUtils testContentsIdWithGeoPackage:self.geoPackage];
}

@end
