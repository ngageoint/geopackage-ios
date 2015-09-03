//
//  GPKGGeoPackageValidate.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

/**
 *  Performs GeoPackage validations
 */
@interface GPKGGeoPackageValidate : NSObject

/**
 *  Check the file extension to see if it is a GeoPackage
 *
 *  @param file file path
 *
 *  @return true if GeoPackage extension
 */
+(BOOL) hasGeoPackageExtension: (NSString *) file;

/**
 *  Validate the extension file as a GeoPackage
 *
 *  @param file file path
 */
+(void) validateGeoPackageExtension: (NSString *) file;

/**
 *  Check the GeoPackage for the minimum required tables
 *
 *  @param geoPackage GeoPackage
 *
 *  @return true if has minimum tables
 */
+(BOOL) hasMinimumTables: (GPKGGeoPackage *) geoPackage;

/**
 *  Validate the GeoPackage has the minimum required tables
 *
 *  @param geoPackage GeoPackage
 */
+(void) validateMinimumTables: (GPKGGeoPackage *) geoPackage;

@end
