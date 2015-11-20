//
//  GPKGTileCreateTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGTileCreateTestCase.h"
#import "GPKGTileTestUtils.h"

@implementation GPKGTileCreateTestCase

- (void)testTileMatrixBoundingBox {
    
    [GPKGTileTestUtils testTileMatrixBoundingBox:self.geoPackage];
    
}

@end
