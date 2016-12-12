//
//  GPKGCreateElevationTilesTiffGeoPackageTestCase.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackageTestCase.h"
#import "GPKGElevationTileValues.h"

@interface GPKGCreateElevationTilesTiffGeoPackageTestCase : GPKGGeoPackageTestCase

@property (nonatomic, strong) GPKGElevationTileValues *elevationTileValues;
@property (nonatomic) BOOL allowNils;

@end
