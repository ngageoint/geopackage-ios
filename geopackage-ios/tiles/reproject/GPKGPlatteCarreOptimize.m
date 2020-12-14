//
//  GPKGPlatteCarreOptimize.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/14/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGPlatteCarreOptimize.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGPlatteCarreOptimize

+(GPKGPlatteCarreOptimize *) create{
    return [[GPKGPlatteCarreOptimize alloc] init];
}

+(GPKGPlatteCarreOptimize *) createWorld{
    return [[GPKGPlatteCarreOptimize alloc] initWithWorld:YES];
}

-(instancetype) init{
    return [super init];
}

-(instancetype) initWithWorld: (BOOL) world{
    return [super initWithWorld:world];
}

-(SFPProjection *) projection{
    return [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
}

-(GPKGTileGrid *) tileGrid{
    return [[GPKGTileGrid alloc] initWithMinX:0 andMinY:0 andMaxX:1 andMaxY:0];
}

-(GPKGBoundingBox *) boundingBox{
    return [[GPKGBoundingBox alloc] init];
}

-(GPKGTileGrid *) tileGridWithBoundingBox: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom{
    return [GPKGTileBoundingBoxUtils tileGridWithWgs84BoundingBox:boundingBox andZoom:zoom];
}

-(GPKGBoundingBox *) boundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    return [GPKGTileBoundingBoxUtils wgs84BoundingBoxWithTileGrid:tileGrid andZoom:zoom];
}

@end
