//
//  GPKGGeoPackageFactory.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageFactory.h"

@implementation GPKGGeoPackageFactory

+(GPKGGeoPackageManager *) getManager{
    return [[GPKGGeoPackageManager alloc] init];
}

@end
