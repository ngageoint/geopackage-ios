//
//  GPKGFeatureIndexManagerImportTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/20/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexManagerImportTest.h"
#import "GPKGFeatureIndexManagerUtils.h"

@implementation GPKGFeatureIndexManagerImportTest

- (void)testIndexer {
    [GPKGFeatureIndexManagerUtils testIndexWithGeoPackage:self.geoPackage];
}

@end
