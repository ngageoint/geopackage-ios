//
//  GPKGMapShapePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "GPKGMapShape.h"
#import "GPKGMapPoint.h"
#import "GPKGShapePoints.h"

@interface GPKGMapShapePoints : NSObject

@property (nonatomic, strong) GPKGMapShape *shape;
@property (nonatomic, strong) NSMutableDictionary *shapePoints;

-(instancetype) init;

-(void) addPoint: (GPKGMapPoint *) point withShape: (NSObject<GPKGShapePoints> *) shapePoints;

-(void) addPointId: (int) pointId withShape: (NSObject<GPKGShapePoints> *) shapePoints;

-(void) addShapePoints: (NSObject<GPKGShapePoints> *) shapePoints;

-(void) addPoint: (GPKGMapPoint *) point;

-(void) addPoints: (NSArray *) points;

-(void) addMapShapePoints: (GPKGMapShapePoints *) mapShapePoints;

-(BOOL) containsPoint: (GPKGMapPoint *) point;

-(BOOL) containsPointId: (int) pointId;

-(NSObject<GPKGShapePoints> *) getShapePointsForPoint: (GPKGMapPoint *) point;

-(NSObject<GPKGShapePoints> *) getShapePointsForPointId: (int) pointId;

-(BOOL) deletePoint: (GPKGMapPoint *) point fromMapView: (MKMapView *) mapView;

-(void) removeFromMapView: (MKMapView *) mapView;

-(void) updateWithMapView: (MKMapView *) mapView;

-(BOOL) isValid;

+(void) addPointAsPolygon: (GPKGMapPoint *) point toPoints: (NSMutableArray *) points;

+(void) addPointAsPolyline: (GPKGMapPoint *) point toPoints: (NSMutableArray *) points;

@end
