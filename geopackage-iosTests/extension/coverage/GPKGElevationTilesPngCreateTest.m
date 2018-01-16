//
//  GPKGElevationTilesPngCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTilesPngCreateTest.h"
#import "GPKGElevationTilesPngTestUtils.h"

@implementation GPKGElevationTilesPngCreateTest

-(BOOL) shouldAllowNils{
    return true;
}

/**
 * Test the elevation extension with a newly created GeoPackage using the
 * Nearest Neighbor Algorithm
 */
- (void)testElevationsNearestNeighbor {
    [GPKGElevationTilesPngTestUtils testElevationsWithGeoPackage:self.geoPackage andValues:self.elevationTileValues andAlgorithm:GPKG_ETA_NEAREST_NEIGHBOR andAllowNils:self.allowNils];
}

/**
 * Test the elevation extension with a newly created GeoPackage using the
 * Bilinear Algorithm
 */
- (void)testElevationsBilinear {
    [GPKGElevationTilesPngTestUtils testElevationsWithGeoPackage:self.geoPackage andValues:self.elevationTileValues andAlgorithm:GPKG_ETA_BILINEAR andAllowNils:self.allowNils];
}

/**
 * Test the elevation extension with a newly created GeoPackage using the
 * Bicubic Algorithm
 */
- (void)testElevationsBicubic {
    [GPKGElevationTilesPngTestUtils testElevationsWithGeoPackage:self.geoPackage andValues:self.elevationTileValues andAlgorithm:GPKG_ETA_BICUBIC andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Nearest Neighbor Algorithm
 */
- (void)testRandomBoundingBoxNearestNeighbor {
    [GPKGElevationTilesPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.elevationTileValues andAlgorithm:GPKG_ETA_NEAREST_NEIGHBOR andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Bilinear Algorithm
 */
- (void)testRandomBoundingBoxBilinear {
    [GPKGElevationTilesPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.elevationTileValues andAlgorithm:GPKG_ETA_BILINEAR andAllowNils:self.allowNils];
}

/**
 * Test a random bounding box using the Bicubic Algorithm
 */
- (void)testRandomBoundingBoxBicubic {
    [GPKGElevationTilesPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:self.elevationTileValues andAlgorithm:GPKG_ETA_BICUBIC andAllowNils:self.allowNils];
}

@end
