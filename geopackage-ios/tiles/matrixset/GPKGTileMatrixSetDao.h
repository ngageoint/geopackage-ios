//
//  GPKGTileMatrixSetDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGTileMatrixSet.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGContents.h"

/**
 *  Tile Matrix Set Data Access Object
 */
@interface GPKGTileMatrixSetDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new tile matrix set dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Get the tile table names
 *
 *  @return tile tables
 */
-(NSArray *) getTileTables;

/**
 *  Get the Spatial Reference System of the Tile Matrix Set
 *
 *  @param tileMatrixSet tile matrix set
 *
 *  @return srs
 */
-(GPKGSpatialReferenceSystem *) getSrs: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Get the Contents of the Tile Matrix Set
 *
 *  @param tileMatrixSet tile matrix set
 *
 *  @return contents
 */
-(GPKGContents *) getContents: (GPKGTileMatrixSet *) tileMatrixSet;

@end
