//
//  GPKGSpatialReferenceSystemImportTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/26/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGSpatialReferenceSystemImportTest.h"
#import "GPKGSpatialReferenceSystemUtils.h"

@implementation GPKGSpatialReferenceSystemImportTest

-(void) testRead{
    [GPKGSpatialReferenceSystemUtils testReadWithGeoPackage: self.geoPackage andExpectedResults:nil];
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
