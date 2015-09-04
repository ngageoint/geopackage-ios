//
//  GPKGPolylinePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGShapePoints.h"
@import MapKit;
#import "GPKGMapPoint.h"

/**
 *  Polyline points shape
 */
@interface GPKGPolylinePoints : NSObject <GPKGShapePoints>

/**
 *  Backing polyline
 */
@property (nonatomic, strong) MKPolyline *polyline;

/**
 *  Polyline points
 */
@property (nonatomic, strong) NSMutableArray *points;

/**
 *  Initialize
 *
 *  @return new polyline points
 */
-(instancetype) init;

/**
 *  Add a point
 *
 *  @param point point
 */
-(void) addPoint: (GPKGMapPoint *) point;

/**
 *  Update the polyline points with the map view
 *
 *  @param mapView map view
 */
-(void) updateWithMapView: (MKMapView *) mapView;

/**
 *  Remove the polyline points from the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

/**
 *  Determine if the polyline points is valid
 *
 *  @return true if valid
 */
-(BOOL) isValid;

/**
 *  Determine if the polyline points has been deleted
 *
 *  @return true if deleted
 */
-(BOOL) isDeleted;

@end
