//
//  GPKGPropertiesExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/23/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"

extern NSString * const GPKG_EXTENSION_PROPERTIES_NAME_NO_AUTHOR;
extern NSString * const GPKG_PROP_EXTENSION_PROPERTIES_DEFINITION;
extern NSString * const GPKG_EXTENSION_PROPERTIES_TABLE_NAME;
extern NSString * const GPKG_EXTENSION_PROPERTIES_COLUMN_PROPERTY;
extern NSString * const GPKG_EXTENSION_PROPERTIES_COLUMN_VALUE;

/**
 * GeoPackage properties extension for defining GeoPackage specific
 * properties, attributes, and metadata
 * <p>
 * <a href=
 * "http://ngageoint.github.io/GeoPackage/docs/extensions/properties.html">http://ngageoint.github.io/GeoPackage/docs/extensions/properties.html</a>
 */
@interface GPKGPropertiesExtension : GPKGBaseExtension

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new properties extension
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get or create the extension
 *
 *  @return extension
 */
-(GPKGExtensions *) extensionCreate;

/**
 * Determine if the GeoPackage has the extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 *  Get the extension name
 *
 *  @return extension name
 */
-(NSString *) extensionName;

/**
 *  Get the extension definition
 *
 *  @return extension definition
 */
-(NSString *) extensionDefinition;

/**
 * Get the number of properties
 *
 * @return property count
 */
-(int) numProperties;

/**
 * Get the properties
 *
 * @return list of properties
 */
-(NSArray<NSString *> *) properties;

/**
 * Check if the property exists, same call as {@link #hasValues(String)}
 *
 * @param property
 *            property name
 * @return true if has property
 */
-(BOOL) hasProperty: (NSString *) property;

/**
 * Get the number of total values combined for all properties
 *
 * @return number of total property values
 */
-(int) numValues;

/**
 * Get the number of values for the property
 *
 * @param property
 *            property name
 * @return number of values
 */
-(int) numValuesOfProperty: (NSString *) property;

/**
 * Check if the property has a single value
 *
 * @param property
 *            property name
 * @return true if has a single value
 */
-(BOOL) hasSingleValueWithProperty: (NSString *) property;

/**
 * Check if the property has any values
 *
 * @param property
 *            property name
 * @return true if has any values
 */
-(BOOL) hasValuesWithProperty: (NSString *) property;

/**
 * Get the first value for the property
 *
 * @param property
 *            property name
 * @return value or null
 */
-(NSString *) valueOfProperty: (NSString *) property;

/**
 * Get the values for the property
 *
 * @param property
 *            property name
 * @return list of values
 */
-(NSArray<NSString *> *) valuesOfProperty: (NSString *) property;

/**
 * Check if the property has the value
 *
 * @param property
 *            property name
 * @param value
 *            property value
 * @return true if property has the value
 */
-(BOOL) hasValue: (NSString *) value withProperty: (NSString *) property;

/**
 * Add a property value, creating the extension if needed
 *
 * @param property
 *            property name
 * @param value
 *            value
 * @return true if added, false if already existed
 */
-(BOOL) addValue: (NSString *) value withProperty: (NSString *) property;

/**
 * Delete the property and all the property values
 *
 * @param property
 *            property name
 * @return deleted values count
 */
-(int) deleteProperty: (NSString *) property;

/**
 * Delete the property value
 *
 * @param property
 *            property name
 * @param value
 *            property value
 * @return deleted values count
 */
-(int) deleteValue: (NSString *) value withProperty: (NSString *) property;

/**
 * Delete all properties and values
 *
 * @return deleted values count
 */
-(int) deleteAll;

/**
 * Remove the extension
 */
-(void) removeExtension;

@end
