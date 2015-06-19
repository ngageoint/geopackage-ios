//
//  GPKGMultiPolylinePoints.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMultiPolylinePoints.h"
#import "GPKGUtils.h"

@implementation GPKGMultiPolylinePoints

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.polylinePoints = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addPolylinePoints: (GPKGPolylinePoints *) polylinePoint{
    [GPKGUtils addObject:polylinePoint toArray:self.polylinePoints];
}

-(void) updateWithMapView: (MKMapView *) mapView{
    for(GPKGPolylinePoints * polylinePoint in self.polylinePoints){
        [polylinePoint updateWithMapView:mapView];
    }
}

-(void) removeFromMapView: (MKMapView *) mapView{
    for(GPKGPolylinePoints * polylinePoint in self.polylinePoints){
        [polylinePoint removeFromMapView:mapView];
    }
}

-(BOOL) isValid{
    BOOL valid = true;
    for(GPKGPolylinePoints * polylinePoint in self.polylinePoints){
        valid = [polylinePoint isValid];
        if(!valid){
            break;
        }
    }
    return valid;
}

-(BOOL) isDeleted{
    BOOL deleted = true;
    for(GPKGPolylinePoints * polylinePoint in self.polylinePoints){
        deleted = [polylinePoint isDeleted];
        if(!deleted){
            break;
        }
    }
    return deleted;
}

@end
