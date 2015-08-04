//
//  GPKGMapShapeTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMapShapeTypes.h"
#import "GPKGUtils.h"

NSString * const GPKG_MST_POINT_NAME = @"POINT";
NSString * const GPKG_MST_POLYLINE_NAME = @"POLYLINE";
NSString * const GPKG_MST_POLYGON_NAME = @"POINT";
NSString * const GPKG_MST_MULTI_POINT_NAME = @"MULTI_POINT";
NSString * const GPKG_MST_MULTI_POLYLINE_NAME = @"MULTI_POLYLINE";
NSString * const GPKG_MST_MULTI_POLYGON_NAME = @"MULTI_POLYGON";
NSString * const GPKG_MST_POLYLINE_POINTS_NAME = @"POLYLINE_POINTS";
NSString * const GPKG_MST_POLYGON_POINTS_NAME = @"POLYGON_POINTS";
NSString * const GPKG_MST_MULTI_POLYLINE_POINTS_NAME = @"MULTI_POLYLINE_POINTS";
NSString * const GPKG_MST_MULTI_POLYGON_POINTS_NAME = @"MULTI_POLYGON_POINTS";
NSString * const GPKG_MST_COLLECTION_NAME = @"COLLECTION";

@implementation GPKGMapShapeTypes

+(NSString *) name: (enum GPKGMapShapeType) shapeType{
    NSString * name = nil;
    
    switch(shapeType){
        case GPKG_MST_POINT:
            name = GPKG_MST_POINT_NAME;
            break;
        case GPKG_MST_POLYLINE:
            name = GPKG_MST_POLYLINE_NAME;
            break;
        case GPKG_MST_POLYGON:
            name = GPKG_MST_POLYGON_NAME;
            break;
        case GPKG_MST_MULTI_POINT:
            name = GPKG_MST_MULTI_POINT_NAME;
            break;
        case GPKG_MST_MULTI_POLYLINE:
            name = GPKG_MST_MULTI_POLYLINE_NAME;
            break;
        case GPKG_MST_MULTI_POLYGON:
            name = GPKG_MST_MULTI_POLYGON_NAME;
            break;
        case GPKG_MST_POLYLINE_POINTS:
            name = GPKG_MST_POLYLINE_POINTS_NAME;
            break;
        case GPKG_MST_POLYGON_POINTS:
            name = GPKG_MST_POLYGON_POINTS_NAME;
            break;
        case GPKG_MST_MULTI_POLYLINE_POINTS:
            name = GPKG_MST_MULTI_POLYLINE_POINTS_NAME;
            break;
        case GPKG_MST_MULTI_POLYGON_POINTS:
            name = GPKG_MST_MULTI_POLYGON_POINTS_NAME;
            break;
        case GPKG_MST_COLLECTION:
            name = GPKG_MST_COLLECTION_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGMapShapeType) fromName: (NSString *) name{
    enum GPKGMapShapeType value = -1;
    
    if(name != nil){
        name = [name uppercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_MST_POINT], GPKG_MST_POINT_NAME,
                               [NSNumber numberWithInteger:GPKG_MST_POLYLINE], GPKG_MST_POLYLINE_NAME,
                               [NSNumber numberWithInteger:GPKG_MST_POLYGON], GPKG_MST_POLYGON_NAME,
                               [NSNumber numberWithInteger:GPKG_MST_MULTI_POINT], GPKG_MST_MULTI_POINT_NAME,
                               [NSNumber numberWithInteger:GPKG_MST_MULTI_POLYLINE], GPKG_MST_MULTI_POLYLINE_NAME,
                               [NSNumber numberWithInteger:GPKG_MST_MULTI_POLYGON], GPKG_MST_MULTI_POLYGON_NAME,
                               [NSNumber numberWithInteger:GPKG_MST_POLYLINE_POINTS], GPKG_MST_POLYLINE_POINTS_NAME,
                               [NSNumber numberWithInteger:GPKG_MST_POLYGON_POINTS], GPKG_MST_POLYGON_POINTS_NAME,
                               [NSNumber numberWithInteger:GPKG_MST_MULTI_POLYLINE_POINTS], GPKG_MST_MULTI_POLYLINE_POINTS_NAME,
                               [NSNumber numberWithInteger:GPKG_MST_MULTI_POLYGON_POINTS], GPKG_MST_MULTI_POLYGON_POINTS_NAME,
                               [NSNumber numberWithInteger:GPKG_MST_COLLECTION], GPKG_MST_COLLECTION_NAME,
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        value = (enum GPKGMapShapeType)[enumValue intValue];
    }
    
    return value;
}

@end
