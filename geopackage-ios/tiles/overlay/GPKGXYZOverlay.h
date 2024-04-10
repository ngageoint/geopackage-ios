//
//  GPKXYZOverlay.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileDao.h"
#import "GPKGBoundedOverlay.h"
#import "GPKGTileRetriever.h"

/**
 * XYZ Overlay, assumes XYZ tiles
 */
@interface GPKGXYZOverlay : GPKGBoundedOverlay

/**
 *  Initialize
 *
 *  @param tileDao tile dao
 *
 *  @return new xyz overlay
 */
-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao;

/**
 *  Get the tile retriever
 *
 *  @return retriever
 */
-(NSObject<GPKGTileRetriever> *) retriever;

@end
