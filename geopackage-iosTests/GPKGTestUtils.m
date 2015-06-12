//
//  GPKGTestUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/12/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTestUtils.h"

NSString * const GPKG_GEOPACKAGE_TEST_SAMPLE_RANGE_CONSTRAINT = @"sampleRange";
NSString * const GPKG_GEOPACKAGE_TEST_SAMPLE_ENUM_CONSTRAINT = @"sampleEnum";
NSString * const GPKG_GEOPACKAGE_TEST_SAMPLE_GLOB_CONSTRAINT = @"sampleGlob";
NSString * const GPKG_GEOPACKAGE_TEST_INTEGER_COLUMN = @"test_integer";

@implementation GPKGTestUtils

+(void)assertNil:(id) value{
    if(value != nil){
        [NSException raise:@"Assert Nil" format:@"Value is not nil: %@", value];
    }
}

+(void)assertNotNil:(id) value{
    if(value == nil){
        [NSException raise:@"Assert Not Nil" format:@"Value is nil: %@", value];
    }
}

+(void)assertTrue: (BOOL) value{
    if(!value){
        [NSException raise:@"Assert True" format:@"Value is false"];
    }
}

+(void)assertFalse: (BOOL) value{
    if(value){
        [NSException raise:@"Assert False" format:@"Value is true"];
    }
}

+(void)assertEqualWithValue:(NSObject *) value andValue2: (NSObject *) value2{
    if(value == nil){
        if(value2 != nil){
            [NSException raise:@"Assert Equal" format:@"Value 1: '%@' is not equal to Value 2: '%@'", value, value2];
        }
    } else if(![value isEqual:value2]){
        [NSException raise:@"Assert Equal" format:@"Value 1: '%@' is not equal to Value 2: '%@'", value, value2];
    }
}

+(void)assertEqualBoolWithValue:(BOOL) value andValue2: (BOOL) value2{
    if(value != value2){
        [NSException raise:@"Assert Equal BOOL" format:@"Value 1: '%d' is not equal to Value 2: '%d'", value, value2];
    }
}

+(void)assertEqualIntWithValue:(int) value andValue2: (int) value2{
    if(value != value2){
        [NSException raise:@"Assert Equal int" format:@"Value 1: '%d' is not equal to Value 2: '%d'", value, value2];
    }
}

+(void) createConstraints: (GPKGGeoPackage *) geoPackage{
    
    [geoPackage createDataColumnConstraintsTable];
    
    GPKGDataColumnConstraintsDao * dao = [geoPackage getDataColumnConstraintsDao];
    
    GPKGDataColumnConstraints * sampleRange = [[GPKGDataColumnConstraints alloc] init];
    [sampleRange setConstraintName:GPKG_GEOPACKAGE_TEST_SAMPLE_RANGE_CONSTRAINT];
    [sampleRange setDataColumnConstraintType:GPKG_DCCT_RANGE];
    [sampleRange setMin: [[NSDecimalNumber alloc] initWithDouble:1.0]];
    [sampleRange setMinIsInclusiveValue:true];
    [sampleRange setMax: [[NSDecimalNumber alloc] initWithDouble:10.0]];
    [sampleRange setMaxIsInclusiveValue:true];
    [dao create:sampleRange];
    
    GPKGDataColumnConstraints * sampleEnum1 = [[GPKGDataColumnConstraints alloc] init];
    [sampleEnum1 setConstraintName:GPKG_GEOPACKAGE_TEST_SAMPLE_ENUM_CONSTRAINT];
    [sampleEnum1 setDataColumnConstraintType:GPKG_DCCT_ENUM];
    [sampleEnum1 setValue:@"1"];
    [dao create:sampleEnum1];
    
    GPKGDataColumnConstraints * sampleEnum3 = [[GPKGDataColumnConstraints alloc] init];
    [sampleEnum3 setConstraintName:GPKG_GEOPACKAGE_TEST_SAMPLE_ENUM_CONSTRAINT];
    [sampleEnum3 setDataColumnConstraintType:GPKG_DCCT_ENUM];
    [sampleEnum3 setValue:@"3"];
    [dao create:sampleEnum3];
    
    GPKGDataColumnConstraints * sampleEnum5 = [[GPKGDataColumnConstraints alloc] init];
    [sampleEnum5 setConstraintName:GPKG_GEOPACKAGE_TEST_SAMPLE_ENUM_CONSTRAINT];
    [sampleEnum5 setDataColumnConstraintType:GPKG_DCCT_ENUM];
    [sampleEnum5 setValue:@"5"];
    [dao create:sampleEnum5];
    
    GPKGDataColumnConstraints * sampleEnum7 = [[GPKGDataColumnConstraints alloc] init];
    [sampleEnum7 setConstraintName:GPKG_GEOPACKAGE_TEST_SAMPLE_ENUM_CONSTRAINT];
    [sampleEnum7 setDataColumnConstraintType:GPKG_DCCT_ENUM];
    [sampleEnum7 setValue:@"7"];
    [dao create:sampleEnum7];
    
    GPKGDataColumnConstraints * sampleEnum9 = [[GPKGDataColumnConstraints alloc] init];
    [sampleEnum9 setConstraintName:GPKG_GEOPACKAGE_TEST_SAMPLE_ENUM_CONSTRAINT];
    [sampleEnum9 setDataColumnConstraintType:GPKG_DCCT_ENUM];
    [sampleEnum9 setValue:@"9"];
    [dao create:sampleEnum9];
    
    GPKGDataColumnConstraints * sampleGlob = [[GPKGDataColumnConstraints alloc] init];
    [sampleGlob setConstraintName:GPKG_GEOPACKAGE_TEST_SAMPLE_GLOB_CONSTRAINT];
    [sampleGlob setDataColumnConstraintType:GPKG_DCCT_GLOB];
    [sampleGlob setValue:@"[1-2][0-9][0-9][0-9]"];
    [dao create:sampleGlob];
}

+(GPKGFeatureTable *) createFeatureTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andContents: (GPKGContents *) contents andGeometryColumn: (NSString *) geometryColumn andGeometryType: (enum WKBGeometryType) geometryType{
    // TODO
    return nil;
}

+(void) addRowsToFeatureTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andFeatureTable: (GPKGFeatureTable *) table andNumRows: (int) numRows andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    // TODO
}
@end
