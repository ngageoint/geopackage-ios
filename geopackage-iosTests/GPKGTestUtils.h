//
//  GPKGTestUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/12/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

extern NSString * const GPKG_GEOPACKAGE_TEST_SAMPLE_RANGE_CONSTRAINT;
extern NSString * const GPKG_GEOPACKAGE_TEST_SAMPLE_ENUM_CONSTRAINT;
extern NSString * const GPKG_GEOPACKAGE_TEST_SAMPLE_GLOB_CONSTRAINT;
extern NSString * const GPKG_GEOPACKAGE_TEST_INTEGER_COLUMN;

@interface GPKGTestUtils : NSObject

+(void)assertNil:(id) value;

+(void)assertNotNil:(id) value;

+(void)assertTrue: (BOOL) value;

+(void)assertFalse: (BOOL) value;

+(void)assertEqualWithValue:(NSObject *) value andValue2: (NSObject *) value2;

+(void)assertEqualBoolWithValue:(BOOL) value andValue2: (BOOL) value2;

+(void)assertEqualIntWithValue:(int) value andValue2: (int) value2;

+(void) createConstraints: (GPKGGeoPackage *) geoPackage;

+(GPKGFeatureTable *) createFeatureTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andContents: (GPKGContents *) contents andGeometryColumn: (NSString *) geometryColumn andGeometryType: (enum WKBGeometryType) geometryType;

+(void) addRowsToFeatureTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andFeatureTable: (GPKGFeatureTable *) table andNumRows: (int) numRows andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

@end
