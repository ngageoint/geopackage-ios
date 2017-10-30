//
//  GPKGMapUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/14/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GPKGBoundingBox.h"
#import "GPKGLocationBoundingBox.h"
#import "GPKGMapPoint.h"

/**
 *  Map utility methods
 */
@interface GPKGMapUtils : NSObject

/**
 *  Get the current zoom level of the map view
 *
 *  @param mapView map view
 *
 *  @return current zoom level
 */
+(double) currentZoomWithMapView: (MKMapView *) mapView;

/**
 *  Get the tolerance distance meters in the current region of the map view
 *
 *  @param mapView map view
 *
 *  @return tolerance distance in meters
 */
+(double) toleranceDistanceInMapView: (MKMapView *) mapView;

/**
 *  Get the WGS84 bounding box of the current map view screen.
 *  The max longitude will be larger than the min resulting in it to be larger than 180.0
 *
 *  @param mapView map view
 *
 *  @return current bounding box
 */
+(GPKGBoundingBox *) boundingBoxOfMapView: (MKMapView *) mapView;

/**
 * Build a location bounding box using the click location, map view, and screen percentage tolerance.
 * The bounding box can be used to query for features that were clicked
 *
 * @param point                 click point
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return bounding box
 */
+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the map point click location and map view that can be used to query for features
 *
 *  @param mapPoint map point
 *  @param mapView  map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithMapPoint: (GPKGMapPoint *) mapPoint andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the mapkit map point click location and map view that can be used to query for features
 *
 *  @param mapPoint mapkit map point
 *  @param mapView  map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithMKMapPoint: (MKMapPoint) mapPoint andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the point click location and map view that can be used to query for features
 *
 *  @param point   point
 *  @param mapView map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithPoint: (WKBPoint *) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the location coordinate click location and map view that can be used to query for features
 *
 *  @param location location coordinate
 *  @param mapView  map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the cg point click location and map view that can be used to query for features
 *
 *  @param point   cg point
 *  @param mapView map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the location coordinate click location and map view bounds
 *
 *  @param location  location coordinate
 *  @param mapBounds map bounds
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andMapBounds: (GPKGBoundingBox *) mapBounds andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) getToleranceDistanceWithPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

@end
