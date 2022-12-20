//
//  GPKGAttributesUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackage.h"

@interface GPKGAttributesUtils : NSObject

/**
 * Test read
 *
 * @param geoPackage
 */
+(void) testReadWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test update
 *
 * @param geoPackage
 */
+(void) testUpdateWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test update with added columns
 *
 * @param geoPackage GeoPackage
 */
+(void) testUpdateAddColumnsWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test updates for the attributes table
 *
 * @param dao
 *            attributes dao
 */
+(void) testUpdateWithDao: (GPKGAttributesDao *) dao;

/**
 * Test create
 *
 * @param geoPackage
 */
+(void) testCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test delete
 *
 * @param geoPackage
 */
+(void) testDeleteWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
