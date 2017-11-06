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
#import "GPKGMapShape.h"
#import "GPKGMultiPoint.h"
#import "GPKGMultiPolyline.h"
#import "GPKGMultiPolygon.h"
#import "GPKGMapTolerance.h"

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
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithPoint: (WKBPoint *) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param location              click location
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithLocationCoordinate: (CLLocationCoordinate2D) location andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithPoint: (WKBPoint *) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param location              click location
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithLocationCoordinate: (CLLocationCoordinate2D) location andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance screen pixels
 */
+(double) toleranceScreenWithMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  If the polyline spans the -180 / 180 longitude, builds the complementary path.
 *  If points exist below 0, the path will have points above MKMapSizeWorld.width.
 *  If points exist above MKMapSizeWorld.width, the path will have points below 0.
 *  The returned path should be released.
 *
 *  @param polyline polyline
 *
 *  @return complementary path
 */
+(CGPathRef) complementaryWorldPathOfPolyline: (MKPolyline *) polyline;

/**
 *  If the polygon spans the -180 / 180 longitude, builds the complementary path.
 *  If points exist below 0, the path will have points above MKMapSizeWorld.width.
 *  If points exist above MKMapSizeWorld.width, the path will have points below 0.
 *  The returned path should be released.
 *
 *  @param polygon polygon
 *
 *  @return complementary path
 */
+(CGPathRef) complementaryWorldPathOfPolygon: (MKPolygon *) polygon;

/**
 *  If the multi point spans the -180 / 180 longitude, builds the complementary path.
 *  If points exist below 0, the path will have points above MKMapSizeWorld.width.
 *  If points exist above MKMapSizeWorld.width, the path will have points below 0.
 *  The returned path should be released.
 *
 *  @param multiPoint multi point
 *
 *  @return complementary path
 */
+(CGPathRef) complementaryWorldPathOfMultiPoint: (MKMultiPoint *) multiPoint;

/**
 *  If the points span the -180 / 180 longitude, builds the complementary path.
 *  If points exist below 0, the path will have points above MKMapSizeWorld.width.
 *  If points exist above MKMapSizeWorld.width, the path will have points below 0.
 *  The returned path should be released.
 *
 *  @param points points
 *  @param pointCount point count
 *
 *  @return complementary path
 */
+(CGPathRef) complementaryWorldPathOfPoints: (MKMapPoint *) points andPointCount: (NSUInteger) pointCount;

/**
 * Is the location on or near the shape
 *
 * @param location  location point
 * @param shape     map shape
 * @param tolerance distance and screen tolerance
 * @return true if location is on shape
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location onShape: (GPKGMapShape *) mapShape andTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location near the map point
 *
 * @param location  location point
 * @param mapPoint  map point
 * @param tolerance distance and screen tolerance
 * @return true if location is near map point
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location nearMapPoint: (GPKGMapPoint *) mapPoint withTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location near the other location
 *
 * @param location1  location point 1
 * @param location2  location point 2
 * @param tolerance distance and screen tolerance
 * @return true if location 1 is near location 2
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location1 nearLocation: (CLLocationCoordinate2D) location2 withTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location near the multi point
 *
 * @param location   location point
 * @param multiPoint multi point
 * @param tolerance  distance and screen tolerance
 * @return true if location is near multi point
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location nearMultiPoint: (GPKGMultiPoint *) multiPoint withTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location on the polyline
 *
 * @param location  location point
 * @param polyline  polyline
 * @param tolerance distance and screen tolerance
 * @return true if location is on polyline
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location onPolyline: (MKPolyline *) polyline andTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location on the multi polyline
 *
 * @param location      location point
 * @param multiPolyline multi polyline
 * @param tolerance     distance and screen tolerance
 * @return true if location is on multi polyline
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location onMultiPolyline: (GPKGMultiPolyline *) multiPolyline withTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location on the polygon
 *
 * @param location location point
 * @param polygon  polygon
 * @return true if location is on the polygon
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location onPolygon: (MKPolygon *) polygon;

/**
 * Is the location on the polygon
 *
 * @param location     location point
 * @param multiPolygon multi polygon
 * @return true if location is on the multi polygon
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location onMultiPolygon: (GPKGMultiPolygon *) multiPolygon;

@end
