//
//  GPKGGeometryExtensions.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKBGeometryTypes.h"

/**
 *  Geometry Extensions utility methods and constants
 */
@interface GPKGGeometryExtensions : NSObject

/**
 *  Determine if the geometry type is an extension
 *
 *  @param geometryType geometry type
 *
 *  @return true if an extension
 */
+(BOOL) isExtension: (enum WKBGeometryType) geometryType;

/**
 *  Determine if the geometry type is a GeoPackage extension
 *
 *  @param geometryType geometry type
 *
 *  @return true if a GeoPackage extension
 */
+(BOOL) isGeoPackageExtension: (enum WKBGeometryType) geometryType;

/**
 *  Get the extension name of a GeoPackage extension Geometry
 *
 *  @param geometryType geometry type
 *
 *  @return extension name
 */
+(NSString *) getExtensionName: (enum WKBGeometryType) geometryType;

/**
 *  Get the extension name of an extension Geometry, either user-defined or
 *  GeoPackage extension
 *
 *  @param author       author
 *  @param geometryType geometry type
 *
 *  @return extension name
 */
+(NSString *) getExtensionNameWithAuthor: (NSString *) author andType: (enum WKBGeometryType) geometryType;

@end
