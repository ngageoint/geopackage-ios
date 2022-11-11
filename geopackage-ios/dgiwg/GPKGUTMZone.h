//
//  GPKGUTMZone.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * North min EPSG code
 */
extern NSInteger const GPKG_UTM_NORTH_MIN;

/**
 * North max EPSG code
 */
extern NSInteger const GPKG_UTM_NORTH_MAX;

/**
 * South min EPSG code
 */
extern NSInteger const GPKG_UTM_SOUTH_MIN;

/**
 * South max EPSG code
 */
extern NSInteger const GPKG_UTM_SOUTH_MAX;

/**
 * UTM Zone utilities
 */
@interface GPKGUTMZone : NSObject

/**
 * Get the UTM Zone
 *
 * @param epsg
 *            UTM Zone EPSG (GPKG_UTM_NORTH_MIN - GPKG_UTM_NORTH_MAX or
 *            GPKG_UTM_SOUTH_MIN - GPKG_UTM_SOUTH_MAX)
 * @return UTM Zone
 */
+(int) zone: (int) epsg;

/**
 * Get the UTM Zone Latitude Direction
 *
 * @param epsg
 *            UTM Zone EPSG (GPKG_UTM_NORTH_MIN - GPKG_UTM_NORTH_MAX or
 *            GPKG_UTM_SOUTH_MIN - GPKG_UTM_SOUTH_MAX)
 * @return latitude direction
 */
+(NSString *) latDirection: (int) epsg;

/**
 * Get the central meridian
 *
 * @param zone
 *            UTM zone
 * @return central meridian
 */
+(int) centralMeridian: (int) zone;

/**
 * Get the UTM Zone False Northing
 *
 * @param epsg
 *            UTM Zone EPSG (GPKG_UTM_NORTH_MIN - GPKG_UTM_NORTH_MAX or
 *            GPKG_UTM_SOUTH_MIN - GPKG_UTM_SOUTH_MAX)
 * @return false northing
 */
+(int) falseNorthing: (int) epsg;

/**
 * Is the EPSG a UTM Zone
 *
 * @param epsg
 *            EPSG
 * @return true if UTM zone
 */
+(BOOL) isZone: (int) epsg;

/**
 * Is the EPSG a UTM North Zone
 *
 * @param epsg
 *            EPSG
 * @return true if UTM north zone
 */
+(BOOL) isNorth: (int) epsg;

/**
 * Is the EPSG a UTM South Zone
 *
 * @param epsg
 *            EPSG
 * @return true if UTM south zone
 */
+(BOOL) isSouth: (int) epsg;

@end
