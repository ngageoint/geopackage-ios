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
#import "GPKGMapShapeConverter.h"

@implementation GPKGPolygonPoints

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.points = [[NSMutableArray alloc] init];
        self.holes = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addPoint: (GPKGMapPoint *) point{
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
            
            [mapView removeOverlay:self.polygon];
            
            CLLocationCoordinate2D * points = [GPKGMapShapeConverter getLocationCoordinatesFromPoints: self.points];
            
            NSMutableArray * holePolygons = [[NSMutableArray alloc] init];
            for(GPKGPolygonHolePoints * hole in self.holes){
                if(![hole isDeleted]){
                    CLLocationCoordinate2D * holePoints = [GPKGMapShapeConverter getLocationCoordinatesFromPoints: [hole getPoints]];
                    MKPolygon * holePolygon = [MKPolygon polygonWithCoordinates:holePoints count:[[hole getPoints] count]];
                    [GPKGUtils addObject:holePolygon toArray:holePolygons];
                }
            }
            
            self.polygon = [MKPolygon polygonWithCoordinates:points count:[self.points count] interiorPolygons:holePolygons];
            
            [mapView addOverlay:self.polygon];
        }
    }
}

-(void) removeFromMapView: (MKMapView *) mapView{
    if(self.polygon != nil){
        [mapView removeOverlay:self.polygon];
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

-(void) deletePoint: (GPKGMapPoint *) point fromMapView: (MKMapView * ) mapView{
    if([self.points containsObject:point]){
        [self.points removeObject:point];
        [mapView removeAnnotation:point];
        [self updateWithMapView:mapView];
    }
}

-(void) addNewPoint: (GPKGMapPoint *) point{
    [GPKGMapShapePoints addPointAsPolygon:point toPoints: self.points];
}

-(NSObject<GPKGShapePoints> *) createChild{
    GPKGPolygonHolePoints * hole = [[GPKGPolygonHolePoints alloc] initWithPolygonPoints:self];
    [GPKGUtils addObject:hole toArray:self.holes];
    return hole;
}

@end
