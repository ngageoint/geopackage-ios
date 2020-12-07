//
//  GPKGTileGridBoundingBox.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/7/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTileGrid.h"
#import "GPKGBoundingBox.h"

/**
 *  Tile Grid with Bounding Box and optional zoom level
 */
@interface GPKGTileGridBoundingBox : NSObject

/**
 *  Zoom Level
 */
@property (nonatomic, strong) NSNumber *zoomLevel;

/**
 *  Tile Grid
 */
@property (nonatomic, strong) GPKGTileGrid *tileGrid;

/**
 *  Bounding Box
 */
@property (nonatomic, strong) GPKGBoundingBox *boundingBox;

/**
 *  Initialize
 *
 *  @param tileGrid tile grid
 *  @param boundingBox bounding box
 *  @return tile grid bounding box
 */
-(instancetype) initWithGrid: (GPKGTileGrid *) tileGrid andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Initialize
 *
 *  @param zoomLevel zoom level
 *  @param tileGrid tile grid
 *  @param boundingBox bounding box
 *  @return tile grid bounding box
 */
-(instancetype) initWithZoom: (NSNumber *) zoomLevel andGrid: (GPKGTileGrid *) tileGrid andBoundingBox: (GPKGBoundingBox *) boundingBox;

@end
