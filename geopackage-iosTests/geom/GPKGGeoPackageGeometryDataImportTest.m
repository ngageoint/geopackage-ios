//
//  GPKGGeoPackageGeometryDataImportTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageGeometryDataImportTest.h"
#import "GPKGGeoPackageGeometryDataUtils.h"

@implementation GPKGGeoPackageGeometryDataImportTest

- (void)testReadWriteBytes {
    [GPKGGeoPackageGeometryDataUtils testReadWriteBytesWithGeoPackage:self.geoPackage];
}

-(void) testGeometryProjectionTransform {
    [GPKGGeoPackageGeometryDataUtils testGeometryProjectionTransform:self.geoPackage];
}

@end
