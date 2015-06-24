//
//  GPKGMultiPolygonPoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGPolygonPoints.h"

@class GPKGPolygonPoints;

@interface GPKGMultiPolygonPoints : NSObject

@property (nonatomic, strong) NSMutableArray *polygonPoints;

-(instancetype) init;

-(void) addPolygonPoints: (GPKGPolygonPoints *) polygonPoints;

-(void) updateWithMapView: (MKMapView *) mapView;

-(void) removeFromMapView: (MKMapView *) mapView;

-(BOOL) isValid;

-(BOOL) isDeleted;

@end
