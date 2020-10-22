//
//  GPKGContentsImportTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/25/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGContentsImportTest.h"
#import "GPKGContentsUtils.h"

@implementation GPKGContentsImportTest

-(void) testRead{
    [GPKGContentsUtils testReadWithGeoPackage: self.geoPackage andExpectedResults:nil];
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
