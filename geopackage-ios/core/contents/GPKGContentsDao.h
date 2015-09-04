//
//  GPKGContentsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGContents.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGGeometryColumns.h"
#import "GPKGTileMatrixSet.h"

/**
 *  Contents Data Access Object
 */
@interface GPKGContentsDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new contents dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Delete the Contents, cascading
 *
 *  @param contents contents
 *
 *  @return rows deleted
 */
-(int) deleteCascade: (GPKGContents *) contents;

/**
 *  Delete the Contents, cascading optionally including the user table
 *
 *  @param contents  contents
 *  @param userTable delete user table
 *
 *  @return rows deleted
 */
-(int) deleteCascade: (GPKGContents *) contents andUserTable: (BOOL) userTable;

/**
 *  Delete the collection of Contents, cascading
 *
 *  @param contentsCollection contents array
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWithCollection: (NSArray *) contentsCollection;

/**
 *  Delete the collection of Contents, cascading optionally including the user table
 *
 *  @param contentsCollection contents array
 *  @param userTable          delete user table
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWithCollection: (NSArray *) contentsCollection andUserTable: (BOOL) userTable;

/**
 *  Delete the Contents where, cascading
 *
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Delete the Contents where, cascading optionally including the user table
 *
 *  @param where     where clause
 *  @param whereArgs where args
 *  @param userTable delete user table
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andUserTable: (BOOL) userTable;

/**
 *  Delete the Contents by id, cascading
 *
 *  @param id id
 *
 *  @return rows deleted
 */
-(int) deleteByIdCascade: (NSString *) id;

/**
 *  Delete the Contents by id, cascading optionally including the user table
 *
 *  @param id        id
 *  @param userTable delete user table
 *
 *  @return rows deleted
 */
-(int) deleteByIdCascade: (NSString *) id andUserTable: (BOOL) userTable;

/**
 *  Delete the Contents by ids, cascading
 *
 *  @param idCollection id array
 *
 *  @return rows deleted
 */
-(int) deleteIdsCascade: (NSArray *) idCollection;

/**
 *  Delete the Contents by ids, cascading optionally including the user table
 *
 *  @param idCollection id array
 *  @param userTable    delete user table
 *
 *  @return rows deleted
 */
-(int) deleteIdsCascade: (NSArray *) idCollection andUserTable: (BOOL) userTable;

/**
 *  Delete the table
 *
 *  @param table table name
 */
-(void) deleteTable: (NSString *) table;

/**
 *  Get the Spatial Reference System
 *
 *  @param contents contents
 *
 *  @return srs
 */
-(GPKGSpatialReferenceSystem *) getSrs: (GPKGContents *) contents;

/**
 *  Get the Geometry Columns
 *
 *  @param contents contents
 *
 *  @return geometry columns
 */
-(GPKGGeometryColumns *) getGeometryColumns: (GPKGContents *) contents;

/**
 *  Get the Tile Matrix Set
 *
 *  @param contents contents
 *
 *  @return tile matrix set
 */
-(GPKGTileMatrixSet *) getTileMatrixSet: (GPKGContents *) contents;

/**
 *  Get the Tile Matrix results
 *
 *  @param contents contents
 *
 *  @return result set
 */
-(GPKGResultSet *) getTileMatrix: (GPKGContents *) contents;

@end
