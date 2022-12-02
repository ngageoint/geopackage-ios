//
//  GPKGDgiwgGeoPackageManagerTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 12/1/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgGeoPackageManagerTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGDgiwgGeoPackageFactory.h"
#import "GPKGDgiwgGeoPackageTestCase.h"
#import "GPKGIOUtils.h"

@implementation GPKGDgiwgGeoPackageManagerTestCase

NSString * const GPKG_DGIWG_TEST_FILE_NAME = @"AGC_BUCK_Ft-Bliss_14-20_v1-0_29AUG2016";

NSString * const GPKG_DGIWG_TEST_FILE_NAME_NON_INFORMATIVE = @"NonInformativeName";

NSString * const GPKG_DGIWG_TEST_FILE_NAME_NON_INFORMATIVE2 = @"Non-Informative_Name";

/**
 * Test creating and opening a database
 */
-(void) testCreateOpenInformative{
    [self testCreateOpenWithName:GPKG_DGIWG_TEST_FILE_NAME andInformative:YES];
}

/**
 * Test creating and opening a database
 */
-(void) testCreateOpenNonInformative{
    [self testCreateOpenWithName:GPKG_DGIWG_TEST_FILE_NAME_NON_INFORMATIVE andInformative:NO];
}

/**
 * Test creating and opening a database
 */
-(void) testCreateOpenNonInformative2{
    [self testCreateOpenWithName:GPKG_DGIWG_TEST_FILE_NAME_NON_INFORMATIVE2 andInformative:NO];
}

/**
 * Test creating and opening a database
 */
-(void) testCreateInDirectoryOpenInformative{
    [self testCreateInDirectoryOpenWithName:GPKG_DGIWG_TEST_FILE_NAME andInformative:YES];
}

/**
 * Test creating and opening a database
 */
-(void) testCreateInDirectoryOpenNonInformative{
    [self testCreateInDirectoryOpenWithName:GPKG_DGIWG_TEST_FILE_NAME_NON_INFORMATIVE andInformative:NO];
}

/**
 * Test creating and opening a database
 */
-(void) testCreateInDirectoryOpenNonInformative2{
    [self testCreateInDirectoryOpenWithName:GPKG_DGIWG_TEST_FILE_NAME_NON_INFORMATIVE2 andInformative:NO];
}

/**
 * Test creating and opening a database
 *
 * @param name        file name
 * @param informative expected complete informative file name
 */
-(void) testCreateOpenWithName: (NSString *) name andInformative: (BOOL) informative{
    
    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    
    [manager delete:name];
    
    // Create
    GPKGDgiwgFile *file = [manager create:name withMetadata:[GPKGDgiwgGeoPackageTestCase metadata]];
    [GPKGTestUtils assertNotNil:file];
    [GPKGTestUtils assertEqualWithValue:name andValue2:[file name]];
    [GPKGTestUtils assertEqualBoolWithValue:informative andValue2:[file.fileName isInformative]];
    [GPKGTestUtils assertTrue:[manager exists:name]];
    [GPKGTestUtils assertTrue:[[manager databases] containsObject:name]];
    
    // Open
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:file];
    [GPKGTestUtils assertNotNil:geoPackage];
    [GPKGTestUtils assertEqualWithValue:name andValue2:geoPackage.name];
    [GPKGTestUtils assertEqualBoolWithValue:informative andValue2:[[geoPackage fileName] isInformative]];
    [GPKGTestUtils assertEqualWithValue:name andValue2:[[geoPackage fileName] name]];
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager deleteDGIWG:file]];
}

/**
 * Test creating and opening a database
 *
 * @param name        file name
 * @param informative expected complete informative file name
 */
-(void) testCreateInDirectoryOpenWithName: (NSString *) name andInformative: (BOOL) informative{
    
    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    
    [manager delete:name];
    
    NSString *directory = @"temp";
    [GPKGIOUtils createDirectoryIfNotExists:directory];
    
    // Create
    GPKGDgiwgFile *file = [manager create:name inDirectory:directory withMetadata:[GPKGDgiwgGeoPackageTestCase metadata]];
    [GPKGTestUtils assertNotNil:file];
    [GPKGTestUtils assertEqualWithValue:name andValue2:[file name]];
    [GPKGTestUtils assertEqualBoolWithValue:informative andValue2:[file.fileName isInformative]];
    [GPKGTestUtils assertTrue:[manager exists:name]];
    [GPKGTestUtils assertTrue:[[manager databases] containsObject:name]];
    
    // Open
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:file];
    [GPKGTestUtils assertNotNil:geoPackage];
    [GPKGTestUtils assertEqualWithValue:name andValue2:geoPackage.name];
    [GPKGTestUtils assertEqualBoolWithValue:informative andValue2:[[geoPackage fileName] isInformative]];
    [GPKGTestUtils assertEqualWithValue:name andValue2:[[geoPackage fileName] name]];
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager deleteDGIWG:file]];
}

@end
