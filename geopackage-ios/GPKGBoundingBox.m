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

-(WKBGeometryEnvelope *) buildEnvelope{
    WKBGeometryEnvelope * envelope = [[WKBGeometryEnvelope alloc] init];
    [envelope setMinX:self.minLongitude];
    [envelope setMaxX:self.maxLongitude];
    [envelope setMinY:self.minLatitude];
    [envelope setMaxY:self.maxLatitude];
    return envelope;
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
    double minLongitude = [self.minLongitude doubleValue];
    double maxLongitude = [self.maxLongitude doubleValue];
    CLLocationCoordinate2D lowerLeft = CLLocationCoordinate2DMake([self.minLatitude doubleValue], minLongitude);
    CLLocationCoordinate2D upperRight = CLLocationCoordinate2DMake([self.maxLatitude doubleValue], maxLongitude);
    CLLocationCoordinate2D center = [GPKGTileBoundingBoxUtils pointBetweenFromLocation:lowerLeft andToLocation:upperRight];
    if(minLongitude + 360.0 == maxLongitude){
        center = CLLocationCoordinate2DMake(center.latitude, maxLongitude - 180.0);
    }
    return center;
}

-(struct GPKGBoundingBoxSize) sizeInMeters{
    
    CLLocationCoordinate2D center = [self getCenter];
    
    CLLocationCoordinate2D left = CLLocationCoordinate2DMake(center.latitude, [self.minLongitude doubleValue]);
    CLLocationCoordinate2D right = CLLocationCoordinate2DMake(center.latitude, [self.maxLongitude doubleValue]);
    double width1 = [GPKGTileBoundingBoxUtils distanceBetweenLocation:left andLocation:center];
    double width2 = [GPKGTileBoundingBoxUtils distanceBetweenLocation:center andLocation:right];
    
    CLLocationCoordinate2D upper = CLLocationCoordinate2DMake([self.maxLatitude doubleValue], center.longitude);
    CLLocationCoordinate2D lower = CLLocationCoordinate2DMake([self.minLatitude doubleValue], center.longitude);
    double height = [GPKGTileBoundingBoxUtils distanceBetweenLocation:lower andLocation:upper];
    
    struct GPKGBoundingBoxSize size;
    size.width = width1 + width2;
    size.height = height;
    
    return size;
}

@end
