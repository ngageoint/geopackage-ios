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

@implementation GPKGRelationTypes

+(NSString *) name: (enum GPKGRelationType) relationType{
    NSString * name = nil;
    
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
    NSString * dataType = nil;
    
    switch(relationType){
        case GPKG_RT_FEATURES:
            dataType = [GPKGContentsDataTypes name:GPKG_CDT_FEATURES];
            break;
        case GPKG_RT_SIMPLE_ATTRIBUTES:
            dataType = [GPKGContentsDataTypes name:GPKG_CDT_ATTRIBUTES];
            break;
        case GPKG_RT_MEDIA:
            dataType = [GPKGContentsDataTypes name:GPKG_CDT_ATTRIBUTES];
            break;
    }
    
    return dataType;
}

@end
