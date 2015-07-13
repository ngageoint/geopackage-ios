//
//  GPKGBoundingBox.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBoundingBox.h"

@implementation GPKGBoundingBox

-(instancetype) init{
    self = [self initWithMinLongitude:[[NSDecimalNumber alloc] initWithFloat:-180.0]
                      andMaxLongitude:[[NSDecimalNumber alloc] initWithFloat:180.0]
                       andMinLatitude:[[NSDecimalNumber alloc] initWithFloat:-90.0]
                       andMaxLatitude:[[NSDecimalNumber alloc] initWithFloat:90.0]];
    return self;
}

-(instancetype) initWithMinLongitude: (NSDecimalNumber *) minLongitude
                     andMaxLongitude: (NSDecimalNumber *) maxLongitude
                      andMinLatitude: (NSDecimalNumber *) minLatitude
                      andMaxLatitude: (NSDecimalNumber *) maxLatitude{
    self = [super init];
    if(self != nil){
        self.minLongitude = minLongitude;
        self.maxLongitude = maxLongitude;
        self.minLatitude = minLatitude;
        self.maxLatitude = maxLatitude;
    }
    return self;
}

-(instancetype) initWithMinLongitudeDouble: (double) minLongitude
                     andMaxLongitudeDouble: (double) maxLongitude
                      andMinLatitudeDouble: (double) minLatitude
                      andMaxLatitudeDouble: (double) maxLatitude{
    return [self initWithMinLongitude:[[NSDecimalNumber alloc] initWithDouble:minLongitude]
                      andMaxLongitude:[[NSDecimalNumber alloc] initWithDouble:maxLongitude]
                       andMinLatitude:[[NSDecimalNumber alloc] initWithDouble:minLatitude]
                       andMaxLatitude:[[NSDecimalNumber alloc] initWithDouble:maxLatitude]];
}

-(BOOL) equals: (GPKGBoundingBox *) boundingBox{
    if(self == boundingBox){
        return true;
    }
    if(boundingBox == nil){
        return false;
    }
    if([self.maxLatitude doubleValue] != [boundingBox.maxLatitude doubleValue]){
        return false;
    }
    if([self.maxLongitude doubleValue] != [boundingBox.maxLongitude doubleValue]){
        return false;
    }
    if([self.minLatitude doubleValue] != [boundingBox.minLatitude doubleValue]){
        return false;
    }
    if([self.minLongitude doubleValue] != [boundingBox.minLongitude doubleValue]){
        return false;
    }
    return true;
}

-(MKMapRect) getMapRect{
    MKMapPoint lowerLeft = MKMapPointForCoordinate (CLLocationCoordinate2DMake([self.minLatitude doubleValue], [self.minLongitude doubleValue]));
    MKMapPoint upperRight = MKMapPointForCoordinate (CLLocationCoordinate2DMake([self.maxLatitude doubleValue], [self.maxLongitude doubleValue]));
    MKMapRect mapRect = MKMapRectMake(lowerLeft.x, lowerLeft.y, upperRight.x, upperRight.y);
    return mapRect;
}

-(MKCoordinateRegion) getCoordinateRegion{
    MKCoordinateSpan span = [self getSpan];
    CLLocationCoordinate2D center = [self getCenterWithSpan:span];
    MKCoordinateRegion coordRegion = MKCoordinateRegionMake(center, span);
    return coordRegion;
}

-(MKCoordinateSpan) getSpan{
    MKCoordinateSpan span = MKCoordinateSpanMake([self.maxLatitude doubleValue] - [self.minLatitude doubleValue], [self.maxLongitude doubleValue] - [self.minLongitude doubleValue]);
    return span;
}

-(CLLocationCoordinate2D) getCenter{
    MKCoordinateSpan span = [self getSpan];
    CLLocationCoordinate2D center = [self getCenterWithSpan:span];
    return center;
}

-(CLLocationCoordinate2D) getCenterWithSpan: (MKCoordinateSpan) span{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(([self.maxLatitude doubleValue] - span.latitudeDelta / 2), [self.maxLongitude doubleValue] - span.longitudeDelta / 2);
    return center;
}

@end
