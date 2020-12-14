//
//  GPKGTileReprojectionOptimize.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/10/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojectionOptimize.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGTileReprojectionOptimize

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

-(SFPProjection *) projection{
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
