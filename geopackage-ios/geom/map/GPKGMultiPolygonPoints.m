//
//  GPKGMultiPolygonPoints.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMultiPolygonPoints.h"
#import "GPKGUtils.h"

@implementation GPKGMultiPolygonPoints

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.polygonPoints = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addPolygonPoints: (GPKGPolygonPoints *) polygonPoint{
    [GPKGUtils addObject:polygonPoint toArray:self.polygonPoints];
}

-(void) updateWithMapView: (MKMapView *) mapView{
    for(GPKGPolygonPoints * polygonPoint in self.polygonPoints){
        [polygonPoint updateWithMapView:mapView];
    }
}

-(void) removeFromMapView: (MKMapView *) mapView{
    for(GPKGPolygonPoints * polygonPoint in self.polygonPoints){
        [polygonPoint removeFromMapView:mapView];
    }
}

-(BOOL) isValid{
    BOOL valid = true;
    for(GPKGPolygonPoints * polygonPoint in self.polygonPoints){
        valid = [polygonPoint isValid];
        if(!valid){
            break;
        }
    }
    return valid;
}

-(BOOL) isDeleted{
    BOOL deleted = true;
    for(GPKGPolygonPoints * polygonPoint in self.polygonPoints){
        deleted = [polygonPoint isDeleted];
        if(!deleted){
            break;
        }
    }
    return deleted;
}

@end
