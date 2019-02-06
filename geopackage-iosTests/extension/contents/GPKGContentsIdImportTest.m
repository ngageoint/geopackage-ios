//
//  GPKGContentsIdImportTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/6/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGContentsIdImportTest.h"
#import "GPKGContentsIdUtils.h"

@implementation GPKGContentsIdImportTest

/**
 * Test contents id
 */
- (void)testContentsId {
    [GPKGContentsIdUtils testContentsIdWithGeoPackage:self.geoPackage];
}

@end
