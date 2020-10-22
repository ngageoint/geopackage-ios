//
//  GPKGContentsCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/25/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGContentsCreateTest.h"
#import "GPKGContentsUtils.h"
#import "GPKGTestSetupTeardown.h"

@implementation GPKGContentsCreateTest

-(void) testRead{
    [GPKGContentsUtils testReadWithGeoPackage: self.geoPackage andExpectedResults:[NSNumber numberWithInteger:GPKG_TEST_SETUP_CREATE_CONTENTS_COUNT]];
}

-(void) testUpdate{
    [GPKGContentsUtils testUpdateWithGeoPackage: self.geoPackage];
}

-(void) testCreate{
    [GPKGContentsUtils testCreateWithGeoPackage: self.geoPackage];
}

-(void) testDelete{
    [GPKGContentsUtils testDeleteWithGeoPackage: self.geoPackage];
}

-(void) testDeleteCascade{
    [GPKGContentsUtils testDeleteCascadeWithGeoPackage: self.geoPackage];
}

@end
