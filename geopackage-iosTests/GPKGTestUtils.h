//
//  GPKGTestUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/12/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

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

+(void)assertEqualDecimalNumberWithValue:(NSDecimalNumber *) value andValue2: (NSDecimalNumber *) value2 andDelta: (double) delta;

+(void)assertEqualBoolWithValue:(BOOL) value andValue2: (BOOL) value2;

+(void)assertEqualIntWithValue:(int) value andValue2: (int) value2;

+(void)assertEqualUnsignedIntWithValue:(unsigned int) value andValue2: (unsigned int) value2;

+(void)assertEqualUnsignedLongWithValue:(unsigned long) value andValue2: (unsigned long) value2;

+(void)assertEqualDoubleWithValue:(double) value andValue2: (double) value2;

+(void)assertEqualDoubleWithValue:(double) value andValue2: (double) value2 andDelta: (double) delta;

+(BOOL) equalDoubleWithValue:(double) value andValue2: (double) value2 andDelta: (double) delta;

+(void)assertEqualDoubleWithValue:(double) value andValue2: (double) value2 andPercentage: (double) percentage;

+(void)assertEqualDataWithValue:(NSData *) value andValue2: (NSData *) value2;

+(void)fail:(NSString *) message;

+(void) createConstraints: (GPKGGeoPackage *) geoPackage;

+(GPKGFeatureTable *) createFeatureTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andContents: (GPKGContents *) contents andGeometryColumn: (NSString *) geometryColumn andGeometryType: (enum SFGeometryType) geometryType;

+(GPKGFeatureTable *) buildFeatureTableWithTableName: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumn andGeometryType: (enum SFGeometryType) geometryType;

+(GPKGTileTable *) buildTileTableWithTableName: (NSString *) tableName;

+(void) addRowsToFeatureTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andFeatureTable: (GPKGFeatureTable *) table andNumRows: (int) numRows andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM andAllowEmptyFeatures: (BOOL) allowEmptyFeatures;

+(void) addRowsToTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileMatrix: (GPKGTileMatrix *) tileMatrix andData: (NSData *) tileData;

+(SFPoint *) createPointWithHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

+(SFLineString *) createLineStringWithHasZ: (BOOL) hasZ andHasM: (BOOL) hasM andRing: (BOOL) ring;

+(SFPolygon *) createPolygonWithHasZ: (BOOL) hasZ andHasM: (BOOL) hasM;

+(NSDecimalNumber *) roundDouble: (double) value;

+(NSDecimalNumber *) roundDouble: (double) value withScale: (int) scale;

+(int) randomIntLessThan: (int) max;

+(double) randomDouble;

+(double) randomDoubleLessThan: (double) max;

+(void) validateGeoPackage: (GPKGGeoPackage *) geoPackage;

+(void) validateIntegerValue: (NSObject *) value andDataType: (enum GPKGDataType) dataType;

+(void) validateFloatValue: (NSObject *) value andDataType: (enum GPKGDataType) dataType;

@end
