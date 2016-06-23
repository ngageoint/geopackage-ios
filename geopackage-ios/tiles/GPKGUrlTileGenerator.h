//
//  GPKGUrlTileGenerator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileGenerator.h"

/**
 *  Creates a set of tiles within a GeoPackage by downloading the tiles from a URL
 */
@interface GPKGUrlTileGenerator : GPKGTileGenerator

/**
 *  TMS URL flag, when true x,y,z converted to TMS when requesting the tile
 */
@property (nonatomic) BOOL tms;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tableName  table name
 *  @param tileUrl    tile URL
 *  @param minZoom    min zoom
 *  @param maxZoom    max zoom
 *  @param boundingBox tiles bounding box
 *  @param projection tiles projection
 *
 *  @return new url tile generator
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andTileUrl: (NSString *) tileUrl andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection;

@end
