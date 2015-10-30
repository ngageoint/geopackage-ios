//
//  GPKGNumberFeaturesTile.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGCustomFeaturesTile.h"

/**
 * Draws a tile indicating the number of features that exist within the tile, visible when zoomed
 * in closer. The number is drawn in the center of the tile and by default is surrounded by a colored
 * circle with border.  By default a tile border is drawn and the tile is colored (transparently
 * most likely). The paint objects for each draw type can be modified to or set to null (except for
 * the text paint object).
 */
@interface GPKGNumberFeaturesTile : NSObject<GPKGCustomFeaturesTile>

/**
 *  Text font used for the drawn number
 */
@property (nonatomic, strong) NSString * textFont;

/**
 *  Text font size used for the drawn number
 */
@property (nonatomic) double textFontSize;

/**
 *  Text color
 */
@property (nonatomic) UIColor * textColor;

/**
 *  When true, circle is drawn
 */
@property (nonatomic) BOOL drawCircle;

/**
 *  Circle stroke width
 */
@property (nonatomic) double circleStrokeWidth;

/**
 *  Circle color
 */
@property (nonatomic, strong) UIColor * circleColor;

/**
 *  When true, circle is filled with color
 */
@property (nonatomic) BOOL fillCircle;

/**
 *  Circle fill color
 */
@property (nonatomic, strong) UIColor * circleFillColor;

/**
 *  When true, tile border is drawn
 */
@property (nonatomic) BOOL drawTileBorder;

/**
 *  Tile Border stroke width
 */
@property (nonatomic) double tileBorderStrokeWidth;

/**
 *  Tile Border color
 */
@property (nonatomic, strong) UIColor * tileBorderColor;

/**
 *  When true, tile is filled with color
 */
@property (nonatomic) BOOL fillTile;

/**
 *  Tile fill color
 */
@property (nonatomic, strong) UIColor * tileFillColor;

/**
 *  The percentage of border to include around the edges of the text in the circle
 */
@property (nonatomic) float circlePaddingPercentage;

/**
 *  Flag indicating whether tiles should be drawn for feature tables that are not indexed
 */
@property (nonatomic) BOOL drawUnindexedTiles;

/**
 *  Text used when drawing tiles for feature tables that are not indexed
 */
@property (nonatomic, strong) NSString * unindexedText;

/**
 *  Initialize
 *
 *  @return new number feature tile
 */
-(instancetype) init;

@end
