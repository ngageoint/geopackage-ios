//
//  GPKGCoverageDataTiffTestUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGCoverageDataAlgorithms.h"
#import "GPKGCoverageDataValues.h"
#import "GPKGGeoPackage.h"
#import "GPKGCoverageDataResults.h"

@interface GPKGCoverageDataTiffTestUtils : NSObject

+(void) testCoverageDataWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGCoverageDataValues *) coverageDataValues andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils;

+(void) testRandomBoundingBoxWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGCoverageDataValues *) coverageDataValues andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils;

+(NSDecimalNumber *) valueWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andLatitude: (double) latitude andLongitude: (double) longitude andEpsg: (int) epsg;

+(GPKGCoverageDataResults *) valuesWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andBoundingBox: (GPKGBoundingBox *) boundingBox andWidth: (int) width andHeight: (int) height andEpsg: (int) epsg;

@end
