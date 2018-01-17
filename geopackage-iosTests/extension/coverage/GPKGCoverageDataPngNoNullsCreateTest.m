//
//  GPKGCoverageDataPngNoNullsCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataPngNoNullsCreateTest.h"
#import "GPKGCoverageDataPngTestUtils.h"

@implementation GPKGCoverageDataPngNoNullsCreateTest

-(BOOL) shouldAllowNils{
    return false;
}

/**
 * Test the coverage data extension with a newly created GeoPackage using the
 * Nearest Neighbor Algorithm
 */
- (void)testNearestNeighbor {
    [GPKGCoverageDataPngTestUtils testCoverageDataWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_ETA_NEAREST_NEIGHBOR andAllowNils:self.allowNils];
}

/**
 * Test the coverage data extension with a newly created GeoPackage using the
 * Bilinear Algorithm
 */
- (void)testBilinear {
    [GPKGCoverageDataPngTestUtils testCoverageDataWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_ETA_BILINEAR andAllowNils:self.allowNils];
}

/**
 * Test the coverage data extension with a newly created GeoPackage using the
 * Bicubic Algorithm
 */
- (void)testBicubic {
    [GPKGCoverageDataPngTestUtils testCoverageDataWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_ETA_BICUBIC andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Nearest Neighbor Algorithm
 */
- (void)testRandomBoundingBoxNearestNeighbor {
    [GPKGCoverageDataPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_ETA_NEAREST_NEIGHBOR andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Bilinear Algorithm
 */
- (void)testRandomBoundingBoxBilinear {
    [GPKGCoverageDataPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_ETA_BILINEAR andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Bicubic Algorithm
 */
- (void)testRandomBoundingBoxBicubic {
    [GPKGCoverageDataPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_ETA_BICUBIC andAllowNils:self.allowNils];
}

@end
