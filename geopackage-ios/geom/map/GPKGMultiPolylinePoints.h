//
//  GPKGMultiPolylinePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGPolylinePoints.h"

@interface GPKGMultiPolylinePoints : NSObject

@property (nonatomic, strong) NSMutableArray *polylinePoints;

-(instancetype) init;

-(void) addPolylinePoints: (GPKGPolylinePoints *) polylinePoints;

-(void) updateWithMapView: (MKMapView *) mapView;

-(void) removeFromMapView: (MKMapView *) mapView;

-(BOOL) isValid;

-(BOOL) isDeleted;

@end
