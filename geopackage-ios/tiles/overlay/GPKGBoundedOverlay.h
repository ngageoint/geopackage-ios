//
//  GPKGBoundedOverlay.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGBoundingBox.h"
#import "GPKGProjection.h"

/**
 * Abstract overlay which provides bounding returned tiles by zoom levels and/or a bounding box
 */
@interface GPKGBoundedOverlay : MKTileOverlay

/**
 *  Min zoom
 */
@property (nonatomic, strong) NSNumber * minZoom;

/**
 *  Max zoom
 */
@property (nonatomic, strong) NSNumber * maxZoom;

/**
 *  Web mercator bounding box
 */
@property (nonatomic, strong) GPKGBoundingBox * webMercatorBoundingBox;

/**
 *  Initialize
 *
 *  @return new bounded overlay
 */
-(instancetype) init;

/**
 *  Set the bounding box, provided as the indicated projection
 *
 *  @param boundingBox bounding box
 *  @param projection projection of bounding box
 */
-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (GPKGProjection *) projection;

/**
 *  Get the bounding box as the provided projection
 *
 *  @param projection returned bounding box projection
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) getBoundingBoxWithProjection: (GPKGProjection *) projection;

/**
 *  Determine if there is a tile for the x, y, and zoom
 *
 *  @param x x coordinate
 *  @param y y coordinate
 *  @param zoom zoom value
 *
 *  @return true if there is a tile
 */
-(BOOL) hasTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom;

/**
 *  Is the tile within the zoom and bounding box bounds
 *
 *  @param x x coordinate
 *  @param y y coordinate
 *  @param zoom zoom value
 *
 *  @return true if within the bounds
 */
-(BOOL) isWithinBoundsWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom;

/**
 *  Check if the zoom is within the overlay zoom range
 *
 *  @param zoom zoom value
 *
 *  @return true if within the zoom bounds
 */
-(BOOL) isWithinZoom: (double) zoom;

/**
 *  Check if the tile request is within the desired tile bounds
 *
 *  @param x x coordinate
 *  @param y y coordinate
 *  @param zoom zoom value
 *
 *  @return true if within the bounding box bounds
 */
-(BOOL) isWithinBoundingBoxWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom;

@end
