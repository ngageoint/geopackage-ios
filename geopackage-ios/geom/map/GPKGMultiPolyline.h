//
//  GPKGMultiPolyline.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

@import MapKit;

/**
 *  Multi polyline shape
 */
@interface GPKGMultiPolyline : NSObject

/**
 *  Polylines
 */
@property (nonatomic, strong) NSMutableArray *polylines;

/**
 *  Initialize
 *
 *  @return new multi polyline
 */
-(instancetype) init;

/**
 *  Add a polyline
 *
 *  @param polyline polyline
 */
-(void) addPolyline: (MKPolyline*) polyline;

/**
 *  Remove the multi polyline from the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

/**
 *  Updates hidden state on the map
 *
 *  @param hidden hidden flag
 *  @param mapView map view
 */
-(void) hidden: (BOOL) hidden fromMapView: (MKMapView *) mapView;

@end
