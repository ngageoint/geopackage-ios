//
//  GPKGTileMatrixDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGTileMatrix.h"
#import "GPKGContents.h"

/**
 *  Tile Matrix Data Access Object
 */
@interface GPKGTileMatrixDao : GPKGBaseDao

/**
 * Create the DAO
 *
 * @param database
 *            database connection
 * @return dao
 */
+(GPKGTileMatrixDao *) createWithDatabase: (GPKGConnection *) database;

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new tile matrix dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Get the Contents of the Tile Matrix
 *
 *  @param tileMatrix tile matrix
 *
 *  @return contents
 */
-(GPKGContents *) contents: (GPKGTileMatrix *) tileMatrix;

/**
 * Query tile matrices for a table name
 *
 * @param tableName
 *            table name
 * @return result set
 */
-(GPKGResultSet *) queryForTableName: (NSString *) table;

/**
 * Query tile matrices for a table name
 *
 * @param tableName
 *            table name
 * @return tile matrices
 */
-(NSArray<GPKGTileMatrix *> *) tileMatricesForTableName: (NSString *) table;

/**
 *  Delete Tile Matrices for a table name
 *
 *  @param table table name
 *
 *  @return rows deleted
 */
-(int) deleteByTableName: (NSString *) table;

@end
