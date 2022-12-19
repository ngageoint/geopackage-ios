//
//  GPKGMapUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/14/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGLocationBoundingBox.h"
#import "GPKGMapShape.h"
#import "GPKGMultiPoint.h"
#import "GPKGMultiPolyline.h"
#import "GPKGMultiPolygon.h"
#import "GPKGMapTolerance.h"
#import "GPKGPixelBounds.h"

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
 *  Get the current rounded zoom level of the map view
 *
 *  @param mapView map view
 *
 *  @return current zoom level
 */
+(int) currentRoundedZoomWithMapView: (MKMapView *) mapView;

/**
 *  Get the tolerance distance meters in the current region of the visible map view.
 *  Tolerance distance can be used for geometry simplification and is approximately the
 *  number of meters per view pixel.
 *
 *  @param mapView map view
 *
 *  @return tolerance distance in meters
 */
+(double) toleranceDistanceInMapView: (MKMapView *) mapView;

/**
 *  Get the tolerance distance meters in the current region of the visible map projected bounds.
 *  Tolerance distance can be used for geometry simplification and is approximately the
 *  number of meters per view pixel.
 *
 *  @param viewWidth view width
 *  @param viewHeight view height
 *  @param boundingBox bounding box
 *  @param projection bounding box projection
 *
 *  @return tolerance distance in meters
 */
+(double) toleranceDistanceWithWidth: (float) viewWidth andHeight: (float) viewHeight andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

/**
 *  Get the tolerance distance meters in the current region of the visible map bounds.
 *  Tolerance distance can be used for geometry simplification and is approximately the
 *  number of meters per view pixel.
 *
 *  @param viewWidth view width
 *  @param viewHeight view height
 *  @param boundingBox WGS84 bounding box
 *
 *  @return tolerance distance in meters
 */
+(double) toleranceDistanceWithWidth: (float) viewWidth andHeight: (float) viewHeight andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Get a WGS84 Bounding Box from a projected bounding box
 *
 * @param boundingBox bounding box
 * @param projection  bounding box projection
 * @return WGS84 bounding box
 */
+(GPKGBoundingBox *) wgs84BoundingBoxOfBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

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
 * @param mapView             map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return bounding box
 */
+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Build a location bounding box using the click location, pixel bounds, map view, and screen percentage tolerance.
 * The bounding box can be used to query for features that were clicked
 *
 * @param point                 click point
 * @param pixelBounds    click pixel bounds
 * @param mapView              map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return bounding box
 */
+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithCGPoint: (CGPoint) point andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Build a location bounding box using the click location, zoom level, pixel bounds, map view, and screen percentage tolerance.
 * The bounding box can be used to query for features that were clicked
 *
 * @param point                 click point
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView              map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return bounding box
 */
+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithCGPoint: (CGPoint) point andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Build a location bounding box using the click location, scale factor, zoom level, pixel bounds, map view, and screen percentage tolerance.
 * The bounding box can be used to query for features that were clicked
 *
 * @param point                 click point
 * @param scale                 scale factor
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView              map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return bounding box
 */
+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithCGPoint: (CGPoint) point andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Build a location bounding box using the click location, scale factor, zoom level, pixel bounds, map view, and screen percentage tolerance.
 * The bounding box can be used to query for features that were clicked
 *
 * @param location                 click location
 * @param mapView              map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return bounding box
 */
+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Build a location bounding box using the click location, scale factor, zoom level, pixel bounds, map view, and screen percentage tolerance.
 * The bounding box can be used to query for features that were clicked
 *
 * @param location                 click location
 * @param pixelBounds    click pixel bounds
 * @param mapView              map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return bounding box
 */
+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Build a location bounding box using the click location, scale factor, zoom level, pixel bounds, map view, and screen percentage tolerance.
 * The bounding box can be used to query for features that were clicked
 *
 * @param location                 click location
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView              map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return bounding box
 */
+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Build a location bounding box using the click location, scale factor, zoom level, pixel bounds, map view, and screen percentage tolerance.
 * The bounding box can be used to query for features that were clicked
 *
 * @param location                 click location
 * @param scale                 scale factor
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView              map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return bounding box
 */
+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

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
 *  Build a bounding box using the map point click location and map view that can be used to query for features
 *
 *  @param mapPoint map point
 *  @param pixelBounds    click pixel bounds
 *  @param mapView  map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithMapPoint: (GPKGMapPoint *) mapPoint andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the map point click location and map view that can be used to query for features
 *
 *  @param mapPoint map point
 *  @param zoom                   current zoom level
 *  @param pixelBounds    click pixel bounds
 *  @param mapView  map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithMapPoint: (GPKGMapPoint *) mapPoint andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the map point click location and map view that can be used to query for features
 *
 *  @param mapPoint map point
 *  @param scale                 scale factor
 *  @param zoom                   current zoom level
 *  @param pixelBounds    click pixel bounds
 *  @param mapView  map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithMapPoint: (GPKGMapPoint *) mapPoint andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

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
+(GPKGBoundingBox *) buildClickBoundingBoxWithPoint: (SFPoint *) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the point click location and map view that can be used to query for features
 *
 *  @param point   point
 *  @param pixelBounds    click pixel bounds
 *  @param mapView map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithPoint: (SFPoint *) point andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the point click location and map view that can be used to query for features
 *
 *  @param point   point
 *  @param zoom                   current zoom level
 *  @param pixelBounds    click pixel bounds
 *  @param mapView map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithPoint: (SFPoint *) point andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the point click location and map view that can be used to query for features
 *
 *  @param point   point
 *  @param scale                 scale factor
 *  @param zoom                   current zoom level
 *  @param pixelBounds    click pixel bounds
 *  @param mapView map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithPoint: (SFPoint *) point andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

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
 *  Build a bounding box using the location coordinate click location and map view that can be used to query for features
 *
 *  @param location location coordinate
 *  @param pixelBounds    click pixel bounds
 *  @param mapView  map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the location coordinate click location and map view that can be used to query for features
 *
 *  @param location location coordinate
 *  @param zoom                   current zoom level
 *  @param pixelBounds    click pixel bounds
 *  @param mapView  map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the location coordinate click location and map view that can be used to query for features
 *
 *  @param location location coordinate
 *  @param scale                 scale factor
 *  @param zoom                   current zoom level
 *  @param pixelBounds    click pixel bounds
 *  @param mapView  map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

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
 *  Build a bounding box using the cg point click location and map view that can be used to query for features
 *
 *  @param point   cg point
 *  @param pixelBounds    click pixel bounds
 *  @param mapView map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithCGPoint: (CGPoint) point andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the cg point click location and map view that can be used to query for features
 *
 *  @param point   cg point
 *  @param zoom                   current zoom level
 *  @param pixelBounds    click pixel bounds
 *  @param mapView map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithCGPoint: (CGPoint) point andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 *  Build a bounding box using the cg point click location and map view that can be used to query for features
 *
 *  @param point   cg point
 *  @param scale                 scale factor
 *  @param zoom                   current zoom level
 *  @param pixelBounds    click pixel bounds
 *  @param mapView map view
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithCGPoint: (CGPoint) point andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Build a bounding box using the click location
 *
 * @param locationBoundingBox click bounding box
 * @return bounding box
 */
+(GPKGBoundingBox *) buildClickBoundingBoxWithLocationBoundingBox: (GPKGLocationBoundingBox *) locationBoundingBox;

/**
 *  Build a location bounding box using the location coordinate click location and map view bounds
 *
 *  @param location  location coordinate
 *  @param mapBounds map bounds
 *  @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 *
 *  @return bounding box
 */
+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andMapBounds: (GPKGBoundingBox *) mapBounds andScreenPercentage: (float) screenClickPercentage;

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
+(GPKGMapTolerance *) toleranceWithPoint: (SFPoint *) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithPoint: (SFPoint *) point andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithPoint: (SFPoint *) point andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param scale                 scale factor
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithPoint: (SFPoint *) point andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

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
 * @param location              click location
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithLocationCoordinate: (CLLocationCoordinate2D) location andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param location              click location
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param location              click location
 * @param scale                 scale factor
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithLocationCoordinate: (CLLocationCoordinate2D) location andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param location              click location
 * @param boundingBox   click bounding box
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithLocationCoordinate: (CLLocationCoordinate2D) location andBoundingBox: (GPKGLocationBoundingBox *) boundingBox andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

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
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithCGPoint: (CGPoint) point andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithCGPoint: (CGPoint) point andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param scale                 scale factor
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithCGPoint: (CGPoint) point andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and screen pixels from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param boundingBox   click bounding box
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithCGPoint: (CGPoint) point andBoundingBox: (GPKGLocationBoundingBox *) boundingBox andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance meters and default screen pixels from the click bounding box
 *
 * @param location              click location
 * @param boundingBox click bounding box
 * @return tolerance distance in meters and screen pixels
 */
+(GPKGMapTolerance *) toleranceWithLocationCoordinate: (CLLocationCoordinate2D) location andBoundingBox: (GPKGLocationBoundingBox *) boundingBox;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithPoint: (SFPoint *) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithPoint: (SFPoint *) point andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithPoint: (SFPoint *) point andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param scale                 scale factor
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithPoint: (SFPoint *) point andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

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
 * @param location              click location
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithLocationCoordinate: (CLLocationCoordinate2D) location andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param location              click location
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param location              click location
 * @param scale                 scale factor
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithLocationCoordinate: (CLLocationCoordinate2D) location andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

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
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithCGPoint: (CGPoint) point andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithCGPoint: (CGPoint) point andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click location on the map view and map with the screen percentage tolerance.
 *
 * @param point                 click point
 * @param scale                 scale factor
 * @param zoom                   current zoom level
 * @param pixelBounds    click pixel bounds
 * @param mapView               map view
 * @param screenClickPercentage screen click percentage between 0.0 and 1.0 for how close a feature
 *                              on the screen must be to be included in a click query
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithCGPoint: (CGPoint) point andScale: (float) scale andZoom: (double) zoom andPixelBounds: (GPKGPixelBounds *) pixelBounds andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage;

/**
 * Get the allowable tolerance distance in meters from the click bounding box
 *
 * @param point                 click point
 * @param boundingBox click bounding box
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithCGPoint: (CGPoint) point andBoundingBox: (GPKGLocationBoundingBox *) boundingBox andMapView: (MKMapView *) mapView;

/**
 * Get the allowable tolerance distance in meters from the click bounding box
 *
 * @param location              click location
 * @param boundingBox click bounding box
 * @return tolerance distance in meters
 */
+(double) toleranceDistanceWithLocationCoordinate: (CLLocationCoordinate2D) location andBoundingBox: (GPKGLocationBoundingBox *) boundingBox;

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
 * @param mapShape  map shape
 * @param tolerance distance and screen tolerance
 * @return true if location is on shape
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location onShape: (GPKGMapShape *) mapShape withTolerance: (GPKGMapTolerance *) tolerance;

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
+(BOOL) isLocation: (CLLocationCoordinate2D) location onPolyline: (MKPolyline *) polyline withTolerance: (GPKGMapTolerance *) tolerance;

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
 * @param location  location point
 * @param polygon   polygon
 * @param tolerance distance and screen tolerance
 * @return true if location is on the polygon
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location onPolygon: (MKPolygon *) polygon withTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location on the polygon
 *
 * @param location     location point
 * @param multiPolygon multi polygon
 * @param tolerance    distance and screen tolerance
 * @return true if location is on the multi polygon
 */
+(BOOL) isLocation: (CLLocationCoordinate2D) location onMultiPolygon: (GPKGMultiPolygon *) multiPolygon withTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location on or near the shape, returning the distance when on the shape
 *
 * @param location  location point
 * @param mapShape  map shape
 * @param tolerance distance and screen tolerance
 * @return distance when on shape, -1.0 when distance not calculated, nil when not on shape
 */
+(NSDecimalNumber *) distanceIfLocation: (CLLocationCoordinate2D) location onShape: (GPKGMapShape *) mapShape withTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location near the map point, returning the distance when on point
 *
 * @param location  location point
 * @param mapPoint  map point
 * @param tolerance distance and screen tolerance
 * @return distance when on point, nil when not
 */
+(NSDecimalNumber *) distanceIfLocation: (CLLocationCoordinate2D) location nearMapPoint: (GPKGMapPoint *) mapPoint withTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location near the other location, returning the distance when on location
 *
 * @param location1  location point 1
 * @param location2  location point 2
 * @param tolerance distance and screen tolerance
 * @return distance when on location, nil when not
 */
+(NSDecimalNumber *) distanceIfLocation: (CLLocationCoordinate2D) location1 nearLocation: (CLLocationCoordinate2D) location2 withTolerance: (GPKGMapTolerance *) tolerance;

/**
 * Is the location near the multi point, returning the nearest distance when on multi point
 *
 * @param location   location point
 * @param multiPoint multi point
 * @param tolerance  distance and screen tolerance
 * @return distance when on multi point, nil when not
 */
+(NSDecimalNumber *) distanceIfLocation: (CLLocationCoordinate2D) location nearMultiPoint: (GPKGMultiPoint *) multiPoint withTolerance: (GPKGMapTolerance *) tolerance;

@end
