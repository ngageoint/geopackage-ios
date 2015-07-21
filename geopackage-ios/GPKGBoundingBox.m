//
//  GPKGBoundingBox.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBoundingBox.h"
#import "GPKGTileBoundingBoxUtils.h"

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

-(instancetype) initWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self initWithMinLongitude:boundingBox.minLongitude andMaxLongitude:boundingBox.maxLongitude andMinLatitude:boundingBox.minLatitude andMaxLatitude:boundingBox.maxLatitude];
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
    MKMapRect mapRect = MKMapRectNull;
    mapRect = MKMapRectUnion(mapRect, MKMapRectMake(lowerLeft.x, lowerLeft.y, 0, 0));
    mapRect= MKMapRectUnion(mapRect, MKMapRectMake(upperRight.x, upperRight.y, 0, 0));
    return mapRect;
}

-(MKCoordinateRegion) getCoordinateRegion{
    MKCoordinateSpan span = [self getSpan];
    CLLocationCoordinate2D center = [self getCenter];
    MKCoordinateRegion coordRegion = MKCoordinateRegionMake(center, span);
    return coordRegion;
}

-(MKCoordinateSpan) getSpan{
    MKCoordinateSpan span = MKCoordinateSpanMake([self.maxLatitude doubleValue] - [self.minLatitude doubleValue], [self.maxLongitude doubleValue] - [self.minLongitude doubleValue]);
    return span;
}

-(CLLocationCoordinate2D) getCenter{
    CLLocationCoordinate2D lowerLeft = CLLocationCoordinate2DMake([self.minLatitude doubleValue], [self.minLongitude doubleValue]);
    CLLocationCoordinate2D upperRight = CLLocationCoordinate2DMake([self.maxLatitude doubleValue], [self.maxLongitude doubleValue]);
    CLLocationCoordinate2D center = [GPKGTileBoundingBoxUtils pointBetweenFromLocation:lowerLeft andToLocation:upperRight];
    return center;
}

-(struct GPKGBoundingBoxSize) sizeInMeters{
    CLLocation * lowerLeft = [[CLLocation alloc] initWithLatitude:[self.minLatitude doubleValue] longitude:[self.minLongitude doubleValue]];
    CLLocation * upperLeft = [[CLLocation alloc] initWithLatitude:[self.maxLatitude doubleValue] longitude:[self.minLongitude doubleValue]];
    CLLocation * lowerRight = [[CLLocation alloc] initWithLatitude:[self.minLatitude doubleValue] longitude:[self.maxLongitude doubleValue]];
    CLLocation * upperRight = [[CLLocation alloc] initWithLatitude:[self.maxLatitude doubleValue] longitude:[self.maxLongitude doubleValue]];
    
    double width = MAX([lowerLeft distanceFromLocation:lowerRight], [upperLeft distanceFromLocation:upperRight]);
    double height = MAX([lowerLeft distanceFromLocation:upperLeft], [lowerRight distanceFromLocation:upperRight]);
    
    struct GPKGBoundingBoxSize size;
    size.width = width;
    size.height = height;
    
    return size;
}

@end
