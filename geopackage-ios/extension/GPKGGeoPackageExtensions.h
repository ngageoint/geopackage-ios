//
//  GPKGGeoPackageExtensions.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

/**
 *  GeoPackage extension management class for deleting extensions for a table or
 *  in a GeoPackage
 */
@interface GPKGGeoPackageExtensions : NSObject

/**
 *  Delete all table extensions for the table within the GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table      table
 */
+(void) deleteTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 *  Delete all extensions
 *
 *  @param geoPackage GeoPackage
 */
+(void) deleteExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
