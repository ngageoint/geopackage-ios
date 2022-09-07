//
//  GPKGGeometryExtensions.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryExtensions.h"
#import "SFGeometryTypes.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGExtensions.h"
#import "GPKGProperties.h"
#import "SFWBGeometryCodes.h"

NSString * const GPKG_PROP_GEOMETRY_TYPES_EXTENSION_DEFINITION = @"geopackage.extensions.geometry_types";
NSString * const GPKG_PROP_USER_GEOMETRY_TYPES_EXTENSION_DEFINITION = @"geopackage.extensions.user_geometry_types";

@implementation GPKGGeometryExtensions

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.geometryTypesDefinition = [GPKGProperties valueOfProperty:GPKG_PROP_GEOMETRY_TYPES_EXTENSION_DEFINITION];
        self.userGeometryTypesDefinition = [GPKGProperties valueOfProperty:GPKG_PROP_USER_GEOMETRY_TYPES_EXTENSION_DEFINITION];
    }
    return self;
}

-(GPKGExtensions *) extensionCreateWithTable: (NSString *) tableName andColumn: (NSString *) columnName andType: (enum SFGeometryType) geometryType{
    
    NSString *extensionName = [GPKGGeometryExtensions extensionName:geometryType];
    GPKGExtensions *extension = [self extensionCreateWithName:extensionName andTableName:tableName andColumnName:columnName andDefinition:self.geometryTypesDefinition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(BOOL) hasWithTable: (NSString *) tableName andColumn: (NSString *) columnName andType: (enum SFGeometryType) geometryType{
    
    NSString *extensionName = [GPKGGeometryExtensions extensionName:geometryType];
    BOOL exists = [self hasWithExtensionName:extensionName andTableName:tableName andColumnName:columnName];
    
    return exists;
}

+(BOOL) isExtension: (enum SFGeometryType) geometryType{
    return [SFWBGeometryCodes codeFromGeometryType:geometryType] > [SFWBGeometryCodes codeFromGeometryType:SF_GEOMETRYCOLLECTION];
}

+(BOOL) isNonStandard: (enum SFGeometryType) geometryType{
    return [SFWBGeometryCodes codeFromGeometryType:geometryType] > [SFWBGeometryCodes codeFromGeometryType:SF_SURFACE];
}

+(BOOL) isGeoPackageExtension: (enum SFGeometryType) geometryType{
    int geometryCode = [SFWBGeometryCodes codeFromGeometryType:geometryType];
    return geometryCode >= [SFWBGeometryCodes codeFromGeometryType:SF_CIRCULARSTRING] && geometryCode <= [SFWBGeometryCodes codeFromGeometryType:SF_SURFACE];
}

+(NSString *) extensionName: (enum SFGeometryType) geometryType{
    
    if(![self isExtension:geometryType]){
        [NSException raise:@"Not Extension" format:@"Geometry Type is not an extension: %@", [SFGeometryTypes name:geometryType]];
    }
    
    if(![self isGeoPackageExtension:geometryType]){
        [NSException raise:@"Not GeoPackage Extension" format:@"Geometry Type is not a GeoPackage extension, User-Defined requires an author: %@", [SFGeometryTypes name:geometryType]];
    }
    
    NSString *extensionName = [NSString stringWithFormat:@"%@%@%@",
                                [GPKGExtensions buildDefaultAuthorExtensionName:GPKG_GEOMETRY_EXTENSION_PREFIX],
                                GPKG_EX_EXTENSION_NAME_DIVIDER,
                                [SFGeometryTypes name:geometryType]];
    return extensionName;
}

-(GPKGExtensions *) extensionCreateWithTable: (NSString *) tableName andColumn: (NSString *) columnName andAuthor: (NSString *) author andType: (enum SFGeometryType) geometryType{
    
    NSString *extensionName = [GPKGGeometryExtensions extensionNameWithAuthor:author andType:geometryType];
    NSString *description = [GPKGGeometryExtensions isGeoPackageExtension:geometryType] ? self.geometryTypesDefinition : self.userGeometryTypesDefinition;
    GPKGExtensions *extension = [self extensionCreateWithName:extensionName andTableName:tableName andColumnName:columnName andDefinition:description andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(BOOL) hasWithTable: (NSString *) tableName andColumn: (NSString *) columnName andAuthor: (NSString *) author andType: (enum SFGeometryType) geometryType{
    
    NSString *extensionName = [GPKGGeometryExtensions extensionNameWithAuthor:author andType:geometryType];
    BOOL exists = [self hasWithExtensionName:extensionName andTableName:tableName andColumnName:columnName];
    
    return exists;
}

+(NSString *) extensionNameWithAuthor: (NSString *) author andType: (enum SFGeometryType) geometryType{
    
    if(![self isExtension:geometryType]){
        [NSException raise:@"Not Extension" format:@"Geometry Type is not an extension: %@", [SFGeometryTypes name:geometryType]];
    }
    
    NSString *extensionName = [NSString stringWithFormat:@"%@%@%@",
                                [GPKGExtensions buildExtensionNameWithAuthor:([self isGeoPackageExtension:geometryType] ? GPKG_EXTENSION_AUTHOR : author) andExtensionName:GPKG_GEOMETRY_EXTENSION_PREFIX],
                                GPKG_EX_EXTENSION_NAME_DIVIDER,
                                [SFGeometryTypes name:geometryType]];
    return extensionName;
}

@end
