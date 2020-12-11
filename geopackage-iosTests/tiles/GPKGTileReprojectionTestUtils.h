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
 * @param geoPackage GeoPackage
 */
+(void) testReprojectWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test reproject replacing the table
 *
 * @param geoPackage GeoPackage
 */
+(void) testReprojectReplaceWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test reproject of individual zoom levels
 *
 * @param geoPackage GeoPackage
 */
+(void) testReprojectZoomLevelsWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test reproject of overwriting a zoom level
 *
 * @param geoPackage GeoPackage
 */
+(void) testReprojectZoomOverwriteWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test reproject of overwriting a table
 *
 * @param geoPackage GeoPackage
 */
+(void) testReprojectOverwriteWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test reproject with zoom level mappings
 *
 * @param geoPackage GeoPackage
 */
+(void) testReprojectToZoomWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test reproject with zoom level matrix and tile length configurations
 *
 * @param geoPackage GeoPackage
 */
+(void) testReprojectMatrixAndTileLengthsWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test reproject with tile optimization
 *
 * @param geoPackage GeoPackage
 * @param world world bounds
 */
+(void) testReprojectOptimizeWithGeoPackage: (GPKGGeoPackage *) geoPackage andWorld: (BOOL) world;

@end
