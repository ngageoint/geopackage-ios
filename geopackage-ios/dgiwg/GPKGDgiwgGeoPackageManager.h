//
//  GPKGDgiwgGeoPackageManager.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackageManager.h"
#import "GPKGDgiwgFile.h"
#import "GPKGDgiwgGeoPackage.h"

/**
 * DGIWG (Defence Geospatial Information Working Group) GeoPackage Manager used
 * to create and open GeoPackages
 */
@interface GPKGDgiwgGeoPackageManager : GPKGGeoPackageManager

/**
 * Initialize
 *
 * @return new DGIWG GeoPackage Manager
 */
-(instancetype) init;

/**
 * Create a GeoPackage
 *
 * @param database database name
 * @param metadata metadata
 * @return GeoPackage file if created
 */
-(GPKGDgiwgFile *) create: (NSString *) database withMetadata: (NSString *) metadata;

/**
 * Create a GeoPackage
 *
 * @param database database name
 * @param uri      URI
 * @param metadata metadata
 * @return GeoPackage file if created
 */
-(GPKGDgiwgFile *) create: (NSString *) database withURI: (NSString *) uri andMetadata: (NSString *) metadata;

/**
 *  Create a new GeoPackage database in specified directory
 *
 *  @param database    database name
 *  @param dbDirectory directory
 *  @param metadata metadata
 *  @return GeoPackage file if created
 */
-(GPKGDgiwgFile *) create: (NSString *) database inDirectory: (NSString *) dbDirectory withMetadata: (NSString *) metadata;

/**
 *  Create a new GeoPackage database in specified directory
 *
 *  @param database    database name
 *  @param dbDirectory directory
 *  @param uri      URI
 *  @param metadata metadata
 *  @return GeoPackage file if created
 */
-(GPKGDgiwgFile *) create: (NSString *) database inDirectory: (NSString *) dbDirectory withURI: (NSString *) uri andMetadata: (NSString *) metadata;

/**
 * Open the database
 *
 * @param database database name
 * @return open GeoPackage
 */
-(GPKGDgiwgGeoPackage *) open: (NSString *) database;

/**
 * Open the database
 *
 * @param database database name
 * @param validate validate the GeoPackage
 * @return open GeoPackage
 */
-(GPKGDgiwgGeoPackage *) open: (NSString *) database andValidate: (BOOL) validate;

/**
 * Delete the database
 *
 * @param file GeoPackage file
 * @return true if deleted
 */
-(BOOL) deleteDGIWG: (GPKGDgiwgFile *) file;

/**
 * Delete the database
 *
 * @param file GeoPackage file
 * @param deleteFile true to delete the GeoPackage file
 * @return true if deleted
 */
-(BOOL) deleteDGIWG: (GPKGDgiwgFile *) file andFile: (BOOL) deleteFile;

/**
 * Is the GeoPackage valid according to the DGIWG GeoPackage Profile
 *
 * @param geoPackage GeoPackage
 * @return true if valid
 */
+(BOOL) isValid: (GPKGDgiwgGeoPackage *) geoPackage;

/**
 * Validate the GeoPackage against the DGIWG GeoPackage Profile
 *
 * @param geoPackage GeoPackage
 * @return validation errors
 */
+(GPKGDgiwgValidationErrors *) validate: (GPKGDgiwgGeoPackage *) geoPackage;

@end
