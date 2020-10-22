//
//  GPKGTileTableScalingCreateTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 3/15/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGTileTableScalingCreateTest.h"
#import "GPKGTileTableScalingUtils.h"

@implementation GPKGTileTableScalingCreateTest

- (void)testScaling {
    [GPKGTileTableScalingUtils testScalingWithGeoPackage:self.geoPackage];
}

@end
