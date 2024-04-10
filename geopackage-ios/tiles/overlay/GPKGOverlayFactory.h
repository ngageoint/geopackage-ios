//
//  GPKGOverlayFactory.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileScaling.h"
#import "GPKGCompositeOverlay.h"
#import "GPKGFeatureOverlay.h"

/**
 *  Get a tile provider for the Tile DAO
 */
@interface GPKGOverlayFactory : NSObject

/**
 *  Get a Tile Overlay for the Tile DAO
 *
 *  @param tileDao tile dao
 *
 *  @return tile overlay
 */
+(MKTileOverlay *) tileOverlayWithTileDao: (GPKGTileDao *) tileDao;

/**
 *  Get a Tile Overlay for the Tile DAO
 *
 *  @param tileDao tile dao
 *  @param scaling tile scaling
 *
 *  @return tile overlay
 */
+(MKTileOverlay *) tileOverlayWithTileDao: (GPKGTileDao *) tileDao andScaling: (GPKGTileScaling *) scaling;

/**
 *  Get a Bounded Overlay Tile Provider for the Tile DAO
 *
 *  @param tileDao tile dao
 *
 *  @return bounded overlay
 */
+(GPKGBoundedOverlay *) boundedOverlay: (GPKGTileDao *) tileDao;

/**
 *  Get a Bounded Overlay Tile Provider for the Tile DAO
 *
 *  @param tileDao tile dao
 *  @param scaling tile scaling
 *
 *  @return bounded overlay
 */
+(GPKGBoundedOverlay *) boundedOverlay: (GPKGTileDao *) tileDao andScaling: (GPKGTileScaling *) scaling;

/**
 * Create a composite overlay by first adding a tile overlay for the tile DAO followed by the provided overlay
 *
 * @param tileDao tile dao
 * @param overlay bounded overlay
 * @return composite overlay
 */
+(GPKGCompositeOverlay *) compositeOverlayWithTileDao: (GPKGTileDao *) tileDao andOverlay: (GPKGBoundedOverlay *) overlay;

/**
 * Create a composite overlay by first adding tile overlays for the tile DAOs followed by the provided overlay
 *
 * @param tileDaos array of tile daos
 * @param overlay  bounded overlay
 * @return composite overlay
 */
+(GPKGCompositeOverlay *) compositeOverlayWithTileDaos: (NSArray<GPKGTileDao *> *) tileDaos andOverlay: (GPKGBoundedOverlay *) overlay;

/**
 * Create a composite overlay by adding tile overlays for the tile DAOs
 *
 * @param tileDaos array of tile daos
 * @return composite overlay
 */
+(GPKGCompositeOverlay *) compositeOverlayWithTileDaos: (NSArray<GPKGTileDao *> *) tileDaos;

/**
 * Create a composite overlay linking the feature overly with
 *
 * @param featureOverlay feature overlay
 * @param geoPackage     GeoPackage
 * @return linked bounded overlay
 */
+(GPKGBoundedOverlay *) linkedFeatureOverlayWithOverlay: (GPKGFeatureOverlay *) featureOverlay andGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get a Tile Overlay for the tile or feature table
 *
 *  @param geoPackage GeoPackage
 *  @param table tile or feature table
 *
 *  @return tile overlay
 */
+(MKTileOverlay *) tileOverlayWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) table;

/**
 *  Get a Bounded Overlay Tile Provider for the tile or feature table
 *
 *  @param geoPackage GeoPackage
 *  @param table tile or feature table
 *
 *  @return tile overlay
 */
+(GPKGBoundedOverlay *) boundedOverlayWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) table;

/**
 *  Get a Tile Overlay for the tile or feature DAO
 *
 *  @param geoPackage GeoPackage
 *  @param userDao user DAO
 *
 *  @return tile overlay
 */
+(MKTileOverlay *) tileOverlayWithGeoPackage: (GPKGGeoPackage *) geoPackage andUserDao: (GPKGUserDao *) userDao;

/**
 *  Get a Bounded Overlay Tile Provider for the tile or feature DAO
 *
 *  @param geoPackage GeoPackage
 *  @param userDao user DAO
 *
 *  @return tile overlay
 */
+(GPKGBoundedOverlay *) boundedOverlayWithGeoPackage: (GPKGGeoPackage *) geoPackage andUserDao: (GPKGUserDao *) userDao;

@end
