//
//  GPKGRelatedSimpleAttributesImportTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedSimpleAttributesImportTest.h"
#import "GPKGRelatedSimpleAttributesUtils.h"

@implementation GPKGRelatedSimpleAttributesImportTest

/**
 * Test related simple attributes tables
 */
- (void)testSimpleAttributes {
    [GPKGRelatedSimpleAttributesUtils testSimpleAttributes:self.geoPackage];
}

@end
