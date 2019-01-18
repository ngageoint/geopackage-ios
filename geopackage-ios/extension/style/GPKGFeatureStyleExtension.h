//
//  GPKGFeatureStyleExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGContentsIdExtension.h"

extern NSString * const GPKG_EXTENSION_FEATURE_STYLE_AUTHOR;
extern NSString * const GPKG_EXTENSION_FEATURE_STYLE_NAME_NO_AUTHOR;
extern NSString * const GPKG_PROP_EXTENSION_FEATURE_STYLE_DEFINITION;

/**
 * Table name prefix for mapping styles
 */
extern NSString * const GPKG_FSE_TABLE_MAPPING_STYLE;

/**
 * Table name prefix for mapping style defaults
 */
extern NSString * const GPKG_FSE_TABLE_MAPPING_TABLE_STYLE;

/**
 * Table name prefix for mapping icons
 */
extern NSString * const GPKG_FSE_TABLE_MAPPING_ICON;

/**
 * Table name prefix for mapping icon defaults
 */
extern NSString * const GPKG_FSE_TABLE_MAPPING_TABLE_ICON;

/**
 * Feature Style extension
 */
@interface GPKGFeatureStyleExtension : GPKGBaseExtension

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param relatedTables related tables
 *
 *  @return new feature style extension
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andRelatedTables: (GPKGRelatedTablesExtension *) relatedTables;

/**
 * Get the feature tables registered with the extension
 *
 * @return list of feature table names
 */
-(NSArray<NSString *> *) tables;

/**
 * Determine if the GeoPackage has the extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 * Determine if the GeoPackage has the extension for the feature table
 *
 * @param featureTable
 *            feature table
 * @return true if has extension
 */
-(BOOL) hasWithTable: (NSString *) featureTable;

/**
 * Get the related tables extension
 *
 * @return related tables extension
 */
-(GPKGRelatedTablesExtension *) relatedTables;

/**
 * Get the contents id extension
 *
 * @return contents id extension
 */
-(GPKGContentsIdExtension *) contentsId;

/**
 * Create style, icon, table style, and table icon relationships for the
 * feature table
 *
 * @param featureTable
 *            feature table
 */
-(void) createRelationshipsWithTable: (NSString *) featureTable;

/**
 * Check if feature table has a style, icon, table style, or table icon
 * relationships
 *
 * @param featureTable
 *            feature table
 * @return true if has a relationship
 */
-(BOOL) hasRelationshipWithTable: (NSString *) featureTable;

/**
 * Create a style relationship for the feature table
 *
 * @param featureTable
 *            feature table
 */
-(void) createStyleRelationshipWithTable: (NSString *) featureTable;

/**
 * Determine if a style relationship exists for the feature table
 *
 * @param featureTable
 *            feature table
 * @return true if relationship exists
 */
-(BOOL) hasStyleRelationshipWithTable: (NSString *) featureTable;

/**
 * Create a feature table style relationship
 *
 * @param featureTable
 *            feature table
 */
-(void) createTableStyleRelationshipWithTable: (NSString *) featureTable;

/**
 * Determine if a feature table style relationship exists
 *
 * @param featureTable
 *            feature table
 * @return true if relationship exists
 */
-(BOOL) hasTableStyleRelationshipWithTable: (NSString *) featureTable;

/**
 * Create an icon relationship for the feature table
 *
 * @param featureTable
 *            feature table
 */
-(void) createIconRelationshipWithTable: (NSString *) featureTable;

/**
 * Determine if an icon relationship exists for the feature table
 *
 * @param featureTable
 *            feature table
 * @return true if relationship exists
 */
-(BOOL) hasIconRelationshipWithTable: (NSString *) featureTable;

/**
 * Create a feature table icon relationship
 *
 * @param featureTable
 *            feature table
 */
-(void) createTableIconRelationshipWithTable: (NSString *) featureTable;

/**
 * Determine if a feature table icon relationship exists
 *
 * @param featureTable
 *            feature table
 * @return true if relationship exists
 */
-(BOOL) hasTableIconRelationshipWithTable: (NSString *) featureTable;

/**
 * Get the mapping table name
 *
 * @param tablePrefix
 *            table name prefix
 * @param featureTable
 *            feature table name
 * @return mapping table name
 */
-(NSString *) mappingTableNameWithPrefix: (NSString *) tablePrefix andTable: (NSString *) featureTable;

/**
 * Delete the style and icon table and row relationships for all feature
 * tables
 */
-(void) deleteRelationships;

/**
 * Delete the style and icon table and row relationships for the feature
 * table
 *
 * @param featureTable
 *            feature table
 */
-(void) deleteRelationshipsWithTable: (NSString *) featureTable;

/**
 * Delete a style relationship for the feature table
 *
 * @param featureTable
 *            feature table
 */
-(void) deleteStyleRelationshipWithTable: (NSString *) featureTable;

/**
 * Delete a table style relationship for the feature table
 *
 * @param featureTable
 *            feature table
 */
-(void) deleteTableStyleRelationshipWithTable: (NSString *) featureTable;

/**
 * Delete a icon relationship for the feature table
 *
 * @param featureTable
 *            feature table
 */
-(void) deleteIconRelationshipWithTable: (NSString *) featureTable;

/**
 * Delete a table icon relationship for the feature table
 *
 * @param featureTable
 *            feature table
 */
-(void) deleteTableIconRelationshipWithTable: (NSString *) featureTable;

/**
 * Completely remove and delete the extension and all styles and icons
 */
-(void) removeExtension;

@end
