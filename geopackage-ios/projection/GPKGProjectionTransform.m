//
//  GPKGProjectionTransform.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGProjectionTransform.h"
#import "GPKGUtils.h"

@implementation GPKGProjectionTransform

-(instancetype) initWithFrom: (GPKGProjection *) fromProjection andTo: (GPKGProjection *) toProjection{
    self = [super init];
    if(self != nil){
        self.fromProjection = fromProjection;
        self.toProjection = toProjection;
    }
    return self;
}

// TODO
//-(WKBPoint *) transformWithPoint: (WKBPoint *) from{}

-(GPKGBoundingBox *) transformWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    //TODO
    return boundingBox;
}

-(NSArray *) transformWithX: (double) x andY: (double) y{
    //TODO
    NSMutableArray *coord = [[NSMutableArray alloc] initWithCapacity:2];
    [GPKGUtils addObject:[NSNumber numberWithDouble:x] toArray:coord];
    [GPKGUtils addObject:[NSNumber numberWithDouble:y] toArray:coord];
    return coord;
}

@end
