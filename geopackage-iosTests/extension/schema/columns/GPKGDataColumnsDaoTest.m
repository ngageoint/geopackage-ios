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
#import "GPKGSchemaExtension.h"

@implementation GPKGDataColumnsDaoTest

-(GPKGGeoPackage *) createGeoPackage{
    return [GPKGTestSetupTeardown setUpCreateWithFeatures:YES andTiles:YES];
}

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    [GPKGTestSetupTeardown tearDownCreateWithGeoPackage:self.geoPackage];
    
    [super tearDown];
}

- (void)testRetrieveDataColumns {
    GPKGGeoPackage *geoPackage = [self geoPackage];
    GPKGDataColumnsDao *dao = [GPKGSchemaExtension dataColumnsDaoWithGeoPackage:geoPackage];
    GPKGDataColumns *column = [dao dataColumnByTableName:@"point2d" andColumnName:GPKG_GEOPACKAGE_TEST_INTEGER_COLUMN];
    [GPKGTestUtils assertNotNil:column];
    GPKGDataColumns *nilColumn = [dao dataColumnByTableName:@"nope" andColumnName:@"nope"];
    [GPKGTestUtils assertNil:nilColumn];
}

@end
