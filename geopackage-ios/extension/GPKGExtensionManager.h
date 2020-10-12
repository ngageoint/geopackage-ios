//
//  GPKGExtensionManager.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGExtensionManagement.h"
#import "GPKGGeoPackage.h"

/**
 *  GeoPackage Extension Manager for deleting and copying extensions
 */
@interface GPKGExtensionManager : GPKGExtensionManagement

/**
 * Initialize
 *
 * @param geoPackage
 *            GeoPackage
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Delete the RTree Spatial extension for the table
 *
 * @param table
 *            table name
 */
-(void) deleteRTreeSpatialIndexForTable: (NSString *) table;

/**
 * Delete the RTree Spatial extension
 */
-(void) deleteRTreeSpatialIndexExtension;

/**
 * Copy the RTree Spatial extension for the table
 *
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
-(void) copyRTreeSpatialIndexFromTable: (NSString *) table toTable: (NSString *) newTable;

/**
 * Delete the Related Tables extensions for the table
 *
 * @param table
 *            table name
 */
-(void) deleteRelatedTablesForTable: (NSString *) table;

/**
 * Delete the Related Tables extension
 */
-(void) deleteRelatedTablesExtension;

/**
 * Copy the Related Tables extensions for the table
 *
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
-(void) copyRelatedTablesFromTable: (NSString *) table toTable: (NSString *) newTable;

/**
 * Delete the Gridded Coverage extensions for the table
 *
 * @param table
 *            table name
 */
-(void) deleteGriddedCoverageForTable: (NSString *) table;

/**
 * Delete the Gridded Coverage extension
 */
-(void) deleteGriddedCoverageExtension;

/**
 * Copy the Gridded Coverage extensions for the table
 *
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
-(void) copyGriddedCoverageFromTable: (NSString *) table toTable: (NSString *) newTable;

/**
 * Delete the Schema extensions for the table
 *
 * @param table
 *            table name
 */
-(void) deleteSchemaForTable: (NSString *) table;

/**
 * Delete the Schema extension
 */
-(void) deleteSchemaExtension;

/**
 * Copy the Schema extensions for the table
 *
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
-(void) copySchemaFromTable: (NSString *) table toTable: (NSString *) newTable;

/**
 * Delete the Metadata extensions for the table
 *
 * @param table
 *            table name
 */
-(void) deleteMetadataForTable: (NSString *) table;

/**
 * Delete the Metadata extension
 */
-(void) deleteMetadataExtension;

/**
 * Copy the Metadata extensions for the table
 *
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
-(void) copyMetadataFromTable: (NSString *) table toTable: (NSString *) newTable;

/**
 * Delete the WKT for Coordinate Reference Systems extension
 */
-(void) deleteCrsWktExtension;

@end
