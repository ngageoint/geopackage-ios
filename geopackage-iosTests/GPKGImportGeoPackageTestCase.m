//
//  GPKGImportGeoPackageTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGImportGeoPackageTestCase.h"
#import "GPKGTestSetupTeardown.h"

@implementation GPKGImportGeoPackageTestCase

-(GPKGGeoPackage *) getGeoPackage{
    return [GPKGTestSetupTeardown setUpImport];
}

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    [GPKGTestSetupTeardown tearDownImportWithGeoPackage:self.geoPackage];
    
    [super tearDown];
}

@end
