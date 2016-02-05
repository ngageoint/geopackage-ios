//
//  GPKGStandardFormatOverlay.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "GPKGTileDao.h"
#import "GPKGBoundedOverlay.h"

/**
 * Standard Map Tile Overlay, assumes the Standard Maps API zoom level and z,x,y grid
 */
@interface GPKGStandardFormatOverlay : GPKGBoundedOverlay

/**
 *  Initialize
 *
 *  @param tileDao tile dao
 *
 *  @return new standard format overlay
 */
-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao;

@end
