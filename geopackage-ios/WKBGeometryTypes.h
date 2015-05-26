//
//  WKBGeometryTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

enum WKBGeometryType{
    WKB_GEOMETRY = 0,
    WKB_POINT,
    WKB_LINESTRING,
    WKB_POLYGON,
    WKB_MULTIPOINT,
    WKB_MULTILINESTRING,
    WKB_MULTIPOLYGON,
    WKB_GEOMETRYCOLLECTION,
    WKB_CIRCULARSTRING,
    WKB_COMPOUNDCURVE,
    WKB_CURVEPOLYGON,
    WKB_MULTICURVE,
    WKB_MULTISURFACE,
    WKB_CURVE,
    WKB_SURFACE,
    WKB_POLYHEDRALSURFACE,
    WKB_TIN,
    WKB_TRIANGLE,
    WKB_NONE
};

extern NSString * const WKB_GEOMETRY_NAME;
extern NSString * const WKB_POINT_NAME;
extern NSString * const WKB_LINESTRING_NAME;
extern NSString * const WKB_POLYGON_NAME;
extern NSString * const WKB_MULTIPOINT_NAME;
extern NSString * const WKB_MULTILINESTRING_NAME;
extern NSString * const WKB_MULTIPOLYGON_NAME;
extern NSString * const WKB_GEOMETRYCOLLECTION_NAME;
extern NSString * const WKB_CIRCULARSTRING_NAME;
extern NSString * const WKB_COMPOUNDCURVE_NAME;
extern NSString * const WKB_CURVEPOLYGON_NAME;
extern NSString * const WKB_MULTICURVE_NAME;
extern NSString * const WKB_MULTISURFACE_NAME;
extern NSString * const WKB_CURVE_NAME;
extern NSString * const WKB_SURFACE_NAME;
extern NSString * const WKB_POLYHEDRALSURFACE_NAME;
extern NSString * const WKB_TIN_NAME;
extern NSString * const WKB_TRIANGLE_NAME;
extern NSString * const WKB_NONE_NAME;

@interface WKBGeometryTypes : NSObject

+(NSString *) name: (enum WKBGeometryType) geometryType;

+(enum WKBGeometryType) fromName: (NSString *) name;

+(int) code: (enum WKBGeometryType) geometryType;

@end
