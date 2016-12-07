//
//  GPKGImportElevationTilesGeoPackageTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGImportElevationTilesGeoPackageTestCase.h"
#import "GPKGGeoPackageManager.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGTestConstants.h"

@implementation GPKGImportElevationTilesGeoPackageTestCase

-(GPKGGeoPackage *) getGeoPackage{
    
    GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];
    
    // Delete
    [manager delete:GPKG_TEST_IMPORT_ELEVATION_TILES_DB_NAME];
    
    NSString *filePath  = [[[NSBundle bundleForClass:[GPKGImportElevationTilesGeoPackageTestCase class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_IMPORT_ELEVATION_TILES_DB_FILE_NAME];
    
    // Import
    [manager importGeoPackageFromPath:filePath withName:GPKG_TEST_IMPORT_ELEVATION_TILES_DB_NAME];
    
    // Open
    GPKGGeoPackage * geoPackage = [manager open:GPKG_TEST_IMPORT_ELEVATION_TILES_DB_NAME];
    [manager close];
    if(geoPackage == nil){
        [NSException raise:@"Failed to Open" format:@"Failed to open database"];
    }
    
    return geoPackage;
}

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    // Close
    if (self.geoPackage != nil) {
        [self.geoPackage close];
    }
    
    [super tearDown];
}

@end
