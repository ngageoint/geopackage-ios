//
//  GPKGMapShapePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "GPKGMapShape.h"
#import "GPKGMapPoint.h"
#import "GPKGShapePoints.h"

/**
 *  Map Shape with map points and corresponding shape point objects
 */
@interface GPKGMapShapePoints : NSObject

/**
 *  Map shape
 */
@property (nonatomic, strong) GPKGMapShape *shape;

/**
 *  Mapping between point ids and shape points they belong to (or NSNull for non shapes)
 */
@property (nonatomic, strong) NSMutableDictionary *shapePoints;

/**
 *  Initialize
 *
 *  @return new map shape points
 */
-(instancetype) init;

/**
 *  Add the point to the shape
 *
 *  @param point       map point
 *  @param shapePoints shape points
 */
-(void) addPoint: (GPKGMapPoint *) point withShape: (NSObject<GPKGShapePoints> *) shapePoints;

/**
 *  Add the point id to the shape
 *
 *  @param pointId     map point id
 *  @param shapePoints shape points
 */
-(void) addPointId: (int) pointId withShape: (NSObject<GPKGShapePoints> *) shapePoints;

/**
 *  Add all map points in the shape
 *
 *  @param shapePoints shape points
 */
-(void) addShapePoints: (NSObject<GPKGShapePoints> *) shapePoints;

/**
 *  Add a map point with no shape
 *
 *  @param point map point
 */
-(void) addPoint: (GPKGMapPoint *) point;

/**
 *  Add an array of map points with no shape
 *
 *  @param points map points
 */
-(void) addPoints: (NSArray *) points;

/**
 *  Add an embedded map shape points
 *
 *  @param mapShapePoints map shape points
 */
-(void) addMapShapePoints: (GPKGMapShapePoints *) mapShapePoints;

/**
 *  Check if contains the shape point
 *
 *  @param point map point
 *
 *  @return true if contains point
 */
-(BOOL) containsPoint: (GPKGMapPoint *) point;

/**
 *  Check if contains the shape point id
 *
 *  @param pointId map point id
 *
 *  @return true if contains point id
 */
-(BOOL) containsPointId: (int) pointId;

/**
 *  Get the shape points for a map point, only returns a value for shapes that can be edited
 *
 *  @param point map point
 *
 *  @return shape points
 */
-(NSObject<GPKGShapePoints> *) getShapePointsForPoint: (GPKGMapPoint *) point;

/**
 *  Get the shape points for a map point id, only returns a value for shapes that can be edited
 *
 *  @param pointId map point id
 *
 *  @return shape points
 */
-(NSObject<GPKGShapePoints> *) getShapePointsForPointId: (int) pointId;

/**
 *  Delete the map point and corresponding shape from the map view
 *
 *  @param point   map point
 *  @param mapView map view
 *
 *  @return true if deleted
 */
-(BOOL) deletePoint: (GPKGMapPoint *) point fromMapView: (MKMapView *) mapView;

/**
 *  Removes all objects added to the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

/**
 *  Updates all objects on the map view that could have changed from moved points
 *
 *  @param mapView map view
 */
-(void) updateWithMapView: (MKMapView *) mapView;

/**
 *  Determines if the shape is in a valid state
 *
 *  @return true if valid
 */
-(BOOL) isValid;

/**
 *  Polygon add a map point to the points where it is closest to the surrounding points
 *
 *  @param point  map point
 *  @param points polygon points
 */
+(void) addPointAsPolygon: (GPKGMapPoint *) point toPoints: (NSMutableArray *) points;

/**
 *  Polyline add a map point to the points where it is closest to the surrounding points
 *
 *  @param point  map point
 *  @param points polyline points
 */
+(void) addPointAsPolyline: (GPKGMapPoint *) point toPoints: (NSMutableArray *) points;

@end
