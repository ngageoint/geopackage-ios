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

- (void)testIndex {
    [GPKGFeatureIndexManagerUtils testIndexWithGeoPackage:self.geoPackage];
}

- (void) testLargeIndex{
    [GPKGFeatureIndexManagerUtils testLargeIndexWithGeoPackage:self.geoPackage andNumFeatures:10000];
}

- (void) testTimedIndex{
    [GPKGFeatureIndexManagerUtils testTimedIndexWithGeoPackage:self.geoPackage andCompareProjectionCounts:NO andVerbose:NO];
}

@end
