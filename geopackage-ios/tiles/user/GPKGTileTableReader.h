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
 *  Initialize
 *
 *  @param tableName  table name
 *
 *  @return new tile table reader
 */
-(instancetype) initWithTable: (NSString *) tableName;

/**
 *  Read the tile table with the database connection
 *
 *  @param db database connection
 *
 *  @return tile table
 */
-(GPKGTileTable *) readTileTableWithConnection: (GPKGConnection *) db;

@end
