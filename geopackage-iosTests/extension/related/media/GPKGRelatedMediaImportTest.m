//
//  GPKGRelatedMediaImportTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedMediaImportTest.h"
#import "GPKGRelatedMediaUtils.h"

@implementation GPKGRelatedMediaImportTest

/**
 * Test related media tables
 */
- (void)testMedia {
    [GPKGRelatedMediaUtils testMedia:self.geoPackage];
}

@end
