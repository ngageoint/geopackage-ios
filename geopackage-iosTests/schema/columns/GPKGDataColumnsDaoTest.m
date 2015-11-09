//
//  GPKGDataColumnsDaoTest.m
//  geopackage-ios
//
//  Created by Dan Barela on 11/9/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGDataColumnsDaoTest.h"
#import "GPKGTestSetupTeardown.h"
#import "GPKGTestUtils.h"

@implementation GPKGDataColumnsDaoTest

-(GPKGGeoPackage *) getGeoPackage{
    return [GPKGTestSetupTeardown setUpCreateWithFeatures:true andTiles:true];
}

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    [GPKGTestSetupTeardown tearDownCreateWithGeoPackage:self.geoPackage];
    
    [super tearDown];
}

- (void)testRetrieveDataColumns {
    GPKGGeoPackage * geoPackage = [self getGeoPackage];
    GPKGDataColumnsDao * dao = [geoPackage getDataColumnsDao];
    GPKGDataColumns * column = [dao getDataColumnByTableName:@"point2d" andColumnName:GPKG_GEOPACKAGE_TEST_INTEGER_COLUMN];
    [GPKGTestUtils assertNotNil:column];
    GPKGDataColumns * nilColumn = [dao getDataColumnByTableName:@"nope" andColumnName:@"nope"];
    [GPKGTestUtils assertNil:nilColumn];
}

@end
