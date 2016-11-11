//
//  GPKGGriddedCoverageDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGGriddedCoverage.h"

/**
 * Gridded Coverage Data Access Object
 */
@interface GPKGGriddedCoverageDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new gridded coverage dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Query by tile matrix set
 *
 *  @param tileMatrixSet tile matrix set
 *
 *  @return gridded coverage
 */
-(GPKGGriddedCoverage *) queryByTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Query by tile matrix set name
 *
 *  @param tileMatrixSetName tile matrix set name
 *
 *  @return gridded coverage
 */
-(GPKGGriddedCoverage *) queryByTileMatrixSetName: (NSString *) tileMatrixSetName;

/**
 *  Delete by tile matrix set
 *
 *  @param tileMatrixSet tile matrix set
 *
 *  @return deleted count
 */
-(int) deleteByTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Delete by tile matrix set name
 *
 *  @param tileMatrixSetName tile matrix set name
 *
 *  @return deleted count
 */
-(int) deleteByTileMatrixSetName: (NSString *) tileMatrixSetName;

/**
 * Get the tile matrix set
 *
 *  @param griddedCoverage gridded coverage
 *
 * @return tile matrix set
 */
-(GPKGTileMatrixSet *) getTileMatrixSet: (GPKGGriddedCoverage *) griddedCoverage;

@end
