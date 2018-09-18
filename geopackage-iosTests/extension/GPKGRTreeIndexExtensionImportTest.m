//
//  GPKGRTreeIndexExtensionImportTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/18/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRTreeIndexExtensionImportTest.h"
#import "GPKGRTreeIndexExtensionUtils.h"

@implementation GPKGRTreeIndexExtensionImportTest

- (void)testRTree {
    [GPKGRTreeIndexExtensionUtils testRTreeWithGeoPackage:self.geoPackage];
}

@end
