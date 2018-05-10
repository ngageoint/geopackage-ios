//
//  GPKGGeometryJSONCompatible.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/10/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGGeometryJSONCompatible.h"
#import "SFGeometry.h"
#import "SFPoint.h"
#import "SFLineString.h"
#import "SFPolygon.h"
#import "SFMultiPoint.h"
#import "SFMultiLineString.h"
#import "SFMultiPolygon.h"
#import "SFGeometryCollection.h"
#import "SFCircularString.h"
#import "SFCompoundCurve.h"
#import "SFCurvePolygon.h"
#import "SFPolyhedralSurface.h"
#import "SFTIN.h"
#import "SFTriangle.h"

@implementation GPKGGeometryJSONCompatible

+(NSObject *) jsonCompatibleGeometry: (SFGeometry *) geometry{
    
    NSMutableDictionary * jsonObject = [[NSMutableDictionary alloc] init];
    
    NSObject * geometryObject = [self jsonCompatibleGeometryObject:geometry];
    
    if(geometryObject != nil){
        [jsonObject setObject:geometryObject forKey:[SFGeometryTypes name:geometry.geometryType]];
    }
    
    return jsonObject;
}

+(NSObject *) jsonCompatibleGeometryObject: (SFGeometry *) geometry{
    
    NSObject * geometryObject = nil;
    
    enum SFGeometryType geometryType = geometry.geometryType;
    switch (geometryType) {
        case SF_POINT:
            geometryObject = [self getPoint:(SFPoint *)geometry];
            break;
        case SF_LINESTRING:
            geometryObject = [self getLineString:(SFLineString *)geometry];
            break;
        case SF_POLYGON:
            geometryObject = [self getPolygon:(SFPolygon *)geometry];
            break;
        case SF_MULTIPOINT:
            geometryObject = [self getMultiPoint:(SFMultiPoint *)geometry];
            break;
        case SF_MULTILINESTRING:
            geometryObject = [self getMultiLineString:(SFMultiLineString *)geometry];
            break;
        case SF_MULTIPOLYGON:
            geometryObject = [self getMultiPolygon:(SFMultiPolygon *)geometry];
            break;
        case SF_CIRCULARSTRING:
            geometryObject = [self getLineString:(SFCircularString *)geometry];
            break;
        case SF_COMPOUNDCURVE:
            geometryObject = [self getCompoundCurve:(SFCompoundCurve *)geometry];
            break;
        case SF_CURVEPOLYGON:
            geometryObject = [self getCurvePolygon:(SFCurvePolygon *)geometry];
            break;
        case SF_POLYHEDRALSURFACE:
            geometryObject = [self getPolyhedralSurface:(SFPolyhedralSurface *)geometry];
            break;
        case SF_TIN:
            geometryObject = [self getPolyhedralSurface:(SFTIN *)geometry];
            break;
        case SF_TRIANGLE:
            geometryObject = [self getPolygon:(SFTriangle *)geometry];
            break;
        case SF_GEOMETRYCOLLECTION:
        {
            NSMutableArray * jsonGeoCollectionObject = [[NSMutableArray alloc] init];
            SFGeometryCollection * geomCollection = (SFGeometryCollection *) geometry;
            NSArray * geometries = geomCollection.geometries;
            for(int i = 0; i < geometries.count; i++){
                SFGeometry * subGeometry = [geometries objectAtIndex:i];
                [jsonGeoCollectionObject addObject:[self jsonCompatibleGeometry:subGeometry]];
            }
            geometryObject = jsonGeoCollectionObject;
        }
            break;
        default:
            break;
    }
    
    return geometryObject;
}

+(NSObject *) getPoint: (SFPoint *) point{
    NSMutableDictionary * jsonObject = [[NSMutableDictionary alloc] init];
    [jsonObject setObject:point.x forKey:@"x"];
    [jsonObject setObject:point.y forKey:@"y"];
    if([point hasZ]){
        [jsonObject setObject:point.z forKey:@"z"];
    }
    if([point hasM]){
        [jsonObject setObject:point.m forKey:@"m"];
    }
    return jsonObject;
}

+(NSObject *) getMultiPoint: (SFMultiPoint *) multiPoint{
    NSMutableArray * jsonObject = [[NSMutableArray alloc] init];
    NSArray * points = [multiPoint points];
    for(int i = 0; i < points.count; i++){
        SFPoint * point = [points objectAtIndex:i];
        [jsonObject addObject:[self getPoint:point]];
    }
    return jsonObject;
}

+(NSObject *) getLineString: (SFLineString *) lineString{
    NSMutableArray * jsonObject = [[NSMutableArray alloc] init];
    for(SFPoint * point in lineString.points){
        [jsonObject addObject:[self getPoint:point]];
    }
    return jsonObject;
}

+(NSObject *) getMultiLineString: (SFMultiLineString *) multiLineString{
    NSMutableArray * jsonObject = [[NSMutableArray alloc] init];
    NSArray * lineStrings = [multiLineString lineStrings];
    for(int i = 0; i < lineStrings.count; i++){
        SFLineString * lineString = [lineStrings objectAtIndex:i];
        [jsonObject addObject:[self getLineString:lineString]];
    }
    return jsonObject;
}

+(NSObject *) getPolygon: (SFPolygon *) polygon{
    NSMutableArray * jsonObject = [[NSMutableArray alloc] init];
    for(int i = 0; i < polygon.rings.count; i++){
        SFLineString * ring = [polygon.lineStrings objectAtIndex:i];
        [jsonObject addObject:[self getLineString:ring]];
    }
    return jsonObject;
}

+(NSObject *) getMultiPolygon: (SFMultiPolygon *) multiPolygon{
    NSMutableArray * jsonObject = [[NSMutableArray alloc] init];
    NSArray * polygons = [multiPolygon polygons];
    for(int i = 0; i < polygons.count; i++){
        SFPolygon * polygon = [polygons objectAtIndex:i];
        [jsonObject addObject:[self getPolygon:polygon]];
    }
    return jsonObject;
}

+(NSObject *) getCompoundCurve: (SFCompoundCurve *) compoundCurve{
    NSMutableArray * jsonObject = [[NSMutableArray alloc] init];
    for(int i = 0; i < compoundCurve.lineStrings.count; i++){
        SFLineString * lineString = [compoundCurve.lineStrings objectAtIndex:i];
        [jsonObject addObject:[self getLineString:lineString]];
    }
    return jsonObject;
}

+(NSObject *) getCurvePolygon: (SFCurvePolygon *) curvePolygon{
    NSMutableArray * jsonObject = [[NSMutableArray alloc] init];
    for(int i = 0; i < curvePolygon.rings.count; i++){
        SFCurve * ring = [curvePolygon.rings objectAtIndex:i];
        [jsonObject addObject:[self jsonCompatibleGeometryObject:ring]];
    }
    return jsonObject;
}

+(NSObject *) getPolyhedralSurface: (SFPolyhedralSurface *) polyhedralSurface{
    NSMutableArray * jsonObject = [[NSMutableArray alloc] init];
    for(int i = 0; i < polyhedralSurface.polygons.count; i++){
        SFPolygon * polygon = [polyhedralSurface.polygons objectAtIndex:i];
        [jsonObject addObject:[self getPolygon:polygon]];
    }
    return jsonObject;
}

@end
