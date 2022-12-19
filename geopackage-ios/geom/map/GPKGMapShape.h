//
//  GPKGMapShape.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMapShapeTypes.h"
#import "GPKGBoundingBox.h"

/**
 *  Map shape object
 */
@interface GPKGMapShape : NSObject

/**
 *  Geometry type
 */
@property (nonatomic) enum SFGeometryType geometryType;

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
-(instancetype) initWithGeometryType: (enum SFGeometryType) geometryType andShapeType: (enum GPKGMapShapeType) shapeType andShape: (NSObject *) shape;

/**
 *  Remove the shape from the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

/**
 *  Set the shape hidden state
 *
 *  @param hidden true to make hidden, false to make visible
 *  @param mapView map view
 */
-(void) hidden: (BOOL) hidden fromMapView: (MKMapView *) mapView;

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
