//
//  GPKGGeoPackageTile.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  GeoPackage tile wrapper containing tile dimensions and raw image data
 */
@interface GPKGGeoPackageTile : NSObject

/**
 *  Tile width
 */
@property (nonatomic) int width;

/**
 *  Tile height
 */
@property (nonatomic) int height;

/**
 *  Image data
 */
@property (nonatomic, strong) NSData *data;

/**
 *  Initialize
 *
 *  @param width    tile width
 *  @param height   tile height
 *  @param tileData tile data
 *
 *  @return new instance
 */
-(instancetype) initWithWidth: (int) width andHeight: (int) height andData: (NSData *) tileData;

@end
