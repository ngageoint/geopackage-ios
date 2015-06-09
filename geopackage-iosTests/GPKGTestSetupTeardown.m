//
//  GPKGTestSetupTeardown.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTestSetupTeardown.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGTestConstants.h"

@implementation GPKGTestSetupTeardown

+(GPKGGeoPackage *) setUpCreateWithFeatures: (BOOL) features andTiles: (BOOL) tiles{
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    
    // Delete
    [manager delete:GPKG_TEST_DB_NAME];
    
    // Create
    [manager create:GPKG_TEST_DB_NAME];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:GPKG_TEST_DB_NAME];
    if(geoPackage == nil){
        [NSException raise:@"Failed to Open" format:@"Failed to open database"];
    }
    
    if(features){
        [self setUpCreateFeaturesWithGeoPackage:geoPackage];
    }
    
    if(tiles){
        [self setUpCreateTilesWithGeoPackage:geoPackage];
    }
    
    [self setUpCreateCommonWithGeoPackage:geoPackage];
    
    return geoPackage;
}

+(void) setUpCreateCommonWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) setUpCreateFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) setUpCreateTilesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) tearDownCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
 
    // Close
    if (geoPackage != nil) {
        [geoPackage close];
    }
    
    // Delete
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    [manager delete:GPKG_TEST_DB_NAME];
}

+(GPKGGeoPackage *) setUpImport{
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    
    // Delete
    [manager delete:GPKG_TEST_IMPORT_DB_NAME];
    
    NSString *filePath  = [[[NSBundle bundleForClass:[GPKGTestSetupTeardown class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_IMPORT_DB_FILE_NAME];
    
    // Import
    [manager importGeoPackage:filePath];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:filePath];
    if(geoPackage == nil){
        [NSException raise:@"Failed to Open" format:@"Failed to open database"];
    }
    
    return geoPackage;
}

+(void) tearDownImportWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Close
    if (geoPackage != nil) {
        [geoPackage close];
    }
    
    // Delete
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    [manager delete:GPKG_TEST_IMPORT_DB_NAME];
}

@end
