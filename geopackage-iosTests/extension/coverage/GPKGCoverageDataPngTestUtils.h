//
//  GPKGCoverageDataPngTestUtils.h
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

@interface GPKGCoverageDataPngTestUtils : NSObject

+(void) testCoverageDataWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGCoverageDataValues *) coverageDataValues andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils;

@end
