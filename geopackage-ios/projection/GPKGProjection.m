//
//  GPKGProjection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGProjection.h"

@implementation GPKGProjection

-(instancetype) initWithEpsg: (NSNumber *) epsg{
    self = [super init];
    if(self != nil){
        self.epsg = epsg;
    }
    return self;
}

-(double) toMeters: (double) value{
    //TODO
    return value;
}

@end
