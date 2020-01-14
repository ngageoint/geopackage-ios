//
//  GPKGGeoPackageTileRetriever.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTileRetriever.h"
#import "GPKGTileDao.h"
#import "GPKGTileScaling.h"

/**
 *  GeoPackage Tile Retriever, assumes the Standard Maps API zoom level and z,x,y grid
 */
@interface GPKGGeoPackageTileRetriever : NSObject<GPKGTileRetriever>

/**
 *  Initializer
 *
 *  @param tileDao tile dao
 *
 *  @return new instance
 */
-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao;

/**
 *  Initializer
 *
 *  @param tileDao tile dao
 *  @param width   tile width
 *  @param height  tile height
 *
 *  @return new instance
 */
-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height;

/**
 *  Get the web mercator bounding box
 *
 *  @return web mercator bounding box
 */
-(GPKGBoundingBox *) webMercatorBoundingBox;

/**
 * Get the Tile Scaling options
 *
 * @return tile scaling options
 */
-(GPKGTileScaling *) scaling;

/**
 * Set the Tile Scaling options
 *
 * @param scaling tile scaling options
 */
-(void) setScaling: (GPKGTileScaling *) scaling;

@end
