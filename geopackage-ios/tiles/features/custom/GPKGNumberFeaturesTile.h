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

// TODO

@end
