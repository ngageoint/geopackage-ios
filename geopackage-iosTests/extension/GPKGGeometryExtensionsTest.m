//
//  GPKGGeometryExtensionsTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeometryExtensionsTest.h"
#import "GPKGGeometryExtensions.h"
#import "GPKGTestUtils.h"
#import "SFWBGeometryCodes.h"

@implementation GPKGGeometryExtensionsTest

/**
 *  Test the is extension check
 */
-(void) testIsExtension{
    
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:SF_GEOMETRY]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:SF_POINT]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:SF_LINESTRING]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:SF_POLYGON]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:SF_MULTIPOINT]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:SF_MULTILINESTRING]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:SF_MULTIPOLYGON]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:SF_GEOMETRYCOLLECTION]];
    
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:SF_CIRCULARSTRING]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:SF_COMPOUNDCURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:SF_CURVEPOLYGON]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:SF_MULTICURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:SF_MULTISURFACE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:SF_CURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:SF_SURFACE]];
    
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:SF_POLYHEDRALSURFACE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:SF_TIN]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:SF_TRIANGLE]];
}

/**
 *  Test the is GeoPackage extension check
 */
-(void) testIsGeoPackageExtension{
    
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_GEOMETRY]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_POINT]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_LINESTRING]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_POLYGON]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_MULTIPOINT]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_MULTILINESTRING]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_MULTIPOLYGON]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_GEOMETRYCOLLECTION]];
    
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:SF_CIRCULARSTRING]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:SF_COMPOUNDCURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:SF_CURVEPOLYGON]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:SF_MULTICURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:SF_MULTISURFACE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:SF_CURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:SF_SURFACE]];
    
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_POLYHEDRALSURFACE]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_TIN]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:SF_TRIANGLE]];
}

/**
 *  Test the GeoPackage get extension name
 */
-(void) testGeoPackageExtensionName{
    
    @try{
        [GPKGGeometryExtensions extensionName:SF_GEOMETRY];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionName:SF_POINT];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionName:SF_LINESTRING];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionName:SF_POLYGON];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionName:SF_MULTIPOINT];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionName:SF_MULTILINESTRING];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionName:SF_MULTIPOLYGON];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionName:SF_GEOMETRYCOLLECTION];
    }@catch(NSException *exception){
        // Expected
    }
    
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_CIRCULARSTRING] andValue2:[GPKGGeometryExtensions extensionName:SF_CIRCULARSTRING]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_COMPOUNDCURVE] andValue2:[GPKGGeometryExtensions extensionName:SF_COMPOUNDCURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_CURVEPOLYGON] andValue2:[GPKGGeometryExtensions extensionName:SF_CURVEPOLYGON]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_MULTICURVE] andValue2:[GPKGGeometryExtensions extensionName:SF_MULTICURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_MULTISURFACE] andValue2:[GPKGGeometryExtensions extensionName:SF_MULTISURFACE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_CURVE] andValue2:[GPKGGeometryExtensions extensionName:SF_CURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_SURFACE] andValue2:[GPKGGeometryExtensions extensionName:SF_SURFACE]];
    
    @try{
        [GPKGGeometryExtensions extensionName:SF_POLYHEDRALSURFACE];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionName:SF_TIN];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionName:SF_TRIANGLE];
    }@catch(NSException *exception){
        // Expected
    }
}

/**
 *  Test the get extension name
 */
-(void) testExtensionName{
    
    NSString *author = @"nga";
    
    @try{
        [GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_GEOMETRY];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_POINT];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_LINESTRING];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_POLYGON];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_MULTIPOINT];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_MULTILINESTRING];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_MULTIPOLYGON];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_GEOMETRYCOLLECTION];
    }@catch(NSException *exception){
        // Expected
    }
    
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_CIRCULARSTRING] andValue2:[GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_CIRCULARSTRING]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_COMPOUNDCURVE] andValue2:[GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_COMPOUNDCURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_CURVEPOLYGON] andValue2:[GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_CURVEPOLYGON]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_MULTICURVE] andValue2:[GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_MULTICURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_MULTISURFACE] andValue2:[GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_MULTISURFACE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_CURVE] andValue2:[GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_CURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:SF_SURFACE] andValue2:[GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_SURFACE]];
    
    [GPKGTestUtils assertEqualWithValue:[self expectedUserDefinedExtensionNameWithAuthor:author andType:SF_POLYHEDRALSURFACE] andValue2:[GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_POLYHEDRALSURFACE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedUserDefinedExtensionNameWithAuthor:author andType:SF_TIN] andValue2:[GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_TIN]];
    [GPKGTestUtils assertEqualWithValue:[self expectedUserDefinedExtensionNameWithAuthor:author andType:SF_TRIANGLE] andValue2:[GPKGGeometryExtensions extensionNameWithAuthor:author andType:SF_TRIANGLE]];
    
}

/**
 *  Test the Geometry Extension creation
 */
- (void)testGeometryExtension {
    
    GPKGGeometryExtensions * extensions = [[GPKGGeometryExtensions alloc] initWithGeoPackage:self.geoPackage];
    GPKGExtensionsDao * extensionsDao = extensions.extensionsDao;
    
    // Test non extension geometries
    for(int i = SF_GEOMETRY; i <= SF_GEOMETRYCOLLECTION; i++){
        
        enum SFGeometryType geometryType = [SFWBGeometryCodes geometryTypeFromCode:i];
        @try{
            [extensions extensionCreateWithTable:@"table_name" andColumn:@"column_name" andType:geometryType];
            [GPKGTestUtils fail:[NSString stringWithFormat:@"Geometry Extension was created for %@", [SFGeometryTypes name:geometryType]]];
        }@catch(NSException *exception){
            // Expected
        }
    }
    
    // Test user created extension geometries
    for(int i = SF_POLYHEDRALSURFACE; i <= SF_TRIANGLE; i++){
        
        enum SFGeometryType geometryType = [SFWBGeometryCodes geometryTypeFromCode:i];
        @try{
            [extensions extensionCreateWithTable:@"table_name" andColumn:@"column_name" andType:geometryType];
            [GPKGTestUtils fail:[NSString stringWithFormat:@"Geometry Extension was created for %@", [SFGeometryTypes name:geometryType]]];
        }@catch(NSException *exception){
            // Expected
        }
    }
    
    // Test geometry extensions
    int count = [extensionsDao count];
    for(int i = SF_CIRCULARSTRING; i <= SF_SURFACE; i++){
        
        enum SFGeometryType geometryType = [SFWBGeometryCodes geometryTypeFromCode:i];
        NSString * tableName = [NSString stringWithFormat:@"table_%@", [SFGeometryTypes name:geometryType]];
        NSString * columnName = @"geom";
        GPKGExtensions * extension = [extensions extensionCreateWithTable:tableName andColumn:columnName andType:geometryType];
        [GPKGTestUtils assertNotNil:extension];
        [GPKGTestUtils assertTrue:[extensions hasWithTable:tableName andColumn:columnName andType:geometryType]];
        [GPKGTestUtils assertEqualIntWithValue:++count andValue2:[extensionsDao count]];
        
        [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:[self expectedGeoPackageExtensionNameWithType:geometryType]];
        [GPKGTestUtils assertEqualWithValue:[extension author] andValue2:[self expectedGeoPackageExtensionAuthor]];
        [GPKGTestUtils assertEqualWithValue:[extension extensionNameNoAuthor] andValue2:[self expectedGeoPackageExtensionNameNoAuthorWithType:geometryType]];
        [GPKGTestUtils assertEqualWithValue:extension.tableName andValue2:tableName];
        [GPKGTestUtils assertEqualWithValue:extension.columnName andValue2:columnName];
        [GPKGTestUtils assertEqualIntWithValue:[extension extensionScopeType] andValue2:GPKG_EST_READ_WRITE];
        [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:extensions.geometryTypesDefinition];
    }
    
}

/**
 *  Test the User Geometry Extension creation
 */
- (void)testUserGeometryExtension {
    
    GPKGGeometryExtensions * extensions = [[GPKGGeometryExtensions alloc] initWithGeoPackage:self.geoPackage];
    GPKGExtensionsDao * extensionsDao = extensions.extensionsDao;
    
    NSString *author = @"nga";
    
    // Test non extension geometries
    for(int i = SF_GEOMETRY; i <= SF_GEOMETRYCOLLECTION; i++){
        
        enum SFGeometryType geometryType = [SFWBGeometryCodes geometryTypeFromCode:i];
        @try{
            [extensions extensionCreateWithTable:@"table_name" andColumn:@"column_name" andAuthor:author andType:geometryType];
            [GPKGTestUtils fail:[NSString stringWithFormat:@"Geometry Extension was created for %@", [SFGeometryTypes name:geometryType]]];
        }@catch(NSException *exception){
            // Expected
        }
    }
    
    // Test geometry extensions
    int count = [extensionsDao count];
    for(int i = SF_CIRCULARSTRING; i <= SF_TRIANGLE; i++){
        
        enum SFGeometryType geometryType = [SFWBGeometryCodes geometryTypeFromCode:i];
        NSString * tableName = [NSString stringWithFormat:@"table_%@", [SFGeometryTypes name:geometryType]];
        NSString * columnName = @"geom";
        GPKGExtensions * extension = [extensions extensionCreateWithTable:tableName andColumn:columnName andAuthor:author andType:geometryType];
        [GPKGTestUtils assertNotNil:extension];
        [GPKGTestUtils assertTrue:[extensions hasWithTable:tableName andColumn:columnName andAuthor:author andType:geometryType]];
        [GPKGTestUtils assertEqualIntWithValue:++count andValue2:[extensionsDao count]];
        
        [GPKGTestUtils assertEqualWithValue:[extension extensionNameNoAuthor] andValue2:[self expectedGeoPackageExtensionNameNoAuthorWithType:geometryType]];
        [GPKGTestUtils assertEqualWithValue:extension.tableName andValue2:tableName];
        [GPKGTestUtils assertEqualWithValue:extension.columnName andValue2:columnName];
        [GPKGTestUtils assertEqualIntWithValue:[extension extensionScopeType] andValue2:GPKG_EST_READ_WRITE];
        
        if(i <= SF_SURFACE){
            [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:[self expectedGeoPackageExtensionNameWithType:geometryType]];
            [GPKGTestUtils assertEqualWithValue:[extension author] andValue2:[self expectedGeoPackageExtensionAuthor]];
            [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:extensions.geometryTypesDefinition];
        }else{
            [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:[self expectedUserDefinedExtensionNameWithAuthor:author andType:geometryType]];
            [GPKGTestUtils assertEqualWithValue:[extension author] andValue2:author];
            [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:extensions.userGeometryTypesDefinition];
        }
    }
    
}

-(NSString *) expectedGeoPackageExtensionNameWithType:(enum SFGeometryType) type{
    return [NSString stringWithFormat:@"%@_%@", [self expectedGeoPackageExtensionAuthor], [self expectedGeoPackageExtensionNameNoAuthorWithType:type]];
}

-(NSString *) expectedGeoPackageExtensionAuthor{
    return @"gpkg";
}

-(NSString *) expectedGeoPackageExtensionNameNoAuthorWithType:(enum SFGeometryType) type{
    return [NSString stringWithFormat:@"geom_%@", [SFGeometryTypes name:type]];
}

-(NSString *) expectedUserDefinedExtensionNameWithAuthor: (NSString *) author andType: (enum SFGeometryType) type{
    return [NSString stringWithFormat:@"%@_geom_%@", author, [SFGeometryTypes name:type]];
}

@end
