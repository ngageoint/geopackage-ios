//
//  GPKGTileImportTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGTileImportTestCase.h"
#import "GPKGTileTestUtils.h"

@implementation GPKGTileImportTestCase

- (void)testTileMatrixBoundingBox {
    
    [GPKGTileTestUtils testTileMatrixBoundingBox:self.geoPackage];
    
}

@end
