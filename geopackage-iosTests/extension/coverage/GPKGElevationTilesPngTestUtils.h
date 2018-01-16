//
//  GPKGElevationTilesPngTestUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGCoverageDataAlgorithms.h"
#import "GPKGElevationTileValues.h"
#import "GPKGGeoPackage.h"
#import "GPKGCoverageDataResults.h"

@interface GPKGElevationTilesPngTestUtils : NSObject

+(void) testElevationsWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGElevationTileValues *) elevationTileValues andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils;

+(void) testRandomBoundingBoxWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGElevationTileValues *) elevationTileValues andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils;

+(NSDecimalNumber *) elevationWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andLatitude: (double) latitude andLongitude: (double) longitude andEpsg: (int) epsg;

+(GPKGCoverageDataResults *) elevationsWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andBoundingBox: (GPKGBoundingBox *) boundingBox andWidth: (int) width andHeight: (int) height andEpsg: (int) epsg;

@end
