//
//  GPKGGriddedCoverageEncodingTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/18/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGGriddedCoverageEncodingTypes.h"
#import "GPKGUtils.h"

NSString * const GPKG_GCET_CENTER_NAME = @"grid-value-is-center";
NSString * const GPKG_GCET_AREA_NAME = @"grid-value-is-area";
NSString * const GPKG_GCET_CORNER_NAME = @"grid-value-is-corner";

@implementation GPKGGriddedCoverageEncodingTypes

+(NSString *) name: (enum GPKGGriddedCoverageEncodingType) griddedCoverageEncodingType{
    NSString * name = nil;
    
    switch(griddedCoverageEncodingType){
        case GPKG_GCET_CENTER:
            name = GPKG_GCET_CENTER_NAME;
            break;
        case GPKG_GCET_AREA:
            name = GPKG_GCET_AREA_NAME;
            break;
        case GPKG_GCET_CORNER:
            name = GPKG_GCET_CORNER_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGGriddedCoverageEncodingType) fromName: (NSString *) name{
    enum GPKGGriddedCoverageEncodingType value = -1;
    
    if(name != nil){
        name = [name lowercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_GCET_CENTER], GPKG_GCET_CENTER_NAME,
                               [NSNumber numberWithInteger:GPKG_GCET_AREA], GPKG_GCET_AREA_NAME,
                               [NSNumber numberWithInteger:GPKG_GCET_CORNER], GPKG_GCET_CORNER_NAME,
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        if(enumValue != nil){
            value = (enum GPKGGriddedCoverageEncodingType)[enumValue intValue];
        }
    }
    
    return value;
}

@end
