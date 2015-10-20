//
//  GPKGGeometryIndexDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGGeometryIndex.h"
#import "GPKGTableIndex.h"
#import "WKBGeometryEnvelope.h"

/**
 * Geometry Index Data Access Object
 */
@interface GPKGGeometryIndexDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new geometry index dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Get the Table Index of the Geometry Index
 *
 *  @param geometryIndex geometry index
 *
 *  @return table index
 */
-(GPKGTableIndex *) getTableIndex: (GPKGGeometryIndex *) geometryIndex;

/**
 *  Query by table name
 *
 *  @param tableName table name
 *
 *  @return geometry index results
 */
-(GPKGResultSet *) queryForTableName: (NSString *) tableName;

/**
 *  Count by table name
 *
 *  @param tableName table name
 *
 *  @return count
 */
-(int) countByTableName: (NSString *) tableName;

/**
 *  Populate a new geometry index from an envelope
 *
 *  @param tableIndex table index
 *  @param geomId     geometry id
 *  @param envelope   geometry envelope
 *
 *  @return geometry index
 */
-(GPKGGeometryIndex *) populateWithTableIndex: (GPKGTableIndex *) tableIndex andGeomId: (int) geomId andGeometryEnvelope: (WKBGeometryEnvelope *) envelope;

@end
