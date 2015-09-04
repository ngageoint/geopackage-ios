//
//  GPKGSpatialReferenceSystemDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/15/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"
#import "GPKGBaseDao.h"
#import "GPKGSpatialReferenceSystem.h"

/**
 *  Spatial Reference System Data Access Object
 */
@interface GPKGSpatialReferenceSystemDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new spatial reference system dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 * Creates the required EPSG WGS84 Spatial Reference System (spec
 * Requirement 11)
 *
 *  @return wgs84 srs
 */
-(GPKGSpatialReferenceSystem *) createWgs84;

/**
 * Creates the required Undefined Cartesian Spatial Reference System (spec
 * Requirement 11)
 *
 *  @return undefined cartesian srs
 */
-(GPKGSpatialReferenceSystem *) createUndefinedCartesian;

/**
 * Creates the required Undefined Geographic Spatial Reference System (spec
 * Requirement 11)
 *
 *  @return undefined geographic srs
 */
-(GPKGSpatialReferenceSystem *) createUndefinedGeographic;

/**
 * Creates the Web Mercator Spatial Reference System if it does not already
 * exist
 *
 *  @return web mercator srs
 */
-(GPKGSpatialReferenceSystem *) createWebMercator;

/**
 *  Get or Create the Spatial Reference System for the provided id
 *
 *  @param srsId srs id
 *
 *  @return srs
 */
-(GPKGSpatialReferenceSystem *) getOrCreateWithSrsId: (NSNumber*) srsId;

/**
 *  Delete the Spatial Reference System, cascading
 *
 *  @param srs srs
 *
 *  @return rows deleted
 */
-(int) deleteCascade: (GPKGSpatialReferenceSystem *) srs;

/**
 *  Delete the collection of Spatial Reference Systems, cascading
 *
 *  @param srsCollection srs array
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWithCollection: (NSArray *) srsCollection;

/**
 *  Delete the Spatial Reference System where, cascading
 *
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Delete the Spatial Reference System by id, cascading
 *
 *  @param id id
 *
 *  @return rows deleted
 */
-(int) deleteByIdCascade: (NSNumber *) id;

/**
 *  Delete Spatial Reference Systems by ids, cascading
 *
 *  @param idCollection id array
 *
 *  @return rows deleted
 */
-(int) deleteIdsCascade: (NSArray *) idCollection;

/**
 *  Get Contents referencing the SRS
 *
 *  @param srs srs
 *
 *  @return result set
 */
-(GPKGResultSet *) getContents: (GPKGSpatialReferenceSystem *) srs;

/**
 *  Get Geometry Columns referencing the SRS
 *
 *  @param srs srs
 *
 *  @return result set
 */
-(GPKGResultSet *) getGeometryColumns: (GPKGSpatialReferenceSystem *) srs;

/**
 *  Get Tile Matrix Sets referencing the SRS
 *
 *  @param srs srs
 *
 *  @return result set
 */
-(GPKGResultSet *) getTileMatrixSet: (GPKGSpatialReferenceSystem *) srs;

@end
