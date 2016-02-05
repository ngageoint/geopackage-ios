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

/**
 *  Delete the Geometry Index extension for the table
 *
 *  @param geoPackage GeoPackage
 *  @param table      table name
 */
+(void) deleteGeometryIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 *  Delete the Geometry Index extension including the extension entries and
 *  custom tables
 *
 *  @param geoPackage GeoPackage
 */
+(void) deleteGeometryIndexExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Delete the Feature Tile Link extensions for the table
 *
 *  @param geoPackage GeoPackage
 *  @param table      table name
 */
+(void) deleteFeatureTileLinkWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 *  Delete the Feature Tile Link extension including the extension entries
 *  and custom tables
 *
 *  @param geoPackage GeoPackage
 */
+(void) deleteFeatureTileLinkExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
