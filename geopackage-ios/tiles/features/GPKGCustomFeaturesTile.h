//
//  GPKGCustomFeaturesTile.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#ifndef GPKGCustomFeaturesTile_h
#define GPKGCustomFeaturesTile_h

@import MapKit;
#import "GPKGFeatureIndexResults.h"
#import "GPKGFeatureDao.h"

/**
 *  Interface defining custom feature tile drawing.
 *  The tile drawn will be used instead of drawing all of the features.
 */
@protocol GPKGCustomFeaturesTile <NSObject>

/**
 *  Draw a custom tile
 *
 *  @param tileWidth           tile width to draw
 *  @param tileHeight          tile height to draw
 *  @param tileFeatureCount    count of features in the requested tile
 *  @param featureIndexResults results as feature index results
 *
 *  @return image
 */
-(UIImage *) drawTileWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight andTileFeatureCount: (int) tileFeatureCount andFeatureIndexResults: (GPKGFeatureIndexResults *) featureIndexResults;

/**
 *  Draw a custom tile when the number of features within the tile is unknown.
 *  This is called when a feature table is not indexed and more total features exist than the
 *  max per tile.
 *
 *  @param tileWidth         tile width to draw
 *  @param tileHeight        tile height to draw
 *  @param totalFeatureCount count of total features in the feature table
 *  @param featureDao        feature data access object
 *  @param results           feature row results
 *
 *  @return image
 */
-(UIImage *) drawUnindexedTileWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight andTotalFeatureCount: (int) totalFeatureCount andFeatureDao: (GPKGFeatureDao *) featureDao andResults: (GPKGResultSet *) results;

@end

#endif /* GPKGCustomFeaturesTile_h */
