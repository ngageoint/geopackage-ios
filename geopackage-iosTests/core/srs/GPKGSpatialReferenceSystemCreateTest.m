//
//  GPKGSpatialReferenceSystemCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/26/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGSpatialReferenceSystemCreateTest.h"
#import "GPKGSpatialReferenceSystemUtils.h"

#import "GPKGTestSetupTeardown.h"

@implementation GPKGSpatialReferenceSystemCreateTest

-(void) testRead{
    [GPKGSpatialReferenceSystemUtils testReadWithGeoPackage: self.geoPackage andExpectedResults:[NSNumber numberWithInteger:GPKG_TEST_SETUP_CREATE_SRS_COUNT]];
}

-(void) testUpdate{
    [GPKGSpatialReferenceSystemUtils testUpdateWithGeoPackage: self.geoPackage];
}

-(void) testCreate{
    [GPKGSpatialReferenceSystemUtils testCreateWithGeoPackage: self.geoPackage];
}

-(void) testDelete{
    [GPKGSpatialReferenceSystemUtils testDeleteWithGeoPackage: self.geoPackage];
}

-(void) testDeleteCascade{
    [GPKGSpatialReferenceSystemUtils testDeleteCascadeWithGeoPackage: self.geoPackage];
}

@end
