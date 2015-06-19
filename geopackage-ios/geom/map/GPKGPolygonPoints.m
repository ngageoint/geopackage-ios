//
//  GPKGPolygonPoints.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGPolygonPoints.h"
#import "GPKGUtils.h"
#import "GPKGMapShapePoints.h"

@implementation GPKGPolygonPoints

-(instancetype) initWithConverter: (GPKGMapShapeConverter *) converter{
    self = [super init];
    if(self != nil){
        self.converter = converter;
        self.points = [[NSMutableArray alloc] init];
        self.holes = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addPoint: (MKPointAnnotation *) point{
    [GPKGUtils addObject:point toArray:self.points];
}

-(void) addHole: (GPKGPolygonHolePoints *) hole{
    [GPKGUtils addObject:hole toArray:self.holes];
}

-(void) updateWithMapView: (MKMapView *) mapView{
    if(self.polygon != nil){
        if([self isDeleted]){
            [self removeFromMapView:mapView];
        }else{
            
            [mapView removeAnnotation:self.polygon];
            
            CLLocationCoordinate2D * points = [self.converter getLocationCoordinatesFromPoints: self.points];
            
            NSMutableArray * holePolygons = [[NSMutableArray alloc] init];
            for(GPKGPolygonHolePoints * hole in self.holes){
                if(![hole isDeleted]){
                    CLLocationCoordinate2D * holePoints = [self.converter getLocationCoordinatesFromPoints: [hole getPoints]];
                    MKPolygon * holePolygon = [MKPolygon polygonWithCoordinates:holePoints count:[[hole getPoints] count]];
                    [GPKGUtils addObject:holePolygon toArray:holePolygons];
                }
            }
            
            self.polygon = [MKPolygon polygonWithCoordinates:points count:[self.points count] interiorPolygons:holePolygons];
        }
    }
}

-(void) removeFromMapView: (MKMapView *) mapView{
    if(self.polygon != nil){
        [mapView removeAnnotation:self.polygon];
        self.polygon = nil;
    }
    [mapView removeAnnotations:self.points];
    for(GPKGPolygonHolePoints * hole in self.holes){
        [hole removeFromMapView:mapView];
    }
}

-(BOOL) isValid{
    NSUInteger count = [self.points count];
    BOOL valid = count == 0 || count >= 3;
    if(valid){
        for(GPKGPolygonHolePoints * hole in self.holes){
            valid = [hole isValid];
            if(!valid){
                break;
            }
        }
    }
    return valid;
}

-(BOOL) isDeleted{
    return [self.points count] == 0;
}

-(NSArray *) getPoints{
    return self.points;
}

-(void) deletePoint: (MKPointAnnotation *) point fromMapView: (MKMapView * ) mapView{
    if([self.points containsObject:point]){
        [self.points removeObject:point];
        [mapView removeAnnotation:point];
        [self updateWithMapView:mapView];
    }
}

-(void) addNewPoint: (MKPointAnnotation *) point{
    [GPKGMapShapePoints addPointAsPolygon:point toPoints: self.points];
}

-(NSObject<GPKGShapePoints> *) createChild{
    GPKGPolygonHolePoints * hole = [[GPKGPolygonHolePoints alloc] initWithPolygonPoints:self];
    [GPKGUtils addObject:hole toArray:self.holes];
    return hole;
}

@end
