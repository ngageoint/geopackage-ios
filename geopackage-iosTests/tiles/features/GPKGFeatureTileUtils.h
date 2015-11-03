//
//  GPKGFeatureTileUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/30/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGCreateGeoPackageTestCase.h"
#import "GPKGFeatureTiles.h"
#import "WKBLineString.h"

@interface GPKGFeatureTileUtils : GPKGCreateGeoPackageTestCase

+(GPKGFeatureDao *) createFeatureDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

+(int) insertFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao;

+(void) insertFourPointsWithFeatureDao: (GPKGFeatureDao *) featureDao andX: (double) x andY: (double) y;

+(void) insertFourLinesWithFeatureDao: (GPKGFeatureDao *) featureDao andPoints: (NSArray *) points;

+(void) insertFourPolygonsWithFeatureDao: (GPKGFeatureDao *) featureDao andLines: (NSArray *) lines;

+(NSArray *) convertPoints: (NSArray *) points withNegativeY: (BOOL) negativeY andNegativeX: (BOOL) negativeX;

+(NSArray *) convertLines: (NSArray *) lines withNegativeY: (BOOL) negativeY andNegativeX: (BOOL) negativeX;

+(long long) insertPointWithFeatureDao: (GPKGFeatureDao *) featureDao andX: (double) x andY: (double) y;

+(void) setPointWithFeatureRow: (GPKGFeatureRow *) featureRow andX: (double) x andY: (double) y;

+(long long) insertLineWithFeatureDao: (GPKGFeatureDao *) featureDao andPoints: (NSArray *) points;

+(WKBLineString *) getLineStringWithPoints: (NSArray *) points;

+(long long) insertPolygonWithFeatureDao: (GPKGFeatureDao *) featureDao andLines: (NSArray *) lines;

+(void) updateLastChangeWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao;


@end
