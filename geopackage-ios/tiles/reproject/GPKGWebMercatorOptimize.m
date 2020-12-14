//
//  GPKGWebMercatorOptimize.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/14/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGWebMercatorOptimize.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionConstants.h"
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

-(SFPProjection *) projection{
    return [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
}

-(GPKGTileGrid *) tileGrid{
    return [[GPKGTileGrid alloc] initWithMinX:0 andMinY:0 andMaxX:0 andMaxY:0];
}

-(GPKGBoundingBox *) boundingBox{
    return [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH andMinLatitudeDouble:-PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH andMaxLongitudeDouble:PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH andMaxLatitudeDouble:PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH];
}

-(GPKGTileGrid *) tileGridWithBoundingBox: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom{
    return [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:boundingBox andZoom:zoom];
}

-(GPKGBoundingBox *) boundingBoxWithTileGrid: (GPKGTileGrid *) tileGrid andZoom: (int) zoom{
    return [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithTileGrid:tileGrid andZoom:zoom];
}

@end
