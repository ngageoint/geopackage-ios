//
//  GPKGMapShapeConverter.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "GPKGProjection.h"
#import "WKBPoint.h"
#import "GPKGMapPoint.h"
#import "WKBLineString.h"
#import "WKBCircularString.h"
#import "WKBPolygon.h"
#import "GPKGMultiPoint.h"
#import "WKBMultiPoint.h"
#import "GPKGMultiPolyline.h"
#import "WKBMultiLineString.h"
#import "WKBCompoundCurve.h"
#import "GPKGMultiPolygon.h"
#import "WKBMultiPolygon.h"
#import "WKBPolyhedralSurface.h"
#import "GPKGMapShape.h"
#import "WKBGeometry.h"
#import "GPKGMapShapePoints.h"
#import "GPKGPolylinePoints.h"
#import "GPKGPolygonPoints.h"
#import "GPKGMultiPolylinePoints.h"
#import "WKBTIN.h"
#import "WKBTriangle.h"
#import "GPKGMultiPolygonPoints.h"

@class GPKGPolylinePoints;
@class GPKGPolygonPoints;
@class GPKGMultiPolylinePoints;
@class GPKGMultiPolygonPoints;

/**
 *  Provides conversion methods between Well-Known Binary geometry objects and Map shapes. Includes adding shapes to map view functionality.
 */
@interface GPKGMapShapeConverter : NSObject

/**
 *  Geometry shape projection
 */
@property (nonatomic, strong) GPKGProjection *projection;

/**
 *  Initialize
 *
 *  @param projection projection
 *
 *  @return new map shape converter
 */
-(instancetype) initWithProjection: (GPKGProjection *) projection;

/**
 *  Transform a projection WKB point to WGS84
 *
 *  @param point projection point
 *
 *  @return wgs84 point
 */
-(WKBPoint *) toWgs84WithPoint: (WKBPoint *) point;

/**
 *  Transform a WGS84 WKB point to the projection
 *
 *  @param point wgs84 point
 *
 *  @return projection point
 */
-(WKBPoint *) toProjectionWithPoint: (WKBPoint *) point;

/**
 *  Convert a WKB point to a map point
 *
 *  @param point wkb point
 *
 *  @return map point
 */
-(GPKGMapPoint *) toMapPointWithPoint: (WKBPoint *) point;

/**
 *  Convert a WKB point to a MapKit map point
 *
 *  @param point wkb point
 *
 *  @return MK map point
 */
-(MKMapPoint) toMKMapPointWithPoint: (WKBPoint *) point;

/**
 *  Convert a map point to a WKB point
 *
 *  @param mapPoint map point
 *
 *  @return wkb point
 */
-(WKBPoint *) toPointWithMapPoint: (GPKGMapPoint *) mapPoint;

/**
 *  Convert a map point to a WKB point
 *
 *  @param mapPoint map point
 *  @param hasZ     haz z value
 *  @param hasM     has m value
 *
 *  @return wkb point
 */
-(WKBPoint *) toPointWithMapPoint: (GPKGMapPoint *) mapPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert a MapKit map point to a WKB point
 *
 *  @param mapPoint MK map point
 *
 *  @return wkb point
 */
-(WKBPoint *) toPointWithMKMapPoint: (MKMapPoint) mapPoint;

/**
 *  Convert a MapKit map point to a WKB point
 *
 *  @param mapPoint MK map point
 *  @param hasZ     haz z value
 *  @param hasM     has m value
 *
 *  @return wkb point
 */
-(WKBPoint *) toPointWithMKMapPoint: (MKMapPoint) mapPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert a WKB line string to a polyline
 *
 *  @param lineString wkb line string
 *
 *  @return polyline
 */
-(MKPolyline *) toMapPolylineWithLineString: (WKBLineString *) lineString;

/**
 *  Convert a MapKit polyline to a WKB line string
 *
 *  @param mapPolyline polyline
 *
 *  @return wkb line string
 */
-(WKBLineString *) toLineStringWithMapPolyline: (MKPolyline *) mapPolyline;

/**
 *  Convert a MapKit polyline to a WKB line string
 *
 *  @param mapPolyline polyline
 *  @param hasZ        haz z value
 *  @param hasM        has m value
 *
 *  @return wkb line string
 */
-(WKBLineString *) toLineStringWithMapPolyline: (MKPolyline *) mapPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert a pointer array of MapKit map points to a WKB line string
 *
 *  @param mapPoints  MK map points pointer
 *  @param pointCount number of points at pointer
 *
 *  @return wkb line string
 */
-(WKBLineString *) toLineStringWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount;

/**
 *  Convert a pointer array of MapKit map points to a WKB line string
 *
 *  @param mapPoints  MK map points pointer
 *  @param pointCount number of points at pointer
 *  @param hasZ       haz z value
 *  @param hasM       has m value
 *
 *  @return wkb line string
 */
-(WKBLineString *) toLineStringWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert an array of map points to a WKB line string
 *
 *  @param mapPoints map points
 *
 *  @return wkb line string
 */
-(WKBLineString *) toLineStringWithMapPoints: (NSArray *) mapPoints;

/**
 *  Convert an array of map points to a WKB line string
 *
 *  @param mapPoints map points
 *  @param hasZ      haz z value
 *  @param hasM      has m value
 *
 *  @return wkb line string
 */
-(WKBLineString *) toLineStringWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert an array of map points to a WKB circular string
 *
 *  @param mapPoints map points
 *
 *  @return wkb circular string
 */
-(WKBCircularString *) toCircularStringWithMapPoints: (NSArray *) mapPoints;

/**
 *  Convert an array of map points to a WKB circular string
 *
 *  @param mapPoints map points
 *  @param hasZ      haz z value
 *  @param hasM      has m value
 *
 *  @return wkb circular string
 */
-(WKBCircularString *) toCircularStringWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Populate a WKB line string with MapKit map points from a pointer array
 *
 *  @param lineString wkb line string
 *  @param mapPoints  MK map points pointer
 *  @param pointCount number of points at pointer
 */
-(void) populateLineString: (WKBLineString *) lineString withMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount;

/**
 *  Populate a WKB line string with an array of map points
 *
 *  @param lineString wkb line string
 *  @param mapPoints  map points
 */
-(void) populateLineString: (WKBLineString *) lineString withMapPoints: (NSArray *) mapPoints;

/**
 *  Convert WKB polygon to a MapKit polygon
 *
 *  @param polygon wkb polygon
 *
 *  @return MK polygon
 */
-(MKPolygon *) toMapPolygonWithPolygon: (WKBPolygon *) polygon;

/**
 *  Convert a MapKit polygon to a WKB polygon
 *
 *  @param mapPolygon MK polygon
 *
 *  @return WKB polygon
 */
-(WKBPolygon *) toPolygonWithMapPolygon: (MKPolygon *) mapPolygon;

/**
 *  Convert a MapKit polygon to a WKB polygon
 *
 *  @param mapPolygon MK polygon
 *  @param hasZ       has z value
 *  @param hasM       has m value
 *
 *  @return WKB polygon
 */
-(WKBPolygon *) toPolygonWithMapPolygon: (MKPolygon *) mapPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert a pointer array of MapKit map points and MapKit polygon holes to a WKB polygon
 *
 *  @param mapPoints  MK map points pointer
 *  @param pointCount number of points at pointer
 *  @param holes      MK polygon holes
 *
 *  @return WKB polygon
 */
-(WKBPolygon *) toPolygonWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHolePolygons: (NSArray *) holes;

/**
 *  Convert a pointer array of MapKit map points and MapKit polygon holes to a WKB polygon
 *
 *  @param mapPoints  MK map points pointer
 *  @param pointCount number of points at pointer
 *  @param holes      MK polygon holes
 *  @param hasZ       has z value
 *  @param hasM       has m value
 *
 *  @return WKB polygon
 */
-(WKBPolygon *) toPolygonWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHolePolygons: (NSArray *) holes andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert an array of map points and array of hole map point arrays to a WKB polygon
 *
 *  @param mapPoints map points
 *  @param holes     array of hole map points arrays
 *
 *  @return WKB polygon
 */
-(WKBPolygon *) toPolygonWithMapPoints: (NSArray *) mapPoints andHolePoints: (NSArray *) holes;

/**
 *  Convert an array of map points and array of hole map point arrays to a WKB polygon
 *
 *  @param mapPoints map points
 *  @param holes     array of hole map points arrays
 *  @param hasZ      has z value
 *  @param hasM      has m value
 *
 *  @return WKB polygon
 */
-(WKBPolygon *) toPolygonWithMapPoints: (NSArray *) mapPoints andHolePoints: (NSArray *) holes andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert WKB multi point to multi point
 *
 *  @param multiPoint wkb multi point
 *
 *  @return multi point
 */
-(GPKGMultiPoint *) toMapMultiPointWithMultiPoint: (WKBMultiPoint *) multiPoint;

/**
 *  Convert multi point to WKB multi point
 *
 *  @param mapMultiPoint multi point
 *
 *  @return wkb multi point
 */
-(WKBMultiPoint *) toMultiPointWithMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint;

/**
 *  Convert multi point to WKB multi point
 *
 *  @param mapMultiPoint multi point
 *  @param hasZ          has z value
 *  @param hasM          has m value
 *
 *  @return wkb multi point
 */
-(WKBMultiPoint *) toMultiPointWithMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert map points to WKB multi point
 *
 *  @param mapPoints map points
 *
 *  @return wkb multi point
 */
-(WKBMultiPoint *) toMultiPointWithMapPoints: (NSArray *) mapPoints;

/**
 *  Convert map points to WKB multi point
 *
 *  @param mapPoints map points
 *  @param hasZ      has z value
 *  @param hasM      has m value
 *
 *  @return wkb multi point
 */
-(WKBMultiPoint *) toMultiPointWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert WKB multi line string to multi polyline
 *
 *  @param multiLineString wkb multi line string
 *
 *  @return multi polyline
 */
-(GPKGMultiPolyline *) toMapMultiPolylineWithMultiLineString: (WKBMultiLineString *) multiLineString;

/**
 *  Convert polylines to WKB multi line string
 *
 *  @param mapPolylines polylines
 *
 *  @return wkb multi line string
 */
-(WKBMultiLineString *) toMultiLineStringWithMapPolylines: (NSArray *) mapPolylines;

/**
 *  Convert polylines to WKB multi line string
 *
 *  @param mapPolylines polylines
 *  @param hasZ         has z value
 *  @param hasM         has m value
 *
 *  @return wkb multi line string
 */
-(WKBMultiLineString *) toMultiLineStringWithMapPolylines: (NSArray *) mapPolylines andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert polyline point arrays to WKB multi line string
 *
 *  @param mapPolylinesArray polyline point arrays
 *
 *  @return wkb multi line string
 */
-(WKBMultiLineString *) toMultiLineStringWithMapPolylinesArray: (NSArray *) mapPolylinesArray;

/**
 *  Convert polyline point arrays to WKB multi line string
 *
 *  @param mapPolylinesArray polyline point arrays
 *  @param hasZ              has z value
 *  @param hasM              has m value
 *
 *  @return wkb multi line string
 */
-(WKBMultiLineString *) toMultiLineStringWithMapPolylinesArray: (NSArray *) mapPolylinesArray andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert polyline point arrays to WKB compound curve
 *
 *  @param mapPolylinesArray polyline point arrays
 *
 *  @return wkb compound curve
 */
-(WKBCompoundCurve *) toCompoundCurveWithMapPolylinesArray: (NSArray *) mapPolylinesArray;

/**
 *  Convert polyline point arrays to WKB compound curve
 *
 *  @param mapPolylinesArray polyline point arrays
 *  @param hasZ              has z value
 *  @param hasM              has m value
 *
 *  @return wkb compound curve
 */
-(WKBCompoundCurve *) toCompoundCurveWithMapPolylinesArray: (NSArray *) mapPolylinesArray andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert multi polyline to WKB multi line string
 *
 *  @param multiPolyline multi polyline
 *
 *  @return wkb multi line string
 */
-(WKBMultiLineString *) toMultiLineStringWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline;

/**
 *  Convert multi polyline to WKB multi line string
 *
 *  @param multiPolyline multi polyline
 *  @param hasZ          has z value
 *  @param hasM          has m value
 *
 *  @return wkb multi line string
 */
-(WKBMultiLineString *) toMultiLineStringWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert multi polyline to WKB compound curve
 *
 *  @param multiPolyline multi polyline
 *
 *  @return wkb compound curve
 */
-(WKBCompoundCurve *) toCompoundCurveWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline;

/**
 *  Convert multi polyline to WKB compound curve
 *
 *  @param multiPolyline multi polyline
 *  @param hasZ          has z value
 *  @param hasM          has m value
 *
 *  @return wkb compound curve
 */
-(WKBCompoundCurve *) toCompoundCurveWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert WKB multi polygon to multi polygon
 *
 *  @param multiPolygon wkb multi polygon
 *
 *  @return multi polygon
 */
-(GPKGMultiPolygon *) toMapMultiPolygonWithMultiPolygon: (WKBMultiPolygon *) multiPolygon;

/**
 *  Convert polygons to WKB multi polygon
 *
 *  @param mapPolygons polygons
 *
 *  @return wkb multi polygon
 */
-(WKBMultiPolygon *) toMultiPolygonWithMapPolygons: (NSArray *) mapPolygons;

/**
 *  Convert polygons to WKB multi polygon
 *
 *  @param mapPolygons polygons
 *  @param hasZ        has z value
 *  @param hasM        has m value
 *
 *  @return wkb multi polygon
 */
-(WKBMultiPolygon *) toMultiPolygonWithMapPolygons: (NSArray *) mapPolygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Create WKB multi polygon with WKB polygons
 *
 *  @param polygons wkb polygons
 *
 *  @return wkb multi polygon
 */
-(WKBMultiPolygon *) createMultiPolygonWithPolygons: (NSArray *) polygons;

/**
 *  Create WKB multi polygon with WKB polygons
 *
 *  @param polygons wkb polygons
 *  @param hasZ     has z value
 *  @param hasM     has m value
 *
 *  @return wkb multi polygon
 */
-(WKBMultiPolygon *) createMultiPolygonWithPolygons: (NSArray *) polygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert multi polygon to WKB multi polygon
 *
 *  @param mapMultiPolygon multi polygon
 *
 *  @return wkb multi polygon
 */
-(WKBMultiPolygon *) toMultiPolygonWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon;

/**
 *  Convert multi polygon to WKB multi polygon
 *
 *  @param mapMultiPolygon multi polygon
 *  @param hasZ            has z value
 *  @param hasM            has m value
 *
 *  @return wkb multi polygon
 */
-(WKBMultiPolygon *) toMultiPolygonWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert WKB compound curve to multi polyline
 *
 *  @param compoundCurve wkb compound curve
 *
 *  @return multi polyline
 */
-(GPKGMultiPolyline *) toMapMultiPolylineWithCompoundCurve: (WKBCompoundCurve *) compoundCurve;

/**
 *  Convert polylines to WKB compound curve
 *
 *  @param mapPolylines polylines
 *
 *  @return wkb compound curve
 */
-(WKBCompoundCurve *) toCompoundCurveWithMapPolylines: (NSArray *) mapPolylines;

/**
 *  Convert polylines to WKB compound curve
 *
 *  @param mapPolylines polylines
 *  @param hasZ         has z value
 *  @param hasM         has m value
 *
 *  @return wkb compound curve
 */
-(WKBCompoundCurve *) toCompoundCurveWithMapPolylines: (NSArray *) mapPolylines andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert WKB polyhedral surface to multi polygon
 *
 *  @param polyhedralSurface wkb polyhedral surface
 *
 *  @return multi polygon
 */
-(GPKGMultiPolygon *) toMapMultiPolygonWithPolyhedralSurface: (WKBPolyhedralSurface *) polyhedralSurface;

/**
 *  Convert polygons to WKB polyhedral surface
 *
 *  @param mapPolygons polygons
 *
 *  @return wkb polyhedral surface
 */
-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapPolygons: (NSArray *) mapPolygons;

/**
 *  Convert polygons to WKB polyhedral surface
 *
 *  @param mapPolygons polygons
 *  @param hasZ        has z value
 *  @param hasM        has m value
 *
 *  @return wkb polyhedral surface
 */
-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapPolygons: (NSArray *) mapPolygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert multi polygon to WKB polyhedral surface
 *
 *  @param mapMultiPolygon multi polygon
 *
 *  @return wkb polyhedral surface
 */
-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon;

/**
 *  Convert multi polygon to WKB polyhedral surface
 *
 *  @param mapMultiPolygon multi polygon
 *  @param hasZ            has z value
 *  @param hasM            has m value
 *
 *  @return wkb polyhedral surface
 */
-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

/**
 *  Convert a WKB Geometry to a Map shape
 *
 *  @param geometry wkb geometry
 *
 *  @return map shape
 */
-(GPKGMapShape *) toShapeWithGeometry: (WKBGeometry *) geometry;

/**
 *  Convert a WKB Geometry Collection to an array of Map shapes
 *
 *  @param geometryCollection wkb geometry collection
 *
 *  @return array of Map shapes
 */
-(NSArray *) toShapesWithGeometryCollection: (WKBGeometryCollection *) geometryCollection;

/**
 *  Convert a WKB Geometry to a Map shape and add it to the map view
 *
 *  @param geometry wkb geometry
 *  @param mapView  map view
 *
 *  @return map shape
 */
-(GPKGMapShape *) addGeometry: (WKBGeometry *) geometry toMapView: (MKMapView *) mapView;

/**
 *  Add a shape to the map view
 *
 *  @param mapShape map shape
 *  @param mapView  map view
 *
 *  @return map shape
 */
+(GPKGMapShape *) addMapShape: (GPKGMapShape *) mapShape toMapView: (MKMapView *) mapView;

/**
 *  Add a map point to the map view
 *
 *  @param mapPoint map point
 *  @param mapView  map view
 *
 *  @return map point
 */
+(GPKGMapPoint *) addMapPoint: (GPKGMapPoint *) mapPoint toMapView: (MKMapView *) mapView;

/**
 *  Add a map point to the map view with point options
 *
 *  @param mapPoint     map point
 *  @param mapView      map view
 *  @param pointOptions point options
 *
 *  @return map point
 */
+(GPKGMapPoint *) addMapPoint: (GPKGMapPoint *) mapPoint toMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions;

/**
 *  Add a MapKit map point to the map view with point options
 *
 *  @param mkMapPoint   mk map point
 *  @param mapView      map view
 *  @param pointOptions point options
 *
 *  @return map point
 */
+(GPKGMapPoint *) addMKMapPoint: (MKMapPoint) mkMapPoint toMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions;

/**
 *  Add polyline to the map view
 *
 *  @param mapPolyline polyline
 *  @param mapView     map view
 *
 *  @return polyline
 */
+(MKPolyline *) addMapPolyline: (MKPolyline *) mapPolyline toMapView: (MKMapView *) mapView;

/**
 *  Add polygon to the map view
 *
 *  @param mapPolylgon polygon
 *  @param mapView     map view
 *
 *  @return polygon
 */
+(MKPolygon *) addMapPolygon: (MKPolygon *) mapPolylgon toMapView: (MKMapView *) mapView;

/**
 *  Add multi point to the map view
 *
 *  @param mapMultiPoint multi point
 *  @param mapView       map view
 *
 *  @return multi point
 */
+(GPKGMultiPoint *) addMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint toMapView: (MKMapView *) mapView;

/**
 *  Add multi point to the map view with point options
 *
 *  @param mapMultiPoint multi point
 *  @param mapView       map view
 *  @param pointOptions  point options
 *
 *  @return multi point
 */
+(GPKGMultiPoint *) addMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint toMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions;

/**
 *  Add multi polyline to the map view
 *
 *  @param mapMultiPolyline multi polyline
 *  @param mapView          map view
 *
 *  @return multi polyline
 */
+(GPKGMultiPolyline *) addMapMultiPolyline: (GPKGMultiPolyline *) mapMultiPolyline toMapView: (MKMapView *) mapView;

/**
 *  Add multi polygon to the map view
 *
 *  @param mapMultiPolygon multi polygon
 *  @param mapView         map view
 *
 *  @return multi polygon
 */
+(GPKGMultiPolygon *) addMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon toMapView: (MKMapView *) mapView;

/**
 *  Convert a WKB geometry collection to a list of Map shapes and add it to the map view
 *
 *  @param geometryCollection wkb geometry collection
 *  @param mapView            map view
 *
 *  @return map shapes
 */
-(NSArray *) addGeometryCollection: (WKBGeometryCollection *) geometryCollection toMapView: (MKMapView *) mapView;

/**
 *  Add a shape to the map view as points
 *
 *  @param mapShape                map shape
 *  @param mapView                 map view
 *  @param pointOptions            point options
 *  @param polylinePointOptions    polyline point options
 *  @param polygonPointOptions     polygon point options
 *  @param polygonHolePointOptions polygon hole point options
 *
 *  @return map shape points
 */
-(GPKGMapShapePoints *) addMapShape: (GPKGMapShape *) mapShape asPointsToMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions andPolylinePointOptions: (GPKGMapPointOptions *) polylinePointOptions andPolygonPointOptions: (GPKGMapPointOptions *) polygonPointOptions andPolygonPointHoleOptions: (GPKGMapPointOptions *) polygonHolePointOptions;

/**
 *  Add the MapKit map points to the map view as map points
 *
 *  @param mapPoints           mk map points
 *  @param pointCount          count of map points
 *  @param mapView             map view
 *  @param pointOptions        point options
 *  @param ignoreIdenticalEnds ignore starting and ending points that are identical, such as in polygons and polygon holes
 *
 *  @return map points
 */
-(NSMutableArray *) addMKMapPoints: (MKMapPoint *) mapPoints withPointCount: (NSUInteger) pointCount asPointsToMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions andIgnoreIdenticalEnds: (BOOL) ignoreIdenticalEnds;

/**
 *  Add polyline to the map view as points
 *
 *  @param mapPolyline          polyline
 *  @param mapView              map view
 *  @param polylinePointOptions polyline point options
 *
 *  @return polyline points
 */
-(GPKGPolylinePoints *) addMapPolyline: (MKPolyline *) mapPolyline asPointsToMapView: (MKMapView *) mapView withPolylinePointOptions: (GPKGMapPointOptions *) polylinePointOptions;

/**
 *  Add polygon to the map view as points
 *
 *  @param mapPolygon              polygon
 *  @param mapView                 map view
 *  @param shapePoints             shape points
 *  @param polygonPointOptions     polygon point options
 *  @param polygonHolePointOptions polygon hole point options
 *
 *  @return polygon points
 */
-(GPKGPolygonPoints *) addMapPolygon: (MKPolygon *) mapPolygon asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints withPolygonPointOptions: (GPKGMapPointOptions *) polygonPointOptions andPolygonPointHoleOptions: (GPKGMapPointOptions *) polygonHolePointOptions;

/**
 *  Add multi polyline to the map view as points
 *
 *  @param mapMultiPolyline     multi polyline
 *  @param mapView              map view
 *  @param shapePoints          shape points
 *  @param polylinePointOptions polyline point options
 *
 *  @return multi polyline points
 */
-(GPKGMultiPolylinePoints *) addMapMultiPolyline: (GPKGMultiPolyline *) mapMultiPolyline asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints withPolylinePointOptions: (GPKGMapPointOptions *) polylinePointOptions;

/**
 *  Add multi polygon to the map view as points
 *
 *  @param mapMultiPolygon         multi polygon
 *  @param mapView                 map view
 *  @param shapePoints             shape points
 *  @param polygonPointOptions     polygon point options
 *  @param polygonHolePointOptions polygon hole point options
 *
 *  @return multi polygon points
 */
-(GPKGMultiPolygonPoints *) addMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints withPolygonPointOptions: (GPKGMapPointOptions *) polygonPointOptions andPolygonPointHoleOptions: (GPKGMapPointOptions *) polygonHolePointOptions;

/**
 *  Get the location coordinates from the map points
 *
 *  @param points map points
 *
 *  @return location coordinates
 */
+(CLLocationCoordinate2D *) getLocationCoordinatesFromPoints: (NSArray *) points;

/**
 *  Get the location coordinates from the locations
 *
 *  @param locations CLLocation array
 *
 *  @return location coordinates
 */
+(CLLocationCoordinate2D *) getLocationCoordinatesFromLocations: (NSArray *) locations;

/**
 *  Convert a Map Shape to a WKB Geometry
 *
 *  @param mapShape map shape
 *
 *  @return wkb geometry
 */
-(WKBGeometry *) toGeometryFromMapShape: (GPKGMapShape *) mapShape;

@end
