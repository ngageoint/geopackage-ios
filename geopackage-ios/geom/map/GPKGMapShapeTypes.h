//
//  GPKGMapShapeTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Enumeration of map shape types
 */
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

/**
 *  Map shape type names
 */
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

/**
 *  Get the name of the shape type
 *
 *  @param shapeType shape type
 *
 *  @return shape type name
 */
+(NSString *) name: (enum GPKGMapShapeType) shapeType;

/**
 *  Get the map shape type of the name
 *
 *  @param name shape type name
 *
 *  @return shape type
 */
+(enum GPKGMapShapeType) fromName: (NSString *) name;

@end
