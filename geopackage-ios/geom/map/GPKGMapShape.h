//
//  GPKGMapShape.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKBGeometryTypes.h"
#import "GPKGMapShapeTypes.h"
@import MapKit;
#import "GPKGBoundingBox.h"

/**
 *  Map shape object
 */
@interface GPKGMapShape : NSObject

/**
 *  Geometry type
 */
@property (nonatomic) enum WKBGeometryType geometryType;

/**
 *  Shape type
 */
@property (nonatomic) enum GPKGMapShapeType shapeType;

/**
 *  Shape object
 */
@property (nonatomic, strong) NSObject *shape;

/**
 *  Initialize
 *
 *  @param geometryType geometry type
 *  @param shapeType    shape type
 *  @param shape        shape object
 *
 *  @return new map shape
 */
-(instancetype) initWithGeometryType: (enum WKBGeometryType) geometryType andShapeType: (enum GPKGMapShapeType) shapeType andShape: (NSObject *) shape;

/**
 *  Remove the shape from the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

/**
 *  Update the shape on the map view
 *
 *  @param mapView map view
 */
-(void) updateWithMapView: (MKMapView *) mapView;

/**
 *  Determine if the map shape is valid
 *
 *  @return true if a valid shape
 */
-(BOOL) isValid;

/**
 *  Get a bounding box that includes the entire shape
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) boundingBox;

/**
 *  Expanding the provided bounding box to include the entire shape
 *
 *  @param boundingBox bounding box
 */
-(void) expandBoundingBox: (GPKGBoundingBox *) boundingBox;

@end
