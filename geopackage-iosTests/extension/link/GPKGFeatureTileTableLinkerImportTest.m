//
//  GPKGFeatureTileTableLinkerImportTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureTileTableLinkerImportTest.h"
#import "GPKGFeatureTileTableLinkerUtils.h"

@implementation GPKGFeatureTileTableLinkerImportTest

- (void)testLink {
    [GPKGFeatureTileTableLinkerUtils testLinkWithGeoPackage:self.geoPackage];
}

@end
