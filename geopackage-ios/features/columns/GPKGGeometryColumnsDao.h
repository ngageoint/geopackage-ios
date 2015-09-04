//
//  GPKGGeometryColumnsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"
#import "GPKGBaseDao.h"
#import "GPKGGeometryColumns.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGContents.h"

/**
 *  Geometry Columns Data Access Object
 */
@interface GPKGGeometryColumnsDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new geometry columns dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Query for the table name
 *
 *  @param tableName table name
 *
 *  @return geometry columns
 */
-(GPKGGeometryColumns *) queryForTableName: (NSString *) tableName;

/**
 *  Get the feature table names
 *
 *  @return feature tables
 */
-(NSArray *) getFeatureTables;

/**
 *  Get the Spatial Reference System of the Geometry Columns
 *
 *  @param geometryColumns geometry columns
 *
 *  @return srs
 */
-(GPKGSpatialReferenceSystem *) getSrs: (GPKGGeometryColumns *) geometryColumns;

/**
 *  Get the Contents of the Geometry Columns
 *
 *  @param geometryColumns geometry columns
 *
 *  @return contents
 */
-(GPKGContents *) getContents: (GPKGGeometryColumns *) geometryColumns;

@end
