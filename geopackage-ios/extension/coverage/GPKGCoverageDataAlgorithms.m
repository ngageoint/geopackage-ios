//
//  GPKGCoverageDataAlgorithms.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataAlgorithms.h"
#import "GPKGUtils.h"

NSString * const GPKG_ETA_NEAREST_NEIGHBOR_NAME = @"Nearest Neighbor";
NSString * const GPKG_ETA_BILINEAR_NAME = @"Bilinear";
NSString * const GPKG_ETA_BICUBIC_NAME = @"Bicubic";

@implementation GPKGCoverageDataAlgorithms

+(NSString *) name: (enum GPKGCoverageDataAlgorithm) algorithm{
    NSString * name = nil;
    
    switch(algorithm){
        case GPKG_ETA_NEAREST_NEIGHBOR:
            name = GPKG_ETA_NEAREST_NEIGHBOR_NAME;
            break;
        case GPKG_ETA_BILINEAR:
            name = GPKG_ETA_BILINEAR_NAME;
            break;
        case GPKG_ETA_BICUBIC:
            name = GPKG_ETA_BICUBIC_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGCoverageDataAlgorithm) fromName: (NSString *) name{
    enum GPKGCoverageDataAlgorithm value = -1;
    
    if(name != nil){
        name = [name uppercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_ETA_NEAREST_NEIGHBOR], [GPKG_ETA_NEAREST_NEIGHBOR_NAME uppercaseString],
                               [NSNumber numberWithInteger:GPKG_ETA_BILINEAR], [GPKG_ETA_BILINEAR_NAME uppercaseString],
                               [NSNumber numberWithInteger:GPKG_ETA_BICUBIC], [GPKG_ETA_BICUBIC_NAME uppercaseString],
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        value = (enum GPKGCoverageDataAlgorithm)[enumValue intValue];
    }
    
    return value;
}

@end
