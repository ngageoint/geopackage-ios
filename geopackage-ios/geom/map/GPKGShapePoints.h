//
//  GPKGShapePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#ifndef geopackage_ios_GPKGShapePoints_h
#define geopackage_ios_GPKGShapePoints_h

@import MapKit;
#import "GPKGMapPoint.h"

/**
 *  Shape points protocol, defining the interface for shapes comprised of points
 */
@protocol GPKGShapePoints <NSObject>

/**
 *  Get the points
 *
 *  @return points
 */
-(NSArray *) getPoints;

/**
 *  Delete the point from the shape and map view
 *
 *  @param point   point
 *  @param mapView map view
 */
-(void) deletePoint: (GPKGMapPoint *) point fromMapView: (MKMapView * ) mapView;

/**
 *  Add a new point to the shape
 *
 *  @param point point
 */
-(void) addNewPoint: (GPKGMapPoint *) point;

@end

#endif