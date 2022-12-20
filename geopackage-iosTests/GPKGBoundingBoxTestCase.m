//
//  GPKGBoundingBoxTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/14/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGBoundingBoxTestCase.h"
#import "GPKGTestUtils.h"
#import "PROJProjectionFactory.h"
#import "PROJProjectionConstants.h"

@implementation GPKGBoundingBoxTestCase

/**
 * Test centroid methods
 */
-(void) testCentroid{
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:5.0 andMinLatitudeDouble:10.0 andMaxLongitudeDouble:30.0 andMaxLatitudeDouble:55.0];
    
    SFPoint *centroid = [boundingBox centroid];

    [GPKGTestUtils assertEqualDoubleWithValue:17.5 andValue2:[centroid.x doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:32.5 andValue2:[centroid.y doubleValue]];

    SFPoint *centroid2 = [boundingBox centroidInProjection:[PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR]];
    
    [GPKGTestUtils assertEqualDoubleWithValue:[centroid.x doubleValue] andValue2:[centroid2.x doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[centroid.y doubleValue] andValue2:[centroid2.y doubleValue]];

    SFPoint *geometryCentroid = [[boundingBox buildGeometry] centroid];
    
    [GPKGTestUtils assertEqualDoubleWithValue:[geometryCentroid.x doubleValue] andValue2:[centroid.x doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[geometryCentroid.y doubleValue] andValue2:[centroid.y doubleValue]];

    SFPoint *degreesCentroid = [boundingBox degreesCentroid];

    [GPKGTestUtils assertEqualDoubleWithValue:17.5 andValue2:[degreesCentroid.x doubleValue] andDelta:0.0000001];
    [GPKGTestUtils assertEqualDoubleWithValue:33.12597587060761 andValue2:[degreesCentroid.y doubleValue] andDelta:0.000001];
    
    SFPoint *degreesCentroid2 = [boundingBox centroidInProjection:[PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];

    [GPKGTestUtils assertEqualDoubleWithValue:[degreesCentroid.x doubleValue] andValue2:[degreesCentroid2.x doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[degreesCentroid.y doubleValue] andValue2:[degreesCentroid2.y doubleValue]];

    SFPoint *geometryDegreesCentroid = [[boundingBox buildGeometry] degreesCentroid];

    [GPKGTestUtils assertEqualDoubleWithValue:[geometryDegreesCentroid.x doubleValue] andValue2:[degreesCentroid.x doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[geometryDegreesCentroid.y doubleValue] andValue2:[degreesCentroid.y doubleValue]];
    
}

@end
