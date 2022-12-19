//
//  GPKGFeatureTableReader.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/27/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTableReader.h"
#import "GPKGFeatureTable.h"

/**
 *  Reads the metadata from an existing feature table
 */
@interface GPKGFeatureTableReader : GPKGUserTableReader

/**
 *  Geometry column name
 */
@property (nonatomic, strong) NSString *columnName;

/**
 *  Initialize
 *
 *  @param geometryColumns geometry columns
 *
 *  @return new feature table reader
 */
-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

/**
 *  Initialize
 *
 *  @param tableName          table name
 *  @param geometryColumnName geometry column name
 *
 *  @return new feature table reader
 */
-(instancetype) initWithTable: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumnName;

/**
 *  Initialize
 *
 *  @param tableName          table name
 *
 *  @return new feature table reader
 */
-(instancetype) initWithTable: (NSString *) tableName;

/**
 *  Read the feature table with the database connection
 *
 *  @param db database connection
 *
 *  @return feature table
 */
-(GPKGFeatureTable *) readFeatureTableWithConnection: (GPKGConnection *) db;

@end
