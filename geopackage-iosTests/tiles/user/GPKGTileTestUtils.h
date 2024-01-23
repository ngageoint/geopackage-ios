//
//  GPKGTileTestUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGTileTestUtils : NSObject

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
 * Test get zoom level
 *
 * @param geoPackage
 */
+(void) testGetZoomLevelWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test querying for the bounding box at a tile matrix zoom level
 *
 * @param geoPackage
 */
+(void)testTileMatrixBoundingBox: (GPKGGeoPackage *) geoPackage;

/**
 * Test bounds query on any table as a user custom dao
 *
 * @param geoPackage
 */
+(void)testBoundsQuery: (GPKGGeoPackage *) geoPackage;

@end
