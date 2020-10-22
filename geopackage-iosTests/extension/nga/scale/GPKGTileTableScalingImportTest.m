//
//  GPKGTileTableScalingImportTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 3/15/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGTileTableScalingImportTest.h"
#import "GPKGTileTableScalingUtils.h"

@implementation GPKGTileTableScalingImportTest

- (void)testScaling {
    [GPKGTileTableScalingUtils testScalingWithGeoPackage:self.geoPackage];
}

@end
