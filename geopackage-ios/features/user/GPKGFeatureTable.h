//
//  GPKGFeatureTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTable.h"
#import "GPKGFeatureColumn.h"
#import "GPKGGeometryColumns.h"

/**
 *  Represents a user feature table
 */
@interface GPKGFeatureTable : GPKGUserTable

/**
 *  Geometry column index
 */
@property (nonatomic) int geometryIndex;

/**
 *  Initialize
 *
 *  @param geometryColumns geometry columns
 *  @param columns         feature columns
 *
 *  @return new feature table
 */
-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andColumns: (NSArray *) columns;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns   feature columns
 *
 *  @return new feature table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

/**
 *  Initialize
 *
 *  @param tableName      table name
 *  @param geometryColumn geometry column
 *  @param columns        feature columns
 *
 *  @return new feature table
 */
-(instancetype) initWithTable: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumn andColumns: (NSArray *) columns;

/**
 *  Get the geometry feature column
 *
 *  @return geometry feature column
 */
-(GPKGFeatureColumn *) getGeometryColumn;

@end
