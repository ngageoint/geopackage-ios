//
//  GPKGTableIndexDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGGeoPackage.h"
#import "GPKGTableIndex.h"
#import "GPKGExtensions.h"

/**
 *  Table Index Data Access Object
 */
@interface GPKGTableIndexDao : GPKGBaseDao

/**
 * Create the DAO
 *
 * @param geoPackage
 *            GeoPackage
 * @return dao
 */
+(GPKGTableIndexDao *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Create the DAO
 *
 * @param database
 *            database connection
 * @return dao
 */
+(GPKGTableIndexDao *) createWithDatabase: (GPKGConnection *) database;

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new table index dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Delete the Table Index, cascading
 *
 *  @param tableIndex table index
 *
 *  @return rows deleted
 */
-(int) deleteCascade: (GPKGTableIndex *) tableIndex;

/**
 *  Delete the collection of Table Indices, cascading
 *
 *  @param tableIndexCollection table index array
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWithCollection: (NSArray *) tableIndexCollection;

/**
 *  Delete the Table Index where, cascading
 *
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Delete the Table Index by id, cascading
 *
 *  @param id id
 *
 *  @return rows deleted
 */
-(int) deleteByIdCascade: (NSString *) id;

/**
 *  Delete the Table Indices by ids, cascading
 *
 *  @param idCollection id array
 *
 *  @return rows deleted
 */
-(int) deleteIdsCascade: (NSArray *) idCollection;

/**
 *  Delete the table
 *
 *  @param table table name
 */
-(void) deleteTable: (NSString *) table;

/**
 *  Get the Geometry Index results
 *
 *  @param tableIndex table index
 *
 *  @return result set
 */
-(GPKGResultSet *) geometryIndices: (GPKGTableIndex *) tableIndex;

/**
 *  Get the count of Geometry Index results
 *
 *  @param tableIndex table index
 *
 *  @return count
 */
-(int) geometryIndexCount: (GPKGTableIndex *) tableIndex;

/**
 *  Delete all table indices, cascading to geometry indices
 *
 *  @return rows deleted
 */
-(int) deleteAllCascade;

@end
