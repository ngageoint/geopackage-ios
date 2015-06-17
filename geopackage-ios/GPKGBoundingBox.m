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

@end
