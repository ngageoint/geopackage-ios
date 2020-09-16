//
//  GPKGNGAExtensions.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"
#import "GPKGExtensionManagement.h"

/**
 * NGA Extension author
 */
extern NSString * const GPKG_NGA_EXTENSION_AUTHOR;

/**
 *  NGA extensions
 *
 *  http://ngageoint.github.io/GeoPackage/docs/extensions/
 */
@interface GPKGNGAExtensions : GPKGExtensionManagement

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
 * Copy all NGA table extensions for the table within the GeoPackage
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copyTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

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
 * Copy the Geometry Index extension for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copyGeometryIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

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

/**
 * Copy the Feature Tile Link extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copyFeatureTileLinkWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

/**
 *  Delete the Tile Scaling extensions for the table
 *
 *  @param geoPackage GeoPackage
 *  @param table      table name
 */
+(void) deleteTileScalingWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 *  Delete the Tile Scaling extension including the extension entries and
 *  custom tables
 *
 *  @param geoPackage GeoPackage
 */
+(void) deleteTileScalingExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Copy the Tile Scaling extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copyTileScalingWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

/**
 * Delete the Properties extension if the deleted table is the properties
 * table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 */
+(void) deletePropertiesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 * Delete the properties extension from the GeoPackage
 *
 * @param geoPackage GeoPackage
 */
+(void) deletePropertiesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Delete the Feature Style extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 */
+(void) deleteFeatureStyleWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 * Delete the Feature Style extension including the extension entries and
 * custom tables
 *
 * @param geoPackage GeoPackage
 */
+(void) deleteFeatureStyleExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Copy the Feature Style extensions for the table. Relies on
 * {@link GeoPackageExtensions#copyRelatedTables(GeoPackageCore, String, String)}
 * to be called first.
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copyFeatureStyleWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

/**
 * Delete the Contents Id extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 */
+(void) deleteContentsIdWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 * Delete the Contents Id extension including the extension entries and
 * custom tables
 *
 * @param geoPackage GeoPackage
 */
+(void) deleteContentsIdExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Copy the Contents Id extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copyContentsIdWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

@end
