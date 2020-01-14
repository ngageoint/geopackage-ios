//
//  GPKGManagerTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/16/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGManagerTestCase.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGGeoPackageManager.h"
#import "GPKGTestConstants.h"
#import "GPKGTestUtils.h"

@implementation GPKGManagerTestCase

- (void)setUp {
    [super setUp];
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory manager];
    [manager delete:GPKG_TEST_DB_NAME];
    [manager delete:GPKG_TEST_IMPORT_DB_NAME];
    [manager delete:GPKG_TEST_IMPORT_CORRUPT_DB_NAME];
}

- (void)tearDown {
    
    
    [super tearDown];
}

-(void) testCreateOpenDelete{
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory manager];
    
    // Verify does not exist
    [GPKGTestUtils assertFalse:[manager exists:GPKG_TEST_DB_NAME]];
    [GPKGTestUtils assertFalse:[[manager databases] containsObject:GPKG_TEST_DB_NAME]];
    
    // Create
    [GPKGTestUtils assertTrue:[manager create:GPKG_TEST_DB_NAME]];
    [GPKGTestUtils assertTrue:[manager exists:GPKG_TEST_DB_NAME]];
    [GPKGTestUtils assertTrue:[[manager databases] containsObject:GPKG_TEST_DB_NAME]];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:GPKG_TEST_DB_NAME];
    [GPKGTestUtils assertNotNil:geoPackage];
    [geoPackage close];
    
    // Open with inverse validation
    manager.openHeaderValidation = !manager.openHeaderValidation;
    manager.openIntegrityValidation = !manager.openIntegrityValidation;
    geoPackage = [manager open:GPKG_TEST_DB_NAME];
    [GPKGTestUtils assertNotNil:geoPackage];
    [geoPackage close];
    
    // Delete
    [GPKGTestUtils assertTrue:[manager delete:GPKG_TEST_DB_NAME]];
    [GPKGTestUtils assertFalse:[manager exists:GPKG_TEST_DB_NAME]];
    [GPKGTestUtils assertFalse:[[manager databases] containsObject:GPKG_TEST_DB_NAME]];
}

-(void) testImport{
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory manager];
    
    // Verify does not exist
    [GPKGTestUtils assertFalse:[manager exists:GPKG_TEST_DB_NAME]];
    [GPKGTestUtils assertFalse:[[manager databases] containsObject:GPKG_TEST_DB_NAME]];
    
    // Import
    NSString *importFile  = [[[NSBundle bundleForClass:[GPKGManagerTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_IMPORT_DB_FILE_NAME];
    [GPKGTestUtils assertTrue:[manager importGeoPackageFromPath:importFile]];
    [GPKGTestUtils assertTrue:[manager exists:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertTrue:[[manager databases] containsObject:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertTrue:[manager validate:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertTrue:[manager validateHeader:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertTrue:[manager validateIntegrity:GPKG_TEST_IMPORT_DB_NAME]];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:GPKG_TEST_IMPORT_DB_NAME];
    [GPKGTestUtils assertNotNil:geoPackage];
    [geoPackage close];
    
    @try {
        [manager importGeoPackageFromPath:importFile];
        [NSException raise:@"Importing Twice" format:@"Importing database again did not cause exception"];
    }
    @catch (NSException *exception) {
        // expected
    }
    
    // Import with override
    [GPKGTestUtils assertTrue:[manager importGeoPackageFromPath:importFile andOverride:true]];
    
    // Open
    geoPackage = [manager open:GPKG_TEST_IMPORT_DB_NAME];
    [GPKGTestUtils assertNotNil:geoPackage];
    [geoPackage close];
    
    // Delete
    [GPKGTestUtils assertTrue:[manager delete:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertFalse:[manager exists:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertFalse:[[manager databases] containsObject:GPKG_TEST_IMPORT_DB_NAME]];
    
    // Try to import file with no extension
    NSString *noFileExtension  = [[[NSBundle bundleForClass:[GPKGManagerTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_IMPORT_DB_NAME];
    @try {
        [manager importGeoPackageFromPath:noFileExtension];
        [NSException raise:@"No Extension" format:@"GeoPackage without extension did not throw an exception"];
    }
    @catch (NSException *exception) {
        // expected
    }
    
    // Try to import file with invalid extension
    NSString *invalidFileExtension  = [[[NSBundle bundleForClass:[GPKGManagerTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_IMPORT_DB_NAME];
    invalidFileExtension = [invalidFileExtension stringByAppendingString:@".invalid"];
    @try {
        [manager importGeoPackageFromPath:invalidFileExtension];
        [NSException raise:@"Invalid Extension" format:@"GeoPackage with invalid extension did not throw an exception"];
    }
    @catch (NSException *exception) {
        // expected
    }

    // Try to import corrupt database
    NSString *loadCorruptFileLocation  = [[[NSBundle bundleForClass:[GPKGManagerTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_IMPORT_CORRUPT_DB_FILE_NAME];
    @try {
        [manager importGeoPackageFromPath:loadCorruptFileLocation];
        [NSException raise:@"Corrupted GeoPackage" format:@"Corrupted GeoPackage did not throw an exception"];
    }
    @catch (NSException *exception) {
        // expected
    }
    
    // Import and Open with inverse validation
    manager.importHeaderValidation = !manager.importHeaderValidation;
    manager.importIntegrityValidation = !manager.importIntegrityValidation;
    manager.openHeaderValidation = !manager.openHeaderValidation;
    manager.openIntegrityValidation = !manager.openIntegrityValidation;
    
    // Import
    [GPKGTestUtils assertTrue:[manager importGeoPackageFromPath:importFile]];
    [GPKGTestUtils assertTrue:[manager exists:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertTrue:[[manager databases] containsObject:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertTrue:[manager validate:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertTrue:[manager validateHeader:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertTrue:[manager validateIntegrity:GPKG_TEST_IMPORT_DB_NAME]];
    
    // Open
    geoPackage = [manager open:GPKG_TEST_IMPORT_DB_NAME];
    [GPKGTestUtils assertNotNil:geoPackage];
    [geoPackage close];
    
    // Delete
    [GPKGTestUtils assertTrue:[manager delete:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertFalse:[manager exists:GPKG_TEST_IMPORT_DB_NAME]];
    [GPKGTestUtils assertFalse:[[manager databases] containsObject:GPKG_TEST_IMPORT_DB_NAME]];
}

@end
