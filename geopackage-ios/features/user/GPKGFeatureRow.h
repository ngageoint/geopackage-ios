//
//  GPKGFeatureRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserRow.h"
#import "GPKGFeatureTable.h"
#import "GPKGGeometryData.h"

/**
 *  Feature Row containing the values from a single result set row
 */
@interface GPKGFeatureRow : GPKGUserRow

/**
 *  Feature Table
 */
@property (nonatomic, strong) GPKGFeatureTable *featureTable;

/**
 *  Initialize
 *
 *  @param table       feature table
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return new feature row
 */
-(instancetype) initWithFeatureTable: (GPKGFeatureTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table feature table
 *
 *  @return new feature row
 */
-(instancetype) initWithFeatureTable: (GPKGFeatureTable *) table;

/**
 *  Get the geometry column index
 *
 *  @return geometry column index
 */
-(int) getGeometryColumnIndex;

/**
 *  Get the geometry column
 *
 *  @return geometry feature column
 */
-(GPKGFeatureColumn *) getGeometryColumn;

/**
 *  Get the geometry
 *
 *  @return geometry data
 */
-(GPKGGeometryData *) getGeometry;

/**
 *  Set the geometry
 *
 *  @param geometryData geometry data
 */
-(void) setGeometry: (GPKGGeometryData *) geometryData;

@end
