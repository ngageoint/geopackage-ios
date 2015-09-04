//
//  GPKGTileTableReader.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTableReader.h"
#import "GPKGTileMatrixSet.h"
#import "GPKGTileTable.h"

/**
 *  Reads the metadata from an existing tile table
 */
@interface GPKGTileTableReader : GPKGUserTableReader

/**
 *  Tile Matrix Set
 */
@property (nonatomic, strong) GPKGTileMatrixSet * tileMatrixSet;

/**
 *  Initialize
 *
 *  @param tileMatrixSet tile matrix set
 *
 *  @return new tile table reader
 */
-(instancetype) initWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Read the tile table with the database connection
 *
 *  @param db database connection
 *
 *  @return tile table
 */
-(GPKGTileTable *) readTileTableWithConnection: (GPKGConnection *) db;

@end
