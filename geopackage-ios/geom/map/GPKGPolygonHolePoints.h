//
//  GPKGPolygonHolePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGShapePoints.h"
#import "GPKGPolygonPoints.h"
@import MapKit;
#import "GPKGMapPoint.h"

@class GPKGPolygonPoints;

/**
 *  Polygon hole points shape
 */
@interface GPKGPolygonHolePoints : NSObject <GPKGShapePoints>

/**
 *  Parent polygon points
 */
@property (nonatomic, strong) GPKGPolygonPoints *parentPolygon;

/**
 *  Polygon hole points
 */
@property (nonatomic, strong) NSMutableArray *points;

/**
 *  Initialize
 *
 *  @param polygonPoints polygon points
 *
 *  @return new polygon hole points
 */
-(instancetype) initWithPolygonPoints: (GPKGPolygonPoints *) polygonPoints;

/**
 *  Add a hole point
 *
 *  @param point point
 */
-(void) addPoint: (GPKGMapPoint *) point;

/**
 *  Remove the polygon hole points from the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

/**
 *  Determine if the polygon hole points is valid
 *
 *  @return true if valid
 */
-(BOOL) isValid;

/**
 *  Determine if the polygon hole points has been deleted
 *
 *  @return true if deleted
 */
-(BOOL) isDeleted;

@end
