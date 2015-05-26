//
//  GPKGProjectionFactory.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGProjectionFactory.h"

@implementation GPKGProjectionFactory

+(GPKGProjection *) getProjection: (NSNumber *) epsg{
    //TODO
    GPKGProjection *projection = [[GPKGProjection alloc] initWithEpsg:[NSNumber numberWithInt:3857]];
    return projection;
}

@end
