//
//  GPKGFeatureIndexManagerCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/20/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexManagerCreateTest.h"
#import "GPKGFeatureIndexManagerUtils.h"

@implementation GPKGFeatureIndexManagerCreateTest

-(BOOL) allowEmptyFeatures{
    return NO;
}

- (void)testIndex {
    [GPKGFeatureIndexManagerUtils testIndexWithGeoPackage:self.geoPackage];
}

- (void) testLargeIndex{
    [GPKGFeatureIndexManagerUtils testLargeIndexWithGeoPackage:self.geoPackage andNumFeatures:20000 andVerbose:NO];
}

- (void) testTimedIndex{
    [GPKGFeatureIndexManagerUtils testTimedIndexWithGeoPackage:self.geoPackage andCompareProjectionCounts:NO andVerbose:NO];
}

@end
