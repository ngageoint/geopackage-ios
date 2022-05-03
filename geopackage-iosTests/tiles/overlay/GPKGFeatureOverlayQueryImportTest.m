//
//  GPKGFeatureOverlayQueryImportTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 5/3/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGFeatureOverlayQueryImportTest.h"
#import "GPKGFeatureOverlayQueryUtils.h"

@implementation GPKGFeatureOverlayQueryImportTest

/**
 * Test Build Map Click Table Data
 */
-(void) testBuildMapClickTableData{
    [GPKGFeatureOverlayQueryUtils testBuildMapClickTableData:self.geoPackage];
}

@end
