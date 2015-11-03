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
    self = [super initWithURLTemplate:nil];
    if(self != nil){
        self.featureTiles = featureTiles;
    }
    return self;
}

-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (GPKGProjection *) projection{
    GPKGProjectionTransform * projectionToWebMercator = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    self.webMercatorBoundingBox = [projectionToWebMercator transformWithBoundingBox:boundingBox];
}

-(NSURL *)URLForTilePath:(MKTileOverlayPath)path{
    return [NSURL URLWithString:@""];
}

-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result{
    
    if(!result){
        return;
    }
    
    NSData * tileData = nil;
    
    // Check if generating tiles for the zoom level
    if([self isWithinZoom:path.z] && [self isWithinBoundsWithX:path.x andY:path.y andZoom:path.z]){
        
        // Draw the tile
        tileData = [self.featureTiles drawTileDataWithX:(int)path.x andY:(int)path.y andZoom:(int)path.z];
    }
    
    if(tileData == nil){
        tileData = [[NSData alloc] init];
    }
    result(tileData, nil);
}

-(BOOL) isWithinZoom: (NSInteger) zoom{
    return (self.minZoom == nil || zoom >= [self.minZoom intValue]) && (self.maxZoom == nil || zoom <= [self.maxZoom intValue]);
}

-(BOOL) isWithinBoundsWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    BOOL withinBounds = true;
    
    // If a bounding box is set, check if it overlaps with the request
    if(self.webMercatorBoundingBox != nil){
        
        // Get the bounding box of the requested tile
        GPKGBoundingBox * requestWebMercatorBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:(int)x andY:(int)y andZoom:(int)zoom];
        
        // Check if the request overlaps
        withinBounds = [GPKGTileBoundingBoxUtils overlapWithBoundingBox:self.webMercatorBoundingBox andBoundingBox:requestWebMercatorBoundingBox] != nil;
    }
    
    return withinBounds;
}

-(void) setMinZoom:(NSNumber *)minZoom{
    _minZoom = minZoom;
    [self setMinimumZ:minZoom != nil ? [minZoom intValue] : 0];
}

-(void) setMaxZoom:(NSNumber *)maxZoom{
    _maxZoom = maxZoom;
    [self setMaximumZ:maxZoom != nil ? [maxZoom intValue] : 21];
}

@end
