//
//  GPKGExtensions.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Extension table constants
 */
extern NSString * const GPKG_EX_EXTENSION_NAME_DIVIDER;
extern NSString * const GPKG_EX_TABLE_NAME;
extern NSString * const GPKG_EX_COLUMN_TABLE_NAME;
extern NSString * const GPKG_EX_COLUMN_COLUMN_NAME;
extern NSString * const GPKG_EX_COLUMN_EXTENSION_NAME;
extern NSString * const GPKG_EX_COLUMN_DEFINITION;
extern NSString * const GPKG_EX_COLUMN_SCOPE;

/**
 * Extension scope type enumeration
 */
enum GPKGExtensionScopeType{
    GPKG_EST_READ_WRITE,
    GPKG_EST_WRITE_ONLY
};

/**
 *  Extension scope type enumeration names
 */
extern NSString * const GPKG_EST_READ_WRITE_NAME;
extern NSString * const GPKG_EST_WRITE_ONLY_NAME;

/**
 * Indicates that a particular extension applies to a GeoPackage, a table in a
 * GeoPackage or a column of a table in a GeoPackage. An application that access
 * a GeoPackage can query the gpkg_extensions table instead of the contents of
 * all the user data tables to determine if it has the required capabilities to
 * read or write to tables with extensions, and to “fail fast” and return an
 * error message if it does not.
 */
@interface GPKGExtensions : NSObject

/**
 * Name of the table that requires the extension. When NULL, the extension
 * is required for the entire GeoPackage. SHALL NOT be NULL when the
 * column_name is not NULL.
 */
@property (nonatomic, strong) NSString *tableName;

/**
 * Name of the column that requires the extension. When NULL, the extension
 * is required for the entire table.
 */
@property (nonatomic, strong) NSString *columnName;

/**
 * The case sensitive name of the extension that is required, in the form
 * <author>_<extension_name>.
 */
@property (nonatomic, strong) NSString *extensionName;

/**
 * Definition of the extension in the form specfied by the template in
 * GeoPackage Extension Template (Normative) or reference thereto.
 */
@property (nonatomic, strong) NSString *definition;

/**
 * Indicates scope of extension effects on readers / writers: read-write or
 * write-only in lowercase.
 */
@property (nonatomic, strong) NSString *scope;

/**
 *  Get the extension scope type
 *
 *  @return extension scope type
 */
-(enum GPKGExtensionScopeType) getExtensionScopeType;

/**
 *  Set the extension scope type
 *
 *  @param extensionScopeType extension scope type
 */
-(void) setExtensionScopeType: (enum GPKGExtensionScopeType) extensionScopeType;

/**
 *  Set the table name
 *
 *  @param tableName table name
 */
-(void) setTableName:(NSString *)tableName;

/**
 *  Set the extension name by combining the required parts
 *
 *  @param author        author
 *  @param extensionName extension name
 */
-(void) setExtensionNameWithAuthor: (NSString *) author andExtensionName: (NSString *) extensionName;

/**
 *  Get the author from the beginning of the extension name
 *
 *  @return author
 */
-(NSString *) getAuthor;

/**
 *  Get the extension name with the author prefix removed
 *
 *  @return extension name
 */
-(NSString *) getExtensionNameNoAuthor;

/**
 *  Build the extension name by combining the required parts
 *
 *  @param author        author
 *  @param extensionName extension name
 *  @return extension name
 */
+(NSString *) buildExtensionNameWithAuthor: (NSString *) author andExtensionName: (NSString *) extensionName;

/**
 *  Get the author from the beginning of the extension name
 *
 *  @param extensionName extension name
 *  @return author
 */
+(NSString *) getAuthorWithExtensionName: (NSString *) extensionName;

/**
 *  Get the extension name with the author prefix removed
 *
 *  @param extensionName extension name
 *  @return extension name, no author
 */
+(NSString *) getExtensionNameNoAuthorWithExtensionName: (NSString *) extensionName;

@end
