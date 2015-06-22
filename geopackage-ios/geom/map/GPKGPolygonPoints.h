//
//  GPKGPolygonPoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGShapePoints.h"
#import "GPKGShapeWithChildrenPoints.h"
#import "GPKGMapShapeConverter.h"
@import MapKit;
#import "GPKGPolygonHolePoints.h"
#import "GPKGMapPoint.h"

@class GPKGPolygonHolePoints;

@interface GPKGPolygonPoints : NSObject <GPKGShapePoints, GPKGShapeWithChildrenPoints>

@property (nonatomic, strong) GPKGMapShapeConverter *converter;
@property (nonatomic, strong) MKPolygon *polygon;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *holes;

-(instancetype) initWithConverter: (GPKGMapShapeConverter *) converter;

-(void) addPoint: (GPKGMapPoint *) point;

-(void) addHole: (GPKGPolygonHolePoints *) hole;

-(void) updateWithMapView: (MKMapView *) mapView;

-(void) removeFromMapView: (MKMapView *) mapView;

-(BOOL) isValid;

-(BOOL) isDeleted;

@end
