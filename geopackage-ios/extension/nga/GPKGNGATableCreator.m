//
//  GPKGNGATableCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/14/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGNGATableCreator.h"

NSString * const GPKG_NGA_TABLES = @"nga";

@implementation GPKGNGATableCreator

-(NSString *) properties{
    return GPKG_NGA_TABLES;
}

@end
