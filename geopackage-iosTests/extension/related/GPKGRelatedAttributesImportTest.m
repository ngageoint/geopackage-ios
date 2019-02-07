//
//  GPKGRelatedAttributesImportTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/7/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGRelatedAttributesImportTest.h"
#import "GPKGRelatedAttributesUtils.h"

@implementation GPKGRelatedAttributesImportTest

/**
 * Test related attributes tables
 */
- (void)testAttributes {
    [GPKGRelatedAttributesUtils testAttributesWithGeoPackage:self.geoPackage];
}

@end
