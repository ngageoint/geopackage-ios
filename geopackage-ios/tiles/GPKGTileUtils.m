//
//  GPKGTileUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/5/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGTileUtils.h"
#import <UIKit/UIKit.h>

int const GPKG_TU_TILE_DP = 256;
int const GPKG_TU_TILE_PIXELS_DEFAULT = 256;
int const GPKG_TU_TILE_PIXELS_HIGH = 512;
float const GPKG_TU_SCALE_FACTOR_DEFAULT = 2.0f;

@implementation GPKGTileUtils

+(float) tileLength{
    return [self tileLengthWithScale:[UIScreen mainScreen].nativeScale];
}

+(float) tileLengthWithScale: (float) scale{
    float length;
    if(scale <= GPKG_TU_SCALE_FACTOR_DEFAULT){
        length = GPKG_TU_TILE_PIXELS_DEFAULT;
    }else{
        length = GPKG_TU_TILE_PIXELS_HIGH;
    }
    return length;
}

@end
