//
//  GPKGFeatureDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGGeometryColumns.h"
#import "GPKGFeatureRow.h"
#import "WKBGeometryTypes.h"
#import "GPKGMetadataDb.h"

/**
 *  Feature DAO for reading feature user data tables
 */
@interface GPKGFeatureDao : GPKGUserDao

/**
 *  Geometry Columns
 */
@property (nonatomic, strong) GPKGGeometryColumns * geometryColumns;

/**
 *  Metadata db
 */
@property (nonatomic, strong)  GPKGMetadataDb * metadataDb;

/**
 *  Initialize
 *
 *  @param database        database connection
 *  @param table           feature table
 *  @param geometryColumns geometry columns
 *
 *  @return new feature dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGFeatureTable *) table andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andMetadataDb: (GPKGMetadataDb *) metadataDb;

/**
 *  Get the feature table
 *
 *  @return feature table
 */
-(GPKGFeatureTable *) getFeatureTable;

/**
 *  Get the feature row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return feature row
 */
-(GPKGFeatureRow *) getFeatureRow: (GPKGResultSet *) results;

/**
 *  Create a new feature row with the column types and values
 *
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return feature row as user row
 */
-(GPKGUserRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Create a new feature row
 *
 *  @return feature row
 */
-(GPKGFeatureRow *) newRow;

/**
 *  Get the geometry column name
 *
 *  @return geometry column name
 */
-(NSString *) getGeometryColumnName;

/**
 *  Get the geometry type
 *
 *  @return geometry type
 */
-(enum WKBGeometryType) getGeometryType;

@end
