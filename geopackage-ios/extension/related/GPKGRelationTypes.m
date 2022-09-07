//
//  GPKGRelationTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelationTypes.h"
#import "GPKGUtils.h"
#import "GPKGContentsDataTypes.h"

NSString * const GPKG_RT_FEATURES_NAME = @"features";
NSString * const GPKG_RT_SIMPLE_ATTRIBUTES_NAME = @"simple_attributes";
NSString * const GPKG_RT_MEDIA_NAME = @"media";
NSString * const GPKG_RT_ATTRIBUTES_NAME = @"attributes";
NSString * const GPKG_RT_TILES_NAME = @"tiles";

@implementation GPKGRelationTypes

+(NSString *) name: (enum GPKGRelationType) relationType{
    NSString *name = nil;
    
    switch(relationType){
        case GPKG_RT_FEATURES:
            name = GPKG_RT_FEATURES_NAME;
            break;
        case GPKG_RT_SIMPLE_ATTRIBUTES:
            name = GPKG_RT_SIMPLE_ATTRIBUTES_NAME;
            break;
        case GPKG_RT_MEDIA:
            name = GPKG_RT_MEDIA_NAME;
            break;
        case GPKG_RT_ATTRIBUTES:
            name = GPKG_RT_ATTRIBUTES_NAME;
            break;
        case GPKG_RT_TILES:
            name = GPKG_RT_TILES_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGRelationType) fromName: (NSString *) name{
    enum GPKGRelationType value = -1;
    
    if(name != nil){
        name = [name lowercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_RT_FEATURES], GPKG_RT_FEATURES_NAME,
                               [NSNumber numberWithInteger:GPKG_RT_SIMPLE_ATTRIBUTES], GPKG_RT_SIMPLE_ATTRIBUTES_NAME,
                               [NSNumber numberWithInteger:GPKG_RT_MEDIA], GPKG_RT_MEDIA_NAME,
                               [NSNumber numberWithInteger:GPKG_RT_ATTRIBUTES], GPKG_RT_ATTRIBUTES_NAME,
                               [NSNumber numberWithInteger:GPKG_RT_TILES], GPKG_RT_TILES_NAME,
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        if(enumValue != nil){
            value = (enum GPKGRelationType)[enumValue intValue];
        }
    }
    
    return value;
}

+(NSString *) dataType: (enum GPKGRelationType) relationType{
    NSString *dataType = nil;
    
    switch(relationType){
        case GPKG_RT_FEATURES:
            dataType = GPKG_CDT_FEATURES_NAME;
            break;
        case GPKG_RT_SIMPLE_ATTRIBUTES:
            dataType = GPKG_CDT_ATTRIBUTES_NAME;
            break;
        case GPKG_RT_MEDIA:
            dataType = GPKG_CDT_ATTRIBUTES_NAME;
            break;
        case GPKG_RT_ATTRIBUTES:
            dataType = GPKG_CDT_ATTRIBUTES_NAME;
            break;
        case GPKG_RT_TILES:
            dataType = GPKG_CDT_TILES_NAME;
            break;
    }
    
    return dataType;
}

@end
