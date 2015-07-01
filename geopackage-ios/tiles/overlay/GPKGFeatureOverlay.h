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

@interface GPKGFeatureOverlay : MKTileOverlay

@property (nonatomic, strong) NSNumber * minZoom;
@property (nonatomic, strong) NSNumber * maxZoom;
@property (nonatomic, strong) GPKGBoundingBox * webMercatorBoundingBox;

-(instancetype) initWithFeatureTiles: (GPKGFeatureTiles *) featureTiles;

-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (GPKGProjection *) projection;

@end
