//
//  GPKGFeatureTableIndexImportTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/19/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTableIndexImportTest.h"
#import "GPKGFeatureTableIndexUtils.h"

@implementation GPKGFeatureTableIndexImportTest

- (void)testIndexer {
    [GPKGFeatureTableIndexUtils testIndexWithGeoPackage:self.geoPackage];
}

@end
