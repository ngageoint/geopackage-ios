//
//  GPKGTileScaling.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTileMatrixSet.h"
#import "GPKGTileScalingTypes.h"

/**
 *  Tile Scaling table constants
 */
extern NSString * const GPKG_TS_TABLE_NAME;
extern NSString * const GPKG_TS_COLUMN_PK;
extern NSString * const GPKG_TS_COLUMN_TABLE_NAME;
extern NSString * const GPKG_TS_COLUMN_SCALING_TYPE;
extern NSString * const GPKG_TS_COLUMN_ZOOM_IN;
extern NSString * const GPKG_TS_COLUMN_ZOOM_OUT;

@interface GPKGTileScaling : NSObject <NSMutableCopying>

/**
 *  Foreign key to table_name in gpkg_tile_matrix_set
 */
@property (nonatomic, strong) NSString *tableName;

/**
 * Tile Scaling behavior type
 */
@property (nonatomic, strong) NSString *scalingType;

/**
 * Max zoom levels in to search
 */
@property (nonatomic, strong) NSNumber *zoomIn;

/**
 * Max zoom levels out to search
 */
@property (nonatomic, strong) NSNumber *zoomOut;

/**
 *  Initialize
 *
 *  @return new tile scaling
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param tileMatrixSet tile matrix set
 *  @param scalingType scaling type
 *  @param zoomIn max zoom in levels
 *  @param zoomOut max zoom out levels
 *
 *  @return new tile scaling
 */
-(instancetype) initWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andScalingType: (enum GPKGTileScalingType) scalingType andZoomIn: (NSNumber *) zoomIn andZoomOut: (NSNumber *) zoomOut;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param scalingType scaling type
 *  @param zoomIn max zoom in levels
 *  @param zoomOut max zoom out levels
 *
 *  @return new tile scaling
 */
-(instancetype) initWithTableName: (NSString *) tableName andScalingType: (enum GPKGTileScalingType) scalingType andZoomIn: (NSNumber *) zoomIn andZoomOut: (NSNumber *) zoomOut;

/**
 *  Initialize
 *
 *  @param scalingType scaling type
 *  @param zoomIn max zoom in levels
 *  @param zoomOut max zoom out levels
 *
 *  @return new tile scaling
 */
-(instancetype) initWithScalingType: (enum GPKGTileScalingType) scalingType andZoomIn: (NSNumber *) zoomIn andZoomOut: (NSNumber *) zoomOut;

/**
 *  Set the tile matrix set
 *
 *  @param tileMatrixSet tile matrix set
 */
-(void) setTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Get the tile scaling type
 *
 *  @return tile scaling type
 */
-(enum GPKGTileScalingType) getTileScalingType;

/**
 *  Set the tile scaling type
 *
 *  @param scalingType tile scaling type
 */
-(void) setTileScalingType: (enum GPKGTileScalingType) scalingType;

/**
 *  Is zoom in tile search enabled
 *
 *  @return true if zoom in for tiles is allowed
 */
-(BOOL) isZoomIn;

/**
 *  Is zoom out tile search enabled
 *
 *  @return true if zoom out for tiles is allowed
 */
-(BOOL) isZoomOut;

@end
