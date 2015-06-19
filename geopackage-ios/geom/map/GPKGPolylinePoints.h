//
//  GPKGPolylinePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGShapePoints.h"
#import "GPKGMapShapeConverter.h"
@import MapKit;

@interface GPKGPolylinePoints : NSObject <GPKGShapePoints>

@property (nonatomic, strong) GPKGMapShapeConverter *converter;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, strong) NSMutableArray *points;

-(instancetype) initWithConverter: (GPKGMapShapeConverter *) converter;

-(void) addPoint: (MKPointAnnotation *) point;

-(void) updateWithMapView: (MKMapView *) mapView;

-(void) removeFromMapView: (MKMapView *) mapView;

-(BOOL) isValid;

-(BOOL) isDeleted;

@end
