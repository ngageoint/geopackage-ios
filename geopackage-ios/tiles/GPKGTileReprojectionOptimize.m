//
//  GPKGTileReprojectionOptimize.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/10/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojectionOptimize.h"

@implementation GPKGTileReprojectionOptimize

+(GPKGTileReprojectionOptimize *) webMercator{
    return [[GPKGTileReprojectionOptimize alloc] initWithType:GPKG_TRO_WEB_MERCATOR];
}

+(GPKGTileReprojectionOptimize *) platteCarre{
    return [[GPKGTileReprojectionOptimize alloc] initWithType:GPKG_TRO_PLATTE_CARRE];
}

+(GPKGTileReprojectionOptimize *) webMercatorWorld{
    return [[GPKGTileReprojectionOptimize alloc] initWithType:GPKG_TRO_WEB_MERCATOR andWorld:YES];
}

+(GPKGTileReprojectionOptimize *) platteCarreWorld{
    return [[GPKGTileReprojectionOptimize alloc] initWithType:GPKG_TRO_PLATTE_CARRE andWorld:YES];
}

-(instancetype) initWithType: (enum GPKGTileReprojectionOptimizeType) type{
    return [self initWithType:type andWorld:NO];
}

-(instancetype) initWithType: (enum GPKGTileReprojectionOptimizeType) type andWorld: (BOOL) world{
    self = [super init];
    if(self != nil){
        _type = type;
        _world = world;
    }
    return self;
}

@end
