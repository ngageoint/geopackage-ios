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
            
            GPKGPolygonOptions *options = self.polygon.options;
            
            CLLocationCoordinate2D * points = [GPKGMapShapeConverter locationCoordinatesFromPoints: self.points];
            
            NSMutableArray * holePolygons = [[NSMutableArray alloc] init];
            for(GPKGPolygonHolePoints * hole in self.holes){
                if(![hole isDeleted]){
                    CLLocationCoordinate2D * holePoints = [GPKGMapShapeConverter locationCoordinatesFromPoints: [hole points]];
                    GPKGPolygon * holePolygon = [GPKGPolygon polygonWithCoordinates:holePoints count:[[hole points] count]];
                    free(holePoints);
                    [GPKGUtils addObject:holePolygon toArray:holePolygons];
                }
            }
            
            self.polygon = [GPKGPolygon polygonWithCoordinates:points count:[self.points count] interiorPolygons:holePolygons];
            
            [self.polygon setOptions:options];
            
            free(points);
            
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

-(NSArray *) points{
    return _points;
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

-(void) hidden: (BOOL) hidden fromMapView: (MKMapView *) mapView{
    if(self.polygon != nil){
        if(hidden){
            [mapView removeOverlay:self.polygon];
        }else{
            [mapView addOverlay:self.polygon];
        }
    }
    for(GPKGMapPoint * point in self.points){
        [point hidden:hidden];
    }
    for(GPKGPolygonHolePoints * hole in self.holes){
        [hole hidden: hidden fromMapView:mapView];
    }
}

-(void) hiddenPoints: (BOOL) hidden{
    for(GPKGMapPoint * point in self.points){
        [point hidden:hidden];
    }
    for(GPKGPolygonHolePoints * hole in self.holes){
        [hole hiddenPoints: hidden];
    }
}

-(NSObject<GPKGShapePoints> *) createChild{
    GPKGPolygonHolePoints * hole = [[GPKGPolygonHolePoints alloc] initWithPolygonPoints:self];
    [GPKGUtils addObject:hole toArray:self.holes];
    return hole;
}

@end
