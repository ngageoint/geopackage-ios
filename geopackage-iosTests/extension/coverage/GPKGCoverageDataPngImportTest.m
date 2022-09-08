//
//  GPKGCoverageDataPngImportTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataPngImportTest.h"
#import "GPKGCoverageDataPngTestUtils.h"
#import "PROJProjectionFactory.h"
#import "PROJProjectionConstants.h"
#import "GPKGTestUtils.h"
#import "GPKGCoverageDataPng.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGCoverageDataTestUtils.h"

@implementation GPKGCoverageDataPngImportTest

static BOOL allowNulls = NO;

/**
 * Test the coverage data extension with a newly created GeoPackage using the
 * Nearest Neighbor Algorithm
 */
- (void)testNearestNeighbor {
    [GPKGCoverageDataPngTestUtils testCoverageDataWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_CDA_NEAREST_NEIGHBOR andAllowNils:allowNulls];
}

/**
 * Test the coverage data extension with a newly created GeoPackage using the
 * Bilinear Algorithm
 */
- (void)testBilinear {
    [GPKGCoverageDataPngTestUtils testCoverageDataWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_CDA_BILINEAR andAllowNils:allowNulls];
}

/**
 * Test the coverage data extension with a newly created GeoPackage using the
 * Bicubic Algorithm
 */
- (void)testBicubic {
    [GPKGCoverageDataPngTestUtils testCoverageDataWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_CDA_BICUBIC andAllowNils:allowNulls];
}

/**
 * Test a random bounding box using the Nearest Neighbor Algorithm
 */
- (void)testRandomBoundingBoxNearestNeighbor {
    [GPKGCoverageDataTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_CDA_NEAREST_NEIGHBOR andAllowNils:YES];
}

/**
 * Test a random bounding box using the Bilinear Algorithm
 */
- (void)testRandomBoundingBoxBilinear {
    [GPKGCoverageDataTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_CDA_BILINEAR andAllowNils:YES];
}

/**
 * Test a random bounding box using the Bicubic Algorithm
 */
- (void)testRandomBoundingBoxBicubic {
    [GPKGCoverageDataTestUtils testRandomBoundingBoxWithGeoPackage:self.geoPackage andValues:nil andAlgorithm:GPKG_CDA_BICUBIC andAllowNils:YES];
}

/**
 * Test the pixel encoding
 */
- (void) testPixelEncoding {
    [GPKGCoverageDataTestUtils testPixelEncodingWithGeoPackage:self.geoPackage andAllowNils:YES];
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
    
    GPKGBoundingBox *projectedBoundingBox = nil;
    
    NSArray *coverageDataTables = [GPKGCoverageDataPng tablesForGeoPackage:self.geoPackage];
    GPKGTileMatrixSetDao *dao = [self.geoPackage tileMatrixSetDao];
    
    for(NSString *coverageDataTable in coverageDataTables){
        
        GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *) [dao queryForIdObject:coverageDataTable];
        
        GPKGBoundingBox *boundingBox = [tileMatrixSet boundingBox];
        NSMutableString *log = [NSMutableString string];
        [log appendFormat:@"\n\nMin Latitude: %f\n", [boundingBox.minLatitude doubleValue]];
        [log appendFormat:@"Max Latitude: %f\n", [boundingBox.maxLatitude doubleValue]];
        [log appendFormat:@"Min Longitude: %f\n", [boundingBox.minLongitude doubleValue]];
        [log appendFormat:@"Max Longitude: %f\n\n", [boundingBox.maxLongitude doubleValue]];
        NSLog(log, nil);
        
        GPKGSpatialReferenceSystemDao *srsDao = [self.geoPackage spatialReferenceSystemDao];
        NSNumber *srsId = tileMatrixSet.srsId;
        GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:srsId];
        PROJProjection *projection = [srs projection];
        PROJProjection *requestProjection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        SFPGeometryTransform *coverageToRequest = [SFPGeometryTransform transformFromProjection:projection andToProjection:requestProjection];
        projectedBoundingBox = [boundingBox transform:coverageToRequest];
    }
    
    NSMutableString *log = [NSMutableString string];
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
 * Test coverage data requests within the bounds of the tiles and optionally
 * print
 */
-(void) testBounds{
    
    int requestEpsg = PROJ_EPSG_WEB_MERCATOR;
    
    double widthPixelDistance = 1000;
    double heightPixelDistance = 1000;
    int width = 10;
    int height = 6;
    double minLongitude = -16586000;
    double maxLongitude = minLongitude + (width * widthPixelDistance);
    double minLatitude = 8760000;
    double maxLatitude = minLatitude + (height * heightPixelDistance);
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
    
    PROJProjection *projection = [PROJProjectionFactory projectionWithEpsgInt:requestEpsg];
    PROJProjection *printProjection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    SFPGeometryTransform *wgs84Transform = [SFPGeometryTransform transformFromProjection:projection andToProjection:printProjection];
    
    NSMutableString *log = [NSMutableString string];
    [log appendString:@"\n\nBounds Test\n\n"];
    [log appendString:@"REQUEST\n\n"];
    [log appendFormat:@"   Min Lat: %f\n", [boundingBox.minLatitude doubleValue]];
    [log appendFormat:@"   Max Lat: %f\n", [boundingBox.maxLatitude doubleValue]];
    [log appendFormat:@"   Min Lon: %f\n", [boundingBox.minLongitude doubleValue]];
    [log appendFormat:@"   Max Lon: %f\n", [boundingBox.maxLongitude doubleValue]];
    [log appendFormat:@"   Result Width: %d\n", width];
    [log appendFormat:@"   Result Height: %d\n", height];
    
    [log appendString:@"\n\nWGS84 REQUEST\n\n"];
    GPKGBoundingBox *wgs84BoundingBox = [boundingBox transform:wgs84Transform];
    [log appendFormat:@"   Min Lat: %f\n", [wgs84BoundingBox.minLatitude doubleValue]];
    [log appendFormat:@"   Max Lat: %f\n", [wgs84BoundingBox.maxLatitude doubleValue]];
    [log appendFormat:@"   Min Lon: %f\n", [wgs84BoundingBox.minLongitude doubleValue]];
    [log appendFormat:@"   Max Lon: %f\n", [wgs84BoundingBox.maxLongitude doubleValue]];
    
    [log appendString:@"\n\nWGS84 LOCATIONS\n"];
    
    for (double lat = maxLatitude - (heightPixelDistance * .5); lat >= minLatitude; lat -= heightPixelDistance) {
        [log appendString:@"\n"];
        for (double lon = minLongitude + (widthPixelDistance * .5); lon <= maxLongitude; lon += widthPixelDistance) {
            NSArray *point = [wgs84Transform transformX:lon andY:lat];
            [log appendFormat:@"   (%f,%f)", [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
        }
    }
    [log appendString:@"\n\n"];
    NSLog(log, nil);
    
    for(int i = GPKG_CDA_NEAREST_NEIGHBOR; i <= GPKG_CDA_BICUBIC; i++){
        enum GPKGCoverageDataAlgorithm algorithm = (enum GPKGCoverageDataAlgorithm)i;
        
        NSMutableString *log = [NSMutableString string];
        [log appendFormat:@"\n\n%@ SINGLE COVERAGE DATA VALUES\n", [GPKGCoverageDataAlgorithms name:algorithm]];
        for (double lat = maxLatitude - (heightPixelDistance * .5); lat >= minLatitude; lat -= heightPixelDistance) {
            [log appendString:@"\n"];
            for (double lon = minLongitude + (widthPixelDistance * .5); lon <= maxLongitude; lon += widthPixelDistance) {
                NSDecimalNumber *value = [GPKGCoverageDataTestUtils valueWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:lat andLongitude:lon andEpsg:requestEpsg];
                [log appendFormat:@"   %@", value];
                if(!allowNulls){
                    [GPKGTestUtils assertNotNil:value];
                }
            }
        }
        
        GPKGCoverageDataResults *results = [GPKGCoverageDataTestUtils valuesWithGeoPackage:self.geoPackage andAlgorithm:algorithm andBoundingBox:boundingBox andWidth:width andHeight:height andEpsg:requestEpsg];
        if(!allowNulls){
            [GPKGTestUtils assertNotNil:results];
        }
        if(results != nil){
            [log appendFormat:@"\n\n%@\n", [GPKGCoverageDataAlgorithms name:algorithm]];
            NSArray *values = [results values];
            [GPKGTestUtils assertEqualIntWithValue:height andValue2:(int)values.count];
            [GPKGTestUtils assertEqualIntWithValue:width andValue2:(int)((NSArray *)[values objectAtIndex:0]).count];
            for (int y = 0; y < height; y++) {
                [log appendString:@"\n"];
                for (int x = 0; x < width; x++) {
                    NSDecimalNumber *value = [results valueAtRow:y andColumn:x];
                    [log appendFormat:@"   %@", value];
                    if(!allowNulls){
                        [GPKGTestUtils assertNotNil:value];
                    }
                }
            }
        }
    }
    
}

/**
 * Test a full bounding box around tiles and optionally print. Also test the
 * bounds of individual tiles.
 */
-(void) testFullBoundingBox{
    
    int width = 10;
    int height = 6;
    
    NSArray *coverageDataTables = [GPKGCoverageDataPng tablesForGeoPackage:self.geoPackage];
    GPKGTileMatrixSetDao *dao = [self.geoPackage tileMatrixSetDao];
    
    for(NSString *coverageDataTable in coverageDataTables){
        
        GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *) [dao queryForIdObject:coverageDataTable];
        
        GPKGSpatialReferenceSystem *srs = [dao srs:tileMatrixSet];
        int geoPackageEpsg = [srs.organizationCoordsysId intValue];
        
        PROJProjection *projection = [srs projection];
        PROJProjection *printProjection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        SFPGeometryTransform *wgs84Transform = [SFPGeometryTransform transformFromProjection:projection andToProjection:printProjection];
        
        GPKGBoundingBox *boundingBox = [tileMatrixSet boundingBox];
        
        double minLongitude = [boundingBox.minLongitude doubleValue];
        double maxLongitude = [boundingBox.maxLongitude doubleValue];
        double minLatitude = [boundingBox.minLatitude doubleValue];
        double maxLatitude = [boundingBox.maxLatitude doubleValue];
        
        double widthPixelDistance = (maxLongitude - minLongitude) / width;
        double heightPixelDistance = (maxLatitude - minLatitude) / height;
        
        NSMutableString *log = [NSMutableString string];
        [log appendString:@"\n\nFull Bounding Box Test\n\n"];
        [log appendString:@"REQUEST\n\n"];
        [log appendFormat:@"   Min Lat: %f\n", [boundingBox.minLatitude doubleValue]];
        [log appendFormat:@"   Max Lat: %f\n", [boundingBox.maxLatitude doubleValue]];
        [log appendFormat:@"   Min Lon: %f\n", [boundingBox.minLongitude doubleValue]];
        [log appendFormat:@"   Max Lon: %f\n", [boundingBox.maxLongitude doubleValue]];
        [log appendFormat:@"   Result Width: %d\n", width];
        [log appendFormat:@"   Result Height: %d\n", height];
        
        [log appendString:@"\n\nWGS84 REQUEST\n\n"];
        GPKGBoundingBox *wgs84BoundingBox = [boundingBox transform:wgs84Transform];
        [log appendFormat:@"   Min Lat: %f\n", [wgs84BoundingBox.minLatitude doubleValue]];
        [log appendFormat:@"   Max Lat: %f\n", [wgs84BoundingBox.maxLatitude doubleValue]];
        [log appendFormat:@"   Min Lon: %f\n", [wgs84BoundingBox.minLongitude doubleValue]];
        [log appendFormat:@"   Max Lon: %f\n", [wgs84BoundingBox.maxLongitude doubleValue]];
        
        [log appendString:@"\n\nWGS84 LOCATIONS\n"];
        
        for (double lat = maxLatitude; lat >= minLatitude; lat -= heightPixelDistance) {
            [log appendString:@"\n"];
            for (double lon = minLongitude; lon <= maxLongitude; lon += widthPixelDistance) {
                NSArray *point = [wgs84Transform transformX:lon andY:lat];
                [log appendFormat:@"   (%f,%f)", [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
            }
            NSArray *point = [wgs84Transform transformX:maxLongitude andY:lat];
            [log appendFormat:@"   (%f,%f)", [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
        }
        [log appendString:@"\n"];
        for (double lon = minLongitude; lon <= maxLongitude; lon += widthPixelDistance) {
            NSArray *point = [wgs84Transform transformX:lon andY:minLatitude];
            [log appendFormat:@"   (%f,%f)", [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
        }
        NSArray *point = [wgs84Transform transformX:maxLongitude andY:minLatitude];
        [log appendFormat:@"   (%f,%f)", [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
        [log appendString:@"\n\n"];
        NSLog(log, nil);
        
        for(int i = GPKG_CDA_NEAREST_NEIGHBOR; i <= GPKG_CDA_BICUBIC; i++){
            enum GPKGCoverageDataAlgorithm algorithm = (enum GPKGCoverageDataAlgorithm)i;
            
            NSMutableString *log = [NSMutableString string];
            [log appendFormat:@"\n\n%@ SINGLE COVERAGE DATA VALUES Full Bounding Box\n", [GPKGCoverageDataAlgorithms name:algorithm]];
            for (double lat = maxLatitude; lat >= minLatitude; lat -= heightPixelDistance) {
                [log appendString:@"\n"];
                for (double lon = minLongitude; lon <= maxLongitude; lon += widthPixelDistance) {
                    NSDecimalNumber *value = [GPKGCoverageDataTestUtils valueWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:lat andLongitude:lon andEpsg:geoPackageEpsg];
                    [log appendFormat:@"   %@", value];
                    if(algorithm == GPKG_CDA_NEAREST_NEIGHBOR || (lat < maxLatitude && lon > minLongitude && lat > minLatitude + heightPixelDistance && lon < maxLongitude)){
                        if(!allowNulls){
                            [GPKGTestUtils assertNotNil:value];
                        }
                    }
                }
                NSDecimalNumber *value = [GPKGCoverageDataTestUtils valueWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:lat andLongitude:maxLongitude andEpsg:geoPackageEpsg];
                [log appendFormat:@"   %@", value];
                if(algorithm == GPKG_CDA_NEAREST_NEIGHBOR){
                    if(!allowNulls){
                        [GPKGTestUtils assertNotNil:value];
                    }
                }
            }
            [log appendString:@"\n"];
            for (double lon = minLongitude; lon <= maxLongitude; lon += widthPixelDistance) {
                NSDecimalNumber *value = [GPKGCoverageDataTestUtils valueWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:minLatitude andLongitude:lon andEpsg:geoPackageEpsg];
                [log appendFormat:@"   %@", value];
                if(algorithm == GPKG_CDA_NEAREST_NEIGHBOR){
                    if(!allowNulls){
                        [GPKGTestUtils assertNotNil:value];
                    }
                }
            }
            NSDecimalNumber *value = [GPKGCoverageDataTestUtils valueWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:minLatitude andLongitude:maxLongitude andEpsg:geoPackageEpsg];
            [log appendFormat:@"   %@", value];
            if(algorithm == GPKG_CDA_NEAREST_NEIGHBOR){
                if(!allowNulls){
                    [GPKGTestUtils assertNotNil:value];
                }
            }
            [log appendString:@"\n\n"];
            NSLog(log, nil);
            
            log = [NSMutableString string];
            GPKGCoverageDataResults *results = [GPKGCoverageDataTestUtils valuesWithGeoPackage:self.geoPackage andAlgorithm:algorithm andBoundingBox:boundingBox andWidth:width andHeight:height andEpsg:geoPackageEpsg];
            [log appendFormat:@"\n\n%@ Full Bounding Box\n", [GPKGCoverageDataAlgorithms name:algorithm]];
            NSArray *values = [results values];
            for (int y = 0; y < [results height]; y++) {
                [log appendString:@"\n"];
                for (int x = 0; x < [results width]; x++) {
                    value = [results valueAtRow:y andColumn:x];
                    [log appendFormat:@"   %@", value];
                    if(!allowNulls){
                        [GPKGTestUtils assertNotNil:value];
                    }
                }
            }
            [log appendString:@"\n"];
            NSLog(log, nil);
            
            GPKGTileMatrix *tileMatrix = [results tileMatrix];
            for (int row = 0; row < [tileMatrix.matrixHeight intValue]; row++) {
                for (int column = 0; column < [tileMatrix.matrixWidth intValue]; column++) {
                    
                    GPKGBoundingBox *boundingBox2 = [GPKGTileBoundingBoxUtils boundingBoxWithTotalBoundingBox:boundingBox andTileMatrix:tileMatrix andTileColumn:column andTileRow:row];
                    
                    double minLongitude2 = [boundingBox2.minLongitude doubleValue];
                    double maxLongitude2 = [boundingBox2.maxLongitude doubleValue];
                    double minLatitude2 = [boundingBox2.minLatitude doubleValue];
                    double maxLatitude2 = [boundingBox2.maxLatitude doubleValue];
                    
                    log = [NSMutableString string];
                    [log appendFormat:@"\n\n%@ SINGLE COVERAGE DATA VALUES Tile row = %d, column = %d\n", [GPKGCoverageDataAlgorithms name:algorithm], row, column];
                    
                    value = [GPKGCoverageDataTestUtils valueWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:maxLatitude2 andLongitude:minLongitude2 andEpsg:geoPackageEpsg];
                    NSArray *point = [wgs84Transform transformX:minLongitude2 andY:maxLatitude2];
                    [log appendFormat:@"   %@ (%f,%f)", value, [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
                    if (algorithm != GPKG_CDA_NEAREST_NEIGHBOR && (row == 0 || column == 0)) {
                        [GPKGTestUtils assertNil:value];
                    } else {
                        if(!allowNulls){
                            [GPKGTestUtils assertNotNil:value];
                        }
                    }
                    
                    value = [GPKGCoverageDataTestUtils valueWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:maxLatitude2 andLongitude:maxLongitude2 andEpsg:geoPackageEpsg];
                    point = [wgs84Transform transformX:maxLongitude2 andY:maxLatitude2];
                    [log appendFormat:@"   %@ (%f,%f)\n", value, [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
                    if (algorithm != GPKG_CDA_NEAREST_NEIGHBOR && (row == 0 || column == [tileMatrix.matrixWidth intValue] - 1)) {
                        [GPKGTestUtils assertNil:value];
                    } else {
                        if(!allowNulls){
                            [GPKGTestUtils assertNotNil:value];
                        }
                    }
                    
                    value = [GPKGCoverageDataTestUtils valueWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:minLatitude2 andLongitude:minLongitude2 andEpsg:geoPackageEpsg];
                    point = [wgs84Transform transformX:minLongitude2 andY:minLatitude2];
                    [log appendFormat:@"   %@ (%f,%f)", value, [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
                    if (algorithm != GPKG_CDA_NEAREST_NEIGHBOR && (row == [tileMatrix.matrixHeight intValue] - 1 || column == 0)) {
                        [GPKGTestUtils assertNil:value];
                    } else {
                        if(!allowNulls){
                            [GPKGTestUtils assertNotNil:value];
                        }
                    }
                    
                    value = [GPKGCoverageDataTestUtils valueWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:minLatitude2 andLongitude:maxLongitude2 andEpsg:geoPackageEpsg];
                    point = [wgs84Transform transformX:maxLongitude2 andY:minLatitude2];
                    [log appendFormat:@"   %@ (%f,%f)\n", value, [((NSDecimalNumber *)[point objectAtIndex:1]) doubleValue], [((NSDecimalNumber *)[point objectAtIndex:0]) doubleValue]];
                    if (algorithm != GPKG_CDA_NEAREST_NEIGHBOR && (row == [tileMatrix.matrixHeight intValue] - 1 || column == [tileMatrix.matrixWidth intValue] - 1)) {
                        [GPKGTestUtils assertNil:value];
                    } else {
                        if(!allowNulls){
                            [GPKGTestUtils assertNotNil:value];
                        }
                    }
                    
                    results = [GPKGCoverageDataTestUtils valuesWithGeoPackage:self.geoPackage andAlgorithm:algorithm andBoundingBox:boundingBox2 andWidth:width andHeight:height andEpsg:geoPackageEpsg];

                    [log appendFormat:@"\n\n%@ Tile row = %d, column = %d\n", [GPKGCoverageDataAlgorithms name:algorithm], row, column];
                    if (results == nil) {
                        [log appendString:@"\nnull results"];
                    } else {
                        values = [results values];
                        for (int y = 0; y < [results height]; y++) {
                            [log appendString:@"\n"];
                            for (int x = 0; x < [results width]; x++) {
                                value = [results valueAtRow:y andColumn:x];
                                [log appendFormat:@"   %@", value];
                                if(!allowNulls){
                                    [GPKGTestUtils assertNotNil:value];
                                }
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
    
    NSMutableString *log = [NSMutableString string];
    
    [log appendFormat:@"\n\nLatitude: %f\n", latitude];
    [log appendFormat:@"Longitude: %f\n", longitude];
    
    for(int i = GPKG_CDA_NEAREST_NEIGHBOR; i <= GPKG_CDA_BICUBIC; i++){
        enum GPKGCoverageDataAlgorithm algorithm = (enum GPKGCoverageDataAlgorithm)i;
        NSDecimalNumber *value = [GPKGCoverageDataTestUtils valueWithGeoPackage:self.geoPackage andAlgorithm:algorithm andLatitude:latitude andLongitude:longitude andEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        [log appendFormat:@"%@: %@\n", [GPKGCoverageDataAlgorithms name:algorithm], value];
    }
    [log appendString:@"\n"];

    NSLog(log, nil);
}

@end
