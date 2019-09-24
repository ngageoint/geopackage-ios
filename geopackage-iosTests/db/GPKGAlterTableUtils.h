//
//  GPKGAlterTableUtils.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

/**
 * Alter Table test utils
 */
@interface GPKGAlterTableUtils : NSObject

/**
 * Test column table alterations
 *
 * @param context    context
 * @param geoPackage GeoPackage
 */
+(void) testColumns: (GPKGGeoPackage *) geoPackage;

/**
 * Test copy feature table
 *
 * @param context    context
 * @param geoPackage GeoPackage
 */
+(void) testCopyFeatureTable: (GPKGGeoPackage *) geoPackage;

/**
 * Test copy tile table
 *
 * @param context    context
 * @param geoPackage GeoPackage
 */
+(void) testCopyTileTable: (GPKGGeoPackage *) geoPackage;

/**
 * Test copy attributes table
 *
 * @param context    context
 * @param geoPackage GeoPackage
 */
+(void) testCopyAttributesTable: (GPKGGeoPackage *) geoPackage;

/**
 * Test copy user table
 *
 * @param context    context
 * @param geoPackage GeoPackage
 */
+(void) testCopyUserTable: (GPKGGeoPackage *) geoPackage;

@end
