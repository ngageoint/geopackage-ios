//
//  GPKGGeometryExtensions.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "WKBGeometryTypes.h"

/**
 *  Geometry Extensions utility methods and constants
 */
@interface GPKGGeometryExtensions : GPKGBaseExtension

/**
 *  Geometry Types Extension definition URL
 */
@property (nonatomic, strong) NSString *geometryTypesDefinition;

/**
 *  User Geometry Types Extension definition URL
 */
@property (nonatomic, strong) NSString *userGeometryTypesDefinition;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get or create the extension, non-linear geometry type
 *
 *  @param tableName    table name
 *  @param columnName   column name
 *  @param geometryType geometry type
 *
 *  @return extension
 */
-(GPKGExtensions *) getOrCreateWithTable: (NSString *) tableName andColumn: (NSString *) columnName andType: (enum WKBGeometryType) geometryType;

/**
 *  Determine if the GeoPackage has the extension, non-linear geometry type
 *
 *  @param tableName    table name
 *  @param columnName   column name
 *  @param geometryType geometry type
 *
 *  @return true if has extension
 */
-(BOOL) hasWithTable: (NSString *) tableName andColumn: (NSString *) columnName andType: (enum WKBGeometryType) geometryType;

/**
 *  Get or create the extension, user defined geometry type
 *
 *  @param tableName    table name
 *  @param columnName   column name
 *  @param author       extension author
 *  @param geometryType geometry type
 *
 *  @return extension
 */
-(GPKGExtensions *) getOrCreateWithTable: (NSString *) tableName andColumn: (NSString *) columnName andAuthor: (NSString *) author andType: (enum WKBGeometryType) geometryType;

/**
 *  Determine if the GeoPackage has the extension, user defined geometry type
 *
 *  @param tableName    table name
 *  @param columnName   column name
 *  @param author       extension author
 *  @param geometryType geometry type
 *
 *  @return true if has extension
 */
-(BOOL) hasWithTable: (NSString *) tableName andColumn: (NSString *) columnName andAuthor: (NSString *) author andType: (enum WKBGeometryType) geometryType;

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
