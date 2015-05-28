//
//  WKBGeometryTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "WKBGeometryTypes.h"

NSString * const WKB_GEOMETRY_NAME = @"GEOMETRY";
NSString * const WKB_POINT_NAME = @"POINT";
NSString * const WKB_LINESTRING_NAME = @"LINESTRING";
NSString * const WKB_POLYGON_NAME = @"POLYGON";
NSString * const WKB_MULTIPOINT_NAME = @"MULTIPOINT";
NSString * const WKB_MULTILINESTRING_NAME = @"MULTILINESTRING";
NSString * const WKB_MULTIPOLYGON_NAME = @"MULTIPOLYGON";
NSString * const WKB_GEOMETRYCOLLECTION_NAME = @"GEOMETRYCOLLECTION";
NSString * const WKB_CIRCULARSTRING_NAME = @"CIRCULARSTRING";
NSString * const WKB_COMPOUNDCURVE_NAME = @"COMPOUNDCURVE";
NSString * const WKB_CURVEPOLYGON_NAME = @"CURVEPOLYGON";
NSString * const WKB_MULTICURVE_NAME = @"MULTICURVE";
NSString * const WKB_MULTISURFACE_NAME = @"MULTISURFACE";
NSString * const WKB_CURVE_NAME = @"CURVE";
NSString * const WKB_SURFACE_NAME = @"SURFACE";
NSString * const WKB_POLYHEDRALSURFACE_NAME = @"POLYHEDRALSURFACE";
NSString * const WKB_TIN_NAME = @"TIN";
NSString * const WKB_TRIANGLE_NAME = @"TRIANGLE";
NSString * const WKB_NONE_NAME = @"NONE";

@implementation WKBGeometryTypes

+(NSString *) name: (enum WKBGeometryType) geometryType{
    NSString * name = nil;
    
    switch(geometryType){
        case WKB_GEOMETRY:
            name = WKB_GEOMETRY_NAME;
            break;
        case WKB_POINT:
            name = WKB_POINT_NAME;
            break;
        case WKB_LINESTRING:
            name = WKB_LINESTRING_NAME;
            break;
        case WKB_POLYGON:
            name = WKB_POLYGON_NAME;
            break;
        case WKB_MULTIPOINT:
            name = WKB_MULTIPOINT_NAME;
            break;
        case WKB_MULTILINESTRING:
            name = WKB_MULTILINESTRING_NAME;
            break;
        case WKB_MULTIPOLYGON:
            name = WKB_MULTIPOLYGON_NAME;
            break;
        case WKB_GEOMETRYCOLLECTION:
            name = WKB_GEOMETRYCOLLECTION_NAME;
            break;
        case WKB_CIRCULARSTRING:
            name = WKB_CIRCULARSTRING_NAME;
            break;
        case WKB_COMPOUNDCURVE:
            name = WKB_COMPOUNDCURVE_NAME;
            break;
        case WKB_CURVEPOLYGON:
            name = WKB_CURVEPOLYGON_NAME;
            break;
        case WKB_MULTICURVE:
            name = WKB_MULTICURVE_NAME;
            break;
        case WKB_MULTISURFACE:
            name = WKB_MULTISURFACE_NAME;
            break;
        case WKB_CURVE:
            name = WKB_CURVE_NAME;
            break;
        case WKB_SURFACE:
            name = WKB_SURFACE_NAME;
            break;
        case WKB_POLYHEDRALSURFACE:
            name = WKB_POLYHEDRALSURFACE_NAME;
            break;
        case WKB_TIN:
            name = WKB_TIN_NAME;
            break;
        case WKB_TRIANGLE:
            name = WKB_TRIANGLE_NAME;
            break;
        case WKB_NONE:
            name = WKB_NONE_NAME;
            break;
    }
    
  return name;
}

+(enum WKBGeometryType) fromName: (NSString *) name{
    enum WKBGeometryType value = WKB_NONE;
    
    if(name != nil){
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:WKB_GEOMETRY], WKB_GEOMETRY_NAME,
                                    [NSNumber numberWithInteger:WKB_POINT], WKB_POINT_NAME,
                                    [NSNumber numberWithInteger:WKB_LINESTRING], WKB_LINESTRING_NAME,
                                    [NSNumber numberWithInteger:WKB_POLYGON], WKB_POLYGON_NAME,
                                    [NSNumber numberWithInteger:WKB_MULTIPOINT], WKB_MULTIPOINT_NAME,
                                    [NSNumber numberWithInteger:WKB_MULTILINESTRING], WKB_MULTILINESTRING_NAME,
                                    [NSNumber numberWithInteger:WKB_MULTIPOLYGON], WKB_MULTIPOLYGON_NAME,
                                    [NSNumber numberWithInteger:WKB_GEOMETRYCOLLECTION], WKB_GEOMETRYCOLLECTION_NAME,
                                    [NSNumber numberWithInteger:WKB_CIRCULARSTRING], WKB_CIRCULARSTRING_NAME,
                                    [NSNumber numberWithInteger:WKB_COMPOUNDCURVE], WKB_COMPOUNDCURVE_NAME,
                                    [NSNumber numberWithInteger:WKB_CURVEPOLYGON], WKB_CURVEPOLYGON_NAME,
                                    [NSNumber numberWithInteger:WKB_MULTICURVE], WKB_MULTICURVE_NAME,
                                    [NSNumber numberWithInteger:WKB_MULTISURFACE], WKB_MULTISURFACE_NAME,
                                    [NSNumber numberWithInteger:WKB_CURVE], WKB_CURVE_NAME,
                                    [NSNumber numberWithInteger:WKB_SURFACE], WKB_SURFACE_NAME,
                                    [NSNumber numberWithInteger:WKB_POLYHEDRALSURFACE], WKB_POLYHEDRALSURFACE_NAME,
                                    [NSNumber numberWithInteger:WKB_TIN], WKB_TIN_NAME,
                                    [NSNumber numberWithInteger:WKB_TRIANGLE], WKB_TRIANGLE_NAME,
                                    [NSNumber numberWithInteger:WKB_NONE], WKB_NONE_NAME,
                                    nil
                                    ];
        NSNumber *enumValue = [types objectForKey:name];
        value = (enum WKBGeometryType)[enumValue intValue];
    }
    
    return value;
}

+(int) code: (enum WKBGeometryType) geometryType{
    return (int) geometryType;
}

@end
