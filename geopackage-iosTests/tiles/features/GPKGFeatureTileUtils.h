//
//  GPKGFeatureTileUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/30/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGCreateGeoPackageTestCase.h"
#import "GPKGFeatureTiles.h"

@interface GPKGFeatureTileUtils : GPKGCreateGeoPackageTestCase

+(GPKGFeatureDao *) createFeatureDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

+(int) insertFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao;

+(GPKGFeatureTiles *) createFeatureTilesWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao;

+(void) insertFourPointsWithFeatureDao: (GPKGFeatureDao *) featureDao andX: (double) x andY: (double) y;

//TODO


@end
