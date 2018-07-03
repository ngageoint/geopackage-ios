//
//  GPKGRelatedSimpleAttributesCreateTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedSimpleAttributesCreateTest.h"
#import "GPKGRelatedSimpleAttributesUtils.h"

@implementation GPKGRelatedSimpleAttributesCreateTest

/**
 * Test related simple attributes tables
 */
- (void)testSimpleAttributes {
    [GPKGRelatedSimpleAttributesUtils testSimpleAttributes:self.geoPackage];
}

@end
