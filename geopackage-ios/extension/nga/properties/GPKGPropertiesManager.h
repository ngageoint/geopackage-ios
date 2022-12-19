//
//  GPKGPropertiesManager.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/24/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGGeoPackageCache.h"
#import "GPKGPropertiesExtension.h"

@interface GPKGPropertiesManager : NSObject

/**
 *  Initialize
 *
 *  @return new properties manager
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new properties manager
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Initialize
 *
 *  @param geoPackages array of GeoPackages
 *
 *  @return new properties manager
 */
-(instancetype) initWithGeoPackages: (NSArray<GPKGGeoPackage *> *) geoPackages;

/**
 *  Initialize
 *
 *  @param cache GeoPackage cache
 *
 *  @return new properties manager
 */
-(instancetype) initWithCache: (GPKGGeoPackageCache *) cache;

/**
 * Create a properties extension from the GeoPackage
 *
 * @param geoPackage
 *            GeoPackage
 * @return properties extension
 */
-(GPKGPropertiesExtension *) propertiesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get the GeoPackage names
 *
 * @return names
 */
-(NSSet<NSString *> *) geoPackageNames;

/**
 * Get the number of GeoPackages
 *
 * @return GeoPackage count
 */
-(int) numGeoPackages;

/**
 * Get the GeoPackages
 *
 * @return collection of GeoPackages
 */
-(NSArray<GPKGGeoPackage *> *) geoPackages;

/**
 * Checks if the GeoPackage name exists
 *
 * @param name
 *            GeoPackage name
 * @return true if exists
 */
-(BOOL) hasGeoPackageWithName: (NSString *) name;

/**
 * Get the GeoPackage for the GeoPackage name
 *
 * @param name
 *            GeoPackage name
 * @return GeoPackage
 */
-(GPKGGeoPackage *) geoPackageWithName: (NSString *) name;

/**
 * Add a collection of GeoPackages
 *
 * @param geoPackages
 *            GeoPackages
 */
-(void) addGeoPackages: (NSArray<GPKGGeoPackage *> *) geoPackages;

/**
 * Add GeoPackage
 *
 * @param geoPackage
 *            GeoPackage
 */
-(void) addGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Close all GeoPackages in the manager
 */
-(void) closeGeoPackages;

/**
 * Remove the GeoPackage with the name but does not close it
 *
 * @param name
 *            GeoPackage name
 * @return removed GeoPackage
 */
-(GPKGGeoPackage *) removeGeoPackageWithName: (NSString *) name;

/**
 * Clears all cached GeoPackages but does not close them
 */
-(void) clearGeoPackages;

/**
 * Remove and close the GeoPackage with name, same as
 * {@link #closeGeoPackage(String)}
 *
 * @param name
 *            GeoPackage name
 * @return true if found, removed, and closed
 */
-(BOOL) removeAndCloseGeoPackageWithName: (NSString *) name;

/**
 * Close the GeoPackage with name
 *
 * @param name
 *            GeoPackage name
 * @return true if found and closed
 */
-(BOOL) closeGeoPackageWithName: (NSString *) name;

/**
 * Close GeoPackages not specified in the retain GeoPackage names
 *
 * @param retain
 *            GeoPackages to retain
 */
-(void) closeRetainGeoPackages: (NSArray<NSString *> *) retain;

/**
 * Close GeoPackages with names
 *
 * @param names
 *            GeoPackage names
 */
-(void) closeGeoPackages: (NSArray<NSString *> *) names;

/**
 * Get the number of unique properties
 *
 * @return property count
 */
-(int) numProperties;

/**
 * Get the unique properties
 *
 * @return set of properties
 */
-(NSSet<NSString *> *) properties;

/**
 * Get the GeoPackages with the property name
 *
 * @param property
 *            property name
 * @return GeoPackages
 */
-(NSArray<GPKGGeoPackage *> *) hasProperty: (NSString *) property;

/**
 * Get the GeoPackages missing the property name
 *
 * @param property
 *            property name
 * @return GeoPackages
 */
-(NSArray<GPKGGeoPackage *> *) missingProperty: (NSString *) property;

/**
 * Get the number of unique values for the property
 *
 * @param property
 *            property name
 * @return number of values
 */
-(int) numValuesOfProperty: (NSString *) property;

/**
 * Check if the property has any values
 *
 * @param property
 *            property name
 * @return true if has any values
 */
-(BOOL) hasValuesWithProperty: (NSString *) property;

/**
 * Get the unique values for the property
 *
 * @param property
 *            property name
 * @return set of values
 */
-(NSSet<NSString *> *) valuesOfProperty: (NSString *) property;

/**
 * Get the GeoPackages with the property name and value
 *
 * @param property
 *            property name
 * @param value
 *            property value
 * @return GeoPackages
 */
-(NSArray<GPKGGeoPackage *> *) hasValue: (NSString *) value withProperty: (NSString *) property;

/**
 * Get the GeoPackages missing the property name and value
 *
 * @param property
 *            property name
 * @param value
 *            property value
 * @return GeoPackages
 */
-(NSArray<GPKGGeoPackage *> *) missingValue: (NSString *) value withProperty: (NSString *) property;

/**
 * Add a property value to all GeoPackages
 *
 * @param property
 *            property name
 * @param value
 *            value
 * @return number of GeoPackages added to
 */
-(int) addValue: (NSString *) value withProperty: (NSString *) property;

/**
 * Add a property value to a specified GeoPackage
 *
 * @param geoPackage
 *            GeoPackage name
 * @param property
 *            property name
 * @param value
 *            value
 * @return true if added
 */
-(int) addValue: (NSString *) value withProperty: (NSString *) property inGeoPackage: (NSString *) geoPackage;

/**
 * Delete the property and values from all GeoPackages
 *
 * @param property
 *            property name
 * @return number of GeoPackages deleted from
 */
-(int) deleteProperty: (NSString *) property;

/**
 * Delete the property and values from a specified GeoPackage
 *
 * @param geoPackage
 *            GeoPackage name
 * @param property
 *            property name
 * @return true if deleted
 */
-(int) deleteProperty: (NSString *) property inGeoPackage: (NSString *) geoPackage;

/**
 * Delete the property value from all GeoPackages
 *
 * @param property
 *            property name
 * @param value
 *            property value
 * @return number of GeoPackages deleted from
 */
-(int) deleteValue: (NSString *) value withProperty: (NSString *) property;

/**
 * Delete the property value from a specified GeoPackage
 *
 * @param geoPackage
 *            GeoPackage name
 * @param property
 *            property name
 * @param value
 *            property value
 * @return true if deleted
 */
-(int) deleteValue: (NSString *) value withProperty: (NSString *) property inGeoPackage: (NSString *) geoPackage;

/**
 * Delete all properties and values from all GeoPackages
 *
 * @return number of GeoPackages deleted from
 */
-(int) deleteAll;

/**
 * Delete all properties and values from a specified GeoPackage
 *
 * @param geoPackage
 *            GeoPackage name
 * @return true if any deleted
 */
-(int) deleteAllInGeoPackage: (NSString *) geoPackage;

/**
 * Remove the extension from all GeoPackages
 */
-(void) removeExtension;

/**
 * Remove the extension from a specified GeoPackage
 *
 * @param geoPackage
 *            GeoPackage name
 */
-(void) removeExtensionInGeoPackage: (NSString *) geoPackage;

@end
