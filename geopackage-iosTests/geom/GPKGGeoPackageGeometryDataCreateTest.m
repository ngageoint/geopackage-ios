//
//  GPKGGeoPackageGeometryDataCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/10/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageGeometryDataCreateTest.h"
#import "GPKGGeoPackageGeometryDataUtils.h"

@implementation GPKGGeoPackageGeometryDataCreateTest

- (void)testReadWriteBytes {
    [GPKGGeoPackageGeometryDataUtils testReadWriteBytesWithGeoPackage:self.geoPackage];
}

@end
