//
//  GPKGUTMZone.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGUTMZone.h"

NSInteger const GPKG_UTM_NORTH_MIN = 32601;
NSInteger const GPKG_UTM_NORTH_MAX = 32660;
NSInteger const GPKG_UTM_SOUTH_MIN = 32701;
NSInteger const GPKG_UTM_SOUTH_MAX = 32760;

@implementation GPKGUTMZone

+(int) zone: (int) epsg{
    if(![self isZone:epsg]){
        [self invalidUTMZone:epsg];
    }
    return epsg % 100;
}

+(NSString *) latDirection: (int) epsg{
    NSString *direction = nil;
    if(epsg >= GPKG_UTM_NORTH_MIN && epsg <= GPKG_UTM_NORTH_MAX){
        direction = @"N";
    }else if(epsg >= GPKG_UTM_SOUTH_MIN && epsg <= GPKG_UTM_SOUTH_MAX){
        direction = @"S";
    }else{
        [self invalidUTMZone:epsg];
    }
    return direction;
}

+(int) centralMeridian: (int) zone{
    if(zone < 1 || zone > 60){
        [NSException raise:@"Invalid UTM Zone" format:@"Invalid UTM Zone: %d, Expected 1 - 60", zone];
    }
    return -177 + ((zone - 1) * 6);
}

+(int) falseNorthing: (int) epsg{
    int falseNorthing = 0;
    if(epsg >= GPKG_UTM_NORTH_MIN && epsg <= GPKG_UTM_NORTH_MAX){
        falseNorthing = 0;
    }else if (epsg >= GPKG_UTM_SOUTH_MIN && epsg <= GPKG_UTM_SOUTH_MAX){
        falseNorthing = 10000000;
    }else{
        [self invalidUTMZone:epsg];
    }
    return falseNorthing;
}

+(BOOL) isZone: (int) epsg{
    return [self isNorth:epsg] || [self isSouth:epsg];
}

+(BOOL) isNorth: (int) epsg{
    return epsg >= GPKG_UTM_NORTH_MIN && epsg <= GPKG_UTM_NORTH_MAX;
}

+(BOOL) isSouth: (int) epsg{
    return epsg >= GPKG_UTM_SOUTH_MIN && epsg <= GPKG_UTM_SOUTH_MAX;
}

/**
 * Throw an invalid UTM Zone error
 *
 * @param epsg
 *            EPSG
 */
+(void) invalidUTMZone: (int) epsg{
    [NSException raise:@"Invalid UTM Zone" format:@"Invalid UTM Zone EPSG: %d, Expected %d - %d or %d - %d", epsg, (int) GPKG_UTM_NORTH_MIN, (int) GPKG_UTM_NORTH_MAX, (int) GPKG_UTM_SOUTH_MIN, (int) GPKG_UTM_SOUTH_MAX];
}

@end
