//
//  GPKGFeatureIndexManagerUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/20/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGFeatureIndexManagerUtils : NSObject

/**
 * Test index
 *
 * @param geoPackage GeoPackage
 */
+(void) testIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Test large index
 *
 * @param geoPackage  GeoPackage
 * @param numFeatures num features
 * @param verbose          verbose printing
 */
+(void) testLargeIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andNumFeatures: (int) numFeatures andVerbose: (BOOL) verbose;

/**
 * Test large index
 *
 * @param geoPackage              GeoPackage
 * @param compareProjectionCounts compare projection counts and query counts
 * @param verbose                 verbose printing
 */
+(void) testTimedIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andCompareProjectionCounts: (BOOL) compareProjectionCounts andVerbose: (BOOL) verbose;

/**
 * Test large index
 *
 * @param geoPackage              GeoPackage
 * @param featureTable            feature table
 * @param compareProjectionCounts compare projection counts and query counts
 * @param verbose                 verbose printing
 */
+(void) testTimedIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureTable: (NSString *) featureTable andCompareProjectionCounts: (BOOL) compareProjectionCounts andVerbose: (BOOL) verbose;

@end
