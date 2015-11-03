//
//  GPKGExtensionsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGExtensions.h"

/**
 * Extensions Data Access Object
 */
@interface GPKGExtensionsDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new extensions dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Delete by extension name
 *
 *  @param extensionName extension name
 *
 *  @return rows deleted
 */
-(int) deleteByExtension: (NSString *) extensionName;

/**
 *  Delete by extension name and table name
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *
 *  @return rows deleted
 */
-(int) deleteByExtension: (NSString *) extensionName andTable: (NSString *) tableName;

/**
 *  Delete by extension name, table name, and column name
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *  @param columnName    column name
 *
 *  @return rows deleted
 */
-(int) deleteByExtension: (NSString *) extensionName andTable: (NSString *) tableName andColumnName: (NSString *) columnName;

/**
 *  Query by extension name
 *
 *  @param extensionName extension name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByExtension: (NSString *) extensionName;

/**
 *  Count by extension name
 *
 *  @param extensionName extension name
 *
 *  @return count
 */
-(int) countByExtension: (NSString *) extensionName;

/**
 *  Query by extension name and table name
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByExtension: (NSString *) extensionName andTable: (NSString *) tableName;

/**
 *  Count by extension name and table name
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *
 *  @return count
 */
-(int) countByExtension: (NSString *) extensionName andTable: (NSString *) tableName;

/**
 *  Query by extension name, table name, and column name
 *
 *  @param extensionName extension name
 *  @param tableName     table name
 *  @param columnName    column name
 *
 *  @return result set
 */
-(GPKGExtensions *) queryByExtension: (NSString *) extensionName andTable: (NSString *) tableName andColumnName: (NSString *) columnName;

@end
