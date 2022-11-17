//
//  GPKGDgiwgValidate.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"
#import "GPKGDgiwgValidationErrors.h"

/**
 * Performs DGIWG (Defence Geospatial Information Working Group) GeoPackage
 * validations
 */
@interface GPKGDgiwgValidate : NSObject

/**
 * Is the GeoPackage valid according to the DGIWG GeoPackage Profile
 *
 * @param geoPackage
 *            GeoPackage
 * @return true if valid
 */
+(BOOL) isValid: (GPKGGeoPackage *) geoPackage;

/**
 * Validate the GeoPackage against the DGIWG GeoPackage Profile
 *
 * @param geoPackage
 *            GeoPackage
 * @return validation errors
 */
+(GPKGDgiwgValidationErrors *) validate: (GPKGGeoPackage *) geoPackage;

/**
 * Validate the base GeoPackage against the DGIWG GeoPackage Profile
 *
 * @param geoPackage
 *            GeoPackage
 * @return validation errors
 */
+(GPKGDgiwgValidationErrors *) validateBase: (GPKGGeoPackage *) geoPackage;

/**
 * Validate the GeoPackage table against the DGIWG GeoPackage Profile
 *
 * @param table
 *            table
 * @param geoPackage
 *            GeoPackage
 * @return validation errors
 */
+(GPKGDgiwgValidationErrors *) validateTable: (NSString *) table inGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Validate the GeoPackage tables against the DGIWG GeoPackage Profile
 *
 * @param tables
 *            tables
 * @param geoPackage
 *            GeoPackage
 * @return validation errors
 */
+(GPKGDgiwgValidationErrors *) validateTables: (NSArray<NSString *> *) tables inGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Validate the GeoPackage metadata
 *
 * @param geoPackage
 *            GeoPackage
 * @return validation errors
 */
+(GPKGDgiwgValidationErrors *) validateMetadata: (GPKGGeoPackage *) geoPackage;

/**
 * Validate tile table
 *
 * @param tileTable
 *            tile table
 * @param geoPackage
 *            GeoPackage
 * @return validation errors
 */
+(GPKGDgiwgValidationErrors *) validateTileTable: (NSString *) tileTable inGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Validate the tile coordinate reference system
 *
 * @param tileTable
 *            tile table
 * @param srs
 *            spatial reference system
 * @return validation errors
 */
+(GPKGDgiwgValidationErrors *) validateCRSWithTileTable: (NSString *) tileTable andSRS: (GPKGSpatialReferenceSystem *) srs;

/**
 * Validate feature table
 *
 * @param featureTable
 *            feature table
 * @param geoPackage
 *            GeoPackage
 * @return validation errors
 */
+(GPKGDgiwgValidationErrors *) validateFeatureTable: (NSString *) featureTable inGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Validate the feature coordinate reference system
 *
 * @param featureTable
 *            feature table
 * @param srs
 *            spatial reference system
 * @return validation errors
 */
+(GPKGDgiwgValidationErrors *) validateCRSWithFeatureTable: (NSString *) featureTable andSRS: (GPKGSpatialReferenceSystem *) srs;

@end
