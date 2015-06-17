//
//  GPKGTestSetupTeardown.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

extern NSInteger const GPKG_TEST_SETUP_CREATE_SRS_COUNT;
extern NSInteger const GPKG_TEST_SETUP_CREATE_CONTENTS_COUNT;
extern NSInteger const GPKG_TEST_SETUP_CREATE_GEOMETRY_COLUMNS_COUNT;
extern NSInteger const GPKG_TEST_SETUP_CREATE_TILE_MATRIX_SET_COUNT;
extern NSInteger const GPKG_TEST_SETUP_CREATE_TILE_MATRIX_COUNT;
extern NSInteger const GPKG_TEST_SETUP_CREATE_DATA_COLUMN_COUNT;
extern NSInteger const GPKG_TEST_SETUP_CREATE_DATA_COLUMN_CONSTRAINTS_COUNT;
extern NSInteger const GPKG_TEST_SETUP_CREATE_METADATA_COUNT;
extern NSInteger const GPKG_TEST_SETUP_CREATE_METADATA_REFERENCE_COUNT;
extern NSInteger const GPKG_TEST_SETUP_CREATE_EXTENSIONS_COUNT;

@interface GPKGTestSetupTeardown : NSObject

+(GPKGGeoPackage *) setUpCreateWithFeatures: (BOOL) features andTiles: (BOOL) tiles;

+(void) tearDownCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage;

+(GPKGGeoPackage *) setUpImport;

+(void) tearDownImportWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
