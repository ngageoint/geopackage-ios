//
//  GPKGMultiPolyline.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface GPKGMultiPolyline : NSObject

@property (nonatomic, strong) NSMutableArray *polylines;

-(instancetype) init;

-(void) addPolyline: (MKPolyline*) polyline;

-(void) removeFromMapView: (MKMapView *) mapView;

@end
