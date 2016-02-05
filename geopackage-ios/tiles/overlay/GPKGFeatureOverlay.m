//
//  GPKGFeatureOverlay.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureOverlay.h"
#import "GPKGProjectionTransform.h"
#import "GPKGProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGFeatureOverlay

-(instancetype) initWithFeatureTiles: (GPKGFeatureTiles *) featureTiles{
    self = [super init];
    if(self != nil){
        self.featureTiles = featureTiles;
    }
    return self;
}

-(NSData *) retrieveTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    // Draw the tile
    NSData * tileData = [self.featureTiles drawTileDataWithX:(int)x andY:(int)y andZoom:(int)zoom];
    
    return tileData;
}

@end
