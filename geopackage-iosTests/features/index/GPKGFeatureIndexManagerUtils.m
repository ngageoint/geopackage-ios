//
//  GPKGFeatureIndexManagerUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/20/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexManagerUtils.h"
#import "GPKGFeatureIndexTypes.h"

@implementation GPKGFeatureIndexManagerUtils

+(void) testIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    [self testIndexWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_GEOPACKAGE];
    [self testIndexWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_METADATA];
}

+(void) testIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureIndexType: (enum GPKGFeatureIndexType) type{
    // TODO
}

@end
