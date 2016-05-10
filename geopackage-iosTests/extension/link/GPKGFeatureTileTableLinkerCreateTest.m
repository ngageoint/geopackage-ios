//
//  GPKGFeatureTileTableLinkerCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureTileTableLinkerCreateTest.h"
#import "GPKGFeatureTileTableLinkerUtils.h"

@implementation GPKGFeatureTileTableLinkerCreateTest

- (void)testLink {
    [GPKGFeatureTileTableLinkerUtils testLinkWithGeoPackage:self.geoPackage];
}

@end
