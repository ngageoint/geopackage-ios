//
//  GPKGElevationTilesPngImportTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTilesPngImportTest.h"
#import "GPKGElevationTilesPngTestUtils.h"
#import "GPKGElevationTilesTiff.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProjectionConstants.h"
#import "GPKGProjectionTransform.h"
#import "GPKGTestUtils.h"

@implementation GPKGElevationTilesPngImportTest

/**
 * Test the elevation extension with a newly created GeoPackage using the
 * Nearest Neighbor Algorithm
 */
- (void)testElevationsNearestNeighbor {
    [GPKGElevationTilesPngTestUtils testElevationsWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_NEAREST_NEIGHBOR andAllowNils:false];
}

/**
 * Test the elevation extension with a newly created GeoPackage using the
 * Bilinear Algorithm
 */
- (void)testElevationsBilinear {
    [GPKGElevationTilesPngTestUtils testElevationsWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_BILINEAR andAllowNils:false];
}

/**
 * Test the elevation extension with a newly created GeoPackage using the
 * Bicubic Algorithm
 */
- (void)testElevationsBicubic {
    [GPKGElevationTilesPngTestUtils testElevationsWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_BICUBIC andAllowNils:false];
}

/**
 * Test a random bounding box using the Nearest Neighbor Algorithm
 */
- (void)testRandomBoundingBoxNearestNeighbor {
    [GPKGElevationTilesPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_NEAREST_NEIGHBOR andAllowNils:true];
}

/**
 * Test a random bounding box using the Bilinear Algorithm
 */
- (void)testRandomBoundingBoxBilinear {
    [GPKGElevationTilesPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_BILINEAR andAllowNils:true];
}

/**
 * Test a random bounding box using the Bicubic Algorithm
 */
- (void)testRandomBoundingBoxBicubic {
    [GPKGElevationTilesPngTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_BICUBIC andAllowNils:true];
}

/**
 * Test a single hard coded location and optional print
 */
-(void)testLocation{
    
    double latitude = 61.57941522271581;
    double longitude = -148.96174115565339;
    
    [self testLocationWithLatitude: latitude andLongitude: longitude];
}

-(void) testRandomLocations{
    
    GPKGBoundingBox * projectedBoundingBox = nil;
    
    NSArray * elevationTables = [GPKGElevationTilesTiff tablesForGeoPackage:self.geoPackage];
    GPKGTileMatrixSetDao * dao = [self.geoPackage getTileMatrixSetDao];
    
    for(NSString * elevationTable in elevationTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *) [dao queryForIdObject:elevationTable];
        
        GPKGBoundingBox * boundingBox = [tileMatrixSet getBoundingBox];
        NSLog(@"Min Latitude: %f", [boundingBox.minLatitude doubleValue]);
        NSLog(@"Max Latitude: %f", [boundingBox.maxLatitude doubleValue]);
        NSLog(@"Min Longitude: %f", [boundingBox.minLongitude doubleValue]);
        NSLog(@"Max Longitude: %f", [boundingBox.maxLongitude doubleValue]);
        
        GPKGSpatialReferenceSystemDao * srsDao = [self.geoPackage getSpatialReferenceSystemDao];
        NSNumber * srsId = tileMatrixSet.srsId;
        GPKGSpatialReferenceSystem * srs = [srsDao getOrCreateWithSrsId:srsId];
        GPKGProjection * projection = [GPKGProjectionFactory getProjectionWithSrs:srs];
        GPKGProjection * requestProjection = [GPKGProjectionFactory getProjectionWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        GPKGProjectionTransform * elevationToRequest = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToProjection:requestProjection];
        projectedBoundingBox = [elevationToRequest transformWithBoundingBox:boundingBox];
    }
    
    NSLog(@"Min Latitude: %f", [projectedBoundingBox.minLatitude doubleValue]);
    NSLog(@"Max Latitude: %f", [projectedBoundingBox.maxLatitude doubleValue]);
    NSLog(@"Min Longitude: %f", [projectedBoundingBox.minLongitude doubleValue]);
    NSLog(@"Max Longitude: %f", [projectedBoundingBox.maxLongitude doubleValue]);
    
    double latDistance = [projectedBoundingBox.maxLatitude doubleValue] - [projectedBoundingBox.minLatitude doubleValue];
    double lonDistance = [projectedBoundingBox.maxLongitude doubleValue] - [projectedBoundingBox.minLongitude doubleValue];
    
    for(int i = 0; i < 10; i++){
        
        // Get a random coordinate
        double latitude = latDistance * .9 * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLatitude doubleValue] + (.05 * latDistance);
        double longitude = lonDistance * .9 * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLongitude doubleValue] + (.05 * lonDistance);
        [self testLocationWithLatitude:latitude andLongitude:longitude];
    }
    
}

/**
 * Test elevation requests within the bounds of the tiles and optionally
 * print
 */
-(void) testBounds{
    // TODO
}

/**
 * Test a full bounding box around tiles and optionally print. Also test the
 * bounds of individual tiles.
 */
-(void) testFullBoundingBox{
    // TODO
}

/**
 * Test a single location
 *
 * @param latitude
 * @param longitude
 */
-(void) testLocationWithLatitude: (double) latitude andLongitude: (double) longitude{
    
    NSLog(@"Latitude: %f", latitude);
    NSLog(@"Longitude: %f", longitude);
    
    for(int i = GPKG_ETA_NEAREST_NEIGHBOR; i <= GPKG_ETA_BICUBIC; i++){
        enum GPKGElevationTilesAlgorithm algorithm = (enum GPKGElevationTilesAlgorithm)i;
        NSDecimalNumber * elevation = [GPKGElevationTilesPngTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:latitude andLongitude:longitude andEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        NSLog(@"%@: %f", [GPKGElevationTilesAlgorithms name:algorithm], [elevation doubleValue]);
    }

}

@end
