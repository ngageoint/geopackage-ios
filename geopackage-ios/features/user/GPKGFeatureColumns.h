//
//  GPKGFeatureColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserColumns.h"
#import "GPKGFeatureColumn.h"

/**
 * Collection of feature columns
 */
@interface GPKGFeatureColumns : GPKGUserColumns

/**
 *  Geometry column name
 */
@property (nonatomic, strong) NSString *geometryColumnName;

/**
 *  Geometry column index
 */
@property (nonatomic) int geometryIndex;

/**
 *  Initialize
 *
 *  @param tableName            table name
 *  @param geometryColumn geometry column
 *  @param columns                 columns
 *
 *  @return new feature columns
 */
-(instancetype) initWithTable: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumn andColumns: (NSArray *) columns;

/**
 *  Initialize
 *
 *  @param tableName            table name
 *  @param geometryColumn geometry column
 *  @param columns                 columns
 *  @param custom                   custom column specification
 *
 *  @return new feature columns
 */
-(instancetype) initWithTable: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumn andColumns: (NSArray *) columns andCustom: (BOOL) custom;

/**
 * Initialize
 *
 * @param featureColumns
 *            feature columns
 *
 *  @return new feature columns
 */
-(instancetype) initWithFeatureColumns: (GPKGFeatureColumns *) featureColumns;

/**
 * Check if the table has a geometry column
 *
 * @return true if has a geometry column
 */
-(BOOL) hasGeometryColumn;

/**
 *  Get the geometry feature column
 *
 *  @return geometry feature column
 */
-(GPKGFeatureColumn *) geometryColumn;

@end
