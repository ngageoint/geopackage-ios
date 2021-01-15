//
//  GPKGTileReprojection.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"
#import "GPKGTileReprojectionZoom.h"
#import "GPKGTileReprojectionOptimize.h"
#import "GPKGProgress.h"

/**
 *  Delta for comparisons between same pixel sizes
 */
static double pixelSizeDelta = .00000000001;

/**
 *  Tile Reprojection for reprojecting an existing tile table
 */
@interface GPKGTileReprojection : NSObject

/**
 *  Optional optimization
 */
@property (nonatomic, strong) GPKGTileReprojectionOptimize *optimize;

/**
 *  Overwrite existing tiles at a zoom level when geographic calculations differ
 */
@property (nonatomic) BOOL overwrite;

/**
 *  Tile width in pixels
 */
@property (nonatomic, strong) NSNumber *tileWidth;

/**
 *  Tile height in pixels
 */
@property (nonatomic, strong) NSNumber *tileHeight;

/**
 *  Progress callbacks
 */
@property (nonatomic, strong) NSObject<GPKGProgress> *progress;

/**
 *  Create a Reprojection from a GeoPackage tile table, replacing the existing tiles
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param projection desired projection
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 *  Create a Reprojection from a GeoPackage tile table to a new tile table within the GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectTable new reprojected tile table
 *  @param projection desired projection
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTable: (NSString *) reprojectTable inProjection: (SFPProjection *) projection;

/**
 *  Create a Reprojection from a GeoPackage tile table to a new tile table in a specified GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectGeoPackage GeoPackage for reprojected tile table
 *  @param reprojectTable new reprojected tile table
 *  @param projection desired projection
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTable: (NSString *) reprojectTable inProjection: (SFPProjection *) projection;

/**
 *  Create a Reprojection from a tile table to a new tile table in a specified GeoPackage
 *
 *  @param tileDao tile DAO
 *  @param geoPackage GeoPackage for reprojected tile table
 *  @param table new reprojected tile table
 *  @param projection desired projection
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 *  Create a Reprojection from a GeoPackage tile table to a new tile table
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectTileDao reprojection tile DAO
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTileDao: (GPKGTileDao *) reprojectTileDao;

/**
 *  Create a Reprojection from a GeoPackage tile table to a new tile table
 *
 *  @param tileDao tile DAO
 *  @param reprojectTileDao reprojection tile DAO
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toTileDao: (GPKGTileDao *) reprojectTileDao;

/**
 *  Create a Reprojection from a GeoPackage tile table, replacing the existing tiles
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param optimize desired optimization
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andOptimize: (GPKGTileReprojectionOptimize *) optimize;

/**
 *  Create a Reprojection from a GeoPackage tile table to a new tile table within the GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectTable new reprojected tile table
 *  @param optimize desired optimization
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTable: (NSString *) reprojectTable andOptimize: (GPKGTileReprojectionOptimize *) optimize;

/**
 *  Create a Reprojection from a GeoPackage tile table to a new tile table in a specified GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectGeoPackage GeoPackage for reprojected tile table
 *  @param reprojectTable new reprojected tile table
 *  @param optimize desired optimization
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTable: (NSString *) reprojectTable andOptimize: (GPKGTileReprojectionOptimize *) optimize;

/**
 *  Create a Reprojection from a tile table to a new tile table in a specified GeoPackage
 *
 *  @param tileDao tile DAO
 *  @param geoPackage GeoPackage for reprojected tile table
 *  @param table new reprojected tile table
 *  @param optimize desired optimization
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andOptimize: (GPKGTileReprojectionOptimize *) optimize;

/**
 *  Reproject a GeoPackage tile table, replacing the existing tiles
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param projection desired projection
 *  @return created tiles
 */
+(int) reprojectGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 *  Reproject a GeoPackage tile table to a new tile table within the GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectTable new reprojected tile table
 *  @param projection desired projection
 *  @return created tiles
 */
+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTable: (NSString *) reprojectTable inProjection: (SFPProjection *) projection;

/**
 *  Reproject a GeoPackage tile table to a new tile table in a specified GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectGeoPackage GeoPackage for reprojected tile table
 *  @param reprojectTable new reprojected tile table
 *  @param projection desired projection
 *  @return created tiles
 */
+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTable: (NSString *) reprojectTable inProjection: (SFPProjection *) projection;

/**
 *  Reproject a tile table to a new tile table in a specified GeoPackage
 *
 *  @param tileDao tile DAO
 *  @param geoPackage GeoPackage for reprojected tile table
 *  @param table new reprojected tile table
 *  @param projection desired projection
 *  @return created tiles
 */
+(int) reprojectFromTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 *  Reproject a GeoPackage tile table to a new tile table
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectTileDao reprojection tile DAO
 *  @return created tiles
 */
+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTileDao: (GPKGTileDao *) reprojectTileDao;

/**
 *  Reproject a GeoPackage tile table to a new tile table
 *
 *  @param tileDao tile DAO
 *  @param reprojectTileDao reprojection tile DAO
 *  @return created tiles
 */
+(int) reprojectFromTileDao: (GPKGTileDao *) tileDao toTileDao: (GPKGTileDao *) reprojectTileDao;

/**
 *  Reproject a GeoPackage tile table, replacing the existing tiles
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param optimize desired optimization
 *  @return created tiles
 */
+(int) reprojectGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andOptimize: (GPKGTileReprojectionOptimize *) optimize;

/**
 *  Reproject a GeoPackage tile table to a new tile table within the GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectTable new reprojected tile table
 *  @param optimize desired optimization
 *  @return created tiles
 */
+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTable: (NSString *) reprojectTable andOptimize: (GPKGTileReprojectionOptimize *) optimize;

/**
 *  Reproject a GeoPackage tile table to a new tile table in a specified GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectGeoPackage GeoPackage for reprojected tile table
 *  @param reprojectTable new reprojected tile table
 *  @param optimize desired optimization
 *  @return created tiles
 */
+(int) reprojectFromGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toGeoPackage: (GPKGGeoPackage *) reprojectGeoPackage andTable: (NSString *) reprojectTable andOptimize: (GPKGTileReprojectionOptimize *) optimize;

/**
 *  Reproject a tile table to a new tile table in a specified GeoPackage
 *
 *  @param tileDao tile DAO
 *  @param geoPackage GeoPackage for reprojected tile table
 *  @param table new reprojected tile table
 *  @param optimize desired optimization
 *  @return created tiles
 */
+(int) reprojectFromTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andOptimize: (GPKGTileReprojectionOptimize *) optimize;

/**
 *  Initialize, reproject a tile table to a new tile table in a specified GeoPackage
 *
 *  @param tileDao tile DAO
 *  @param geoPackage GeoPackage for reprojected tile table
 *  @param table new reprojected tile table
 *  @param projection desired projection
 *  @return tile reprojection
 */
-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 *  Initialize, reproject a GeoPackage tile table to a new tile table
 *
 *  @param tileDao tile DAO
 *  @param reprojectTileDao reprojection tile DAO
 *  @return tile reprojection
 */
-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao toTileDao: (GPKGTileDao *) reprojectTileDao;

/**
 *  Get the zoom level configurations
 *
 *  @return zoom configs
 */
-(NSMutableDictionary<NSNumber *,GPKGTileReprojectionZoom *> *) zoomConfigs;

/**
 *  Get the zoom level configuration for a zoom level
 *
 *  @param zoom from zoom level
 *  @return zoom config
 */
-(GPKGTileReprojectionZoom *) configForZoom: (int) zoom;

/**
 *  Get the zoom level configuration or create new configuration for a zoom level
 *
 *  @param zoom from zoom level
 *  @return zoom config
 */
-(GPKGTileReprojectionZoom *) configOrCreateForZoom: (int) zoom;

/**
 *  Set a zoom level configuration for a zoom level
 *
 *  @param config zoom configuration
 *  @param zoom zoom level
 */
-(void) setConfig: (GPKGTileReprojectionZoom *) config forZoom: (int) zoom;

/**
 *  Set a reprojected to zoom level for a zoom level
 *
 *  @param toZoom reprojected zoom level
 *  @param zoom zoom level
 */
-(void) setToZoom: (int) toZoom forZoom: (int) zoom;

/**
 *  Get a reprojected to zoom level from a zoom level, defaults as the zoom level if not set
 *
 *  @param zoom zoom level
 *  @return reprojected to zoom level
 */
-(int) toZoomForZoom: (int) zoom;

/**
 *  Set a reprojected tile width for a zoom level
 *
 *  @param tileWidth reprojected tile width
 *  @param zoom zoom level
 */
-(void) setTileWidth: (int) tileWidth forZoom: (int) zoom;

/**
 *  Get a reprojected tile width from a zoom level
 *
 *  @param zoom zoom level
 *  @return reprojected tile width
 */
-(NSNumber *) tileWidthForZoom: (int) zoom;

/**
 *  Set a reprojected tile height for a zoom level
 *
 *  @param tileHeight reprojected tile height
 *  @param zoom zoom level
 */
-(void) setTileHeight: (int) tileHeight forZoom: (int) zoom;

/**
 *  Get a reprojected tile height from a zoom level
 *
 *  @param zoom zoom level
 *  @return reprojected tile height
 */
-(NSNumber *) tileHeightForZoom: (int) zoom;

/**
 *  Set a reprojected matrix width for a zoom level
 *
 *  @param matrixWidth reprojected matrix width
 *  @param zoom zoom level
 */
-(void) setMatrixWidth: (int) matrixWidth forZoom: (int) zoom;

/**
 *  Get a reprojected matrix width from a zoom level
 *
 *  @param zoom zoom level
 *  @return reprojected matrix width
 */
-(NSNumber *) matrixWidthForZoom: (int) zoom;

/**
 *  Set a reprojected matrix height for a zoom level
 *
 *  @param matrixHeight reprojected matrix height
 *  @param zoom zoom level
 */
-(void) setMatrixHeight: (int) matrixHeight forZoom: (int) zoom;

/**
 *  Get a reprojected matrix height from a zoom level
 *
 *  @param zoom zoom level
 *  @return reprojected matrix height
 */
-(NSNumber *) matrixHeightForZoom: (int) zoom;

/**
 *  Reproject the tile table
 *
 *  @return created tiles
 */
-(int) reproject;

/**
 *  Reproject the tile table within the zoom range
 *
 *  @param minZoom min zoom
 *  @param maxZoom max zoom
 *  @return created tiles
 */
-(int) reprojectWithMinZoom: (int) minZoom andMaxZoom: (int) maxZoom;

/**
 *  Reproject the tile table for the zoom levels, ordered numerically lowest to highest
 *
 *  @param zooms zoom levels, ordered lowest to highest
 *  @return created tiles
 */
-(int) reprojectWithZooms: (NSArray<NSNumber *> *) zooms;

/**
 *  Reproject the tile table for the zoom level
 *
 *  @param zoom zoom level
 *  @return created tiles
 */
-(int) reprojectWithZoom: (int) zoom;

@end
