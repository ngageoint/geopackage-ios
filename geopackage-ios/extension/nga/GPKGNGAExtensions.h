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
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Delete the Geometry Index extension for the table
 *
 *  @param table      table name
 */
-(void) deleteGeometryIndexForTable: (NSString *) table;

/**
 *  Delete the Geometry Index extension including the extension entries and
 *  custom tables
 */
-(void) deleteGeometryIndexExtension;

/**
 * Copy the Geometry Index extension for the table
 *
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
-(void) copyGeometryIndexFromTable: (NSString *) table toTable: (NSString *) newTable;

/**
 *  Delete the Feature Tile Link extensions for the table
 *
 *  @param table      table name
 */
-(void) deleteFeatureTileLinkForTable: (NSString *) table;

/**
 *  Delete the Feature Tile Link extension including the extension entries
 *  and custom tables
 */
-(void) deleteFeatureTileLinkExtension;

/**
 * Copy the Feature Tile Link extensions for the table
 *
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
-(void) copyFeatureTileLinkFromTable: (NSString *) table toTable: (NSString *) newTable;

/**
 *  Delete the Tile Scaling extensions for the table
 *
 *  @param table      table name
 */
-(void) deleteTileScalingForTable: (NSString *) table;

/**
 *  Delete the Tile Scaling extension including the extension entries and
 *  custom tables
 */
-(void) deleteTileScalingExtension;

/**
 * Copy the Tile Scaling extensions for the table
 *
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
-(void) copyTileScalingFromTable: (NSString *) table toTable: (NSString *) newTable;

/**
 * Delete the Properties extension if the deleted table is the properties
 * table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 */
-(void) deletePropertiesForTable: (NSString *) table;

/**
 * Delete the properties extension from the GeoPackage
 *
 * @param geoPackage GeoPackage
 */
-(void) deletePropertiesExtension;

/**
 * Delete the Feature Style extensions for the table
 *
 * @param table
 *            table name
 */
-(void) deleteFeatureStyleForTable: (NSString *) table;

/**
 * Delete the Feature Style extension including the extension entries and
 * custom tables
 */
-(void) deleteFeatureStyleExtension;

/**
 * Copy the Feature Style extensions for the table. Relies on
 * {@link GeoPackageExtensions#copyRelatedTables(GeoPackageCore, String, String)}
 * to be called first.
 *
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
-(void) copyFeatureStyleFromTable: (NSString *) table toTable: (NSString *) newTable;

/**
 * Delete the Contents Id extensions for the table
 *
 * @param geoPackage
 *            GeoPackage
 * @param table
 *            table name
 */
-(void) deleteContentsIdForTable: (NSString *) table;

/**
 * Delete the Contents Id extension including the extension entries and
 * custom tables
 *
 * @param geoPackage GeoPackage
 */
-(void) deleteContentsIdExtension;

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
-(void) copyContentsIdFromTable: (NSString *) table toTable: (NSString *) newTable;

@end
