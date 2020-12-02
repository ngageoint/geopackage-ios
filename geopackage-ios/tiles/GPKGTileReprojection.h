//
//  GPKGTileReprojection.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

/**
 *  Tile Reprojection for reprojecting an existing tile table
 */
@interface GPKGTileReprojection : NSObject

/**
 *  Optimize tile bounds
 */
@property (nonatomic) BOOL optimize;

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
 *  Reproject a GeoPackage tile table, replacing the existing tiles
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param projection desired projection
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 *  Reproject a GeoPackage tile table to a new tile table within the GeoPackage
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectTable new reprojected tile table
 *  @param projection desired projection
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTable: (NSString *) reprojectTable inProjection: (SFPProjection *) projection;

/**
 *  Reproject a GeoPackage tile table to a new tile table in a specified GeoPackage
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
 *  Reproject a tile table to a new tile table in a specified GeoPackage
 *
 *  @param tileDao tile DAO
 *  @param geoPackage GeoPackage for reprojected tile table
 *  @param table new reprojected tile table
 *  @param projection desired projection
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 *  Reproject a GeoPackage tile table to a new tile table
 *
 *  @param geoPackage GeoPackage
 *  @param table tile table
 *  @param reprojectTileDao reprojection tile DAO
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table toTileDao: (GPKGTileDao *) reprojectTileDao;

/**
 *  Reproject a GeoPackage tile table to a new tile table
 *
 *  @param tileDao tile DAO
 *  @param reprojectTileDao reprojection tile DAO
 *  @return tile reprojection
 */
+(GPKGTileReprojection *) createWithTileDao: (GPKGTileDao *) tileDao toTileDao: (GPKGTileDao *) reprojectTileDao;

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
 *  Get the zoom level mapping between zoom levels and reprojected zoom levels, defaults as empty
 *
 *  @return zoom map
 */
-(NSDictionary<NSNumber *,NSNumber *> *) zoomMap;

/**
 *  Set the zoom level mapping between zoom levels and reprojected zoom levels
 *
 *  @param zoomMap zoom map
 */
-(void) setZoomMap: (NSDictionary<NSNumber *,NSNumber *> *) zoomMap;

/**
 *  Set a zoom level mapping between a zoom level and a reprojected zoom level
 *
 *  @param fromZoom from zoom level
 *  @param toZoom to reprojected zoom level
 */
-(void) mapFromZoom: (int) fromZoom toZoom: (int) toZoom;

/**
 *  Get a reprojected zoom level from a zoom level, defaults as the zoom level if not mapped
 *
 *  @param fromZoom from zoom level
 *  @return reprojected zoom level
 */
-(int) zoomFromZoom: (int) fromZoom;

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
 *  Reproject the tile table for the zoom levels
 *
 *  @param zooms zoom levels
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
