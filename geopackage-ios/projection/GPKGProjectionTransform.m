//
//  GPKGProjectionTransform.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGProjectionTransform.h"
#import "GPKGUtils.h"
#import "GPKGProjectionFactory.h"

@implementation GPKGProjectionTransform

-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToProjection: (GPKGProjection *) toProjection{
    self = [super init];
    if(self != nil){
        self.fromProjection = fromProjection;
        self.toProjection = toProjection;
    }
    return self;
}

-(instancetype) initWithFromEpsg: (int) fromEpsg andToEpsg: (int) toEpsg{
    
    GPKGProjection * fromProjection = [GPKGProjectionFactory getProjectionWithInt:fromEpsg];
    GPKGProjection * toProjection = [GPKGProjectionFactory getProjectionWithInt:toEpsg];
    
    return [self initWithFromProjection:fromProjection andToProjection:toProjection];
}

-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToEpsg: (int) toEpsg{
    
    GPKGProjection * toProjection = [GPKGProjectionFactory getProjectionWithInt:toEpsg];
    
    return [self initWithFromProjection:fromProjection andToProjection:toProjection];
}

-(instancetype) initWithFromEpsg: (int) fromEpsg andToProjection: (GPKGProjection *) toProjection{
    
    GPKGProjection * fromProjection = [GPKGProjectionFactory getProjectionWithInt:fromEpsg];
    
    return [self initWithFromProjection:fromProjection andToProjection:toProjection];
}

-(WKBPoint *) transformWithPoint: (WKBPoint *) from{
    //TODO
    return from;
}

-(GPKGBoundingBox *) transformWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    //TODO
    return boundingBox;
}

-(NSArray *) transformWithX: (double) x andY: (double) y{
    //TODO
    NSMutableArray *coord = [[NSMutableArray alloc] initWithCapacity:2];
    [GPKGUtils addObject:[NSDecimalNumber numberWithDouble:x] toArray:coord];
    [GPKGUtils addObject:[NSDecimalNumber numberWithDouble:y] toArray:coord];
    return coord;
}

@end
