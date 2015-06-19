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

@interface GPKGMapShape : NSObject

@property (nonatomic) enum WKBGeometryType geometryType;
@property (nonatomic) enum GPKGMapShapeType shapeType;
@property (nonatomic, strong) NSObject *shape;

-(instancetype) initWithGeometryType: (enum WKBGeometryType) geometryType andShapeType: (enum GPKGMapShapeType) shapeType andShape: (NSObject *) shape;

-(void) removeFromMapView: (MKMapView *) mapView;

-(void) updateWithMapView: (MKMapView *) mapView;

-(BOOL) isValid;

-(GPKGBoundingBox *) boundingBox;

-(void) expandBoundingBox: (GPKGBoundingBox *) boundingBox;

@end
