//
//  GPKGStandardFormatTileRetriever.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTileRetriever.h"
#import "GPKGTileDao.h"

/**
 *  GeoPackage Tile Retriever, assumes the Standard Maps API zoom level and z,x,y grid
 */
@interface GPKGStandardFormatTileRetriever : NSObject<GPKGTileRetriever>

/**
 *  Initializer
 *
 *  @param tileDao tile DAO
 *
 *  @return new instance
 */
-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao;

@end
