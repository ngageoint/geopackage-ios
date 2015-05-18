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

@end
