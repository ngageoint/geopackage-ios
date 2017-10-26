//
//  GPKGBoundingBox.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBoundingBox.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGProjectionConstants.h"

@implementation GPKGBoundingBox

-(instancetype) init{
    self = [self initWithMinLongitude:[[NSDecimalNumber alloc] initWithFloat:-PROJ_WGS84_HALF_WORLD_LON_WIDTH]
                      andMaxLongitude:[[NSDecimalNumber alloc] initWithFloat:PROJ_WGS84_HALF_WORLD_LON_WIDTH]
                       andMinLatitude:[[NSDecimalNumber alloc] initWithFloat:-PROJ_WGS84_HALF_WORLD_LAT_HEIGHT]
                       andMaxLatitude:[[NSDecimalNumber alloc] initWithFloat:PROJ_WGS84_HALF_WORLD_LAT_HEIGHT]];
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

-(instancetype) initWithGeometryEnvelope: (WKBGeometryEnvelope *) envelope{
    return [self initWithMinLongitude:envelope.minX andMaxLongitude:envelope.maxX andMinLatitude:envelope.minY andMaxLatitude:envelope.maxY];
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
    if(minLongitude + (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH) == maxLongitude){
        center = CLLocationCoordinate2DMake(center.latitude, maxLongitude - PROJ_WGS84_HALF_WORLD_LON_WIDTH);
    }
    if(center.longitude > PROJ_WGS84_HALF_WORLD_LON_WIDTH){
        center.longitude -= (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH);
    }else if(center.longitude < -PROJ_WGS84_HALF_WORLD_LON_WIDTH){
        center.longitude += (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH);
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

-(GPKGBoundingBox *) complementaryWithMaxLongitude: (double) maxProjectionLongitude{
    
    GPKGBoundingBox * complementary = nil;
    
    NSDecimalNumber *adjust = nil;
    
    if([self.maxLongitude doubleValue] > maxProjectionLongitude){
        if([self.minLongitude doubleValue] >= -maxProjectionLongitude){
            adjust = [[NSDecimalNumber alloc] initWithDouble:-2 * maxProjectionLongitude];
        }
    }else if([self.minLongitude doubleValue] < -maxProjectionLongitude){
        if([self.maxLongitude doubleValue] <= maxProjectionLongitude){
            adjust = [[NSDecimalNumber alloc] initWithDouble:2 * maxProjectionLongitude];
        }
    }
    
    if(adjust != nil){
        complementary = [[GPKGBoundingBox alloc] initWithBoundingBox:self];
        [complementary setMinLongitude:[complementary.minLongitude decimalNumberByAdding:adjust]];
        [complementary setMaxLongitude:[complementary.maxLongitude decimalNumberByAdding:adjust]];
    }
            
    return complementary;
}

-(GPKGBoundingBox *) complementaryWgs84{
    return [self complementaryWithMaxLongitude:PROJ_WGS84_HALF_WORLD_LON_WIDTH];
}

-(GPKGBoundingBox *) complementaryWebMercator{
    return [self complementaryWithMaxLongitude:PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH];
}

-(GPKGBoundingBox *) boundCoordinatesWithMaxLongitude: (double) maxProjectionLongitude{

    GPKGBoundingBox *bounded = [[GPKGBoundingBox alloc] initWithBoundingBox:self];
    
    double minLongitude = fmod([self.minLongitude doubleValue] + maxProjectionLongitude, 2 * maxProjectionLongitude)
        - maxProjectionLongitude;
    double maxLongitude = fmod([self.maxLongitude doubleValue] + maxProjectionLongitude, 2 * maxProjectionLongitude)
        - maxProjectionLongitude;

    [bounded setMinLongitude:[[NSDecimalNumber alloc] initWithDouble:minLongitude]];
    [bounded setMaxLongitude:[[NSDecimalNumber alloc] initWithDouble:maxLongitude]];

    return bounded;
}

-(GPKGBoundingBox *) boundWgs84Coordinates{
    return [self boundCoordinatesWithMaxLongitude:PROJ_WGS84_HALF_WORLD_LON_WIDTH];
}

-(GPKGBoundingBox *) boundWebMercatorCoordinates{
    return [self boundCoordinatesWithMaxLongitude:PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH];
}

-(GPKGBoundingBox *) expandCoordinatesWithMaxLongitude: (double) maxProjectionLongitude{
    
    GPKGBoundingBox *expanded = [[GPKGBoundingBox alloc] initWithBoundingBox:self];
    
    double minLongitude = [self.minLongitude doubleValue];
    double maxLongitude = [self.maxLongitude doubleValue];
    
    if (minLongitude > maxLongitude) {
        int worldWraps = 1 + (int) ((minLongitude - maxLongitude) / (2 * maxProjectionLongitude));
        maxLongitude += (worldWraps * 2 * maxProjectionLongitude);
        [expanded setMaxLongitude:[[NSDecimalNumber alloc] initWithDouble:maxLongitude]];
    }
    
    return expanded;
}

-(GPKGBoundingBox *) expandWgs84Coordinates{
    return [self expandCoordinatesWithMaxLongitude:PROJ_WGS84_HALF_WORLD_LON_WIDTH];
}

-(GPKGBoundingBox *) expandWebMercatorCoordinates{
    return [self expandCoordinatesWithMaxLongitude:PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH];
}

@end
