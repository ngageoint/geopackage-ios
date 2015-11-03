//
//  GPKGGeometryIndex.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTableIndex.h"

/**
 *  Geometry Index table constants
 */
extern NSString * const GPKG_GI_TABLE_NAME;
extern NSString * const GPKG_GI_COLUMN_PK1;
extern NSString * const GPKG_GI_COLUMN_PK2;
extern NSString * const GPKG_GI_COLUMN_TABLE_NAME;
extern NSString * const GPKG_GI_COLUMN_GEOM_ID;
extern NSString * const GPKG_GI_COLUMN_MIN_X;
extern NSString * const GPKG_GI_COLUMN_MAX_X;
extern NSString * const GPKG_GI_COLUMN_MIN_Y;
extern NSString * const GPKG_GI_COLUMN_MAX_Y;
extern NSString * const GPKG_GI_COLUMN_MIN_Z;
extern NSString * const GPKG_GI_COLUMN_MAX_Z;
extern NSString * const GPKG_GI_COLUMN_MIN_M;
extern NSString * const GPKG_GI_COLUMN_MAX_M;

/**
 * Geometry Index object, for indexing geometries within user feature tables
 */
@interface GPKGGeometryIndex : NSObject

/**
 *  Name of the table
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  Geometry Id column
 */
@property (nonatomic, strong) NSNumber *geomId;

/**
 *  Min X
 */
@property (nonatomic, strong) NSDecimalNumber *minX;

/**
 *  Max X
 */
@property (nonatomic, strong) NSDecimalNumber *maxX;

/**
 *  Min Y
 */
@property (nonatomic, strong) NSDecimalNumber *minY;

/**
 *  Max Y
 */
@property (nonatomic, strong) NSDecimalNumber *maxY;

/**
 *  Min Z
 */
@property (nonatomic, strong) NSDecimalNumber *minZ;

/**
 *  Max Z
 */
@property (nonatomic, strong) NSDecimalNumber *maxZ;

/**
 *  Min M
 */
@property (nonatomic, strong) NSDecimalNumber *minM;

/**
 *  Max M
 */
@property (nonatomic, strong) NSDecimalNumber *maxM;

/**
 *  Set the Table Index
 *
 *  @param tableIndex table index
 */
-(void) setTableIndex: (GPKGTableIndex *) tableIndex;

@end
