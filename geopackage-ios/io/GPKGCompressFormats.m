//
//  GPKGCompressFormats.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGCompressFormats.h"
#import "GPKGUtils.h"

NSString * const GPKG_CF_JPEG_NAME = @"jpeg";
NSString * const GPKG_CF_PNG_NAME = @"png";
NSString * const GPKG_CF_NONE_NAME = @"none";

@implementation GPKGCompressFormats

+(NSString *) name: (enum GPKGCompressFormat) compressFormat{
    NSString * name = nil;
    
    switch(compressFormat){
        case GPKG_CF_JPEG:
            name = GPKG_CF_JPEG_NAME;
            break;
        case GPKG_CF_PNG:
            name = GPKG_CF_PNG_NAME;
            break;
        case GPKG_CF_NONE:
            name = GPKG_CF_NONE_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGCompressFormat) fromName: (NSString *) name{
    enum GPKGCompressFormat value = -1;
    
    if(name != nil){
        name = [name lowercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_CF_JPEG], GPKG_CF_JPEG_NAME,
                               [NSNumber numberWithInteger:GPKG_CF_PNG], GPKG_CF_PNG_NAME,
                               [NSNumber numberWithInteger:GPKG_CF_NONE], GPKG_CF_NONE_NAME,
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        value = (enum GPKGCompressFormat)[enumValue intValue];
    }
    
    return value;
}

@end
