//
//  GPKGGeometryProjectionTransform.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/18/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGProjectionTransform.h"
#import "WKBPoint.h"
#import "WKBLineString.h"
#import "WKBPolygon.h"
#import "WKBMultiPoint.h"
#import "WKBMultiLineString.h"
#import "WKBMultiPolygon.h"
#import "WKBCircularString.h"
#import "WKBCompoundCurve.h"
#import "WKBPolyhedralSurface.h"
#import "WKBTIN.h"
#import "WKBTriangle.h"
#import "WKBGeometryCollection.h"

@interface GPKGGeometryProjectionTransform : NSObject

/**
 *  Initialize
 *
 *  @param transform projection transform
 *
 *  @return new instance
 */
-(instancetype) initWithProjectionTransform: (GPKGProjectionTransform *) transform;

/**
 *  Transform the geometry
 *
 *  @param geometry geometry
 *
 *  @return projected geometry
 */
-(WKBGeometry *) transformGeometry: (WKBGeometry *) geometry;

/**
 *  Transform the point
 *
 *  @param point point
 *
 *  @return projected point
 */
-(WKBPoint *) transformPoint: (WKBPoint *) point;

/**
 *  Transform the line string
 *
 *  @param lineString line string
 *
 *  @return projected line string
 */
-(WKBLineString *) transformLineString: (WKBLineString *) lineString;

/**
 *  Transform the polygon
 *
 *  @param polygon polygon
 *
 *  @return projected polygon
 */
-(WKBPolygon *) transformPolygon: (WKBPolygon *) polygon;

/**
 *  Transform the multi point
 *
 *  @param multiPoint multi point
 *
 *  @return projected multi point
 */
-(WKBMultiPoint *) transformMultiPoint: (WKBMultiPoint *) multiPoint;

/**
 *  Transform the multi line string
 *
 *  @param multiLineString multi line string
 *
 *  @return projected multi line string
 */
-(WKBMultiLineString *) transformMultiLineString: (WKBMultiLineString *) multiLineString;

/**
 *  Transform the multi polygon
 *
 *  @param multiPolygon multi polygon
 *
 *  @return projected multi polygon
 */
-(WKBMultiPolygon *) transformMultiPolygon: (WKBMultiPolygon *) multiPolygon;

/**
 *  Transform the circular string
 *
 *  @param circularString circular string
 *
 *  @return projected circular string
 */
-(WKBCircularString *) transformCircularString: (WKBCircularString *) circularString;

/**
 *  Transform the compound curve
 *
 *  @param compoundCurve compound curve
 *
 *  @return projected compound curve
 */
-(WKBCompoundCurve *) transformCompoundCurve: (WKBCompoundCurve *) compoundCurve;

/**
 *  Transform the polyhedrals surface
 *
 *  @param polyhedralSurface polyhedrals surface
 *
 *  @return projected polyhedrals surface
 */
-(WKBPolyhedralSurface *) transformPolyhedralSurface: (WKBPolyhedralSurface *) polyhedralSurface;

/**
 *  Transform the tin
 *
 *  @param tin tin
 *
 *  @return projected tin
 */
-(WKBTIN *) transformTIN: (WKBTIN *) tin;

/**
 *  Transform the triangle
 *
 *  @param triangle triangle
 *
 *  @return projected triangle
 */
-(WKBTriangle *) transformTriangle: (WKBTriangle *) triangle;

/**
 *  Transform the geometry collection
 *
 *  @param geometryCollection geometry collection
 *
 *  @return projected geometry collection
 */
-(WKBGeometryCollection *) transformGeometryCollection: (WKBGeometryCollection *) geometryCollection;

@end
