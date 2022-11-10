//
//  GPKGDgiwgConstants.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Tile Width
 */
extern NSInteger const GPKG_DGIWG_TILE_WIDTH;

/**
 * Tile Height
 */
extern NSInteger const GPKG_DGIWG_TILE_HEIGHT;

/**
 * Minimum Zoom Level
 */
extern NSInteger const GPKG_DGIWG_MIN_ZOOM_LEVEL;

/**
 * Maximum Zoom Level
 */
extern NSInteger const GPKG_DGIWG_MAX_ZOOM_LEVEL;

/**
 * Invalid unknown description
 */
extern NSString * const GPKG_DGIWG_DESCRIPTION_UNKNOWN;

/**
 * Invalid tbd description
 */
extern NSString * const GPKG_DGIWG_DESCRIPTION_TBD;

/**
 * MIME encoding of metadata
 */
extern NSString * const GPKG_DGIWG_METADATA_MIME_TYPE;

/**
 * DGIWG Metadata Foundation (DMF) base URI
 */
extern NSString * const GPKG_DGIWG_DMF_BASE_URI;

/**
 * DGIWG Metadata Foundation (DMF) 2.0 URI
 */
extern NSString * const GPKG_DGIWG_DMF_2_0_URI;

/**
 * DGIWG Metadata Foundation (DMF) Default URI
 */
extern NSString * const GPKG_DGIWG_DMF_DEFAULT_URI;

/**
 * NMIS base URI
 */
extern NSString * const GPKG_DGIWG_NMIS_BASE_URI;

/**
 * NMIS 8.0 URI
 */
extern NSString * const GPKG_DGIWG_NMIS_8_0_URI;

/**
 * NMIS Default URI
 */
extern NSString * const GPKG_DGIWG_NMIS_DEFAULT_URI;

/**
 * DGIWG (Defence Geospatial Information Working Group) Constants
 */
@interface GPKGDgiwgConstants : NSObject

@end
