//
//  GPKGMultiPolygon.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface GPKGMultiPolygon : NSObject

@property (nonatomic, strong) NSMutableArray *polygons;

-(instancetype) init;

-(void) addPolygon: (MKPolygon *) polygon;

-(void) removeFromMapView: (MKMapView *) mapView;

@end
