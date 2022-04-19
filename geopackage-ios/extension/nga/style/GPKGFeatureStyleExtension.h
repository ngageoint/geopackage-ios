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
#import "GPKGStyleMappingDao.h"
#import "GPKGStyleDao.h"
#import "GPKGIconDao.h"
#import "GPKGFeatureStyles.h"
#import "GPKGFeatureStyle.h"
#import "GPKGPixelBounds.h"

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
 * <p>
 * <a href="http://ngageoint.github.io/GeoPackage/docs/extensions/feature-style.html">http://ngageoint.github.io/GeoPackage/docs/extensions/feature-style.html</a>
 */
@interface GPKGFeatureStyleExtension : GPKGBaseExtension

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new feature style extension
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get the feature tables registered with the extension
 *
 * @return list of feature table names
 */
-(NSArray<NSString *> *) tables;

/**
 *  Get the extension name
 *
 *  @return extension name
 */
-(NSString *) extensionName;

/**
 * Determine if the GeoPackage has the extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 * Get the extension for the feature table
 *
 * @param featureTable
 *            feature table
 * @return extension
 */
-(GPKGExtensions *) forTable: (NSString *) featureTable;

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
 * Create style table
 *
 * @return true if created, false if the table already existed
 */
-(BOOL) createStyleTable;

/**
 * Create icon table
 *
 * @return true if created, false if the table already existed
 */
-(BOOL) createIconTable;

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
 * Get style table relations
 *
 * @return extended relations
 */
-(GPKGResultSet *) styleTableRelations;

/**
 * Determine if there are style table relations
 *
 * @return true if has style table relations
 */
-(BOOL) hasStyleTableRelations;

/**
 * Get icon table relations
 *
 * @return extended relations
 */
-(GPKGResultSet *) iconTableRelations;

/**
 * Determine if there are icon table relations
 *
 * @return true if has icon table relations
 */
-(BOOL) hasIconTableRelations;

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

/**
 * Get a Style Mapping DAO
 *
 * @param featureTable feature table
 * @return style mapping DAO
 */
-(GPKGStyleMappingDao *) styleMappingDaoWithTable: (NSString *) featureTable;

/**
 * Get a Table Style Mapping DAO
 *
 * @param featureTable feature table
 * @return table style mapping DAO
 */
-(GPKGStyleMappingDao *) tableStyleMappingDaoWithTable: (NSString *) featureTable;

/**
 * Get a Icon Mapping DAO
 *
 * @param featureTable feature table
 * @return icon mapping DAO
 */
-(GPKGStyleMappingDao *) iconMappingDaoWithTable: (NSString *) featureTable;

/**
 * Get a Table Icon Mapping DAO
 *
 * @param featureTable feature table
 * @return table icon mapping DAO
 */
-(GPKGStyleMappingDao *) tableIconMappingDaoWithTable: (NSString *) featureTable;

/**
 * Get a style DAO
 *
 * @return style DAO
 */
-(GPKGStyleDao *) styleDao;

/**
 * Get a icon DAO
 *
 * @return icon DAO
 */
-(GPKGIconDao *) iconDao;

/**
 * Get the feature table default feature styles
 *
 * @param featureTable feature table
 * @return table feature styles or null
 */
-(GPKGFeatureStyles *) tableFeatureStylesWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Get the feature table default feature styles
 *
 * @param featureTable feature table
 * @return table feature styles or null
 */
-(GPKGFeatureStyles *) tableFeatureStylesWithTableName: (NSString *) featureTable;

/**
 * Get the feature table default styles
 *
 * @param featureTable feature table
 * @return table styles or null
 */
-(GPKGStyles *) tableStylesWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Get the feature table default styles
 *
 * @param featureTable feature table
 * @return table styles or null
 */
-(GPKGStyles *) tableStylesWithTableName: (NSString *) featureTable;

/**
 * Get the style of the feature table and geometry type
 *
 * @param featureTable feature table
 * @param geometryType geometry type
 * @return style row
 */
-(GPKGStyleRow *) tableStyleWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the default style of the feature table
 *
 * @param featureTable feature table
 * @return style row
 */
-(GPKGStyleRow *) tableStyleDefaultWithTableName: (NSString *) featureTable;

/**
 * Get the feature table default icons
 *
 * @param featureTable feature table
 * @return table icons or null
 */
-(GPKGIcons *) tableIconsWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Get the feature table default icons
 *
 * @param featureTable feature table
 * @return table icons or null
 */
-(GPKGIcons *) tableIconsWithTableName: (NSString *) featureTable;

/**
 * Get the default icon of the feature table
 *
 * @param featureTable feature table
 * @return icon row
 */
-(GPKGIconRow *) tableIconDefaultWithTableName: (NSString *) featureTable;

/**
 * Get the icon of the feature table and geometry type
 *
 * @param featureTable feature table
 * @param geometryType geometry type
 * @return icon row
 */
-(GPKGIconRow *) tableIconWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get all styles used by the feature table
 *
 * @param featureTable feature table
 * @return style rows mapped by ids
 */
-(NSDictionary<NSNumber *, GPKGStyleRow *> *) stylesWithTableName: (NSString *) featureTable;

/**
 * Get all styles used by feature rows in the table
 *
 * @param featureTable feature table
 * @return style rows mapped by ids
 */
-(NSDictionary<NSNumber *, GPKGStyleRow *> *) featureStylesWithTableName: (NSString *) featureTable;

/**
 * Get all icons used by the feature table
 *
 * @param featureTable feature table
 * @return icon rows mapped by ids
 */
-(NSDictionary<NSNumber *, GPKGIconRow *> *) iconsWithTableName: (NSString *) featureTable;

/**
 * Get all icons used by feature rows in the table
 *
 * @param featureTable feature table
 * @return icon rows mapped by ids
 */
-(NSDictionary<NSNumber *, GPKGIconRow *> *) featureIconsWithTableName: (NSString *) featureTable;

/**
 * Get the feature styles for the feature row
 *
 * @param featureRow feature row
 * @return feature styles or null
 */
-(GPKGFeatureStyles *) featureStylesWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the feature styles for the feature table and feature id
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return feature styles or null
 */
-(GPKGFeatureStyles *) featureStylesWithTableName: (NSString *) featureTable andId: (int) featureId;

/**
 * Get the feature styles for the feature table and feature id
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return feature styles or null
 */
-(GPKGFeatureStyles *) featureStylesWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId;

/**
 * Get the feature style (style and icon) of the feature row, searching in
 * order: feature geometry type style or icon, feature default style or
 * icon, table geometry type style or icon, table default style or icon
 *
 * @param featureRow feature row
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the feature style (style and icon) of the feature row with the
 * provided geometry type, searching in order: feature geometry type style
 * or icon, feature default style or icon, table geometry type style or
 * icon, table default style or icon
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the feature style default (style and icon) of the feature row,
 * searching in order: feature default style or icon, table default style or
 * icon
 *
 * @param featureRow feature row
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the feature style (style and icon) of the feature, searching in
 * order: feature geometry type style or icon, feature default style or
 * icon, table geometry type style or icon, table default style or icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the feature style (style and icon) of the feature, searching in
 * order: feature geometry type style or icon, feature default style or
 * icon, table geometry type style or icon, table default style or icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the feature style (style and icon) of the feature, searching in
 * order: feature geometry type style or icon, feature default style or
 * icon, table geometry type style or icon, table default style or icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId;

/**
 * Get the feature style (style and icon) of the feature, searching in
 * order: feature geometry type style or icon, feature default style or
 * icon, table geometry type style or icon, table default style or icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleDefaultWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId;

/**
 * Get the styles for the feature row
 *
 * @param featureRow feature row
 * @return styles or null
 */
-(GPKGStyles *) stylesWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the styles for the feature table and feature id
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return styles or null
 */
-(GPKGStyles *) stylesWithTableName: (NSString *) featureTable andId: (int) featureId;

/**
 * Get the styles for the feature table and feature id
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return styles or null
 */
-(GPKGStyles *) stylesWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId;

/**
 * Get the style of the feature row, searching in order: feature geometry
 * type style, feature default style, table geometry type style, table
 * default style
 *
 * @param featureRow feature row
 * @return style row
 */
-(GPKGStyleRow *) styleWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the style of the feature row with the provided geometry type,
 * searching in order: feature geometry type style, feature default style,
 * table geometry type style, table default style
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 * @return style row
 */
-(GPKGStyleRow *) styleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the default style of the feature row, searching in order: feature
 * default style, table default style
 *
 * @param featureRow feature row
 * @return style row
 */
-(GPKGStyleRow *) styleDefaultWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the style of the feature, searching in order: feature geometry type
 * style, feature default style, table geometry type style, table default
 * style
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return style row
 */
-(GPKGStyleRow *) styleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the style of the feature, searching in order: feature geometry type
 * style, feature default style, table geometry type style, table default
 * style
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return style row
 */
-(GPKGStyleRow *) styleWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the default style of the feature, searching in order: feature default
 * style, table default style
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return style row
 */
-(GPKGStyleRow *) styleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId;

/**
 * Get the default style of the feature, searching in order: feature default
 * style, table default style
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return style row
 */
-(GPKGStyleRow *) styleDefaultWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId;

/**
 * Get the style of the feature, searching in order: feature geometry type
 * style, feature default style, when tableStyle enabled continue searching:
 * table geometry type style, table default style
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param tableStyle   when true and a feature style is not found, query for a
 *                     matching table style
 * @return style row
 */
-(GPKGStyleRow *) styleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType andTableStyle: (BOOL) tableStyle;

/**
 * Get the style of the feature, searching in order: feature geometry type
 * style, feature default style, when tableStyle enabled continue searching:
 * table geometry type style, table default style
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param tableStyle   when true and a feature style is not found, query for a
 *                     matching table style
 * @return style row
 */
-(GPKGStyleRow *) styleWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType andTableStyle: (BOOL) tableStyle;

/**
 * Get the default style of the feature, searching in order: feature default
 * style, when tableStyle enabled continue searching: table default style
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param tableStyle   when true and a feature style is not found, query for a
 *                     matching table style
 * @return style row
 */
-(GPKGStyleRow *) styleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId andTableStyle: (BOOL) tableStyle;

/**
 * Get the default style of the feature, searching in order: feature default
 * style, when tableStyle enabled continue searching: table default style
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param tableStyle   when true and a feature style is not found, query for a
 *                     matching table style
 * @return style row
 */
-(GPKGStyleRow *) styleDefaultWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andTableStyle: (BOOL) tableStyle;

/**
 * Get the icons for the feature row
 *
 * @param featureRow feature row
 * @return icons or null
 */
-(GPKGIcons *) iconsWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the icons for the feature table and feature id
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return icons or null
 */
-(GPKGIcons *) iconsWithTableName: (NSString *) featureTable andId: (int) featureId;

/**
 * Get the icons for the feature table and feature id
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return icons or null
 */
-(GPKGIcons *) iconsWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId;

/**
 * Get the icon of the feature row, searching in order: feature geometry
 * type icon, feature default icon, table geometry type icon, table default
 * icon
 *
 * @param featureRow feature row
 * @return icon row
 */
-(GPKGIconRow *) iconWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the icon of the feature row with the provided geometry type,
 * searching in order: feature geometry type icon, feature default icon,
 * table geometry type icon, table default icon
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 * @return icon row
 */
-(GPKGIconRow *) iconWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the default icon of the feature row, searching in order: feature
 * default icon, table default icon
 *
 * @param featureRow feature row
 * @return icon row
 */
-(GPKGIconRow *) iconDefaultWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the icon of the feature, searching in order: feature geometry type
 * icon, feature default icon, table geometry type icon, table default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return icon row
 */
-(GPKGIconRow *) iconWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the icon of the feature, searching in order: feature geometry type
 * icon, feature default icon, table geometry type icon, table default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return icon row
 */
-(GPKGIconRow *) iconWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the default icon of the feature, searching in order: feature default
 * icon, table default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return icon row
 */
-(GPKGIconRow *) iconDefaultWithTableName: (NSString *) featureTable andId: (int) featureId;

/**
 * Get the default icon of the feature, searching in order: feature default
 * icon, table default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @return icon row
 */
-(GPKGIconRow *) iconDefaultWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId;

/**
 * Get the icon of the feature, searching in order: feature geometry type
 * icon, feature default icon, when tableIcon enabled continue searching:
 * table geometry type icon, table default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param tableIcon    when true and a feature icon is not found, query for a
 *                     matching table icon
 * @return icon row
 */
-(GPKGIconRow *) iconWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType andTableIcon: (BOOL) tableIcon;

/**
 * Get the icon of the feature, searching in order: feature geometry type
 * icon, feature default icon, when tableIcon enabled continue searching:
 * table geometry type icon, table default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param tableIcon    when true and a feature icon is not found, query for a
 *                     matching table icon
 * @return icon row
 */
-(GPKGIconRow *) iconWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType andTableIcon: (BOOL) tableIcon;

/**
 * Get the default icon of the feature, searching in order: feature default
 * icon, when tableIcon enabled continue searching: table default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param tableIcon    when true and a feature icon is not found, query for a
 *                     matching table icon
 * @return icon row
 */
-(GPKGIconRow *) iconDefaultWithTableName: (NSString *) featureTable andId: (int) featureId andTableIcon: (BOOL) tableIcon;

/**
 * Get the default icon of the feature, searching in order: feature default
 * icon, when tableIcon enabled continue searching: table default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param tableIcon    when true and a feature icon is not found, query for a
 *                     matching table icon
 * @return icon row
 */
-(GPKGIconRow *) iconDefaultWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andTableIcon: (BOOL) tableIcon;

/**
 * Set the feature table default feature styles
 *
 * @param featureTable  feature table
 * @param featureStyles default feature styles
 */
-(void) setTableFeatureStylesWithTable: (GPKGFeatureTable *) featureTable andFeatureStyles: (GPKGFeatureStyles *) featureStyles;

/**
 * Set the feature table default feature styles
 *
 * @param featureTable  feature table
 * @param featureStyles default feature styles
 */
-(void) setTableFeatureStylesWithTableName: (NSString *) featureTable andFeatureStyles: (GPKGFeatureStyles *) featureStyles;

/**
 * Set the feature table default styles
 *
 * @param featureTable feature table
 * @param styles       default styles
 */
-(void) setTableStylesWithTable: (GPKGFeatureTable *) featureTable andStyles: (GPKGStyles *) styles;

/**
 * Set the feature table default styles
 *
 * @param featureTable feature table
 * @param styles       default styles
 */
-(void) setTableStylesWithTableName: (NSString *) featureTable andStyles: (GPKGStyles *) styles;

/**
 * Set the feature table style default
 *
 * @param featureTable feature table
 * @param style        style row
 */
-(void) setTableStyleDefaultWithTable: (GPKGFeatureTable *) featureTable andStyle: (GPKGStyleRow *) style;

/**
 * Set the feature table style default
 *
 * @param featureTable feature table
 * @param style        style row
 */
-(void) setTableStyleDefaultWithTableName: (NSString *) featureTable andStyle: (GPKGStyleRow *) style;

/**
 * Set the feature table style for the geometry type
 *
 * @param featureTable feature table
 * @param geometryType geometry type
 * @param style        style row
 */
-(void) setTableStyleWithTable: (GPKGFeatureTable *) featureTable andGeometryType: (enum SFGeometryType) geometryType andStyle: (GPKGStyleRow *) style;

/**
 * Set the feature table style for the geometry type
 *
 * @param featureTable feature table
 * @param geometryType geometry type
 * @param style        style row
 */
-(void) setTableStyleWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType andStyle: (GPKGStyleRow *) style;

/**
 * Set the feature table default icons
 *
 * @param featureTable feature table
 * @param icons        default icons
 */
-(void) setTableIconsWithTable: (GPKGFeatureTable *) featureTable andIcons: (GPKGIcons *) icons;

/**
 * Set the feature table default icons
 *
 * @param featureTable feature table
 * @param icons        default icons
 */
-(void) setTableIconsWithTableName: (NSString *) featureTable andIcons: (GPKGIcons *) icons;

/**
 * Set the feature table icon default
 *
 * @param featureTable feature table
 * @param icon         icon row
 */
-(void) setTableIconDefaultWithTable: (GPKGFeatureTable *) featureTable andIcon: (GPKGIconRow *) icon;

/**
 * Set the feature table icon default
 *
 * @param featureTable feature table
 * @param icon         icon row
 */
-(void) setTableIconDefaultWithTableName: (NSString *) featureTable andIcon: (GPKGIconRow *) icon;

/**
 * Set the feature table icon for the geometry type
 *
 * @param featureTable feature table
 * @param geometryType geometry type
 * @param icon         icon row
 */
-(void) setTableIconWithTable: (GPKGFeatureTable *) featureTable andGeometryType: (enum SFGeometryType) geometryType andIcon: (GPKGIconRow *) icon;

/**
 * Set the feature table icon for the geometry type
 *
 * @param featureTable feature table
 * @param geometryType geometry type
 * @param icon         icon row
 */
-(void) setTableIconWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType andIcon: (GPKGIconRow *) icon;

/**
 * Set the feature styles for the feature row
 *
 * @param featureRow    feature row
 * @param featureStyles feature styles
 */
-(void) setFeatureStylesWithFeature: (GPKGFeatureRow *) featureRow andFeatureStyles: (GPKGFeatureStyles *) featureStyles;

/**
 * Set the feature styles for the feature table and feature id
 *
 * @param featureTable  feature table
 * @param featureId     feature id
 * @param featureStyles feature styles
 */
-(void) setFeatureStylesWithTableName: (NSString *) featureTable andId: (int) featureId andFeatureStyles: (GPKGFeatureStyles *) featureStyles;

/**
 * Set the feature styles for the feature table and feature id
 *
 * @param featureTable  feature table
 * @param featureId     feature id
 * @param featureStyles feature styles
 */
-(void) setFeatureStylesWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andFeatureStyles: (GPKGFeatureStyles *) featureStyles;

/**
 * Set the feature style (style and icon) of the feature row
 *
 * @param featureRow   feature row
 * @param featureStyle feature style
 */
-(void) setFeatureStyleWithFeature: (GPKGFeatureRow *) featureRow andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the feature style (style and icon) of the feature row for the
 * specified geometry type
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 * @param featureStyle feature style
 */
-(void) setFeatureStyleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the feature style default (style and icon) of the feature row
 *
 * @param featureRow   feature row
 * @param featureStyle feature style
 */
-(void) setFeatureStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the feature style (style and icon) of the feature
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param featureStyle feature style
 */
-(void) setFeatureStyleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the feature style (style and icon) of the feature
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param featureStyle feature style
 */
-(void) setFeatureStyleWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the feature style (style and icon) of the feature
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param featureStyle feature style
 */
-(void) setFeatureStyleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the feature style (style and icon) of the feature
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param featureStyle feature style
 */
-(void) setFeatureStyleDefaultWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the styles for the feature row
 *
 * @param featureRow feature row
 * @param styles     styles
 */
-(void) setStylesWithFeature: (GPKGFeatureRow *) featureRow andStyles: (GPKGStyles *) styles;

/**
 * Set the styles for the feature table and feature id
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param styles       styles
 */
-(void) setStylesWithTableName: (NSString *) featureTable andId: (int) featureId andStyles: (GPKGStyles *) styles;

/**
 * Set the styles for the feature table and feature id
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param styles       styles
 */
-(void) setStylesWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andStyles: (GPKGStyles *) styles;

/**
 * Set the style of the feature row
 *
 * @param featureRow feature row
 * @param style      style row
 */
-(void) setStyleWithFeature: (GPKGFeatureRow *) featureRow andStyle: (GPKGStyleRow *) style;

/**
 * Set the style of the feature row for the specified geometry type
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 * @param style        style row
 */
-(void) setStyleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType andStyle: (GPKGStyleRow *) style;

/**
 * Set the default style of the feature row
 *
 * @param featureRow feature row
 * @param style      style row
 */
-(void) setStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow andStyle: (GPKGStyleRow *) style;

/**
 * Set the style of the feature
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param style        style row
 */
-(void) setStyleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType andStyle: (GPKGStyleRow *) style;

/**
 * Set the style of the feature
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param style        style row
 */
-(void) setStyleWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType andStyle: (GPKGStyleRow *) style;

/**
 * Set the default style of the feature
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param style        style row
 */
-(void) setStyleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId andStyle: (GPKGStyleRow *) style;

/**
 * Set the default style of the feature
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param style        style row
 */
-(void) setStyleDefaultWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andStyle: (GPKGStyleRow *) style;

/**
 * Set the icons for the feature row
 *
 * @param featureRow feature row
 * @param icons      icons
 */
-(void) setIconsWithFeature: (GPKGFeatureRow *) featureRow andIcons: (GPKGIcons *) icons;

/**
 * Set the icons for the feature table and feature id
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param icons        icons
 */
-(void) setIconsWithTableName: (NSString *) featureTable andId: (int) featureId andIcons: (GPKGIcons *) icons;

/**
 * Set the icons for the feature table and feature id
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param icons        icons
 */
-(void) setIconsWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andIcons: (GPKGIcons *) icons;

/**
 * Set the icon of the feature row
 *
 * @param featureRow feature row
 * @param icon       icon row
 */
-(void) setIconWithFeature: (GPKGFeatureRow *) featureRow andIcon: (GPKGIconRow *) icon;

/**
 * Set the icon of the feature row for the specified geometry type
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 * @param icon         icon row
 */
-(void) setIconWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType andIcon: (GPKGIconRow *) icon;

/**
 * Set the default icon of the feature row
 *
 * @param featureRow feature row
 * @param icon       icon row
 */
-(void) setIconDefaultWithFeature: (GPKGFeatureRow *) featureRow andIcon: (GPKGIconRow *) icon;

/**
 * Get the icon of the feature, searching in order: feature geometry type
 * icon, feature default icon, table geometry type icon, table default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param icon         icon row
 */
-(void) setIconWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType andIcon: (GPKGIconRow *) icon;

/**
 * Get the icon of the feature, searching in order: feature geometry type
 * icon, feature default icon, table geometry type icon, table default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param icon         icon row
 */
-(void) setIconWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType andIcon: (GPKGIconRow *) icon;

/**
 * Set the default icon of the feature
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param icon         icon row
 */
-(void) setIconDefaultWithTableName: (NSString *) featureTable andId: (int) featureId andIcon: (GPKGIconRow *) icon;

/**
 * Set the default icon of the feature
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param icon         icon row
 */
-(void) setIconDefaultWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andIcon: (GPKGIconRow *) icon;

/**
 * Delete all feature styles including table styles, table icons, style, and
 * icons
 *
 * @param featureTable feature table
 */
-(void) deleteAllFeatureStylesWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete all feature styles including table styles, table icons, style, and
 * icons
 *
 * @param featureTable feature table
 */
-(void) deleteAllFeatureStylesWithTableName: (NSString *) featureTable;

/**
 * Delete all styles including table styles and feature row styles
 *
 * @param featureTable feature table
 */
-(void) deleteAllStylesWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete all styles including table styles and feature row styles
 *
 * @param featureTable feature table
 */
-(void) deleteAllStylesWithTableName: (NSString *) featureTable;

/**
 * Delete all icons including table icons and feature row icons
 *
 * @param featureTable feature table
 */
-(void) deleteAllIconsWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete all icons including table icons and feature row icons
 *
 * @param featureTable feature table
 */
-(void) deleteAllIconsWithTableName: (NSString *) featureTable;

/**
 * Delete the feature table feature styles
 *
 * @param featureTable feature table
 */
-(void) deleteTableFeatureStylesWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete the feature table feature styles
 *
 * @param featureTable feature table
 */
-(void) deleteTableFeatureStylesWithTableName: (NSString *) featureTable;

/**
 * Delete the feature table styles
 *
 * @param featureTable feature table
 */
-(void) deleteTableStylesWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete the feature table styles
 *
 * @param featureTable feature table
 */
-(void) deleteTableStylesWithTableName: (NSString *) featureTable;

/**
 * Delete the feature table default style
 *
 * @param featureTable feature table
 */
-(void) deleteTableStyleDefaultWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete the feature table default style
 *
 * @param featureTable feature table
 */
-(void) deleteTableStyleDefaultWithTableName: (NSString *) featureTable;

/**
 * Delete the feature table style for the geometry type
 *
 * @param featureTable feature table
 * @param geometryType geometry type
 */
-(void) deleteTableStyleWithTable: (GPKGFeatureTable *) featureTable andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete the feature table style for the geometry type
 *
 * @param featureTable feature table
 * @param geometryType geometry type
 */
-(void) deleteTableStyleWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete the feature table icons
 *
 * @param featureTable feature table
 */
-(void) deleteTableIconsWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete the feature table icons
 *
 * @param featureTable feature table
 */
-(void) deleteTableIconsWithTableName: (NSString *) featureTable;

/**
 * Delete the feature table default icon
 *
 * @param featureTable feature table
 */
-(void) deleteTableIconDefaultWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete the feature table default icon
 *
 * @param featureTable feature table
 */
-(void) deleteTableIconDefaultWithTableName: (NSString *) featureTable;

/**
 * Delete the feature table icon for the geometry type
 *
 * @param featureTable feature table
 * @param geometryType geometry type
 */
-(void) deleteTableIconWithTable: (GPKGFeatureTable *) featureTable andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete the feature table icon for the geometry type
 *
 * @param featureTable feature table
 * @param geometryType geometry type
 */
-(void) deleteTableIconWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete all feature styles
 *
 * @param featureTable feature table
 */
-(void) deleteFeatureStylesWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete all feature styles
 *
 * @param featureTable feature table
 */
-(void)  deleteFeatureStylesWithTableName: (NSString *) featureTable;

/**
 * Delete all styles
 *
 * @param featureTable feature table
 */
-(void) deleteStylesWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete all styles
 *
 * @param featureTable feature table
 */
-(void) deleteStylesWithTableName: (NSString *) featureTable;

/**
 * Delete feature row styles
 *
 * @param featureRow feature row
 */
-(void) deleteStylesWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Delete feature row styles
 *
 * @param featureTable feature table
 * @param featureId    feature id
 */
-(void) deleteStylesWithTableName: (NSString *) featureTable andId: (int) featureId;

/**
 * Delete feature row styles
 *
 * @param featureTable feature table
 * @param featureId    feature id
 */
-(void) deleteStylesWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId;

/**
 * Delete the feature row default style
 *
 * @param featureRow feature row
 */
-(void) deleteStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Delete the feature row default style
 *
 * @param featureTable feature table
 * @param featureId    feature id
 */
-(void) deleteStyleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId;

/**
 * Delete the feature row default style
 *
 * @param featureTable feature table
 * @param featureId    feature id
 */
-(void) deleteStyleDefaultWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId;

/**
 * Delete the feature row style for the feature row geometry type
 *
 * @param featureRow feature row
 */
-(void) deleteStyleWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Delete the feature row style for the geometry type
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 */
-(void) deleteStyleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete the feature row style for the geometry type
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 */
-(void) deleteStyleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete the feature row style for the geometry type
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 */
-(void) deleteStyleWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete all icons
 *
 * @param featureTable feature table
 */
-(void) deleteIconsWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete all icons
 *
 * @param featureTable feature table
 */
-(void) deleteIconsWithTableName: (NSString *) featureTable;

/**
 * Delete feature row icons
 *
 * @param featureRow feature row
 */
-(void) deleteIconsWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Delete feature row icons
 *
 * @param featureTable feature table
 * @param featureId    feature id
 */
-(void) deleteIconsWithTableName: (NSString *) featureTable andId: (int) featureId;

/**
 * Delete feature row icons
 *
 * @param featureTable feature table
 * @param featureId    feature id
 */
-(void) deleteIconsWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId;

/**
 * Delete the feature row default icon
 *
 * @param featureRow feature row
 */
-(void) deleteIconDefaultWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Delete the feature row default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 */
-(void) deleteIconDefaultWithTableName: (NSString *) featureTable andId: (int) featureId;

/**
 * Delete the feature row default icon
 *
 * @param featureTable feature table
 * @param featureId    feature id
 */
-(void) deleteIconDefaultWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId;

/**
 * Delete the feature row icon for the feature row geometry type
 *
 * @param featureRow feature row
 */
-(void) deleteIconWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Delete the feature row icon for the geometry type
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 */
-(void) deleteIconWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete the feature row icon for the geometry type
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 */
-(void) deleteIconWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete the feature row icon for the geometry type
 *
 * @param featureTable feature table
 * @param featureId    feature id
 * @param geometryType geometry type
 */
-(void) deleteIconWithTableName: (NSString *) featureTable andIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Count the number of mappings to the style row
 *
 * @param styleRow style row
 * @return mappings count
 */
-(int) countMappingsToStyleRow: (GPKGStyleRow *) styleRow;

/**
 * Count the number of mappings to the style row id
 *
 * @param id style row id
 * @return mappings count
 */
-(int) countMappingsToStyleRowId: (int) id;

/**
 * Determine if a mapping to the style row exists
 *
 * @param styleRow style row
 * @return true if mapping exists
 */
-(BOOL) hasMappingToStyleRow: (GPKGStyleRow *) styleRow;

/**
 * Determine if a mapping to the style row id exists
 *
 * @param id style row id
 * @return true if mapping exists
 */
-(BOOL) hasMappingToStyleRowId: (int) id;

/**
 * Delete style row mappings
 *
 * @param styleRow style row
 * @return number of mapping rows deleted
 */
-(int) deleteMappingsToStyleRow: (GPKGStyleRow *) styleRow;

/**
 * Delete style row mappings
 *
 * @param id style row id
 * @return number of mapping rows deleted
 */
-(int) deleteMappingsToStyleRowId: (int) id;

/**
 * Delete a style row and mappings
 *
 * @param styleRow style row
 * @return number of rows deleted between the style and mapping tables
 */
-(int) deleteStyleRow: (GPKGStyleRow *) styleRow;

/**
 * Delete a style row only if it has no mappings
 *
 * @param styleRow style row
 * @return number of style rows deleted
 */
-(int) deleteNotMappedStyleRow: (GPKGStyleRow *) styleRow;

/**
 * Delete a style row by id and mappings
 *
 * @param id style row id
 * @return number of rows deleted between the style and mapping tables
 */
-(int) deleteStyleRowById: (int) id;

/**
 * Delete a style row by id only if it has no mappings
 *
 * @param id style row id
 * @return number of style rows deleted
 */
-(int) deleteNotMappedStyleRowById: (int) id;

/**
 * Delete style rows matching the where clause and mappings to them
 *
 * @param where where clause
 * @param whereArgs   where arguments
 * @return deleted count
 */
-(int) deleteStyleRowsWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Delete style rows matching the where clause if they have no mappings
 *
 * @param where where clause
 * @param whereArgs   where arguments
 * @return deleted count
 */
-(int) deleteNotMappedStyleRowsWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Delete style rows matching the field values and mappings to them
 *
 * @param fieldValues field values
 * @return deleted count
 */
-(int) deleteStyleRowsByFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Delete style rows matching the field values if they have no mappings
 *
 * @param fieldValues field values
 * @return deleted count
 */
-(int) deleteNotMappedStyleRowsByFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Delete all style rows and mappings to them
 *
 * @return deleted count
 */
-(int) deleteStyleRows;

/**
 * Delete all style rows if they have no mappings
 *
 * @return deleted count
 */
-(int) deleteNotMappedStyleRows;

/**
 * Count the number of mappings to the icon row
 *
 * @param iconRow icon row
 * @return mappings count
 */
-(int) countMappingsToIconRow: (GPKGIconRow *) iconRow;

/**
 * Count the number of mappings to the icon row id
 *
 * @param id icon row id
 * @return mappings count
 */
-(int) countMappingsToIconRowId: (int) id;

/**
 * Determine if a mapping to the icon row exists
 *
 * @param iconRow icon row
 * @return true if mapping exists
 */
-(BOOL) hasMappingToIconRow: (GPKGIconRow *) iconRow;

/**
 * Determine if a mapping to the icon row id exists
 *
 * @param id icon row id
 * @return true if mapping exists
 */
-(BOOL) hasMappingToIconRowId: (int) id;

/**
 * Delete icon row mappings
 *
 * @param iconRow icon row
 * @return number of mapping rows deleted
 */
-(int) deleteMappingsToIconRow: (GPKGIconRow *) iconRow;

/**
 * Delete icon row mappings
 *
 * @param id icon row id
 * @return number of mapping rows deleted
 */
-(int) deleteMappingsToIconRowId: (int) id;

/**
 * Delete an icon row and mappings
 *
 * @param iconRow icon row
 * @return number of rows deleted between the icon and mapping tables
 */
-(int) deleteIconRow: (GPKGIconRow *) iconRow;

/**
 * Delete a icon row only if it has no mappings
 *
 * @param iconRow icon row
 * @return number of icon rows deleted
 */
-(int) deleteNotMappedIconRow: (GPKGIconRow *) iconRow;

/**
 * Delete an icon row by id and mappings
 *
 * @param id icon row id
 * @return number of rows deleted between the icon and mapping tables
 */
-(int) deleteIconRowById: (int) id;

/**
 * Delete a icon row by id only if it has no mappings
 *
 * @param id icon row id
 * @return number of icon rows deleted
 */
-(int) deleteNotMappedIconRowById: (int) id;

/**
 * Delete icon rows matching the where clause and mappings to them
 *
 * @param where where clause
 * @param whereArgs   where arguments
 * @return deleted count
 */
-(int) deleteIconRowsWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Delete icon rows matching the where clause if they have no mappings
 *
 * @param where where clause
 * @param whereArgs   where arguments
 * @return deleted count
 */
-(int) deleteNotMappedIconRowsWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Delete icon rows matching the field values and mappings to them
 *
 * @param fieldValues field values
 * @return deleted count
 */
-(int) deleteIconRowsByFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Delete icon rows matching the field values if they have no mappings
 *
 * @param fieldValues field values
 * @return deleted count
 */
-(int) deleteNotMappedIconRowsByFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Delete all icon rows and mappings to them
 *
 * @return deleted count
 */
-(int) deleteIconRows;

/**
 * Delete all icon rows if they have no mappings
 *
 * @return deleted count
 */
-(int) deleteNotMappedIconRows;

/**
 * Get all the unique style row ids the table maps to
 *
 * @param featureTable feature table
 * @return style row ids
 */
-(NSArray<NSNumber *> *) allTableStyleIdsWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Get all the unique style row ids the table maps to
 *
 * @param featureTable feature table
 * @return style row ids
 */
-(NSArray<NSNumber *> *) allTableStyleIdsWithTableName: (NSString *) featureTable;

/**
 * Get all the unique icon row ids the table maps to
 *
 * @param featureTable feature table
 * @return icon row ids
 */
-(NSArray<NSNumber *> *) allTableIconIdsWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Get all the unique icon row ids the table maps to
 *
 * @param featureTable feature table
 * @return icon row ids
 */
-(NSArray<NSNumber *> *) allTableIconIdsWithTableName: (NSString *) featureTable;

/**
 * Get all the unique style row ids the features map to
 *
 * @param featureTable feature table
 * @return style row ids
 */
-(NSArray<NSNumber *> *) allStyleIdsWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Get all the unique style row ids the features map to
 *
 * @param featureTable feature table
 * @return style row ids
 */
-(NSArray<NSNumber *> *) allStyleIdsWithTableName: (NSString *) featureTable;

/**
 * Get all the unique icon row ids the features map to
 *
 * @param featureTable feature table
 * @return icon row ids
 */
-(NSArray<NSNumber *> *) allIconIdsWithTable: (GPKGFeatureTable *) featureTable;

/**
 * Get all the unique icon row ids the features map to
 *
 * @param featureTable feature table
 * @return icon row ids
 */
-(NSArray<NSNumber *> *) allIconIdsWithTableName: (NSString *) featureTable;

/**
 * Calculate style pixel bounds
 *
 * @param featureTable feature table
 * @return pixel bounds
 */
-(GPKGPixelBounds *) calculatePixelBoundsWithTable: (NSString *) featureTable;

/**
 * Calculate style pixel bounds for the feature table
 *
 * @param featureTable feature table
 * @param scale scale factor
 * @return pixel bounds
 */
-(GPKGPixelBounds *) calculatePixelBoundsWithTable: (NSString *) featureTable andScale: (float) scale;

/**
 * Calculate style pixel bounds for the style row
 *
 * @param styleRow style row
 * @return pixel bounds
 */
+(GPKGPixelBounds *) calculatePixelBoundsWithStyleRow: (GPKGStyleRow *) styleRow;

/**
 * Calculate style pixel bounds for the style row
 *
 * @param styleRow style row
 * @param scale scale factor
 * @return pixel bounds
 */
+(GPKGPixelBounds *) calculatePixelBoundsWithStyleRow: (GPKGStyleRow *) styleRow andScale: (float) scale;

/**
 * Calculate style pixel bounds for the style row
 *
 * @param pixelBounds pixel bounds to expand
 * @param styleRow    style row
 */
+(void) expandPixelBounds: (GPKGPixelBounds *) pixelBounds withStyleRow: (GPKGStyleRow *) styleRow;

/**
 * Calculate style pixel bounds for the style row
 *
 * @param pixelBounds pixel bounds to expand
 * @param styleRow    style row
 * @param scale scale factor
 */
+(void) expandPixelBounds: (GPKGPixelBounds *) pixelBounds withStyleRow: (GPKGStyleRow *) styleRow andScale: (float) scale;

/**
 * Calculate style pixel bounds for the icon row
 *
 * @param iconRow icon row
 * @return pixel bounds
 */
+(GPKGPixelBounds *) calculatePixelBoundsWithIconRow: (GPKGIconRow *) iconRow;

/**
 * Calculate style pixel bounds for the icon row
 *
 * @param iconRow icon row
 * @param scale scale factor
 * @return pixel bounds
 */
+(GPKGPixelBounds *) calculatePixelBoundsWithIconRow: (GPKGIconRow *) iconRow andScale: (float) scale;

/**
 * Calculate style pixel bounds for the icon row
 *
 * @param pixelBounds pixel bounds to expand
 * @param iconRow     icon row
 */
+(void) expandPixelBounds: (GPKGPixelBounds *) pixelBounds withIconRow: (GPKGIconRow *) iconRow;

/**
 * Calculate style pixel bounds for the icon row
 *
 * @param pixelBounds pixel bounds to expand
 * @param iconRow     icon row
 * @param scale scale factor
 */
+(void) expandPixelBounds: (GPKGPixelBounds *) pixelBounds withIconRow: (GPKGIconRow *) iconRow andScale: (float) scale;

@end
