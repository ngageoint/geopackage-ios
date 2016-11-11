//
//  GPKGGriddedCoverage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTileMatrixSet.h"
#import "GPKGGriddedCoverageDataTypes.h"

/**
 *  Gridded Coverage table constants
 */
extern NSString * const GPKG_EGC_TABLE_NAME;
extern NSString * const GPKG_EGC_COLUMN_PK;
extern NSString * const GPKG_EGC_COLUMN_ID;
extern NSString * const GPKG_EGC_COLUMN_TILE_MATRIX_SET_NAME;
extern NSString * const GPKG_EGC_COLUMN_DATATYPE;
extern NSString * const GPKG_EGC_COLUMN_SCALE;
extern NSString * const GPKG_EGC_COLUMN_OFFSET;
extern NSString * const GPKG_EGC_COLUMN_PRECISION;
extern NSString * const GPKG_EGC_COLUMN_DATA_NULL;

/**
 * Gridded Coverage object
 */
@interface GPKGGriddedCoverage : NSObject

/**
 *  Auto increment primary key
 */
@property (nonatomic, strong) NSNumber *id;

/**
 * Foreign key to table_name in gpkg_tile_matrix_set
 */
@property (nonatomic, strong) NSString *tileMatrixSetName;

/**
 *  'integer' or 'float'
 */
@property (nonatomic, strong) NSString *datatype;

/**
 *  Scale as a multiple relative to the unit of measure
 */
@property (nonatomic, strong) NSDecimalNumber *scale;

/**
 * The offset to the 0 value
 */
@property (nonatomic, strong) NSDecimalNumber *offset;

/**
 *  The smallest value that has meaning for this dataset
 */
@property (nonatomic, strong) NSDecimalNumber *precision;

/**
 *  The value that indicates NULL
 */
@property (nonatomic, strong) NSDecimalNumber *dataNull;

/**
 *  Set the tile matrix set
 *
 *  @param tileMatrixSet tile matrix set
 */
-(void) setTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Get the data type
 *
 *  @return data type
 */
-(enum GPKGGriddedCoverageDataType) getGriddedCoverageDataType;

/**
 *  Set the data type
 *
 *  @param dataType data type
 */
-(void) setGriddedCoverageDataType: (enum GPKGGriddedCoverageDataType) dataType;

/**
 *  Get the scale or default value
 *
 *  @return scale as a multiple relative to the unit of measure
 */
-(double) getScaleOrDefault;

/**
 *  Get the offset or default value
 *
 *  @return offset to the 0 value
 */
-(double) getOffsetOrDefault;

/**
 *  Get the precision or default value
 *
 *  @return smallest value that has meaning for this dataset
 */
-(double) getPrecisionOrDefault;

@end
