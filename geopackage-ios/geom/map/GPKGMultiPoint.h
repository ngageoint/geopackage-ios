//
//  GPKGMultiPoint.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "GPKGShapePoints.h"

@interface GPKGMultiPoint : NSObject <GPKGShapePoints>

@property (nonatomic, strong) NSMutableArray *points;

-(instancetype) init;

-(void) addPoint: (MKPointAnnotation *) point;

-(void) removeFromMapView: (MKMapView *) mapView;

@end
