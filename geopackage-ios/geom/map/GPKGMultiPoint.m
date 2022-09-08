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
        self.points = [NSMutableArray array];
    }
    return self;
}

-(void) addPoint: (GPKGMapPoint *) point{
    [GPKGUtils addObject:point toArray:self.points];
}

-(void) removeFromMapView: (MKMapView *) mapView{
    [mapView removeAnnotations:self.points];
}

-(NSArray *) points{
    return _points;
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

-(void) hidden: (BOOL) hidden fromMapView: (MKMapView *) mapView{
    [self hiddenPoints:hidden];
}

-(void) hiddenPoints: (BOOL) hidden{
    for(GPKGMapPoint *point in self.points){
        [point hidden:hidden];
    }
}

@end
