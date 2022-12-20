//
//  GPKGGeoPackageConstants.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  GeoPackage constants
 */
extern NSString * const GPKG_EXTENSION;

/**
 * @deprecated in GeoPackage version 1.2
 */
extern NSString * const GPKG_EXTENDED_EXTENSION __attribute__((deprecated));

extern NSString * const GPKG_MEDIA_TYPE;
extern NSString * const GPKG_APPLICATION_ID;
extern NSInteger const GPKG_USER_VERSION;
extern NSString * const GPKG_METADATA_APPLICATION_ID;
extern NSString * const GPKG_GEOMETRY_MAGIC_NUMBER;
extern NSInteger const GPKG_GEOMETRY_VERSION_1;
extern NSString * const GPKG_SQLITE_HEADER_PREFIX;
extern NSString * const GPKG_SQLITE_APPLICATION_ID;
extern NSString * const GPKG_EXTENSION_AUTHOR;
extern NSString * const GPKG_GEOMETRY_EXTENSION_PREFIX;
extern NSString * const GPKG_UNDEFINED_DEFINITION;
extern NSString * const GPKG_BUNDLE_NAME;
extern NSString * const GPKG_PROPERTY_LIST_TYPE;
extern NSString * const GPKG_RESOURCES_PROPERTIES;
extern CGFloat const GPKG_EARTH_RADIUS;

@interface GPKGGeoPackageConstants : NSObject

@end
