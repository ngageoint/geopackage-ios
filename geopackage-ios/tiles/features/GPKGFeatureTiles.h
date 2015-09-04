//
//  GPKGFeatureTiles.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GPKGResultSet.h"
#import "GPKGBoundingBox.h"
#import "GPKGFeatureDao.h"
#import "GPKGCompressFormats.h"
#import "GPKGFeatureTilePointIcon.h"

/**
 *  Tiles generated from features
 */
@interface GPKGFeatureTiles : NSObject

/**
 *  When true, features are retrieved from the geometry index. When false all geometries are queried
 */
@property (nonatomic) BOOL indexQuery;

/**
 *  Tile width
 */
@property (nonatomic) int tileWidth;

/**
 *  Tile height
 */
@property (nonatomic) int tileHeight;

/**
 *  Compress format
 */
@property (nonatomic) enum GPKGCompressFormat compressFormat;

/**
 *  Point radius
 */
@property (nonatomic) double pointRadius;

/**
 *  Point color
 */
@property (nonatomic) UIColor * pointColor;

/**
 *  Optional point icon in place of a drawn circle
 */
@property (nonatomic, strong) GPKGFeatureTilePointIcon * pointIcon;

/**
 *  Line stroke width
 */
@property (nonatomic) double lineStrokeWidth;

/**
 *  Line color
 */
@property (nonatomic) UIColor * lineColor;

/**
 *  Polygon stroke width
 */
@property (nonatomic) double polygonStrokeWidth;

/**
 *  Polygon color
 */
@property (nonatomic) UIColor * polygonColor;

/**
 *  When true, polygon is filled with color
 */
@property (nonatomic) BOOL fillPolygon;

/**
 *  Polygon fill color
 */
@property (nonatomic) UIColor * polygonFillColor;

/**
 *  Height overlapping pixels between tile images
 */
@property (nonatomic) double heightOverlap;

/**
 *  Width overlapping pixels between tile images
 */
@property (nonatomic) double widthOverlap;

/**
 *  Initialize
 *
 *  @param featureDao feature dao
 *
 *  @return new feature tiles
 */
-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao;

/**
 * Call after making changes to the point icon, point radius, or paint stroke widths.
 * Determines the pixel overlap between tiles
 */
-(void) calculateDrawOverlap;

/**
 *  Manually set the width and height draw overlap
 *
 *  @param pixels pixels
 */
-(void) setDrawOverlapsWithPixels: (double) pixels;

/**
 *  Draw the tile and get the tile data from the x, y, and zoom level
 *
 *  @param x    x
 *  @param y    y
 *  @param zoom zoom level
 *
 *  @return tile data
 */
-(NSData *) drawTileDataWithX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 *  Draw a tile image from the x, y, and zoom level
 *
 *  @param x    x
 *  @param y    y
 *  @param zoom zoom level
 *
 *  @return tile image
 */
-(UIImage *) drawTileWithX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 *  Draw a tile image from the x, y, and zoom level by querying all features. This could
 *  be very slow if there are a lot of features
 *
 *  @param x    x
 *  @param y    y
 *  @param zoom zoom level
 *
 *  @return tile image
 */
-(UIImage *) drawTileQueryIndexWithX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 *  Draw a tile image from the x, y, and zoom level by querying all features. This could
 *  be very slow if there are a lot of features
 *
 *  @param x    x
 *  @param y    y
 *  @param zoom zoom level
 *
 *  @return tile image
 */
-(UIImage *) drawTileQueryAllWithX: (int) x andY: (int) y andZoom: (int) zoom;

/**
 *  Draw a tile image from feature geometries in the provided result set
 *
 *  @param boundingBox bounding box
 *  @param results     result set
 *
 *  @return tile image
 */
-(UIImage *) drawTileWithBoundingBox: (GPKGBoundingBox *) boundingBox andResults: (GPKGResultSet *) results;

/**
 *  Draw a tile image from the feature rows
 *
 *  @param boundingBox bounding box
 *  @param featureRows feature rows
 *
 *  @return tile image
 */
-(UIImage *) drawTileWithBoundingBox: (GPKGBoundingBox *) boundingBox andFeatureRows: (NSArray *) featureRows;

@end
