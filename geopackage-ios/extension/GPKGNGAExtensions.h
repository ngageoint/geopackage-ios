//
//  GPKGNGAExtensions.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

/**
 *  NGA extension management class for deleting extensions for a table or in a
 *  GeoPackage
 */
@interface GPKGNGAExtensions : NSObject

/**
 *  Delete all NGA table extensions for the table within the GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table      table name
 */
+(void) deleteTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 *  Delete all NGA extensions including custom extension tables for the
 *  GeoPackage
 *
 *  @param geoPackage GeoPackage
 */
+(void) deleteExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
