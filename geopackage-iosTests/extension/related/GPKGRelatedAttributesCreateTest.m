//
//  GPKGRelatedAttributesCreateTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/7/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGRelatedAttributesCreateTest.h"
#import "GPKGRelatedAttributesUtils.h"

@implementation GPKGRelatedAttributesCreateTest

/**
 * Test related attributes tables
 */
- (void)testAttributes {
    [GPKGRelatedAttributesUtils testAttributesWithGeoPackage:self.geoPackage];
}

@end
