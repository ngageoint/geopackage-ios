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

@implementation GPKGGeometryExtensionsTest

/**
 *  Test the is extension check
 */
-(void) testIsExtension{
    
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:WKB_GEOMETRY]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:WKB_POINT]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:WKB_LINESTRING]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:WKB_POLYGON]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:WKB_MULTIPOINT]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:WKB_MULTILINESTRING]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:WKB_MULTIPOLYGON]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isExtension:WKB_GEOMETRYCOLLECTION]];
    
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:WKB_CIRCULARSTRING]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:WKB_COMPOUNDCURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:WKB_CURVEPOLYGON]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:WKB_MULTICURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:WKB_MULTISURFACE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:WKB_CURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:WKB_SURFACE]];
    
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:WKB_POLYHEDRALSURFACE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:WKB_TIN]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isExtension:WKB_TRIANGLE]];
}

/**
 *  Test the is GeoPackage extension check
 */
-(void) testIsGeoPackageExtension{
    
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_GEOMETRY]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_POINT]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_LINESTRING]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_POLYGON]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_MULTIPOINT]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_MULTILINESTRING]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_MULTIPOLYGON]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_GEOMETRYCOLLECTION]];
    
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:WKB_CIRCULARSTRING]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:WKB_COMPOUNDCURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:WKB_CURVEPOLYGON]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:WKB_MULTICURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:WKB_MULTISURFACE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:WKB_CURVE]];
    [GPKGTestUtils assertTrue:[GPKGGeometryExtensions isGeoPackageExtension:WKB_SURFACE]];
    
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_POLYHEDRALSURFACE]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_TIN]];
    [GPKGTestUtils assertFalse:[GPKGGeometryExtensions isGeoPackageExtension:WKB_TRIANGLE]];
}

/**
 *  Test the GeoPackage get extension name
 */
-(void) testGeoPackageExtensionName{
    
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_GEOMETRY];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_POINT];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_LINESTRING];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_POLYGON];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_MULTIPOINT];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_MULTILINESTRING];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_MULTIPOLYGON];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_GEOMETRYCOLLECTION];
    }@catch(NSException *exception){
        // Expected
    }
    
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_CIRCULARSTRING] andValue2:[GPKGGeometryExtensions getExtensionName:WKB_CIRCULARSTRING]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_COMPOUNDCURVE] andValue2:[GPKGGeometryExtensions getExtensionName:WKB_COMPOUNDCURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_CURVEPOLYGON] andValue2:[GPKGGeometryExtensions getExtensionName:WKB_CURVEPOLYGON]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_MULTICURVE] andValue2:[GPKGGeometryExtensions getExtensionName:WKB_MULTICURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_MULTISURFACE] andValue2:[GPKGGeometryExtensions getExtensionName:WKB_MULTISURFACE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_CURVE] andValue2:[GPKGGeometryExtensions getExtensionName:WKB_CURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_SURFACE] andValue2:[GPKGGeometryExtensions getExtensionName:WKB_SURFACE]];
    
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_POLYHEDRALSURFACE];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_TIN];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionName:WKB_TRIANGLE];
    }@catch(NSException *exception){
        // Expected
    }
}

/**
 *  Test the get extension name
 */
-(void) testExtensionName{
    
    NSString * author = @"nga";
    
    @try{
        [GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_GEOMETRY];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_POINT];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_LINESTRING];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_POLYGON];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_MULTIPOINT];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_MULTILINESTRING];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_MULTIPOLYGON];
    }@catch(NSException *exception){
        // Expected
    }
    @try{
        [GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_GEOMETRYCOLLECTION];
    }@catch(NSException *exception){
        // Expected
    }
    
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_CIRCULARSTRING] andValue2:[GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_CIRCULARSTRING]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_COMPOUNDCURVE] andValue2:[GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_COMPOUNDCURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_CURVEPOLYGON] andValue2:[GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_CURVEPOLYGON]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_MULTICURVE] andValue2:[GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_MULTICURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_MULTISURFACE] andValue2:[GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_MULTISURFACE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_CURVE] andValue2:[GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_CURVE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedGeoPackageExtensionNameWithType:WKB_SURFACE] andValue2:[GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_SURFACE]];
    
    [GPKGTestUtils assertEqualWithValue:[self expectedUserDefinedExtensionNameWithAuthor:author andType:WKB_POLYHEDRALSURFACE] andValue2:[GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_POLYHEDRALSURFACE]];
    [GPKGTestUtils assertEqualWithValue:[self expectedUserDefinedExtensionNameWithAuthor:author andType:WKB_TIN] andValue2:[GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_TIN]];
    [GPKGTestUtils assertEqualWithValue:[self expectedUserDefinedExtensionNameWithAuthor:author andType:WKB_TRIANGLE] andValue2:[GPKGGeometryExtensions getExtensionNameWithAuthor:author andType:WKB_TRIANGLE]];
    
}

/**
 *  Test the Geometry Extension creation
 */
- (void)testGeometryExtension {
    
    GPKGGeometryExtensions * extensions = [[GPKGGeometryExtensions alloc] initWithGeoPackage:self.geoPackage];
    GPKGExtensionsDao * extensionsDao = extensions.extensionsDao;
    
    // Test non extension geometries
    for(int i = WKB_GEOMETRY; i <= WKB_GEOMETRYCOLLECTION; i++){
        
        enum WKBGeometryType geometryType = [WKBGeometryTypes fromCode:i];
        @try{
            [extensions getOrCreateWithTable:@"table_name" andColumn:@"column_name" andType:geometryType];
            [GPKGTestUtils fail:[NSString stringWithFormat:@"Geometry Extension was created for %@", [WKBGeometryTypes name:geometryType]]];
        }@catch(NSException *exception){
            // Expected
        }
    }
    
    // Test user created extension geometries
    for(int i = WKB_POLYHEDRALSURFACE; i <= WKB_TRIANGLE; i++){
        
        enum WKBGeometryType geometryType = [WKBGeometryTypes fromCode:i];
        @try{
            [extensions getOrCreateWithTable:@"table_name" andColumn:@"column_name" andType:geometryType];
            [GPKGTestUtils fail:[NSString stringWithFormat:@"Geometry Extension was created for %@", [WKBGeometryTypes name:geometryType]]];
        }@catch(NSException *exception){
            // Expected
        }
    }
    
    // Test geometry extensions
    int count = [extensionsDao count];
    for(int i = WKB_CIRCULARSTRING; i <= WKB_SURFACE; i++){
        
        enum WKBGeometryType geometryType = [WKBGeometryTypes fromCode:i];
        NSString * tableName = [NSString stringWithFormat:@"table_%@", [WKBGeometryTypes name:geometryType]];
        NSString * columnName = @"geom";
        GPKGExtensions * extension = [extensions getOrCreateWithTable:tableName andColumn:columnName andType:geometryType];
        [GPKGTestUtils assertNotNil:extension];
        [GPKGTestUtils assertTrue:[extensions hasWithTable:tableName andColumn:columnName andType:geometryType]];
        [GPKGTestUtils assertEqualIntWithValue:++count andValue2:[extensionsDao count]];
        
        [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:[self expectedGeoPackageExtensionNameWithType:geometryType]];
        [GPKGTestUtils assertEqualWithValue:[extension getAuthor] andValue2:[self expectedGeoPackageExtensionAuthor]];
        [GPKGTestUtils assertEqualWithValue:[extension getExtensionNameNoAuthor] andValue2:[self expectedGeoPackageExtensionNameNoAuthorWithType:geometryType]];
        [GPKGTestUtils assertEqualWithValue:extension.tableName andValue2:tableName];
        [GPKGTestUtils assertEqualWithValue:extension.columnName andValue2:columnName];
        [GPKGTestUtils assertEqualIntWithValue:[extension getExtensionScopeType] andValue2:GPKG_EST_READ_WRITE];
        [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:extensions.geometryTypesDefinition];
    }
    
}

/**
 *  Test the User Geometry Extension creation
 */
- (void)testUserGeometryExtension {
    
    GPKGGeometryExtensions * extensions = [[GPKGGeometryExtensions alloc] initWithGeoPackage:self.geoPackage];
    GPKGExtensionsDao * extensionsDao = extensions.extensionsDao;
    
    NSString * author = @"nga";
    
    // Test non extension geometries
    for(int i = WKB_GEOMETRY; i <= WKB_GEOMETRYCOLLECTION; i++){
        
        enum WKBGeometryType geometryType = [WKBGeometryTypes fromCode:i];
        @try{
            [extensions getOrCreateWithTable:@"table_name" andColumn:@"column_name" andAuthor:author andType:geometryType];
            [GPKGTestUtils fail:[NSString stringWithFormat:@"Geometry Extension was created for %@", [WKBGeometryTypes name:geometryType]]];
        }@catch(NSException *exception){
            // Expected
        }
    }
    
    // Test geometry extensions
    int count = [extensionsDao count];
    for(int i = WKB_CIRCULARSTRING; i <= WKB_TRIANGLE; i++){
        
        enum WKBGeometryType geometryType = [WKBGeometryTypes fromCode:i];
        NSString * tableName = [NSString stringWithFormat:@"table_%@", [WKBGeometryTypes name:geometryType]];
        NSString * columnName = @"geom";
        GPKGExtensions * extension = [extensions getOrCreateWithTable:tableName andColumn:columnName andAuthor:author andType:geometryType];
        [GPKGTestUtils assertNotNil:extension];
        [GPKGTestUtils assertTrue:[extensions hasWithTable:tableName andColumn:columnName andAuthor:author andType:geometryType]];
        [GPKGTestUtils assertEqualIntWithValue:++count andValue2:[extensionsDao count]];
        
        [GPKGTestUtils assertEqualWithValue:[extension getExtensionNameNoAuthor] andValue2:[self expectedGeoPackageExtensionNameNoAuthorWithType:geometryType]];
        [GPKGTestUtils assertEqualWithValue:extension.tableName andValue2:tableName];
        [GPKGTestUtils assertEqualWithValue:extension.columnName andValue2:columnName];
        [GPKGTestUtils assertEqualIntWithValue:[extension getExtensionScopeType] andValue2:GPKG_EST_READ_WRITE];
        
        if(i <= WKB_SURFACE){
            [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:[self expectedGeoPackageExtensionNameWithType:geometryType]];
            [GPKGTestUtils assertEqualWithValue:[extension getAuthor] andValue2:[self expectedGeoPackageExtensionAuthor]];
            [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:extensions.geometryTypesDefinition];
        }else{
            [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:[self expectedUserDefinedExtensionNameWithAuthor:author andType:geometryType]];
            [GPKGTestUtils assertEqualWithValue:[extension getAuthor] andValue2:author];
            [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:extensions.userGeometryTypesDefinition];
        }
    }
    
}

-(NSString *) expectedGeoPackageExtensionNameWithType:(enum WKBGeometryType) type{
    return [NSString stringWithFormat:@"%@_%@", [self expectedGeoPackageExtensionAuthor], [self expectedGeoPackageExtensionNameNoAuthorWithType:type]];
}

-(NSString *) expectedGeoPackageExtensionAuthor{
    return @"gpkg";
}

-(NSString *) expectedGeoPackageExtensionNameNoAuthorWithType:(enum WKBGeometryType) type{
    return [NSString stringWithFormat:@"geom_%@", [WKBGeometryTypes name:type]];
}

-(NSString *) expectedUserDefinedExtensionNameWithAuthor: (NSString *) author andType: (enum WKBGeometryType) type{
    return [NSString stringWithFormat:@"%@_geom_%@", author, [WKBGeometryTypes name:type]];
}

@end
