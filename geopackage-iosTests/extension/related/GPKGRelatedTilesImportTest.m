//
//  GPKGRelatedTilesImportTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGRelatedTilesImportTest.h"
#import "GPKGRelatedTilesUtils.h"

@implementation GPKGRelatedTilesImportTest

/**
 * Test related tiles tables
 */
- (void)testTiles {
    [GPKGRelatedTilesUtils testTilesWithGeoPackage:self.geoPackage];
}

@end
