//
//  GPKGCoverageDataTestUtils.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 1/25/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGCoverageDataAlgorithms.h"
#import "GPKGCoverageDataValues.h"
#import "GPKGCoverageData.h"

@interface GPKGCoverageDataTestUtils : NSObject

+(void) testCoverageDataQueriesWithGeoPackage: (GPKGGeoPackage *) geoPackage andCoverageData: (GPKGCoverageData *) coverageData andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils;

+(void) testRandomBoundingBoxWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGCoverageDataValues *) coverageDataValues andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils;

+(NSDecimalNumber *) valueWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andLatitude: (double) latitude andLongitude: (double) longitude andEpsg: (int) epsg;

+(GPKGCoverageDataResults *) valuesWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andBoundingBox: (GPKGBoundingBox *) boundingBox andWidth: (int) width andHeight: (int) height andEpsg: (int) epsg;

+(void) testPixelEncodingWithGeoPackage: (GPKGGeoPackage *) geoPackage andAllowNils: (BOOL) allowNils;

@end
