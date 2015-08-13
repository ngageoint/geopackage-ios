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

@interface GPKGMapShapeConverter : NSObject

@property (nonatomic, strong) GPKGProjection *projection;

-(instancetype) initWithProjection: (GPKGProjection *) projection;

-(WKBPoint *) toWgs84WithPoint: (WKBPoint *) point;

-(WKBPoint *) toProjectionWithPoint: (WKBPoint *) point;

-(GPKGMapPoint *) toMapPointWithPoint: (WKBPoint *) point;

-(MKMapPoint) toMKMapPointWithPoint: (WKBPoint *) point;

-(WKBPoint *) toPointWithMapPoint: (GPKGMapPoint *) mapPoint;

-(WKBPoint *) toPointWithMapPoint: (GPKGMapPoint *) mapPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBPoint *) toPointWithMKMapPoint: (MKMapPoint) mapPoint;

-(WKBPoint *) toPointWithMKMapPoint: (MKMapPoint) mapPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(MKPolyline *) toMapPolylineWithLineString: (WKBLineString *) lineString;

-(WKBLineString *) toLineStringWithMapPolyline: (MKPolyline *) mapPolyline;

-(WKBLineString *) toLineStringWithMapPolyline: (MKPolyline *) mapPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBLineString *) toLineStringWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount;

-(WKBLineString *) toLineStringWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBLineString *) toLineStringWithMapPoints: (NSArray *) mapPoints;

-(WKBLineString *) toLineStringWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBCircularString *) toCircularStringWithMapPoints: (NSArray *) mapPoints;

-(WKBCircularString *) toCircularStringWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(void) populateLineString: (WKBLineString *) lineString withMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount;

-(void) populateLineString: (WKBLineString *) lineString withMapPoints: (NSArray *) mapPoints;

-(MKPolygon *) toMapPolygonWithPolygon: (WKBPolygon *) polygon;

-(WKBPolygon *) toPolygonWithMapPolygon: (MKPolygon *) mapPolygon;

-(WKBPolygon *) toPolygonWithMapPolygon: (MKPolygon *) mapPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBPolygon *) toPolygonWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHolePolygons: (NSArray *) holes;

-(WKBPolygon *) toPolygonWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHolePolygons: (NSArray *) holes andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBPolygon *) toPolygonWithMapPoints: (NSArray *) mapPoints andHolePoints: (NSArray *) holes;

-(WKBPolygon *) toPolygonWithMapPoints: (NSArray *) mapPoints andHolePoints: (NSArray *) holes andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(GPKGMultiPoint *) toMapMultiPointWithMultiPoint: (WKBMultiPoint *) multiPoint;

-(WKBMultiPoint *) toMultiPointWithMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint;

-(WKBMultiPoint *) toMultiPointWithMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBMultiPoint *) toMultiPointWithMapPoints: (NSArray *) mapPoints;

-(WKBMultiPoint *) toMultiPointWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(GPKGMultiPolyline *) toMapMultiPolylineWithMultiLineString: (WKBMultiLineString *) multiLineString;

-(WKBMultiLineString *) toMultiLineStringWithMapPolylines: (NSArray *) mapPolylines;

-(WKBMultiLineString *) toMultiLineStringWithMapPolylines: (NSArray *) mapPolylines andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBMultiLineString *) toMultiLineStringWithMapPolylinesArray: (NSArray *) mapPolylinesArray;

-(WKBMultiLineString *) toMultiLineStringWithMapPolylinesArray: (NSArray *) mapPolylinesArray andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBCompoundCurve *) toCompoundCurveWithMapPolylinesArray: (NSArray *) mapPolylinesArray;

-(WKBCompoundCurve *) toCompoundCurveWithMapPolylinesArray: (NSArray *) mapPolylinesArray andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBMultiLineString *) toMultiLineStringWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline;

-(WKBMultiLineString *) toMultiLineStringWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBCompoundCurve *) toCompoundCurveWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline;

-(WKBCompoundCurve *) toCompoundCurveWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(GPKGMultiPolygon *) toMapMultiPolygonWithMultiPolygon: (WKBMultiPolygon *) multiPolygon;

-(WKBMultiPolygon *) toMultiPolygonWithMapPolygons: (NSArray *) mapPolygons;

-(WKBMultiPolygon *) toMultiPolygonWithMapPolygons: (NSArray *) mapPolygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBMultiPolygon *) createMultiPolygonWithPolygons: (NSArray *) polygons;

-(WKBMultiPolygon *) createMultiPolygonWithPolygons: (NSArray *) polygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBMultiPolygon *) toMultiPolygonWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon;

-(WKBMultiPolygon *) toMultiPolygonWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(GPKGMultiPolyline *) toMapMultiPolylineWithCompoundCurve: (WKBCompoundCurve *) compoundCurve;

-(WKBCompoundCurve *) toCompoundCurveWithMapPolylines: (NSArray *) mapPolylines;

-(WKBCompoundCurve *) toCompoundCurveWithMapPolylines: (NSArray *) mapPolylines andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(GPKGMultiPolygon *) toMapMultiPolygonWithPolyhedralSurface: (WKBPolyhedralSurface *) polyhedralSurface;

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapPolygons: (NSArray *) mapPolygons;

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapPolygons: (NSArray *) mapPolygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon;

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

-(GPKGMapShape *) toShapeWithGeometry: (WKBGeometry *) geometry;

-(NSArray *) toShapesWithGeometryCollection: (WKBGeometryCollection *) geometryCollection;

-(GPKGMapShape *) addGeometry: (WKBGeometry *) geometry toMapView: (MKMapView *) mapView;

+(GPKGMapShape *) addMapShape: (GPKGMapShape *) mapShape toMapView: (MKMapView *) mapView;

+(GPKGMapPoint *) addMapPoint: (GPKGMapPoint *) mapPoint toMapView: (MKMapView *) mapView;

+(GPKGMapPoint *) addMKMapPoint: (MKMapPoint) mkMapPoint toMapView: (MKMapView *) mapView;

+(MKPolyline *) addMapPolyline: (MKPolyline *) mapPolyline toMapView: (MKMapView *) mapView;

+(MKPolygon *) addMapPolygon: (MKPolygon *) mapPolylgon toMapView: (MKMapView *) mapView;

+(GPKGMultiPoint *) addMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint toMapView: (MKMapView *) mapView;

+(GPKGMultiPolyline *) addMapMultiPolyline: (GPKGMultiPolyline *) mapMultiPolyline toMapView: (MKMapView *) mapView;

+(GPKGMultiPolygon *) addMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon toMapView: (MKMapView *) mapView;

-(NSArray *) addGeometryCollection: (WKBGeometryCollection *) geometryCollection toMapView: (MKMapView *) mapView;

-(GPKGMapShapePoints *) addMapShape: (GPKGMapShape *) mapShape asPointsToMapView: (MKMapView *) mapView;

-(NSMutableArray *) addMKMapPoints: (MKMapPoint *) mapPoints withPointCount: (NSUInteger) pointCount asPointsToMapView: (MKMapView *) mapView withIgnoreIdenticalEnds: (BOOL) ignoreIdenticalEnds;

-(GPKGPolylinePoints *) addMapPolyline: (MKPolyline *) mapPolyline asPointsToMapView: (MKMapView *) mapView;

-(GPKGPolygonPoints *) addMapPolygon: (MKPolygon *) mapPolygon asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints;

-(GPKGMultiPolylinePoints *) addMapMultiPolyline: (GPKGMultiPolyline *) mapMultiPolyline asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints;

-(GPKGMultiPolygonPoints *) addMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints;

+(CLLocationCoordinate2D *) getLocationCoordinatesFromPoints: (NSArray *) points;

+(CLLocationCoordinate2D *) getLocationCoordinatesFromLocations: (NSArray *) locations;

-(WKBGeometry *) toGeometryFromMapShape: (GPKGMapShape *) mapShape;

@end
