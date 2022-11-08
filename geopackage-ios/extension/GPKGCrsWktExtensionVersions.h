//
//  GPKGCrsWktExtensionVersions.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/8/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Enumeration of crs wkt extension versions
 */
enum GPKGCrsWktExtensionVersion{
    GPKG_CRS_WKT_V_1,
    GPKG_CRS_WKT_V_1_1
};

/**
 * OGC Well known text representation of Coordinate Reference Systems extension
 * version enumeration
 */
@interface GPKGCrsWktExtensionVersions : NSObject

/**
 * First version
 */
+(enum GPKGCrsWktExtensionVersion) first;

/**
 * Latest supported version
 */
+(enum GPKGCrsWktExtensionVersion) latest;

/**
 * Get the version
 *
 * @param version crs wkt version
 * @return version
 */
+(NSString *) version: (enum GPKGCrsWktExtensionVersion) version;

/**
 * Get the extension name suffix
 *
 * @param version crs wkt version
 * @return extension name suffix
 */
+(NSString *) suffix: (enum GPKGCrsWktExtensionVersion) version;

/**
 * Is the version at or above the minimum version
 *
 * @param version
 *            extension version
 * @param minimum
 *            minimum version
 * @return true if at or above the minimum version
 */
+(BOOL) isVersion: (enum GPKGCrsWktExtensionVersion) version atMinimum: (enum GPKGCrsWktExtensionVersion) minimum;

/**
 * Versions at and above this version
 *
 * @param version
 *            minimum version
 * @return versions at minimum
 */
+(NSArray<NSNumber *> *) atMinimum: (enum GPKGCrsWktExtensionVersion) version;

@end
