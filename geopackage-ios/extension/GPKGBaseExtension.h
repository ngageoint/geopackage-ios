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
 *  Get the extension or create as needed
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *  @param columnName    column name
 *  @param description   extension description
 *  @param scopeType     extension scope type
 *
 *  @return extension
 */
-(GPKGExtensions *) getOrCreateWithExtensionName: (NSString *) extensionName andTableName: (NSString *) tableName andColumnName: (NSString *) columnName andDescription: (NSString *) description andScope: (enum GPKGExtensionScopeType) scopeType;

/**
 *  Get the extension for the name, table name, and column name
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *  @param columnName    column name
 *
 *  @return extension
 */
-(GPKGExtensions *) getWithExtensionName: (NSString *) extensionName andTableName: (NSString *) tableName andColumnName: (NSString *) columnName;

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

@end
