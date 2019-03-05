//
//  GPKGTileUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/5/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGTileUtils.h"
#import <UIKit/UIKit.h>

@implementation GPKGTileUtils

+(float) tileLength{
    float length;
    if([UIScreen mainScreen].nativeScale <= SCALE_FACTOR_DEFAULT){
        length = TILE_PIXELS_DEFAULT;
    }else{
        length = TILE_PIXELS_HIGH;
    }
    return length;
}

@end
