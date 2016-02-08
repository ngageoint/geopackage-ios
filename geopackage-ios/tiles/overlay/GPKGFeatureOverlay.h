//
//  GPKGFeatureOverlay.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "GPKGBoundingBox.h"
#import "GPKGFeatureTiles.h"
#import "GPKGProjection.h"
#import "GPKGBoundedOverlay.h"

/**
 *  Feature Tile Overlay which draws tiles from a feature table
 */
@interface GPKGFeatureOverlay : GPKGBoundedOverlay

/**
 *  Feature tiles
 */
@property (nonatomic, strong) GPKGFeatureTiles *featureTiles;

/**
 *  Initialize
 *
 *  @param featureTiles feature tiles
 *
 *  @return new feature overlay
 */
-(instancetype) initWithFeatureTiles: (GPKGFeatureTiles *) featureTiles;

@end
