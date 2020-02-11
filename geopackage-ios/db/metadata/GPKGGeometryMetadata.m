//
//  GPKGGeometryMetadata.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryMetadata.h"

NSString * const GPKG_GPGM_TABLE_NAME = @"geom_metadata";
NSString * const GPKG_GPGM_COLUMN_PK1 = @"geopackage_id";
NSString * const GPKG_GPGM_COLUMN_PK2 = @"table_name";
NSString * const GPKG_GPGM_COLUMN_PK3 = @"geom_id";
NSString * const GPKG_GPGM_COLUMN_GEOPACKAGE_ID = @"geopackage_id";
NSString * const GPKG_GPGM_COLUMN_TABLE_NAME = @"table_name";
NSString * const GPKG_GPGM_COLUMN_ID = @"geom_id";
NSString * const GPKG_GPGM_COLUMN_MIN_X = @"min_x";
NSString * const GPKG_GPGM_COLUMN_MAX_X = @"max_x";
NSString * const GPKG_GPGM_COLUMN_MIN_Y = @"min_y";
NSString * const GPKG_GPGM_COLUMN_MAX_Y = @"max_y";
NSString * const GPKG_GPGM_COLUMN_MIN_Z = @"min_z";
NSString * const GPKG_GPGM_COLUMN_MAX_Z = @"max_z";
NSString * const GPKG_GPGM_COLUMN_MIN_M = @"min_m";
NSString * const GPKG_GPGM_COLUMN_MAX_M = @"max_m";

@implementation GPKGGeometryMetadata

+(NSArray<NSString *> *) columns{
    return [NSArray arrayWithObjects:
            GPKG_GPGM_COLUMN_GEOPACKAGE_ID,
            GPKG_GPGM_COLUMN_TABLE_NAME,
            GPKG_GPGM_COLUMN_ID,
            GPKG_GPGM_COLUMN_MIN_X,
            GPKG_GPGM_COLUMN_MAX_X,
            GPKG_GPGM_COLUMN_MIN_Y,
            GPKG_GPGM_COLUMN_MAX_Y,
            GPKG_GPGM_COLUMN_MIN_Z,
            GPKG_GPGM_COLUMN_MAX_Z,
            GPKG_GPGM_COLUMN_MIN_M,
            GPKG_GPGM_COLUMN_MAX_M,
            nil];
}

@end
