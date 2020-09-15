//
//  GPKGExtensionManager.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@class GPKGGeoPackage;

/**
 *  GeoPackage extension management class for deleting extensions for a table or
 *  in a GeoPackage
 */
@interface GPKGExtensionManager : NSObject

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

/**
 * Copy all table extensions for the table within the GeoPackage
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
 * Delete the RTree Spatial extension for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 */
+(void) deleteRTreeSpatialIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 * Delete the RTree Spatial extension
 *
 * @param geoPackage
 *            GeoPackage
 */
+(void) deleteRTreeSpatialIndexExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Copy the RTree Spatial extension for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copyRTreeSpatialIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

/**
 * Delete the Related Tables extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 */
+(void) deleteRelatedTablesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 * Delete the Related Tables extension
 *
 * @param geoPackage
 *            GeoPackage
 */
+(void) deleteRelatedTablesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Copy the Related Tables extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copyRelatedTablesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

/**
 * Delete the Gridded Coverage extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 */
+(void) deleteGriddedCoverageWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 * Delete the Gridded Coverage extension
 *
 * @param geoPackage
 *            GeoPackage
 */
+(void) deleteGriddedCoverageExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Copy the Gridded Coverage extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copyGriddedCoverageWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

/**
 * Delete the Schema extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 */
+(void) deleteSchemaWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 * Delete the Schema extension
 *
 * @param geoPackage
 *            GeoPackage
 */
+(void) deleteSchemaExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Copy the Schema extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copySchemaWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

/**
 * Delete the Metadata extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 */
+(void) deleteMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table;

/**
 * Delete the Metadata extension
 *
 * @param geoPackage
 *            GeoPackage
 */
+(void) deleteMetadataExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Copy the Metadata extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
+(void) copyMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable;

/**
 * Delete the WKT for Coordinate Reference Systems extension
 *
 * @param geoPackage
 *            GeoPackage
 */
+(void) deleteCrsWktExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
