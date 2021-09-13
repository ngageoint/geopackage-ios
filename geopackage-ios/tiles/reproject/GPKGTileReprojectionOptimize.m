//
//  GPKGTileReprojectionOptimize.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/10/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojectionOptimize.h"
#import "PROJProjectionFactory.h"
#import "PROJProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGWebMercatorOptimize.h"
#import "GPKGPlatteCarreOptimize.h"

@implementation GPKGTileReprojectionOptimize

+(GPKGTileReprojectionOptimize *) webMercator{
    return [GPKGWebMercatorOptimize create];
}

+(GPKGTileReprojectionOptimize *) platteCarre{
    return [GPKGPlatteCarreOptimize create];
}

+(GPKGTileReprojectionOptimize *) webMercatorWorld{
    return [GPKGWebMercatorOptimize createWorld];
}

+(GPKGTileReprojectionOptimize *) platteCarreWorld{
    return [GPKGPlatteCarreOptimize createWorld];
}

-(instancetype) init{
    return [self initWithWorld:NO];
}

-(instancetype) initWithWorld: (BOOL) world{
    self = [super init];
    if(self != nil){
        _world = world;
    }
    return self;
}

-(PROJProjection *) projection{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGTileGrid *) tileGrid{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGBoundingBox *) boundingBox{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGTileGrid *) tileGridWithBoundingBox: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGBoundingBox *) boundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
