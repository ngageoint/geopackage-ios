//
//  GPKGOverlayFactory.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "GPKGTileDao.h"
#import "GPKGBoundedOverlay.h"

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
+(MKTileOverlay *) getTileOverlayWithTileDao: (GPKGTileDao *) tileDao;

/**
 *  Get a Bounded Overlay Tile Provider for the Tile DAO
 *
 *  @param tileDao tile dao
 *
 *  @return bounded overlay
 */
+(GPKGBoundedOverlay *) getBoundedOverlay: (GPKGTileDao *) tileDao;

@end
