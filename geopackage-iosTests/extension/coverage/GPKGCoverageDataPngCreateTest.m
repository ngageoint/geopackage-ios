//
//  GPKGCoverageDataPngCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataPngCreateTest.h"
#import "GPKGCoverageDataPngTestUtils.h"
#import "GPKGCoverageDataTestUtils.h"

@implementation GPKGCoverageDataPngCreateTest

-(BOOL) shouldAllowNils{
    return YES;
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
    [GPKGCoverageDataTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_CDA_NEAREST_NEIGHBOR andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Bilinear Algorithm
 */
- (void)testRandomBoundingBoxBilinear {
    [GPKGCoverageDataTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_CDA_BILINEAR andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Bicubic Algorithm
 */
- (void)testRandomBoundingBoxBicubic {
    [GPKGCoverageDataTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.coverageDataValues andAlgorithm:GPKG_CDA_BICUBIC andAllowNils:self.allowNils];
}

/**
 * Test the pixel encoding
 */
- (void) testPixelEncoding {
    [GPKGCoverageDataTestUtils testPixelEncodingWithGeoPackage:self.geoPackage andAllowNils:self.allowNils];
}

@end
