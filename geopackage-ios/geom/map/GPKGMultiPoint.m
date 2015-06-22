//
//  GPKGMultiPoint.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMultiPoint.h"
#import "GPKGUtils.h"

@implementation GPKGMultiPoint

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.points = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addPoint: (GPKGMapPoint *) point{
    [GPKGUtils addObject:point toArray:self.points];
}

-(void) removeFromMapView: (MKMapView *) mapView{
    [mapView removeAnnotations:self.points];
}

-(NSArray *) getPoints{
    return self.points;
}

-(void) deletePoint: (GPKGMapPoint *) point fromMapView: (MKMapView * ) mapView{
    if([self.points containsObject:point]){
        [self.points removeObject:point];
        [mapView removeAnnotation:point];
    }
}

-(void) addNewPoint: (GPKGMapPoint *) point{
    [self addPoint:point];
}

@end
