//
//  GPKGDgiwgConstants.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgConstants.h"

NSInteger const GPKG_DGIWG_TILE_WIDTH = 256;
NSInteger const GPKG_DGIWG_TILE_HEIGHT = 256;
NSInteger const GPKG_DGIWG_MIN_ZOOM_LEVEL = 0;
NSInteger const GPKG_DGIWG_MAX_ZOOM_LEVEL = 24;
NSString * const GPKG_DGIWG_DESCRIPTION_UNKNOWN = @"unknown";
NSString * const GPKG_DGIWG_DESCRIPTION_TBD = @"tbd";
NSString * const GPKG_DGIWG_METADATA_MIME_TYPE = @"text/xml";
NSString * const GPKG_DGIWG_DMF_BASE_URI = @"https://dgiwg.org/std/dmf/";
NSString * const GPKG_DGIWG_DMF_2_0_URI = @"https://dgiwg.org/std/dmf/2.0";
NSString * const GPKG_DGIWG_DMF_DEFAULT_URI = GPKG_DGIWG_DMF_2_0_URI;
NSString * const GPKG_DGIWG_NMIS_BASE_URI = @"https://nsgreg-api.nga.mil/schema/nas/";
NSString * const GPKG_DGIWG_NMIS_8_0_URI = @"https://nsgreg-api.nga.mil/schema/nas/8.0";
NSString * const GPKG_DGIWG_NMIS_DEFAULT_URI = GPKG_DGIWG_NMIS_8_0_URI;

@implementation GPKGDgiwgConstants

@end
