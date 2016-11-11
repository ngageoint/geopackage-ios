//
//  GPKGGriddedTileDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGContents.h"
#import "GPKGGriddedTile.h"

/**
 * Gridded Tile Data Access Object
 */
@interface GPKGGriddedTileDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new gridded tile dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Query by contents
 *
 *  @param contents
 *            contents
 *  @return gridded tile result set
 */
-(GPKGResultSet *) queryByContents: (GPKGContents *) contents;

/**
 *  Query by table name
 *
 *  @param tableName table name
 *
 *  @return gridded tile result set
 */
-(GPKGResultSet *) queryByTableName: (NSString *) tableName;

/**
 *  Query by table name and table id
 *
 *  @param tableName table name
 *  @param tileId tile id
 *
 *  @return gridded tile
 */
-(GPKGGriddedTile *) queryByTableName: (NSString *) tableName andTileId :(int) tileId;

/**
 *  Delete by contents
 *
 *  @param contents contents
 *
 *  @return deleted count
 */
-(int) deleteByContents: (GPKGContents *) contents;

/**
 *  Delete by table name
 *
 *  @param tableName table name
 *
 *  @return deleted count
 */
-(int) deleteByTileMatrixSetName: (NSString *) tableName;

/**
 *  Get the contents
 *
 *  @param griddedTile gridded tile
 *
 *  @return contents
 */
-(GPKGContents *) getContents: (GPKGGriddedTile *) griddedTile;

@end
