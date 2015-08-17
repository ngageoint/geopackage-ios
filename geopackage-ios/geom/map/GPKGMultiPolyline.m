//
//  GPKGMultiPolyline.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMultiPolyline.h"
#import "GPKGUtils.h"

@implementation GPKGMultiPolyline

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.polylines = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addPolyline: (MKPolyline *) polyline{
    [GPKGUtils addObject:polyline toArray:self.polylines];
}

-(void) removeFromMapView: (MKMapView *) mapView{
    [mapView removeOverlays:self.polylines];
}

@end
