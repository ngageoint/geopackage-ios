//
//  GPKGFeatureTableReader.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/27/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTableReader.h"
#import "GPKGGeometryColumns.h"
#import "GPKGFeatureTable.h"

/**
 *  Reads the metadata from an existing feature table
 */
@interface GPKGFeatureTableReader : GPKGUserTableReader

/**
 *  Geometry Columns
 */
@property (nonatomic, strong) GPKGGeometryColumns * geometryColumns;

/**
 *  Initialize
 *
 *  @param geometryColumns geometry columns
 *
 *  @return new feature table reader
 */
-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

/**
 *  Read the feature table with the database connection
 *
 *  @param db database connection
 *
 *  @return feature table
 */
-(GPKGFeatureTable *) readFeatureTableWithConnection: (GPKGConnection *) db;

@end
