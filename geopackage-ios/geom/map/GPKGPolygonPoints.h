//
//  GPKGPolygonPoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGShapePoints.h"
#import "GPKGShapeWithChildrenPoints.h"
@import MapKit;
#import "GPKGPolygonHolePoints.h"
#import "GPKGMapPoint.h"

@class GPKGPolygonHolePoints;

/**
 *  Polygon points shape
 */
@interface GPKGPolygonPoints : NSObject <GPKGShapePoints, GPKGShapeWithChildrenPoints>

/**
 *  Backing polygon
 */
@property (nonatomic, strong) MKPolygon *polygon;

/**
 *  Polygon points
 */
@property (nonatomic, strong) NSMutableArray *points;

/**
 *  Polygon holes
 */
@property (nonatomic, strong) NSMutableArray *holes;

/**
 *  Initialize
 *
 *  @return new polygon points
 */
-(instancetype) init;

/**
 *  Add a point
 *
 *  @param point point
 */
-(void) addPoint: (GPKGMapPoint *) point;

/**
 *  Add a hole
 *
 *  @param hole polygon hole points
 */
-(void) addHole: (GPKGPolygonHolePoints *) hole;

/**
 *  Update the polygon points with the map view
 *
 *  @param mapView map view
 */
-(void) updateWithMapView: (MKMapView *) mapView;

/**
 *  Remove the polygon points from the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

/**
 *  Determine if the polygon points is valid
 *
 *  @return true if valid
 */
-(BOOL) isValid;

/**
 *  Determine if the polygon points has been deleted
 *
 *  @return true if deleted
 */
-(BOOL) isDeleted;

@end
