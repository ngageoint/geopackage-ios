//
//  GPKGFeatureUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/27/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGFeatureUtils : NSObject

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

/**
 * Test Feature DAO primary key modifications and disabling value validation
 *
 * @param geoPackage GeoPackage
 */
+(void) testPkModifiableAndValueValidationWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
