//
//  GPKGMultiPolylinePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGPolylinePoints.h"

@class GPKGPolylinePoints;

/**
 *  Multiple Polyline Points shape
 */
@interface GPKGMultiPolylinePoints : NSObject

/**
 *  Polyline points
 */
@property (nonatomic, strong) NSMutableArray *polylinePoints;

/**
 *  Initialize
 *
 *  @return new multiple polyline points
 */
-(instancetype) init;

/**
 *  Add a polyline points shape
 *
 *  @param polylinePoints polyline points
 */
-(void) addPolylinePoints: (GPKGPolylinePoints *) polylinePoints;

/**
 *  Update the multiple polyline points with the map view
 *
 *  @param mapView map view
 */
-(void) updateWithMapView: (MKMapView *) mapView;

/**
 *  Remove the multiple polyline points from the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

/**
 *  Determine if the multiple polyline points is valid
 *
 *  @return true if valid
 */
-(BOOL) isValid;

/**
 *  Determine if the multiple polyline points has been deleted
 *
 *  @return true if deleted
 */
-(BOOL) isDeleted;

@end
