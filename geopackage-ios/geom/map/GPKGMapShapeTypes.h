//
//  GPKGMapShapeTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

enum GPKGMapShapeType{
    GPKG_MST_POINT,
    GPKG_MST_POLYLINE,
    GPKG_MST_POLYGON,
    GPKG_MST_MULTI_POINT,
    GPKG_MST_MULTI_POLYLINE,
    GPKG_MST_MULTI_POLYGON,
    GPKG_MST_POLYLINE_POINTS,
    GPKG_MST_POLYGON_POINTS,
    GPKG_MST_MULTI_POLYLINE_POINTS,
    GPKG_MST_MULTI_POLYGON_POINTS,
    GPKG_MST_COLLECTION
};

extern NSString * const GPKG_MST_POINT_NAME;
extern NSString * const GPKG_MST_POLYLINE_NAME;
extern NSString * const GPKG_MST_POLYGON_NAME;
extern NSString * const GPKG_MST_MULTI_POINT_NAME;
extern NSString * const GPKG_MST_MULTI_POLYLINE_NAME;
extern NSString * const GPKG_MST_MULTI_POLYGON_NAME;
extern NSString * const GPKG_MST_POLYLINE_POINTS_NAME;
extern NSString * const GPKG_MST_POLYGON_POINTS_NAME;
extern NSString * const GPKG_MST_MULTI_POLYLINE_POINTS_NAME;
extern NSString * const GPKG_MST_MULTI_POLYGON_POINTS_NAME;
extern NSString * const GPKG_MST_COLLECTION_NAME;

@interface GPKGMapShapeTypes : NSObject

+(NSString *) name: (enum GPKGMapShapeType) shapeType;

+(enum GPKGMapShapeType) fromName: (NSString *) name;

@end
