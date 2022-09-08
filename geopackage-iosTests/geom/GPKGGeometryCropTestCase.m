//
//  GPKGGeometryCropTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/8/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGGeometryCropTestCase.h"
#import "SFPolygon.h"
#import "GPKGGeometryCrop.h"
#import "PROJProjectionFactory.h"
#import "PROJProjectionConstants.h"
#import "SFGeometryUtils.h"
#import "GPKGTestUtils.h"

@implementation GPKGGeometryCropTestCase


-(void) testCropGeometryData {

    PROJProjection *wgs84 = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    SFPolygon *polygon = [SFPolygon polygon];
    SFLineString *ring = [SFLineString lineString];
    [ring addPoint:[SFPoint pointWithXValue:100 andYValue:80]];
    [ring addPoint:[SFPoint pointWithXValue:120 andYValue:80]];
    [ring addPoint:[SFPoint pointWithXValue:120 andYValue:89]];
    [ring addPoint:[SFPoint pointWithXValue:110 andYValue:80]];
    [ring addPoint:[SFPoint pointWithXValue:100 andYValue:89]];
    [ring addPoint:[SFPoint pointWithXValue:100 andYValue:80]];
    [polygon addRing:ring];
    
    GPKGGeometryData *geometryData = [GPKGGeometryData createWithSrsId:0 andGeometry:polygon];
    
    [GPKGGeometryCrop cropGeometryData:geometryData inProjection:wgs84];
    
    [GPKGTestUtils assertTrue:[[SFGeometryUtils wgs84EnvelopeWithWebMercator] containsEnvelope:[geometryData.geometry envelope]]];
    
}

-(void) testCropGeometryDataWithEnvelope {

    PROJProjection *wgs84 = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    SFPolygon *polygon = [SFPolygon polygon];
    SFLineString *ring = [SFLineString lineString];
    [ring addPoint:[SFPoint pointWithXValue:-10 andYValue:-10]];
    [ring addPoint:[SFPoint pointWithXValue:0 andYValue:-5]];
    [ring addPoint:[SFPoint pointWithXValue:10 andYValue:-10]];
    [ring addPoint:[SFPoint pointWithXValue:5 andYValue:0]];
    [ring addPoint:[SFPoint pointWithXValue:10 andYValue:10]];
    [ring addPoint:[SFPoint pointWithXValue:0 andYValue:5]];
    [ring addPoint:[SFPoint pointWithXValue:-10 andYValue:10]];
    [ring addPoint:[SFPoint pointWithXValue:-5 andYValue:0]];
    [ring addPoint:[SFPoint pointWithXValue:-10 andYValue:-10]];
    [polygon addRing:ring];
    
    GPKGGeometryData *geometryData = [GPKGGeometryData createWithSrsId:0 andGeometry:polygon];
    
    SFGeometryEnvelope *envelope = [SFGeometryEnvelope envelopeWithMinXValue:-5 andMinYValue:-5 andMaxXValue:5 andMaxYValue:5];
    
    [GPKGGeometryCrop cropGeometryData:geometryData withEnvelope:envelope inProjection:wgs84];
    
    double accuracy = 0.000000000000001;
    SFGeometryEnvelope *compareEnvelope = [SFGeometryEnvelope envelopeWithMinXValue:[envelope.minX doubleValue] - accuracy andMinYValue:[envelope.minY doubleValue] - accuracy andMaxXValue:[envelope.maxX doubleValue] + accuracy andMaxYValue:[envelope.maxY doubleValue] + accuracy];
    
    [GPKGTestUtils assertTrue:[compareEnvelope containsEnvelope:[geometryData.geometry envelope]]];
    
}

@end
