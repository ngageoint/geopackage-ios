//
//  GPKGElevationTilesTiff.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/29/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTilesCore.h"

@interface GPKGElevationTilesTiff : GPKGElevationTilesCore

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileDao tile dao
 *  @param width specified results width
 *  @param height specified results height
 *  @param requestProjection request projection
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (GPKGProjection *) requestProjection;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileDao tile dao
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileDao tile dao
 *  @param requestProjection request projection
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andProjection: (GPKGProjection *) requestProjection;

@end
