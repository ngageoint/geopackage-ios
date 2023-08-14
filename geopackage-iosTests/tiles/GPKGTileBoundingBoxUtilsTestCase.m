//
//  GPKGTileBoundingBoxUtilsTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/14/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGTileBoundingBoxUtilsTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "PROJProjectionConstants.h"

@implementation GPKGTileBoundingBoxUtilsTestCase

/**
 * Test Tile Bounds
 */
-(void) testTileBounds{
    
    double longitude = -77.196785;
    double latitude = 38.753195;
    int zoom = 6;

    SFPoint *point = [SFPoint pointWithXValue:longitude andYValue:latitude];
    GPKGBoundingBox *boundingBox = [GPKGTileBoundingBoxUtils tileBoundsForWGS84Point:point andZoom:zoom];

    [GPKGTestUtils assertEqualDoubleWithValue:-78.75000000000001 andValue2:[boundingBox.minLongitude doubleValue] andDelta:0.0000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:36.597889133070204 andValue2:[boundingBox.minLatitude doubleValue] andDelta:0.0000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-73.125 andValue2:[boundingBox.maxLongitude doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:40.97989806962014 andValue2:[boundingBox.maxLatitude doubleValue] andDelta:0.0000000000001];

    SFPGeometryTransform *transform = [SFPGeometryTransform transformFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    point = [transform transformPoint:point];
    boundingBox = [GPKGTileBoundingBoxUtils tileBoundsForWebMercatorPoint:point andZoom:zoom];

    [GPKGTestUtils assertEqualDoubleWithValue:-8766409.899970295 andValue2:[boundingBox.minLongitude doubleValue] andDelta:0.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:4383204.9499851465 andValue2:[boundingBox.minLatitude doubleValue] andDelta:0.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-8140237.7642581295 andValue2:[boundingBox.maxLongitude doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:5009377.085697312 andValue2:[boundingBox.maxLatitude doubleValue] andDelta:0.000000001];

    longitude = 151.215026;
    latitude = -33.856686;
    zoom = 15;

    point = [SFPoint pointWithXValue:longitude andYValue:latitude];
    boundingBox = [GPKGTileBoundingBoxUtils tileBoundsForWGS84Point:point andZoom:zoom];

    [GPKGTestUtils assertEqualDoubleWithValue:151.20483398437506 andValue2:[boundingBox.minLongitude doubleValue] andDelta:0.000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-33.86129311351553 andValue2:[boundingBox.minLatitude doubleValue] andDelta:0.0000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:151.21582031250003 andValue2:[boundingBox.maxLongitude doubleValue] andDelta:0.0000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-33.852169701407426 andValue2:[boundingBox.maxLatitude doubleValue] andDelta:0.0000000000001];

    point = [transform transformPoint:point];
    boundingBox = [GPKGTileBoundingBoxUtils tileBoundsForWebMercatorPoint:point andZoom:zoom];

    [GPKGTestUtils assertEqualDoubleWithValue:16832045.124622095 andValue2:[boundingBox.minLongitude doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:-4010192.2519534864 andValue2:[boundingBox.minLatitude doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:16833268.117074657 andValue2:[boundingBox.maxLongitude doubleValue] andDelta:0.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-4008969.2595009245 andValue2:[boundingBox.maxLatitude doubleValue] andDelta:0.00000001];
    
    [transform destroy];
    
}

@end
