//
//  GPKGMultiPolygon.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMultiPolygon.h"
#import "GPKGUtils.h"

@implementation GPKGMultiPolygon

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.polygons = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addPolygon: (MKPolygon *) polygon{
    [GPKGUtils addObject:polygon toArray:self.polygons];
}

-(void) removeFromMapView: (MKMapView *) mapView{
    [mapView removeOverlays:self.polygons];
}

@end
