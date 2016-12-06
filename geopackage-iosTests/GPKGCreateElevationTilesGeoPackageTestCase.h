//
//  GPKGCreateElevationTilesGeoPackageTestCase.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackageTestCase.h"
#import "GPKGElevationTileValues.h"

@interface GPKGCreateElevationTilesGeoPackageTestCase : GPKGGeoPackageTestCase

@property (nonatomic, strong) GPKGElevationTileValues *elevationTileValues;
@property (nonatomic) BOOL allowNils;

-(instancetype) initWithAllowNils: (BOOL) allowNils;

@end
