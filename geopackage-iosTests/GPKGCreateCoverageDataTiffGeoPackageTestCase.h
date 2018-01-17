//
//  GPKGCreateCoverageDataTiffGeoPackageTestCase.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackageTestCase.h"
#import "GPKGCoverageDataValues.h"

@interface GPKGCreateCoverageDataTiffGeoPackageTestCase : GPKGGeoPackageTestCase

@property (nonatomic, strong) GPKGCoverageDataValues *coverageDataValues;
@property (nonatomic) BOOL allowNils;

@end
