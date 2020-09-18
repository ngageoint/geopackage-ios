//
//  GPKGContentsIdExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "GPKGContentsIdDao.h"

extern NSString * const GPKG_EXTENSION_CONTENTS_ID_NAME_NO_AUTHOR;
extern NSString * const GPKG_PROP_EXTENSION_CONTENTS_ID_DEFINITION;

/**
 * This extension assigns a unique integer identifier to tables defined in the
 * contents. Allows foreign key referencing to a contents (text based primary
 * key) by an integer identifier.
 *
 * http://ngageoint.github.io/GeoPackage/docs/extensions/contents-id.html
 */
@interface GPKGContentsIdExtension : GPKGBaseExtension

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new contents id extension
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get the Contents Id DAO
 *
 *  @return contents id dao
 */
-(GPKGContentsIdDao *) dao;

/**
 *  Get the extension name
 *
 *  @return extension name
 */
-(NSString *) extensionName;

/**
 *  Get the extension definition
 *
 *  @return extension definition
 */
-(NSString *) extensionDefinition;

/**
 * Determine if the GeoPackage has the extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 *  Get the contents id for the current result in the result set
 *
 *  @param results result set
 *
 *  @return contents id
 */
-(GPKGContentsId *) contentsId: (GPKGResultSet *) results;

/**
 * Get the contents id object
 *
 * @param contents
 *            contents
 * @return contents id or null
 */
-(GPKGContentsId *) forContents: (GPKGContents *) contents;

/**
 * Get the contents id object
 *
 * @param tableName
 *            table name
 * @return contents id or null
 */
-(GPKGContentsId *) forTableName: (NSString *) tableName;

/**
 * Get the contents id
 *
 * @param contents
 *            contents
 * @return contents id or null
 */
-(NSNumber *) idForContents: (GPKGContents *) contents;

/**
 * Get the contents id
 *
 * @param tableName
 *            table name
 * @return contents id or null
 */
-(NSNumber *) idForTableName: (NSString *) tableName;

/**
 * Create a contents id
 *
 * @param contents
 *            contents
 * @return new contents id
 */
-(GPKGContentsId *) createForContents: (GPKGContents *) contents;

/**
 * Create a contents id
 *
 * @param tableName
 *            table name
 * @return new contents id
 */
-(GPKGContentsId *) createForTableName: (NSString *) tableName;

/**
 * Create a contents id
 *
 * @param contents
 *            contents
 * @return new contents id
 */
-(NSNumber *) createIdForContents: (GPKGContents *) contents;

/**
 * Create a contents id
 *
 * @param tableName
 *            table name
 * @return new contents id
 */
-(NSNumber *) createIdForTableName: (NSString *) tableName;

/**
 * Get or create a contents id
 *
 * @param contents
 *            contents
 * @return new or existing contents id
 */
-(GPKGContentsId *) createGetForContents: (GPKGContents *) contents;

/**
 * Get or create a contents id
 *
 * @param tableName
 *            table name
 * @return new or existing contents id
 */
-(GPKGContentsId *) createGetForTableName: (NSString *) tableName;

/**
 * Get or create a contents id
 *
 * @param contents
 *            contents
 * @return new or existing contents id
 */
-(NSNumber *) createGetIdForContents: (GPKGContents *) contents;

/**
 * Get or create a contents id
 *
 * @param tableName
 *            table name
 * @return new or existing contents id
 */
-(NSNumber *) createGetIdForTableName: (NSString *) tableName;

/**
 * Delete the contents id for the contents
 *
 * @param contents
 *            contents
 *
 * @return true if deleted
 */
-(BOOL) deleteForContents: (GPKGContents *) contents;

/**
 * Delete the contents id for the table
 *
 * @param tableName
 *            table name
 *
 * @return true if deleted
 */
-(BOOL) deleteForTableName: (NSString *) tableName;

/**
 * Create contents ids for contents currently without
 *
 * @return newly created contents ids count
 */
-(int) createIds;

/**
 * Create contents ids for contents of the data type and currently without
 *
 * @param type
 *            contents data type
 * @return newly created contents ids count
 */
-(int) createIdsForType: (enum GPKGContentsDataType) type;

/**
 * Create contents ids for contents of the data type and currently without
 *
 * @param type
 *            contents data type
 * @return newly created contents ids count
 */
-(int) createIdsForTypeName: (NSString *) type;

/**
 * Delete all contents ids
 *
 * @return deleted contents ids count
 */
-(int) deleteIds;

/**
 * Delete contents ids for contents of the data type
 *
 * @param type
 *            contents data type
 * @return deleted contents ids count
 */
-(int) deleteIdsForType: (enum GPKGContentsDataType) type;

/**
 * Delete contents ids for contents of the data type
 *
 * @param type
 *            contents data type
 * @return deleted contents ids count
 */
-(int) deleteIdsForTypeName: (NSString *) type;

/**
 * Get all contents ids
 *
 * @return contents ids
 */
-(GPKGResultSet *) ids;

/**
 * Get the count of contents ids
 *
 * @return count
 */
-(int) count;

/**
 * Get by contents data type
 *
 * @param type
 *            contents data type
 * @return contents ids
 */
-(GPKGResultSet *) idsForType: (enum GPKGContentsDataType) type;

/**
 * Get by contents data type
 *
 * @param type
 *            contents data type
 * @return contents ids
 */
-(GPKGResultSet *) idsForTypeName: (NSString *) type;

/**
 * Get contents without contents ids
 *
 * @return table names without contents ids
 */
-(NSArray<NSString *> *) missing;

/**
 * Get contents by data type without contents ids
 *
 * @param type
 *            contents data type
 * @return table names without contents ids
 */
-(NSArray<NSString *> *) missingForType: (enum GPKGContentsDataType) type;

/**
 * Get contents by data type without contents ids
 *
 * @param type
 *            contents data type
 * @return table names without contents ids
 */
-(NSArray<NSString *> *) missingForTypeName: (NSString *) type;

/**
 * Get or create if needed the extension
 *
 * @return extensions object
 */
-(GPKGExtensions *) extensionCreate;

/**
 * Get the extension
 *
 * @return extensions object or null if one does not exist
 */
-(GPKGExtensions *) extension;

/**
 * Remove all trace of the extension
 */
-(void) removeExtension;

/**
 * Get a Contents Id DAO
 *
 * @return contents id dao
 */
-(GPKGContentsIdDao *) contentsIdDao;

/**
 * Get a Contents Id DAO
 *
 * @param geoPackage
 *            GeoPackage
 * @return contents id dao
 */
+(GPKGContentsIdDao *) contentsIdDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get a Contents Id DAO
 *
 * @param database
 *            database connection
 * @return contents id dao
 */
+(GPKGContentsIdDao *) contentsIdDaoWithDatabase: (GPKGConnection *) database;

/**
 * Create the Contents Id Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createContentsIdTable;

@end

