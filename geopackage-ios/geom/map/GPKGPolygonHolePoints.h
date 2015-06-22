//
//  GPKGPolygonHolePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGShapePoints.h"
#import "GPKGPolygonPoints.h"
@import MapKit;
#import "GPKGMapPoint.h"

@class GPKGPolygonPoints;

@interface GPKGPolygonHolePoints : NSObject <GPKGShapePoints>

@property (nonatomic, strong) GPKGPolygonPoints *parentPolygon;
@property (nonatomic, strong) NSMutableArray *points;

-(instancetype) initWithPolygonPoints: (GPKGPolygonPoints *) polygonPoints;

-(void) addPoint: (GPKGMapPoint *) point;

-(void) removeFromMapView: (MKMapView *) mapView;

-(BOOL) isValid;

-(BOOL) isDeleted;

@end
