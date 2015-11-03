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

/**
 *  Feature Tile Overlay which draws tiles from a feature table
 */
@interface GPKGFeatureOverlay : MKTileOverlay

/**
 *  Feature tiles
 */
@property (nonatomic, strong) GPKGFeatureTiles *featureTiles;

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
 *  @param featureTiles feature tiles
 *
 *  @return new feature overlay
 */
-(instancetype) initWithFeatureTiles: (GPKGFeatureTiles *) featureTiles;

/**
 *  Set the bounding box, provided as the indicated projection
 *
 *  @param boundingBox bounding box
 *  @param projection  projection of the bounding box
 */
-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (GPKGProjection *) projection;

@end
