//
//  GPKGElevationTilesTiffImportTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTilesTiffImportTest.h"
#import "GPKGElevationTilesTiffTestUtils.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProjectionConstants.h"
#import "GPKGProjectionTransform.h"
#import "GPKGTestUtils.h"
#import "GPKGElevationTilesTiff.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGElevationTilesTiffImportTest

/**
 * Test the elevation extension with a newly created GeoPackage using the
 * Nearest Neighbor Algorithm
 */
- (void)testElevationsNearestNeighbor {
    [GPKGElevationTilesTiffTestUtils testElevationsWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_NEAREST_NEIGHBOR andAllowNils:false];
}

/**
 * Test the elevation extension with a newly created GeoPackage using the
 * Bilinear Algorithm
 */
- (void)testElevationsBilinear {
    [GPKGElevationTilesTiffTestUtils testElevationsWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_BILINEAR andAllowNils:false];
}

/**
 * Test the elevation extension with a newly created GeoPackage using the
 * Bicubic Algorithm
 */
- (void)testElevationsBicubic {
    [GPKGElevationTilesTiffTestUtils testElevationsWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_BICUBIC andAllowNils:false];
}

/**
 * Test a random bounding box using the Nearest Neighbor Algorithm
 */
- (void)testRandomBoundingBoxNearestNeighbor {
    [GPKGElevationTilesTiffTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_NEAREST_NEIGHBOR andAllowNils:true];
}

/**
 * Test a random bounding box using the Bilinear Algorithm
 */
- (void)testRandomBoundingBoxBilinear {
    [GPKGElevationTilesTiffTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_BILINEAR andAllowNils:true];
}

/**
 * Test a random bounding box using the Bicubic Algorithm
 */
- (void)testRandomBoundingBoxBicubic {
    [GPKGElevationTilesTiffTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_ETA_BICUBIC andAllowNils:true];
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
        NSMutableString * log = [[NSMutableString alloc] init];
        [log appendFormat:@"\n\nMin Latitude: %f\n", [boundingBox.minLatitude doubleValue]];
        [log appendFormat:@"Max Latitude: %f\n", [boundingBox.maxLatitude doubleValue]];
        [log appendFormat:@"Min Longitude: %f\n", [boundingBox.minLongitude doubleValue]];
        [log appendFormat:@"Max Longitude: %f\n\n", [boundingBox.maxLongitude doubleValue]];
        NSLog(log, nil);
        
        GPKGSpatialReferenceSystemDao * srsDao = [self.geoPackage getSpatialReferenceSystemDao];
        NSNumber * srsId = tileMatrixSet.srsId;
        GPKGSpatialReferenceSystem * srs = [srsDao getOrCreateWithSrsId:srsId];
        GPKGProjection * projection = [GPKGProjectionFactory getProjectionWithSrs:srs];
        GPKGProjection * requestProjection = [GPKGProjectionFactory getProjectionWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        GPKGProjectionTransform * elevationToRequest = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToProjection:requestProjection];
        projectedBoundingBox = [elevationToRequest transformWithBoundingBox:boundingBox];
    }
    
    NSMutableString * log = [[NSMutableString alloc] init];
    [log appendFormat:@"\n\nMin Latitude: %f\n", [projectedBoundingBox.minLatitude doubleValue]];
    [log appendFormat:@"Max Latitude: %f\n", [projectedBoundingBox.maxLatitude doubleValue]];
    [log appendFormat:@"Min Longitude: %f\n", [projectedBoundingBox.minLongitude doubleValue]];
    [log appendFormat:@"Max Longitude: %f\n\n", [projectedBoundingBox.maxLongitude doubleValue]];
    NSLog(log, nil);
    
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
    
    int geoPackageEpsg = PROJ_EPSG_WEB_MERCATOR;
    
    double widthPixelDistance = 1000;
    double heightPixelDistance = 1000;
    int width = 10;
    int height = 6;
    double minLongitude = -16586000;
    double maxLongitude = minLongitude + (width * widthPixelDistance);
    double minLatitude = 8760000;
    double maxLatitude = minLatitude + (height * heightPixelDistance);
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMaxLongitudeDouble:maxLongitude andMinLatitudeDouble:minLatitude andMaxLatitudeDouble:maxLatitude];
    
    GPKGProjection * projection = [GPKGProjectionFactory getProjectionWithInt:geoPackageEpsg];
    GPKGProjection * printProjection = [GPKGProjectionFactory getProjectionWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    GPKGProjectionTransform * wgs84Transform = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToProjection:printProjection];
    
    NSMutableString * log = [[NSMutableString alloc] init];
    [log appendString:@"\n\nBounds Test\n\n"];
    [log appendString:@"REQUEST\n\n"];
    [log appendFormat:@"   Min Lat: %f\n", [boundingBox.minLatitude doubleValue]];
    [log appendFormat:@"   Max Lat: %f\n", [boundingBox.maxLatitude doubleValue]];
    [log appendFormat:@"   Min Lon: %f\n", [boundingBox.minLongitude doubleValue]];
    [log appendFormat:@"   Max Lon: %f\n", [boundingBox.maxLongitude doubleValue]];
    [log appendFormat:@"   Result Width: %d\n", width];
    [log appendFormat:@"   Result Height: %d\n", height];
    
    [log appendString:@"\n\nWGS84 REQUEST\n\n"];
    GPKGBoundingBox * wgs84BoundingBox = [wgs84Transform transformWithBoundingBox:boundingBox];
    [log appendFormat:@"   Min Lat: %f\n", [wgs84BoundingBox.minLatitude doubleValue]];
    [log appendFormat:@"   Max Lat: %f\n", [wgs84BoundingBox.maxLatitude doubleValue]];
    [log appendFormat:@"   Min Lon: %f\n", [wgs84BoundingBox.minLongitude doubleValue]];
    [log appendFormat:@"   Max Lon: %f\n", [wgs84BoundingBox.maxLongitude doubleValue]];
    
    [log appendString:@"\n\nWGS84 LOCATIONS\n"];
    
    for (double lat = maxLatitude - (heightPixelDistance * .5); lat >= minLatitude; lat -= heightPixelDistance) {
        [log appendString:@"\n"];
        for (double lon = minLongitude + (widthPixelDistance * .5); lon <= maxLongitude; lon += widthPixelDistance) {
            NSArray * point = [wgs84Transform transformWithX:lon andY:lat];
            [log appendFormat:@"   (%f,%f)", [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
        }
    }
    [log appendString:@"\n\n"];
    NSLog(log, nil);
    
    for(int i = GPKG_ETA_NEAREST_NEIGHBOR; i <= GPKG_ETA_BICUBIC; i++){
        enum GPKGElevationTilesAlgorithm algorithm = (enum GPKGElevationTilesAlgorithm)i;
        
        NSMutableString * log = [[NSMutableString alloc] init];
        [log appendFormat:@"\n\n%@ SINGLE ELEVATIONS\n", [GPKGElevationTilesAlgorithms name:algorithm]];
        for (double lat = maxLatitude - (heightPixelDistance * .5); lat >= minLatitude; lat -= heightPixelDistance) {
            [log appendString:@"\n"];
            for (double lon = minLongitude + (widthPixelDistance * .5); lon <= maxLongitude; lon += widthPixelDistance) {
                NSDecimalNumber * elevation = [GPKGElevationTilesTiffTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:lat andLongitude:lon andEpsg:geoPackageEpsg];
                [log appendFormat:@"   %@", elevation];
                [GPKGTestUtils assertNotNil:elevation];
            }
        }
        
        GPKGElevationTileResults * results = [GPKGElevationTilesTiffTestUtils elevationsWithGeoPackage:self.geoPackage andAlgorithm:algorithm andBoundingBox:boundingBox andWidth:width andHeight:height andEpsg:geoPackageEpsg];
        [GPKGTestUtils assertNotNil:results];
        [log appendFormat:@"\n\n%@\n", [GPKGElevationTilesAlgorithms name:algorithm]];
        NSArray * elevations = [results elevations];
        [GPKGTestUtils assertEqualIntWithValue:height andValue2:(int)elevations.count];
        [GPKGTestUtils assertEqualIntWithValue:width andValue2:(int)((NSArray *)[elevations objectAtIndex:0]).count];
        for (int y = 0; y < height; y++) {
            [log appendString:@"\n"];
            for (int x = 0; x < width; x++) {
                NSDecimalNumber * elevation = [results elevationAtRow:y andColumn:x];
                [log appendFormat:@"   %@", elevation];
                [GPKGTestUtils assertNotNil:elevation];
            }
        }
    }
    
}

/**
 * Test a full bounding box around tiles and optionally print. Also test the
 * bounds of individual tiles.
 */
-(void) testFullBoundingBox{
    
    int geoPackageEpsg = PROJ_EPSG_WEB_MERCATOR;
    
    int width = 10;
    int height = 6;
    
    GPKGProjection * projection = [GPKGProjectionFactory getProjectionWithInt:geoPackageEpsg];
    GPKGProjection * printProjection = [GPKGProjectionFactory getProjectionWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    GPKGProjectionTransform * wgs84Transform = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToProjection:printProjection];
    
    NSArray * elevationTables = [GPKGElevationTilesTiff tablesForGeoPackage:self.geoPackage];
    GPKGTileMatrixSetDao * dao = [self.geoPackage getTileMatrixSetDao];
    
    for(NSString * elevationTable in elevationTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *) [dao queryForIdObject:elevationTable];
        
        GPKGBoundingBox * boundingBox = [tileMatrixSet getBoundingBox];
        
        double minLongitude = [boundingBox.minLongitude doubleValue];
        double maxLongitude = [boundingBox.maxLongitude doubleValue];
        double minLatitude = [boundingBox.minLatitude doubleValue];
        double maxLatitude = [boundingBox.maxLatitude doubleValue];
        
        double widthPixelDistance = (maxLongitude - minLongitude) / width;
        double heightPixelDistance = (maxLatitude - minLatitude) / height;
        
        NSMutableString * log = [[NSMutableString alloc] init];
        [log appendString:@"\n\nFull Bounding Box Test\n\n"];
        [log appendString:@"REQUEST\n\n"];
        [log appendFormat:@"   Min Lat: %f\n", [boundingBox.minLatitude doubleValue]];
        [log appendFormat:@"   Max Lat: %f\n", [boundingBox.maxLatitude doubleValue]];
        [log appendFormat:@"   Min Lon: %f\n", [boundingBox.minLongitude doubleValue]];
        [log appendFormat:@"   Max Lon: %f\n", [boundingBox.maxLongitude doubleValue]];
        [log appendFormat:@"   Result Width: %d\n", width];
        [log appendFormat:@"   Result Height: %d\n", height];
        
        [log appendString:@"\n\nWGS84 REQUEST\n\n"];
        GPKGBoundingBox * wgs84BoundingBox = [wgs84Transform transformWithBoundingBox:boundingBox];
        [log appendFormat:@"   Min Lat: %f\n", [wgs84BoundingBox.minLatitude doubleValue]];
        [log appendFormat:@"   Max Lat: %f\n", [wgs84BoundingBox.maxLatitude doubleValue]];
        [log appendFormat:@"   Min Lon: %f\n", [wgs84BoundingBox.minLongitude doubleValue]];
        [log appendFormat:@"   Max Lon: %f\n", [wgs84BoundingBox.maxLongitude doubleValue]];
        
        [log appendString:@"\n\nWGS84 LOCATIONS\n"];
        
        for (double lat = maxLatitude; lat >= minLatitude; lat -= heightPixelDistance) {
            [log appendString:@"\n"];
            for (double lon = minLongitude; lon <= maxLongitude; lon += widthPixelDistance) {
                NSArray * point = [wgs84Transform transformWithX:lon andY:lat];
                [log appendFormat:@"   (%f,%f)", [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
            }
            NSArray * point = [wgs84Transform transformWithX:maxLongitude andY:lat];
            [log appendFormat:@"   (%f,%f)", [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
        }
        [log appendString:@"\n"];
        for (double lon = minLongitude; lon <= maxLongitude; lon += widthPixelDistance) {
            NSArray * point = [wgs84Transform transformWithX:lon andY:minLatitude];
            [log appendFormat:@"   (%f,%f)", [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
        }
        NSArray * point = [wgs84Transform transformWithX:maxLongitude andY:minLatitude];
        [log appendFormat:@"   (%f,%f)", [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
        [log appendString:@"\n\n"];
        NSLog(log, nil);
        
        for(int i = GPKG_ETA_NEAREST_NEIGHBOR; i <= GPKG_ETA_BICUBIC; i++){
            enum GPKGElevationTilesAlgorithm algorithm = (enum GPKGElevationTilesAlgorithm)i;
            
            NSMutableString * log = [[NSMutableString alloc] init];
            [log appendFormat:@"\n\n%@ SINGLE ELEVATIONS Full Bounding Box\n", [GPKGElevationTilesAlgorithms name:algorithm]];
            for (double lat = maxLatitude; lat >= minLatitude; lat -= heightPixelDistance) {
                [log appendString:@"\n"];
                for (double lon = minLongitude; lon <= maxLongitude; lon += widthPixelDistance) {
                    NSDecimalNumber * elevation = [GPKGElevationTilesTiffTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:lat andLongitude:lon andEpsg:geoPackageEpsg];
                    [log appendFormat:@"   %@", elevation];
                    if(algorithm == GPKG_ETA_NEAREST_NEIGHBOR || (lat < maxLatitude && lon > minLongitude && lat > minLatitude && lon < maxLongitude)){
                        [GPKGTestUtils assertNotNil:elevation];
                    }
                }
                NSDecimalNumber * elevation = [GPKGElevationTilesTiffTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:lat andLongitude:maxLongitude andEpsg:geoPackageEpsg];
                [log appendFormat:@"   %@", elevation];
                if(algorithm == GPKG_ETA_NEAREST_NEIGHBOR){
                    [GPKGTestUtils assertNotNil:elevation];
                }
            }
            [log appendString:@"\n"];
            for (double lon = minLongitude; lon <= maxLongitude; lon += widthPixelDistance) {
                NSDecimalNumber * elevation = [GPKGElevationTilesTiffTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:minLatitude andLongitude:lon andEpsg:geoPackageEpsg];
                [log appendFormat:@"   %@", elevation];
                if(algorithm == GPKG_ETA_NEAREST_NEIGHBOR){
                    [GPKGTestUtils assertNotNil:elevation];
                }
            }
            NSDecimalNumber * elevation = [GPKGElevationTilesTiffTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:minLatitude andLongitude:maxLongitude andEpsg:geoPackageEpsg];
            [log appendFormat:@"   %@", elevation];
            if(algorithm == GPKG_ETA_NEAREST_NEIGHBOR){
                [GPKGTestUtils assertNotNil:elevation];
            }
            [log appendString:@"\n\n"];
            NSLog(log, nil);
            
            log = [[NSMutableString alloc] init];
            GPKGElevationTileResults * results = [GPKGElevationTilesTiffTestUtils elevationsWithGeoPackage:self.geoPackage andAlgorithm:algorithm andBoundingBox:boundingBox andWidth:width andHeight:height andEpsg:geoPackageEpsg];
            [log appendFormat:@"\n\n%@ Full Bounding Box\n", [GPKGElevationTilesAlgorithms name:algorithm]];
            NSArray * elevations = [results elevations];
            for (int y = 0; y < [results height]; y++) {
                [log appendString:@"\n"];
                for (int x = 0; x < [results width]; x++) {
                    elevation = [results elevationAtRow:y andColumn:x];
                    [log appendFormat:@"   %@", elevation];
                    [GPKGTestUtils assertNotNil:elevation];
                }
            }
            [log appendString:@"\n"];
            NSLog(log, nil);
            
            GPKGTileMatrix * tileMatrix = [results tileMatrix];
            for (int row = 0; row < [tileMatrix.matrixHeight intValue]; row++) {
                for (int column = 0; column < [tileMatrix.matrixWidth intValue]; column++) {
                    
                    GPKGBoundingBox * boundingBox2 = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:boundingBox andTileMatrix:tileMatrix andTileColumn:column andTileRow:row];
                    
                    double minLongitude2 = [boundingBox2.minLongitude doubleValue];
                    double maxLongitude2 = [boundingBox2.maxLongitude doubleValue];
                    double minLatitude2 = [boundingBox2.minLatitude doubleValue];
                    double maxLatitude2 = [boundingBox2.maxLatitude doubleValue];
                    
                    log = [[NSMutableString alloc] init];
                    [log appendFormat:@"\n\n%@ SINGLE ELEVATIONS Tile row = %d, column = %d\n", [GPKGElevationTilesAlgorithms name:algorithm], row, column];
                    
                    elevation = [GPKGElevationTilesTiffTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:maxLatitude2 andLongitude:minLongitude2 andEpsg:geoPackageEpsg];
                    NSArray * point = [wgs84Transform transformWithX:minLongitude2 andY:maxLatitude2];
                    [log appendFormat:@"   %@ (%f,%f)", elevation, [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
                    if (algorithm != GPKG_ETA_NEAREST_NEIGHBOR && (row == 0 || column == 0)) {
                        [GPKGTestUtils assertNil:elevation];
                    } else {
                        [GPKGTestUtils assertNotNil:elevation];
                    }
                    
                    elevation = [GPKGElevationTilesTiffTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:maxLatitude2 andLongitude:maxLongitude2 andEpsg:geoPackageEpsg];
                    point = [wgs84Transform transformWithX:maxLongitude2 andY:maxLatitude2];
                    [log appendFormat:@"   %@ (%f,%f)\n", elevation, [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
                    if (algorithm != GPKG_ETA_NEAREST_NEIGHBOR && (row == 0 || column == [tileMatrix.matrixWidth intValue] - 1)) {
                        [GPKGTestUtils assertNil:elevation];
                    } else {
                        [GPKGTestUtils assertNotNil:elevation];
                    }
                    
                    elevation = [GPKGElevationTilesTiffTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:minLatitude2 andLongitude:minLongitude2 andEpsg:geoPackageEpsg];
                    point = [wgs84Transform transformWithX:minLongitude2 andY:minLatitude2];
                    [log appendFormat:@"   %@ (%f,%f)", elevation, [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
                    if (algorithm != GPKG_ETA_NEAREST_NEIGHBOR && (row == [tileMatrix.matrixHeight intValue] - 1 || column == 0)) {
                        [GPKGTestUtils assertNil:elevation];
                    } else {
                        [GPKGTestUtils assertNotNil:elevation];
                    }
                    
                    elevation = [GPKGElevationTilesTiffTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:minLatitude2 andLongitude:maxLongitude2 andEpsg:geoPackageEpsg];
                    point = [wgs84Transform transformWithX:maxLongitude2 andY:minLatitude2];
                    [log appendFormat:@"   %@ (%f,%f)\n", elevation, [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
                    if (algorithm != GPKG_ETA_NEAREST_NEIGHBOR && (row == [tileMatrix.matrixHeight intValue] - 1 || column == [tileMatrix.matrixWidth intValue] - 1)) {
                        [GPKGTestUtils assertNil:elevation];
                    } else {
                        [GPKGTestUtils assertNotNil:elevation];
                    }
                    
                    results = [GPKGElevationTilesTiffTestUtils elevationsWithGeoPackage:self.geoPackage andAlgorithm:algorithm andBoundingBox:boundingBox2 andWidth:width andHeight:height andEpsg:geoPackageEpsg];
                    
                    [log appendFormat:@"\n\n%@ Tile row = %d, column = %d\n", [GPKGElevationTilesAlgorithms name:algorithm], row, column];
                    if (results == nil) {
                        [log appendString:@"\nnull results"];
                    } else {
                        elevations = [results elevations];
                        for (int y = 0; y < [results height]; y++) {
                            [log appendString:@"\n"];
                            for (int x = 0; x < [results width]; x++) {
                                elevation = [results elevationAtRow:y andColumn:x];
                                [log appendFormat:@"   %@", elevation];
                                [GPKGTestUtils assertNotNil:elevation];
                            }
                        }
                    }
                    [log appendString:@"\n\n"];
                    NSLog(log, nil);
                }
            }
        }
        
    }
}

/**
 * Test a single location
 *
 * @param latitude
 * @param longitude
 */
-(void) testLocationWithLatitude: (double) latitude andLongitude: (double) longitude{
    
    NSMutableString * log = [[NSMutableString alloc] init];
    
    [log appendFormat:@"\n\nLatitude: %f\n", latitude];
    [log appendFormat:@"Longitude: %f\n", longitude];
    
    for(int i = GPKG_ETA_NEAREST_NEIGHBOR; i <= GPKG_ETA_BICUBIC; i++){
        enum GPKGElevationTilesAlgorithm algorithm = (enum GPKGElevationTilesAlgorithm)i;
        NSDecimalNumber * elevation = [GPKGElevationTilesTiffTestUtils elevationWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:latitude andLongitude:longitude andEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        [log appendFormat:@"%@: %@\n", [GPKGElevationTilesAlgorithms name:algorithm], elevation];
    }
    [log appendString:@"\n"];
    
    NSLog(log, nil);
}

@end
