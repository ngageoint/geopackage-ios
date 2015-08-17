//
//  GPKGPolylinePoints.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGPolylinePoints.h"
#import "GPKGUtils.h"
#import "GPKGMapShapePoints.h"
#import "GPKGMapShapeConverter.h"

@implementation GPKGPolylinePoints

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

-(void) updateWithMapView: (MKMapView *) mapView{
    if(self.polyline != nil){
        if([self isDeleted]){
            [self removeFromMapView:mapView];
        }else{
            
            [mapView removeOverlay:self.polyline];
            
            CLLocationCoordinate2D * points = [GPKGMapShapeConverter getLocationCoordinatesFromPoints: self.points];
            self.polyline = [MKPolyline polylineWithCoordinates:points count:[self.points count]];
            
            [mapView addOverlay:self.polyline];
        }
    }
}

-(void) removeFromMapView: (MKMapView *) mapView{
    if(self.polyline != nil){
        [mapView removeOverlay:self.polyline];
        self.polyline = nil;
    }
    [mapView removeAnnotations:self.points];
}

-(BOOL) isValid{
    NSUInteger count = [self.points count];
    return count == 0 || count >= 2;
}

-(BOOL) isDeleted{
    return [self.points count] == 0;
}

-(NSArray *) getPoints{
    return self.points;
}

-(void) deletePoint: (GPKGMapPoint *) point fromMapView: (MKMapView * ) mapView{
    if([self.points containsObject:point]){
        [self.points removeObject:point];
        [mapView removeAnnotation:point];
        [self updateWithMapView:mapView];
    }
}

-(void) addNewPoint: (GPKGMapPoint *) point{
    [GPKGMapShapePoints addPointAsPolyline:point toPoints: self.points];
}

@end
