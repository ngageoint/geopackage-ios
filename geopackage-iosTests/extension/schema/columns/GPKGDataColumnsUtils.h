//
//  GPKGDataColumnsUtils.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/7/24.
//  Copyright © 2024 NGA. All rights reserved.
//

#import "GPKGGeoPackage.h"

@interface GPKGDataColumnsUtils : NSObject

/**
 * Test create column titles
 *
 * @param geoPackage GeoPackage
 */
+(void) testColumnTitles: (GPKGGeoPackage *) geoPackage;

/**
 * Test save and load schema
 *
 * @param geoPackage GeoPackage
 */
+(void) testSaveLoadSchema: (GPKGGeoPackage *) geoPackage;

@end
