//
//  GPKGTileReprojectionZoom.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/4/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Optional Tile Reprojection configuration for a zoom level
 */
@interface GPKGTileReprojectionZoom : NSObject

/**
 *  Reprojected new zoom level
 */
@property (nonatomic, strong) NSNumber *toZoom;

/**
 *  Number of columns at the zoom level
 */
@property (nonatomic, strong) NSNumber *matrixWidth;

/**
 *  Number of rows at the zoom level
 */
@property (nonatomic, strong) NSNumber *matrixHeight;

/**
 *  Tile width in pixels
 */
@property (nonatomic, strong) NSNumber *tileWidth;

/**
 *  Tile height in pixels
 */
@property (nonatomic, strong) NSNumber *tileHeight;

/**
 *  Initialize zoom level reprojection configuration
 *
 *  @param zoom zoom level
 *  @return tile reprojection zoom
 */
-(instancetype) initWithZoom: (int) zoom;

/**
 *  Get the zoom level
 *
 *  @return zoom level
 */
-(int) zoom;

/**
 *  Has to zoom level value
 *
 *  @return true if has value
 */
-(BOOL) hasToZoom;

/**
 *  Has matrix width value
 *
 *  @return true if has value
 */
-(BOOL) hasMatrixWidth;

/**
 *  Has matrix height value
 *
 *  @return true if has value
 */
-(BOOL) hasMatrixHeight;

/**
 *  Has tile width value
 *
 *  @return true if has value
 */
-(BOOL) hasTileWidth;

/**
 *  Has tile height value
 *
 *  @return true if has value
 */
-(BOOL) hasTileHeight;

@end
