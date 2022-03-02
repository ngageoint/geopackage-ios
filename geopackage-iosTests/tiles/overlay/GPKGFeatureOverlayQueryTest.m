//
//  GPKGFeatureOverlayQueryTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 3/2/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGFeatureOverlayQueryTest.h"
#import "GPKGTestUtils.h"
#import "GPKGFeatureOverlayQuery.h"
#import "PROJProjectionFactory.h"
#import "PROJProjectionConstants.h"
#import "SFPGeometryTransform.h"

@implementation GPKGFeatureOverlayQueryTest

-(void) testTileBounds{

    double longitude = -77.196785;
    double latitude = 38.753195;
    int zoom = 6;

    GPKGMapPoint *mapPoint = [[GPKGMapPoint alloc] initWithLatitude:latitude andLongitude:longitude];
    GPKGBoundingBox *boundingBox = [GPKGFeatureOverlayQuery tileBoundsWithMapPoint:mapPoint andZoom:zoom];
    
    [GPKGTestUtils assertEqualDoubleWithValue:-78.75000000000001 andValue2:[boundingBox.minLongitude doubleValue] andDelta:0.0000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:36.597889133070204 andValue2:[boundingBox.minLatitude doubleValue] andDelta:0.0000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-73.125 andValue2:[boundingBox.maxLongitude doubleValue] andDelta:0.0000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:40.97989806962014 andValue2:[boundingBox.maxLatitude doubleValue] andDelta:0.0000000000001];

    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    GPKGBoundingBox *boundingBox2 = [GPKGFeatureOverlayQuery tileBoundsWithLocationCoordinate:coordinate andZoom:zoom];
    
    [GPKGTestUtils assertEqualWithValue:boundingBox andValue2:boundingBox2];
    
    SFPoint *point = [[SFPoint alloc] initWithXValue:longitude andYValue:latitude];
    GPKGBoundingBox *boundingBox3 = [GPKGFeatureOverlayQuery tileBoundsWithPoint:point andZoom:zoom];
    
    [GPKGTestUtils assertEqualWithValue:boundingBox andValue2:boundingBox3];

    PROJProjection *projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
    SFPGeometryTransform *transform = [SFPGeometryTransform transformFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToProjection:projection];
    point = [transform transformPoint:point];
    boundingBox = [GPKGFeatureOverlayQuery tileBoundsInProjection:projection withPoint:point andZoom:zoom];
    
    [GPKGTestUtils assertEqualDoubleWithValue:-8766409.899970295 andValue2:[boundingBox.minLongitude doubleValue] andDelta:0.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:4383204.9499851465 andValue2:[boundingBox.minLatitude doubleValue] andDelta:0.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-8140237.7642581295 andValue2:[boundingBox.maxLongitude doubleValue] andDelta:0.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:5009377.085697312 andValue2:[boundingBox.maxLatitude doubleValue] andDelta:0.00000001];
    
    longitude = 151.215026;
    latitude = -33.856686;
    zoom = 15;
    
    mapPoint = [[GPKGMapPoint alloc] initWithLatitude:latitude andLongitude:longitude];
    boundingBox = [GPKGFeatureOverlayQuery tileBoundsWithMapPoint:mapPoint andZoom:zoom];
    
    [GPKGTestUtils assertEqualDoubleWithValue:151.20483398437506 andValue2:[boundingBox.minLongitude doubleValue] andDelta:0.000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-33.86129311351553 andValue2:[boundingBox.minLatitude doubleValue] andDelta:0.000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:151.21582031250003 andValue2:[boundingBox.maxLongitude doubleValue] andDelta:0.000000000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-33.852169701407426 andValue2:[boundingBox.maxLatitude doubleValue] andDelta:0.000000000001];

    coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    boundingBox2 = [GPKGFeatureOverlayQuery tileBoundsWithLocationCoordinate:coordinate andZoom:zoom];
    
    [GPKGTestUtils assertEqualWithValue:boundingBox andValue2:boundingBox2];
    
    point = [[SFPoint alloc] initWithXValue:longitude andYValue:latitude];
    boundingBox3 = [GPKGFeatureOverlayQuery tileBoundsWithPoint:point andZoom:zoom];
    
    [GPKGTestUtils assertEqualWithValue:boundingBox andValue2:boundingBox3];

    point = [transform transformPoint:point];
    boundingBox = [GPKGFeatureOverlayQuery tileBoundsInProjection:projection withPoint:point andZoom:zoom];
    
    [GPKGTestUtils assertEqualDoubleWithValue:16832045.124622095 andValue2:[boundingBox.minLongitude doubleValue] andDelta:0.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-4010192.2519534864 andValue2:[boundingBox.minLatitude doubleValue] andDelta:0.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:16833268.117074657 andValue2:[boundingBox.maxLongitude doubleValue] andDelta:0.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:-4008969.2595009245 andValue2:[boundingBox.maxLatitude doubleValue] andDelta:0.00000001];
 
}

@end
