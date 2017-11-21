//
//  GPKGLocationBoundingBox.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/30/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGLocationBoundingBox.h"

@implementation GPKGLocationBoundingBox

-(instancetype) initWithLeft: (CLLocationCoordinate2D) left andUp: (CLLocationCoordinate2D) up andRight: (CLLocationCoordinate2D) right andDown: (CLLocationCoordinate2D) down{
    self = [super init];
    if(self != nil){
        self.leftCoordinate = left;
        self.upCoordinate = up;
        self.rightCoordinate = right;
        self.downCoordinate = down;
    }
    return self;
}

@end
