//
//  GPKGFeatureTableStyles.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureStyleExtension.h"

/**
 * Feature Table Styles, styles and icons for an individual feature table
 */
@interface GPKGFeatureTableStyles : NSObject

/**
 * Constructor
 *
 * @param geoPackage   GeoPackage
 * @param featureTable feature table
 *
 * @return new feature table styles
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (GPKGFeatureTable *) featureTable;

/**
 * Constructor
 *
 * @param geoPackage      GeoPackage
 * @param geometryColumns geometry columns
 *
 * @return new feature table styles
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

/**
 * Constructor
 *
 * @param geoPackage GeoPackage
 * @param contents   feature contents
 *
 * @return new feature table styles
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andContents: (GPKGContents *) contents;

/**
 * Constructor
 *
 * @param geoPackage   GeoPackage
 * @param featureTable feature table
 *
 * @return new feature table styles
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) featureTable;

/**
 * Get the feature style extension
 *
 * @return feature style extension
 */
-(GPKGFeatureStyleExtension *) featureStyleExtension;

/**
 * Get the feature table name
 *
 * @return feature table name
 */
-(NSString *) tableName;

/**
 * Determine if the GeoPackage has the extension for the table
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 * Create style, icon, table style, and table icon relationships for the
 * feature table
 */
-(void) createRelationships;

/**
 * Check if feature table has a style, icon, table style, or table icon
 * relationships
 *
 * @return true if has a relationship
 */
-(BOOL) hasRelationship;

/**
 * Create a style relationship for the feature table
 */
-(void) createStyleRelationship;

/**
 * Determine if a style relationship exists for the feature table
 *
 * @return true if relationship exists
 */
-(BOOL) hasStyleRelationship;

/**
 * Create a feature table style relationship
 */
-(void) createTableStyleRelationship;

/**
 * Determine if feature table style relationship exists
 *
 * @return true if relationship exists
 */
-(BOOL) hasTableStyleRelationship;

/**
 * Create an icon relationship for the feature table
 */
-(void) createIconRelationship;

/**
 * Determine if an icon relationship exists for the feature table
 *
 * @return true if relationship exists
 */
-(BOOL) hasIconRelationship;

/**
 * Create a feature table icon relationship
 */
-(void) createTableIconRelationship;

/**
 * Determine if feature table icon relationship exists
 *
 * @return true if relationship exists
 */
-(BOOL) hasTableIconRelationship;

/**
 * Delete the style and icon table and row relationships for the feature
 * table
 */
-(void) deleteRelationships;

/**
 * Delete a style relationship for the feature table
 */
-(void) deleteStyleRelationship;

/**
 * Delete a table style relationship for the feature table
 */
-(void) deleteTableStyleRelationship;

/**
 * Delete a icon relationship for the feature table
 */
-(void) deleteIconRelationship;

/**
 * Delete a table icon relationship for the feature table
 */
-(void) deleteTableIconRelationship;

/**
 * Get a Style Mapping DAO
 *
 * @return style mapping DAO
 */
-(GPKGStyleMappingDao *) styleMappingDao;

/**
 * Get a Table Style Mapping DAO
 *
 * @return table style mapping DAO
 */
-(GPKGStyleMappingDao *) tableStyleMappingDao;

/**
 * Get a Icon Mapping DAO
 *
 * @return icon mapping DAO
 */
-(GPKGStyleMappingDao *) iconMappingDao;

/**
 * Get a Table Icon Mapping DAO
 *
 * @return table icon mapping DAO
 */
-(GPKGStyleMappingDao *) tableIconMappingDao;

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
 * Get the table feature styles
 *
 * @return table feature styles or null
 */
-(GPKGFeatureStyles *) tableFeatureStyles;

/**
 * Get the table styles
 *
 * @return table styles or null
 */
-(GPKGStyles *) tableStyles;

/**
 * Get the cached table styles, querying and caching if needed
 *
 * @return cached table styles
 */
-(GPKGStyles *) cachedTableStyles;

/**
 * Get the table style of the geometry type
 *
 * @param geometryType geometry type
 * @return style row
 */
-(GPKGStyleRow *) tableStyleWithGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the table style default
 *
 * @return style row
 */
-(GPKGStyleRow *) tableStyleDefault;

/**
 * Get the table icons
 *
 * @return table icons or null
 */
-(GPKGIcons *) tableIcons;

/**
 * Get the cached table icons, querying and caching if needed
 *
 * @return cached table icons
 */
-(GPKGIcons *) cachedTableIcons;

/**
 * Get the table icon of the geometry type
 *
 * @param geometryType geometry type
 * @return icon row
 */
-(GPKGIconRow *) tableIconWithGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the table icon default
 *
 * @return icon row
 */
-(GPKGIconRow *) tableIconDefault;

/**
 * Get the feature styles for the feature row
 *
 * @param featureRow feature row
 * @return feature styles or null
 */
-(GPKGFeatureStyles *) featureStylesWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the feature styles for the feature id
 *
 * @param featureId feature id
 * @return feature styles or null
 */
-(GPKGFeatureStyles *) featureStylesWithId: (int) featureId;

/**
 * Get the feature styles for the feature id
 *
 * @param featureId feature id
 * @return feature styles or null
 */
-(GPKGFeatureStyles *) featureStylesWithIdNumber: (NSNumber *) featureId;

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
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleWithId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the feature style (style and icon) of the feature, searching in
 * order: feature geometry type style or icon, feature default style or
 * icon, table geometry type style or icon, table default style or icon
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleWithIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the feature style (style and icon) of the feature, searching in
 * order: feature geometry type style or icon, feature default style or
 * icon, table geometry type style or icon, table default style or icon
 *
 * @param featureId feature id
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleDefaultWithId: (int) featureId;

/**
 * Get the feature style (style and icon) of the feature, searching in
 * order: feature geometry type style or icon, feature default style or
 * icon, table geometry type style or icon, table default style or icon
 *
 * @param featureId feature id
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleDefaultWithIdNumber: (NSNumber *) featureId;

/**
 * Get the styles for the feature row
 *
 * @param featureRow feature row
 * @return styles or null
 */
-(GPKGStyles *) stylesWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the styles for the feature id
 *
 * @param featureId feature id
 * @return styles or null
 */
-(GPKGStyles *) stylesWithId: (int) featureId;

/**
 * Get the styles for the feature id
 *
 * @param featureId feature id
 * @return styles or null
 */
-(GPKGStyles *) stylesWithIdNumber: (NSNumber *) featureId;

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
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return style row
 */
-(GPKGStyleRow *) styleWithId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the style of the feature, searching in order: feature geometry type
 * style, feature default style, table geometry type style, table default
 * style
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return style row
 */
-(GPKGStyleRow *) styleWithIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the default style of the feature, searching in order: feature default
 * style, table default style
 *
 * @param featureId feature id
 * @return style row
 */
-(GPKGStyleRow *) styleDefaultWithId: (int) featureId;

/**
 * Get the default style of the feature, searching in order: feature default
 * style, table default style
 *
 * @param featureId feature id
 * @return style row
 */
-(GPKGStyleRow *) styleDefaultWithIdNumber: (NSNumber *) featureId;

/**
 * Get the icons for the feature row
 *
 * @param featureRow feature row
 * @return icons or null
 */
-(GPKGIcons *) iconsWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the icons for the feature id
 *
 * @param featureId feature id
 * @return icons or null
 */
-(GPKGIcons *) iconsWithId: (int) featureId;

/**
 * Get the icons for the feature id
 *
 * @param featureId feature id
 * @return icons or null
 */
-(GPKGIcons *) iconsWithIdNumber: (NSNumber *) featureId;

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
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return icon row
 */
-(GPKGIconRow *) iconWithId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the icon of the feature, searching in order: feature geometry type
 * icon, feature default icon, table geometry type icon, table default icon
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 * @return icon row
 */
-(GPKGIconRow *) iconWithIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the default icon of the feature, searching in order: feature default
 * icon, table default icon
 *
 * @param featureId feature id
 * @return icon row
 */
-(GPKGIconRow *) iconDefaultWithId: (int) featureId;

/**
 * Get the default icon of the feature, searching in order: feature default
 * icon, table default icon
 *
 * @param featureId feature id
 * @return icon row
 */
-(GPKGIconRow *) iconDefaultWithIdNumber: (NSNumber *) featureId;

/**
 * Set the feature table default feature styles
 *
 * @param featureStyles default feature styles
 */
-(void) setTableFeatureStyles: (GPKGFeatureStyles *) featureStyles;

/**
 * Set the feature table default styles
 *
 * @param styles default styles
 */
-(void) setTableStyles: (GPKGStyles *) styles;

/**
 * Set the feature table style default
 *
 * @param style style row
 */
-(void) setTableStyleDefault: (GPKGStyleRow *) style;

/**
 * Set the feature table style for the geometry type
 *
 * @param geometryType geometry type
 * @param style        style row
 */
-(void) setTableStyle: (GPKGStyleRow *) style withGeometryType: (enum SFGeometryType) geometryType;

/**
 * Set the feature table default icons
 *
 * @param icons default icons
 */
-(void) setTableIcons: (GPKGIcons *) icons;

/**
 * Set the feature table icon default
 *
 * @param icon icon row
 */
-(void) setTableIconDefault: (GPKGIconRow *) icon;

/**
 * Set the feature table icon for the geometry type
 *
 * @param geometryType geometry type
 * @param icon         icon row
 */
-(void) setTableIcon: (GPKGIconRow *) icon withGeometryType: (enum SFGeometryType) geometryType;

/**
 * Set the feature styles for the feature row
 *
 * @param featureRow    feature row
 * @param featureStyles feature styles
 */
-(void) setFeatureStyles: (GPKGFeatureStyles *) featureStyles withFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the feature styles for the feature table and feature id
 *
 * @param featureId     feature id
 * @param featureStyles feature styles
 */
-(void) setFeatureStyles: (GPKGFeatureStyles *) featureStyles withId: (int) featureId;

/**
 * Set the feature styles for the feature table and feature id
 *
 * @param featureId     feature id
 * @param featureStyles feature styles
 */
-(void) setFeatureStyles: (GPKGFeatureStyles *) featureStyles withIdNumber: (NSNumber *) featureId;

/**
 * Set the feature style (style and icon) of the feature row
 *
 * @param featureRow   feature row
 * @param featureStyle feature style
 */
-(void) setFeatureStyle: (GPKGFeatureStyle *) featureStyle withFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the feature style (style and icon) of the feature row for the
 * specified geometry type
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 * @param featureStyle feature style
 */
-(void) setFeatureStyle: (GPKGFeatureStyle *) featureStyle withFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Set the feature style default (style and icon) of the feature row
 *
 * @param featureRow   feature row
 * @param featureStyle feature style
 */
-(void) setFeatureStyleDefault: (GPKGFeatureStyle *) featureStyle withFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the feature style (style and icon) of the feature
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param featureStyle feature style
 */
-(void) setFeatureStyle: (GPKGFeatureStyle *) featureStyle withId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Set the feature style (style and icon) of the feature
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param featureStyle feature style
 */
-(void) setFeatureStyle: (GPKGFeatureStyle *) featureStyle withIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Set the feature style (style and icon) of the feature
 *
 * @param featureId    feature id
 * @param featureStyle feature style
 */
-(void) setFeatureStyleDefault: (GPKGFeatureStyle *) featureStyle withId: (int) featureId;

/**
 * Set the feature style (style and icon) of the feature
 *
 * @param featureId    feature id
 * @param featureStyle feature style
 */
-(void) setFeatureStyleDefault: (GPKGFeatureStyle *) featureStyle withIdNumber: (NSNumber *) featureId;

/**
 * Set the styles for the feature row
 *
 * @param featureRow feature row
 * @param styles     styles
 */
-(void) setStyles: (GPKGStyles *) styles withFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the styles for the feature table and feature id
 *
 * @param featureId feature id
 * @param styles    styles
 */
-(void) setStyles: (GPKGStyles *) styles withId: (int) featureId;

/**
 * Set the styles for the feature table and feature id
 *
 * @param featureId feature id
 * @param styles    styles
 */
-(void) setStyles: (GPKGStyles *) styles withIdNumber: (NSNumber *) featureId;

/**
 * Set the style of the feature row
 *
 * @param featureRow feature row
 * @param style      style row
 */
-(void) setStyle: (GPKGStyleRow *) style withFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the style of the feature row for the specified geometry type
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 * @param style        style row
 */
-(void) setStyle: (GPKGStyleRow *) style withFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Set the default style of the feature row
 *
 * @param featureRow feature row
 * @param style      style row
 */
-(void) setStyleDefault: (GPKGStyleRow *) style withFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the style of the feature
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param style        style row
 */
-(void) setStyle: (GPKGStyleRow *) style withId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Set the style of the feature
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param style        style row
 */
-(void) setStyle: (GPKGStyleRow *) style withIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Set the default style of the feature
 *
 * @param featureId feature id
 * @param style     style row
 */
-(void) setStyleDefault: (GPKGStyleRow *) style withId: (int) featureId;

/**
 * Set the default style of the feature
 *
 * @param featureId feature id
 * @param style     style row
 */
-(void) setStyleDefault: (GPKGStyleRow *) style withIdNumber: (NSNumber *) featureId;

/**
 * Set the icons for the feature row
 *
 * @param featureRow feature row
 * @param icons      icons
 */
-(void) setIcons: (GPKGIcons *) icons withFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the icons for the feature table and feature id
 *
 * @param featureId feature id
 * @param icons     icons
 */
-(void) setIcons: (GPKGIcons *) icons withId: (int) featureId;

/**
 * Set the icons for the feature table and feature id
 *
 * @param featureId feature id
 * @param icons     icons
 */
-(void) setIcons: (GPKGIcons *) icons withIdNumber: (NSNumber *) featureId;

/**
 * Set the icon of the feature row
 *
 * @param featureRow feature row
 * @param icon       icon row
 */
-(void) setIcon: (GPKGIconRow *) icon withFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the icon of the feature row for the specified geometry type
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 * @param icon         icon row
 */
-(void) setIcon: (GPKGIconRow *) icon withFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Set the default icon of the feature row
 *
 * @param featureRow feature row
 * @param icon       icon row
 */
-(void) setIconDefault: (GPKGIconRow *) icon withFeature: (GPKGFeatureRow *) featureRow;

/**
 * Get the icon of the feature, searching in order: feature geometry type
 * icon, feature default icon, table geometry type icon, table default icon
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param icon         icon row
 */
-(void) setIcon: (GPKGIconRow *) icon withId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the icon of the feature, searching in order: feature geometry type
 * icon, feature default icon, table geometry type icon, table default icon
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 * @param icon         icon row
 */
-(void) setIcon: (GPKGIconRow *) icon withIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Set the default icon of the feature
 *
 * @param featureId feature id
 * @param icon      icon row
 */
-(void) setIconDefault: (GPKGIconRow *) icon withId: (int) featureId;

/**
 * Set the default icon of the feature
 *
 * @param featureId feature id
 * @param icon      icon row
 */
-(void) setIconDefault: (GPKGIconRow *) icon withIdNumber: (NSNumber *) featureId;

/**
 * Delete all feature styles including table styles, table icons, style, and
 * icons
 */
-(void) deleteAllFeatureStyles;

/**
 * Delete all styles including table styles and feature row styles
 */
-(void) deleteAllStyles;

/**
 * Delete all icons including table icons and feature row icons
 */
-(void) deleteAllIcons;

/**
 * Delete the feature table feature styles
 */
-(void) deleteTableFeatureStyles;

/**
 * Delete the feature table styles
 */
-(void) deleteTableStyles;

/**
 * Delete the feature table default style
 */
-(void) deleteTableStyleDefault;

/**
 * Delete the feature table style for the geometry type
 *
 * @param geometryType geometry type
 */
-(void) deleteTableStyleWithGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete the feature table icons
 */
-(void) deleteTableIcons;

/**
 * Delete the feature table default icon
 */
-(void) deleteTableIconDefault;

/**
 * Delete the feature table icon for the geometry type
 *
 * @param geometryType geometry type
 */
-(void) deleteTableIconWithGeometryType: (enum SFGeometryType) geometryType;

/**
 * Clear the cached table feature styles
 */
-(void) clearCachedTableFeatureStyles;

/**
 * Clear the cached table styles
 */
-(void) clearCachedTableStyles;

/**
 * Clear the cached table icons
 */
-(void) clearCachedTableIcons;

/**
 * Delete all feature styles
 */
-(void) deleteFeatureStyles;

/**
 * Delete all styles
 */
-(void) deleteStyles;

/**
 * Delete feature row styles
 *
 * @param featureRow feature row
 */
-(void) deleteStylesWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Delete feature row styles
 *
 * @param featureId feature id
 */
-(void) deleteStylesWithId: (int) featureId;

/**
 * Delete feature row styles
 *
 * @param featureId feature id
 */
-(void) deleteStylesWithIdNumber: (NSNumber *) featureId;

/**
 * Delete the feature row default style
 *
 * @param featureRow feature row
 */
-(void) deleteStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Delete the feature row default style
 *
 * @param featureId feature id
 */
-(void) deleteStyleDefaultWithId: (int) featureId;

/**
 * Delete the feature row default style
 *
 * @param featureId feature id
 */
-(void) deleteStyleDefaultWithIdNumber: (NSNumber *) featureId;

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
 * @param featureId    feature id
 * @param geometryType geometry type
 */
-(void) deleteStyleWithId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete the feature row style for the geometry type
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 */
-(void) deleteStyleWithIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete all icons
 */
-(void) deleteIcons;

/**
 * Delete feature row icons
 *
 * @param featureRow feature row
 */
-(void) deleteIconsWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Delete feature row icons
 *
 * @param featureId feature id
 */
-(void) deleteIconsWithId: (int) featureId;

/**
 * Delete feature row icons
 *
 * @param featureId feature id
 */
-(void) deleteIconsWithIdNumber: (NSNumber *) featureId;

/**
 * Delete the feature row default icon
 *
 * @param featureRow feature row
 */
-(void) deleteIconDefaultWithFeature: (GPKGFeatureRow *) featureRow;

/**
 * Delete the feature row default icon
 *
 * @param featureId feature id
 */
-(void) deleteIconDefaultWithId: (int) featureId;

/**
 * Delete the feature row default icon
 *
 * @param featureId feature id
 */
-(void) deleteIconDefaultWithIdNumber: (NSNumber *) featureId;

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
 * @param featureId    feature id
 * @param geometryType geometry type
 */
-(void) deleteIconWithId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Delete the feature row icon for the geometry type
 *
 * @param featureId    feature id
 * @param geometryType geometry type
 */
-(void) deleteIconWithIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get all the unique style row ids the table maps to
 *
 * @return style row ids
 */
-(NSArray<NSNumber *> *) allTableStyleIds;

/**
 * Get all the unique icon row ids the table maps to
 *
 * @return icon row ids
 */
-(NSArray<NSNumber *> *) allTableIconIds;

/**
 * Get all the unique style row ids the features map to
 *
 * @return style row ids
 */
-(NSArray<NSNumber *> *) allStyleIds;

/**
 * Get all the unique icon row ids the features map to
 *
 * @return icon row ids
 */
-(NSArray<NSNumber *> *) allIconIds;

@end
