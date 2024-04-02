//
//  GPKGRTreeIndexExtensionCreateTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/18/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRTreeIndexExtensionCreateTest.h"
#import "GPKGRTreeIndexExtensionUtils.h"

@implementation GPKGRTreeIndexExtensionCreateTest

- (void)testRTree {
    [GPKGRTreeIndexExtensionUtils testRTreeWithGeoPackage:self.geoPackage andGeodesic:NO];
}

- (void)testRTreeGeodesic {
    [GPKGRTreeIndexExtensionUtils testRTreeWithGeoPackage:self.geoPackage andGeodesic:YES];
}

-(BOOL) allowEmptyFeatures{
    return NO;
}

@end
