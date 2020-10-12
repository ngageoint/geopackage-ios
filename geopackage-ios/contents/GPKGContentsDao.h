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
#import "GPKGContentsDataTypes.h"

/**
 *  Contents Data Access Object
 */
@interface GPKGContentsDao : GPKGBaseDao

/**
 * Create the DAO
 *
 * @param db
 *            database connection
 * @return dao
 */
+(GPKGContentsDao *) createWithDatabase: (GPKGConnection *) database;

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new contents dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 * Get table names by data type
 *
 * @param dataType
 *            data type
 * @return table names
 */
-(NSArray<NSString *> *) tablesByType: (enum GPKGContentsDataType) dataType;

/**
 * Get table names by data types
 *
 * @param dataTypes
 *            data types
 * @return table names
 */
-(NSArray<NSString *> *) tablesByTypes: (NSArray<NSNumber *> *) dataTypes;

/**
 * Get table names by data type
 *
 * @param dataType
 *            data type
 * @return table names
 */
-(NSArray<NSString *> *) tablesByTypeName: (NSString *) dataType;

/**
 * Get table names by data types
 *
 * @param dataTypes
 *            data types
 * @return table names
 */
-(NSArray<NSString *> *) tablesByTypeNames: (NSArray<NSString *> *) dataTypes;

/**
 * Get contents by data type
 *
 * @param dataType
 *            data type
 * @return contents result set
 */
-(GPKGResultSet *) contentsByType: (enum GPKGContentsDataType) dataType;

/**
 * Get contents by data types
 *
 * @param dataTypes
 *            data types
 * @return contents result set
 */
-(GPKGResultSet *) contentsByTypes: (NSArray<NSNumber *> *) dataTypes;

/**
 * Get contents by data type
 *
 * @param dataType
 *            data type
 * @return contents result set
 */
-(GPKGResultSet *) contentsByTypeName: (NSString *) dataType;

/**
 * Get contents by data types
 *
 * @param dataTypes
 *            data types
 * @return contents result set
 */
-(GPKGResultSet *) contentsByTypeNames: (NSArray<NSString *> *) dataTypes;

/**
 * Get table names
 *
 * @return table names
 */
-(NSArray<NSString *> *) tables;

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
-(GPKGSpatialReferenceSystem *) srs: (GPKGContents *) contents;

/**
 *  Get the Geometry Columns
 *
 *  @param contents contents
 *
 *  @return geometry columns
 */
-(GPKGGeometryColumns *) geometryColumns: (GPKGContents *) contents;

/**
 *  Get the Tile Matrix Set
 *
 *  @param contents contents
 *
 *  @return tile matrix set
 */
-(GPKGTileMatrixSet *) tileMatrixSet: (GPKGContents *) contents;

/**
 *  Get the Tile Matrix results
 *
 *  @param contents contents
 *
 *  @return result set
 */
-(GPKGResultSet *) tileMatrix: (GPKGContents *) contents;

/**
 * Get the bounding box for all tables in the provided projection
 *
 * @param projection
 *            desired bounding box projection
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection;

/**
 * Get the bounding box for the table in the table's projection
 *
 * @param table
 *            table name
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table;

/**
 * Get the bounding box for the table in the provided projection
 *
 * @param table
 *            table name
 * @param projection
 *            desired bounding box projection
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 * Get a bounding box in the provided projection
 *
 * @param contents
 *            contents
 * @param projection
 *            desired projection
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxOfContents: (GPKGContents *) contents inProjection: (SFPProjection *) projection;

@end
