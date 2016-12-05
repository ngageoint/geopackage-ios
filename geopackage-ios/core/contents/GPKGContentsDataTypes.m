//
//  GPKGContentsDataTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/31/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGContentsDataTypes.h"
#import "GPKGUtils.h"

NSString * const GPKG_CDT_FEATURES_NAME = @"features";
NSString * const GPKG_CDT_TILES_NAME = @"tiles";
NSString * const GPKG_CDT_ATTRIBUTES_NAME = @"attributes";
NSString * const GPKG_CDT_ELEVATION_TILES_NAME = @"2d-gridded-coverage";

@implementation GPKGContentsDataTypes

+(NSString *) name: (enum GPKGContentsDataType) contentsDataType{
    NSString * name = nil;
    
    switch(contentsDataType){
        case GPKG_CDT_FEATURES:
            name = GPKG_CDT_FEATURES_NAME;
            break;
        case GPKG_CDT_TILES:
            name = GPKG_CDT_TILES_NAME;
            break;
        case GPKG_CDT_ATTRIBUTES:
            name = GPKG_CDT_ATTRIBUTES_NAME;
            break;
        case GPKG_CDT_ELEVATION_TILES:
            name = GPKG_CDT_ELEVATION_TILES_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGContentsDataType) fromName: (NSString *) name{
    enum GPKGContentsDataType value = -1;
    
    if(name != nil){
        name = [name lowercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_CDT_FEATURES], GPKG_CDT_FEATURES_NAME,
                               [NSNumber numberWithInteger:GPKG_CDT_TILES], GPKG_CDT_TILES_NAME,
                               [NSNumber numberWithInteger:GPKG_CDT_ATTRIBUTES], GPKG_CDT_ATTRIBUTES_NAME,
                               [NSNumber numberWithInteger:GPKG_CDT_ELEVATION_TILES], GPKG_CDT_ELEVATION_TILES_NAME,
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        value = (enum GPKGContentsDataType)[enumValue intValue];
    }
    
    return value;
}

@end
