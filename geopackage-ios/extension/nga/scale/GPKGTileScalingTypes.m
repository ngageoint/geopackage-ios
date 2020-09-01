//
//  GPKGTileScalingTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGTileScalingTypes.h"
#import "GPKGUtils.h"

NSString * const GPKG_TSC_IN_NAME = @"in";
NSString * const GPKG_TSC_OUT_NAME = @"out";
NSString * const GPKG_TSC_IN_OUT_NAME = @"in_out";
NSString * const GPKG_TSC_OUT_IN_NAME = @"out_in";
NSString * const GPKG_TSC_CLOSEST_IN_OUT_NAME = @"closest_in_out";
NSString * const GPKG_TSC_CLOSEST_OUT_IN_NAME = @"closest_out_in";

@implementation GPKGTileScalingTypes

+(NSString *) name: (enum GPKGTileScalingType) tileScalingType{
    NSString * name = nil;
    
    switch(tileScalingType){
        case GPKG_TSC_IN:
            name = GPKG_TSC_IN_NAME;
            break;
        case GPKG_TSC_OUT:
            name = GPKG_TSC_OUT_NAME;
            break;
        case GPKG_TSC_IN_OUT:
            name = GPKG_TSC_IN_OUT_NAME;
            break;
        case GPKG_TSC_OUT_IN:
            name = GPKG_TSC_OUT_IN_NAME;
            break;
        case GPKG_TSC_CLOSEST_IN_OUT:
            name = GPKG_TSC_CLOSEST_IN_OUT_NAME;
            break;
        case GPKG_TSC_CLOSEST_OUT_IN:
            name = GPKG_TSC_CLOSEST_OUT_IN_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGTileScalingType) fromName: (NSString *) name{
    enum GPKGTileScalingType value = -1;
    
    if(name != nil){
        name = [name lowercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_TSC_IN], GPKG_TSC_IN_NAME,
                               [NSNumber numberWithInteger:GPKG_TSC_OUT], GPKG_TSC_OUT_NAME,
                               [NSNumber numberWithInteger:GPKG_TSC_IN_OUT], GPKG_TSC_IN_OUT_NAME,
                               [NSNumber numberWithInteger:GPKG_TSC_OUT_IN], GPKG_TSC_OUT_IN_NAME,
                               [NSNumber numberWithInteger:GPKG_TSC_CLOSEST_IN_OUT], GPKG_TSC_CLOSEST_IN_OUT_NAME,
                               [NSNumber numberWithInteger:GPKG_TSC_CLOSEST_OUT_IN], GPKG_TSC_CLOSEST_OUT_IN_NAME,
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        if(enumValue != nil){
            value = (enum GPKGTileScalingType)[enumValue intValue];
        }
    }
    
    return value;
}

@end
