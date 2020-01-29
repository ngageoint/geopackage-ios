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
 *  @param columns   columns
 *  @param values      values
 *
 *  @return new feature row
 */
-(instancetype) initWithFeatureTable: (GPKGFeatureTable *) table andColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values;

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
-(int) geometryColumnIndex;

/**
 *  Get the geometry column
 *
 *  @return geometry feature column
 */
-(GPKGFeatureColumn *) geometryColumn;

/**
 *  Get the geometry
 *
 *  @return geometry data
 */
-(GPKGGeometryData *) geometry;

/**
 *  Set the geometry
 *
 *  @param geometryData geometry data
 */
-(void) setGeometry: (GPKGGeometryData *) geometryData;

/**
 *  Get the simple features geometry value
 *
 *  @return geometry
 */
-(SFGeometry *) geometryValue;

/**
 * Get the simple features geometry type
 *
 * @return geometry type
 */
-(enum SFGeometryType) geometryType;

/**
 *  Get the geometry envelope
 *
 *  @return geometry envelope
 */
-(SFGeometryEnvelope *) geometryEnvelope;

@end
