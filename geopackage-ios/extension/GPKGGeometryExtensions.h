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
 *  @deprecated as of 1.2.1, On August 15, 2016 the GeoPackage SWG voted to
 *             remove this extension from the standard due to
 *             interoperability concerns. (GeoPackage version 1.2)
 */
@property (nonatomic, strong) NSString *userGeometryTypesDefinition __attribute__((deprecated));

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
 *  Get or create the extension, user defined geometry type
 *
 *  @param tableName    table name
 *  @param columnName   column name
 *  @param author       extension author
 *  @param geometryType geometry type
 *
 *  @return extension
 *  @deprecated as of 1.2.1, On August 15, 2016 the GeoPackage SWG voted to
 *             remove this extension from the standard due to
 *             interoperability concerns. (GeoPackage version 1.2)
 */
-(GPKGExtensions *) getOrCreateWithTable: (NSString *) tableName andColumn: (NSString *) columnName andAuthor: (NSString *) author andType: (enum WKBGeometryType) geometryType __attribute__((deprecated));

/**
 *  Determine if the GeoPackage has the extension, user defined geometry type
 *
 *  @param tableName    table name
 *  @param columnName   column name
 *  @param author       extension author
 *  @param geometryType geometry type
 *
 *  @return true if has extension
 *  @deprecated as of 1.2.1, On August 15, 2016 the GeoPackage SWG voted to
 *             remove this extension from the standard due to
 *             interoperability concerns. (GeoPackage version 1.2)
 */
-(BOOL) hasWithTable: (NSString *) tableName andColumn: (NSString *) columnName andAuthor: (NSString *) author andType: (enum WKBGeometryType) geometryType __attribute__((deprecated));

/**
 *  Get the extension name of an extension Geometry, either user-defined or
 *  GeoPackage extension
 *
 *  @param author       author
 *  @param geometryType geometry type
 *
 *  @return extension name
 *  @deprecated as of 1.2.1, On August 15, 2016 the GeoPackage SWG voted to
 *             remove this extension from the standard due to
 *             interoperability concerns. (GeoPackage version 1.2)
 */
+(NSString *) getExtensionNameWithAuthor: (NSString *) author andType: (enum WKBGeometryType) geometryType __attribute__((deprecated));

@end
