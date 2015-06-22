//
//  GPKGPolygonHolePoints.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGPolygonHolePoints.h"
#import "GPKGUtils.h"
#import "GPKGMapShapePoints.h"

@implementation GPKGPolygonHolePoints

-(instancetype) initWithPolygonPoints: (GPKGPolygonPoints *) polygonPoints{
    self = [super init];
    if(self != nil){
        self.parentPolygon = polygonPoints;
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

-(BOOL) isValid{
    NSUInteger count = [self.points count];
    return count == 0 || count >= 3;
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
        [self.parentPolygon updateWithMapView:mapView];
    }
}

-(void) addNewPoint: (GPKGMapPoint *) point{
    [GPKGMapShapePoints addPointAsPolygon:point toPoints: self.points];
}

@end
