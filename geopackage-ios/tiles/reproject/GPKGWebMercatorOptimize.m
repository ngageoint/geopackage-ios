//
//  GPKGWebMercatorOptimize.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/14/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGWebMercatorOptimize.h"
#import "PROJProjectionFactory.h"
#import "PROJProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGWebMercatorOptimize

+(GPKGWebMercatorOptimize *) create{
    return [[GPKGWebMercatorOptimize alloc] init];
}

+(GPKGWebMercatorOptimize *) createWorld{
    return [[GPKGWebMercatorOptimize alloc] initWithWorld:YES];
}

-(instancetype) init{
    return [super init];
}

-(instancetype) initWithWorld: (BOOL) world{
    return [super initWithWorld:world];
}

-(PROJProjection *) projection{
    return [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
}

-(GPKGTileGrid *) tileGrid{
    return [[GPKGTileGrid alloc] initWithMinX:0 andMinY:0 andMaxX:0 andMaxY:0];
}

-(GPKGBoundingBox *) boundingBox{
    return [GPKGBoundingBox worldWebMercator];
}

-(GPKGTileGrid *) tileGridWithBoundingBox: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom{
    return [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:boundingBox andZoom:zoom];
}

-(GPKGBoundingBox *) boundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    return [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithTileGrid:tileGrid andZoom:zoom];
}

@end
