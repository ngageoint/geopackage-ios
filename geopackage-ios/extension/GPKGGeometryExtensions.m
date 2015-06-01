//
//  GPKGGeometryExtensions.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryExtensions.h"
#import "WKBGeometryTypes.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGExtensions.h"

@implementation GPKGGeometryExtensions

+(BOOL) isExtension: (enum WKBGeometryType) geometryType{
    return [WKBGeometryTypes code:geometryType] > [WKBGeometryTypes code:WKB_GEOMETRYCOLLECTION];
}

+(BOOL) isGeoPackageExtension: (enum WKBGeometryType) geometryType{
    int geometryCode = [WKBGeometryTypes code:geometryType];
    return geometryCode >= [WKBGeometryTypes code:WKB_CIRCULARSTRING] && geometryCode <= [WKBGeometryTypes code:WKB_SURFACE];
}

+(NSString *) getExtensionName: (enum WKBGeometryType) geometryType{
    
    if(![self isExtension:geometryType]){
        [NSException raise:@"Not Extension" format:@"Geometry Type is not an extension: %@", [WKBGeometryTypes name:geometryType]];
    }
    
    if(![self isGeoPackageExtension:geometryType]){
        [NSException raise:@"Not GeoPackage Extension" format:@"Geometry Type is not a GeoPackage extension, User-Defined requires an author: %@", [WKBGeometryTypes name:geometryType]];
    }
    
    NSString * extensionName = [NSString stringWithFormat:@"%@%@%@%@%@",
                                GPKG_GEO_PACKAGE_EXTENSION_AUTHOR,
                                GPKG_EX_EXTENSION_NAME_DIVIDER,
                                GPKG_GEOMETRY_EXTENSION_PREFIX,
                                GPKG_EX_EXTENSION_NAME_DIVIDER,
                                [WKBGeometryTypes name:geometryType]];
    return extensionName;
}

+(NSString *) getExtensionNameWithAuthor: (NSString *) author andType: (enum WKBGeometryType) geometryType{
    
    if(![self isExtension:geometryType]){
        [NSException raise:@"Not Extension" format:@"Geometry Type is not an extension: %@", [WKBGeometryTypes name:geometryType]];
    }
    
    NSString * extensionName = [NSString stringWithFormat:@"%@%@%@%@%@",
                                [self isGeoPackageExtension:geometryType] ? GPKG_GEO_PACKAGE_EXTENSION_AUTHOR : author,
                                GPKG_EX_EXTENSION_NAME_DIVIDER,
                                GPKG_GEOMETRY_EXTENSION_PREFIX,
                                GPKG_EX_EXTENSION_NAME_DIVIDER,
                                [WKBGeometryTypes name:geometryType]];
    return extensionName;
}

@end
