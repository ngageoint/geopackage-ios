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
 * Create the DAO
 *
 * @param geoPackage
 *            GeoPackage
 * @return dao
 */
+(GPKGTileMatrixSetDao *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Create the DAO
 *
 * @param database
 *            database connection
 * @return dao
 */
+(GPKGTileMatrixSetDao *) createWithDatabase: (GPKGConnection *) database;

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
-(NSArray *) tileTables;

/**
 *  Get the Spatial Reference System of the Tile Matrix Set
 *
 *  @param tileMatrixSet tile matrix set
 *
 *  @return srs
 */
-(GPKGSpatialReferenceSystem *) srs: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Get the Contents of the Tile Matrix Set
 *
 *  @param tileMatrixSet tile matrix set
 *
 *  @return contents
 */
-(GPKGContents *) contents: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 * Get a bounding box in the provided projection
 
 * @param tileMatrixSet
 *            tile matrix set
 * @param projection
 *            desired projection
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxOfTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet inProjection: (SFPProjection *) projection;

@end
