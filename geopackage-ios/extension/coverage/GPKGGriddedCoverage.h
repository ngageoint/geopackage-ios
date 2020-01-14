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
#import "GPKGGriddedCoverageEncodingTypes.h"

/**
 *  Gridded Coverage table constants
 */
extern NSString * const GPKG_CDGC_TABLE_NAME;
extern NSString * const GPKG_CDGC_COLUMN_PK;
extern NSString * const GPKG_CDGC_COLUMN_ID;
extern NSString * const GPKG_CDGC_COLUMN_TILE_MATRIX_SET_NAME;
extern NSString * const GPKG_CDGC_COLUMN_DATATYPE;
extern NSString * const GPKG_CDGC_COLUMN_SCALE;
extern NSString * const GPKG_CDGC_COLUMN_OFFSET;
extern NSString * const GPKG_CDGC_COLUMN_PRECISION;
extern NSString * const GPKG_CDGC_COLUMN_DATA_NULL;
extern NSString * const GPKG_CDGC_COLUMN_GRID_CELL_ENCODING;
extern NSString * const GPKG_CDGC_COLUMN_UOM;
extern NSString * const GPKG_CDGC_COLUMN_FIELD_NAME;
extern NSString * const GPKG_CDGC_COLUMN_QUANTITY_DEFINITION;

/**
 * Gridded Coverage object
 */
@interface GPKGGriddedCoverage : NSObject <NSMutableCopying>

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
 * Specifies how a value is assigned to a grid cell (pixel)
 */
@property (nonatomic, strong) NSString *gridCellEncoding;

/**
 * Units of Measure for values in the grid coverage
 */
@property (nonatomic, strong) NSString *uom;

/**
 * Type of Gridded Coverage Data (default is Height)
 */
@property (nonatomic, strong) NSString *fieldName;

/**
 * Description of the values contained in the Gridded Coverage
 */
@property (nonatomic, strong) NSString *quantityDefinition;

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
-(enum GPKGGriddedCoverageDataType) griddedCoverageDataType;

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
-(double) scaleOrDefault;

/**
 *  Get the offset or default value
 *
 *  @return offset to the 0 value
 */
-(double) offsetOrDefault;

/**
 *  Get the precision or default value
 *
 *  @return smallest value that has meaning for this dataset
 */
-(double) precisionOrDefault;

/**
 *  Get the encoding type
 *
 *  @return encoding type
 */
-(enum GPKGGriddedCoverageEncodingType) gridCellEncodingType;

/**
 *  Set the encoding type
 *
 *  @param encodingType encoding type
 */
-(void) setGridCellEncodingType: (enum GPKGGriddedCoverageEncodingType) encodingType;

@end
