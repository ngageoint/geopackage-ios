//
//  GPKGAttributesUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
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
