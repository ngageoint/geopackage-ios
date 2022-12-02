//
//  GPKGBaseExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/3/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"
#import "GPKGExtensionsDao.h"

/**
 *  Abstract base GeoPackage extension
 */
@interface GPKGBaseExtension : NSObject

/**
 *  GeoPackage
 */
@property (nonatomic, strong) GPKGGeoPackage *geoPackage;

/**
 *  Extensions DAO
 */
@property (nonatomic, strong) GPKGExtensionsDao *extensionsDao;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new base extension
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Initialize
 *
 *  @param database database
 *
 *  @return new base extension
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Get the extension or create as needed
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *  @param columnName    column name
 *  @param definition    extension definition
 *  @param scopeType     extension scope type
 *
 *  @return extension
 */
-(GPKGExtensions *) extensionCreateWithName: (NSString *) extensionName andTableName: (NSString *) tableName andColumnName: (NSString *) columnName andDefinition: (NSString *) definition andScope: (enum GPKGExtensionScopeType) scopeType;

/**
 *  Get the extensions for the name, ignoring table name and column name values
 *
 *  @param extensionName extension name
 *
 *  @return extension results
 */
-(GPKGResultSet *) extensionsWithName: (NSString *) extensionName;

/**
 *  Determine if the GeoPackage has at least one extension, ignoring table name and column name values
 *
 *  @param extensionName extension name
 *
 *  @return true if extension exists
 */
-(BOOL) hasWithExtensionName: (NSString *) extensionName;

/**
 *  Get the extensions for the name and table name, ignoring column name values
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *
 *  @return extension results
 */
-(GPKGResultSet *) extensionsWithName: (NSString *) extensionName andTableName: (NSString *) tableName;

/**
 *  Determine if the GeoPackage has at least one extension, ignoring column name values
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *
 *  @return true if extension exists
 */
-(BOOL) hasWithExtensionName: (NSString *) extensionName andTableName: (NSString *) tableName;

/**
 *  Get the extension for the name, table name, and column name
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *  @param columnName    column name
 *
 *  @return extension
 */
-(GPKGExtensions *) extensionWithName: (NSString *) extensionName andTableName: (NSString *) tableName andColumnName: (NSString *) columnName;

/**
 *  Determine if the GeoPackage has the extension
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *  @param columnName    column name
 *
 *  @return true if extension exists
 */
-(BOOL) hasWithExtensionName: (NSString *) extensionName andTableName: (NSString *) tableName andColumnName: (NSString *) columnName;

/**
 * Verify the GeoPackage is writable and throw an exception if it is not
 */
-(void) verifyWritable;

@end
