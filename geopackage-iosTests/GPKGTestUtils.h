//
//  GPKGTestUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/12/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"
#import "WKBPoint.h"
#import "WKBLineString.h"
#import "WKBPolygon.h"

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

+(void)assertEqualDoubleWithValue:(double) value andValue2: (double) value2;

+(void) createConstraints: (GPKGGeoPackage *) geoPackage;

+(GPKGFeatureTable *) createFeatureTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andContents: (GPKGContents *) contents andGeometryColumn: (NSString *) geometryColumn andGeometryType: (enum WKBGeometryType) geometryType;

+(GPKGFeatureTable *) buildFeatureTableWithTableName: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumn andGeometryType: (enum WKBGeometryType) geometryType;

+(GPKGTileTable *) buildTileTableWithTableName: (NSString *) tableName;

+(void) addRowsToFeatureTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andFeatureTable: (GPKGFeatureTable *) table andNumRows: (int) numRows andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

+(void) addRowsToTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileMatrix: (GPKGTileMatrix *) tileMatrix andData: (NSData *) tileData;

+(WKBPoint *) createPointWithHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

+(WKBLineString *) createLineStringWithHasZ: (BOOL) hasZ andHasM: (BOOL) hasM andRing: (BOOL) ring;

+(WKBPolygon *) createPolygonWithHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

+(NSDecimalNumber *) roundDouble: (double) value;

+(NSDecimalNumber *) roundDouble: (double) value withScale: (int) scale;

+(int) randomIntLessThan: (int) max;

+(double) randomDouble;

+(double) randomDoubleLessThan: (double) max;

@end
