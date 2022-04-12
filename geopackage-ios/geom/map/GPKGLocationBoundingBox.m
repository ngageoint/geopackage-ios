//
//  GPKGLocationBoundingBox.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/30/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGLocationBoundingBox.h"

@implementation GPKGLocationBoundingBox

-(instancetype) initWithCoordinate: (CLLocationCoordinate2D) coordinate{
    self = [self initWithLeft:coordinate andUp:coordinate andRight:coordinate andDown:coordinate];
    return self;
}

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

-(CLLocationCoordinate2D) westCoordinate{
    return _leftCoordinate;
}

-(CLLocationCoordinate2D) northwestCoordinate{
    return CLLocationCoordinate2DMake(_upCoordinate.latitude, _leftCoordinate.longitude);
}

-(CLLocationCoordinate2D) northCoordinate{
    return _upCoordinate;
}

-(CLLocationCoordinate2D) northeastCoordinate{
    return CLLocationCoordinate2DMake(_upCoordinate.latitude, _rightCoordinate.longitude);
}

-(CLLocationCoordinate2D) eastCoordinate{
    return _rightCoordinate;
}

-(CLLocationCoordinate2D) southeastCoordinate{
    return CLLocationCoordinate2DMake(_downCoordinate.latitude, _rightCoordinate.longitude);
}

-(CLLocationCoordinate2D) southCoordinate{
    return _downCoordinate;
}

-(CLLocationCoordinate2D) southwestCoordinate{
    return CLLocationCoordinate2DMake(_downCoordinate.latitude, _leftCoordinate.longitude);
}

@end
