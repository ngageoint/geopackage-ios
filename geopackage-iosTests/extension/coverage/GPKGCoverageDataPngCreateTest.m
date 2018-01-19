//
//  GPKGCoverageDataPngCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataPngCreateTest.h"
#import "GPKGCoverageDataPngTestUtils.h"

@implementation GPKGCoverageDataPngCreateTest

-(BOOL) shouldAllowNils{
    return true;
}

/**
 * Test the coverage data extension with a newly created GeoPackage using the
 * Nearest Neighbor Algorithm
 */
- (void)testNearestNeighbor {
    [GPKGCoverageDataPngTestUtils testCoverageDataWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_CDA_NEAREST_NEIGHBOR andAllowNils:self.allowNils];
}

/**
 * Test the coverage data extension with a newly created GeoPackage using the
 * Bilinear Algorithm
 */
- (void)testBilinear {
    [GPKGCoverageDataPngTestUtils testCoverageDataWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_CDA_BILINEAR andAllowNils:self.allowNils];
}

/**
 * Test the coverage data extension with a newly created GeoPackage using the
 * Bicubic Algorithm
 */
- (void)testBicubic {
    [GPKGCoverageDataPngTestUtils testCoverageDataWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_CDA_BICUBIC andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Nearest Neighbor Algorithm
 */
- (void)testRandomBoundingBoxNearestNeighbor {
    [GPKGCoverageDataPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_CDA_NEAREST_NEIGHBOR andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Bilinear Algorithm
 */
- (void)testRandomBoundingBoxBilinear {
    [GPKGCoverageDataPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_CDA_BILINEAR andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Bicubic Algorithm
 */
- (void)testRandomBoundingBoxBicubic {
    [GPKGCoverageDataPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_CDA_BICUBIC andAllowNils:self.allowNils];
}

@end
