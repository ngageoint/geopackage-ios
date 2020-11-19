//
//  GPKGTileReprojectionTestUtils.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 11/19/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGTileReprojectionTestUtils : NSObject

/**
 * Test reproject
 *
 * @param geoPackage
 */
+(void) testReprojectWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test reproject replacing the table
 *
 * @param geoPackage
 */
+(void) testReprojectReplaceWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
