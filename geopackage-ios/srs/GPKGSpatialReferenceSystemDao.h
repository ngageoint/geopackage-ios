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
 * Create the DAO
 *
 * @param database
 *            database connection
 * @return dao
 */
+(GPKGSpatialReferenceSystemDao *) createWithDatabase: (GPKGConnection *) database;

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new spatial reference system dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  CRS WKT Extension
 *
 *  @param crsWktExtension CRS WKT Extension
 */
-(void) setCrsWktExtension: (NSObject *) crsWktExtension;

/**
 *  Determine if the SRS table contains the extension definition 12 063
 *  column for CRS WKT
 *
 *  @return true if has extension
 */
-(BOOL) hasDefinition_12_063;

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
 * Creates the required EPSG WGS84 Geographical 3D Spatial Reference System
 *
 * @return spatial reference system
 */
-(GPKGSpatialReferenceSystem *) createWgs84Geographical3D;

/**
 *  Query to get the definition 12 063 value if the extension exists
 *
 *  @param srsId srs id
 *
 *  @return definition or null
 */
-(NSString *) definition_12_063WithSrsId: (NSNumber *) srsId;

/**
 *  Query and set the definition 12 063 in the srs object if the extension
 *  exists
 *
 *  @param srs spatial reference system
 */
-(void) setDefinition_12_063WithSrs: (GPKGSpatialReferenceSystem *) srs;

/**
 *  Query and set the definition 12 063 in the srs objects if the extension
 *  exists
 *
 *  @param srsArray spatial reference system array
 */
-(void) setDefinition_12_063WithSrsArray: (NSArray *) srsArray;

/**
 *  Update the definition 12 063 in the database if the extension exists
 *
 *  @param srsId      srs id
 *  @param definition definition
 */
-(void) updateDefinition_12_063WithSrsId: (NSNumber *) srsId andDefinition: (NSString *) definition;

/**
 *  Update the definition 12 063 in the database if the extension exists
 *
 *  @param srs      spatial reference system
 */
-(void) updateDefinition_12_063WithSrs: (GPKGSpatialReferenceSystem *) srs;

/**
 *  Get or Create the Spatial Reference System for the provided epsg
 *
 *  @param epsg epsg
 *
 *  @return srs
 */
-(GPKGSpatialReferenceSystem *) srsWithEpsg: (NSNumber*) epsg;

/**
 * Get or Create the Spatial Reference System for the provided organization
 * and id
 *
 * @param organization
 *            organization
 * @param coordsysId
 *            coordsys id
 *
 * @return srs
 */
-(GPKGSpatialReferenceSystem *) srsWithOrganization: (NSString *) organization andCoordsysId: (NSNumber *) coordsysId;

/**
 * Get or Create the Spatial Reference System from the projection
 *
 * @param projection
 *            projection
 *
 * @return srs
 */
-(GPKGSpatialReferenceSystem *) srsWithProjection: (SFPProjection *) projection;

/**
 *  Query for the organization coordsys id
 *
 *  @param organization
 *            organization
 *  @param coordsysId
 *            organization coordinate system id
 *
 *  @return srs
 */
-(GPKGSpatialReferenceSystem *) queryForOrganization: (NSString *) organization andCoordsysId: (NSNumber *) coordsysId;

/**
 *  Query for the projection
 *
 *  @param projection
 *            projection
 *
 *  @return srs
 */
-(GPKGSpatialReferenceSystem *) queryForProjection: (SFPProjection *) projection;

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
-(GPKGResultSet *) contents: (GPKGSpatialReferenceSystem *) srs;

/**
 *  Get Geometry Columns referencing the SRS
 *
 *  @param srs srs
 *
 *  @return result set
 */
-(GPKGResultSet *) geometryColumns: (GPKGSpatialReferenceSystem *) srs;

/**
 *  Get Tile Matrix Sets referencing the SRS
 *
 *  @param srs srs
 *
 *  @return result set
 */
-(GPKGResultSet *) tileMatrixSet: (GPKGSpatialReferenceSystem *) srs;

@end
