//
//  GPKGBoundedOverlay.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBoundedOverlay.h"
#import "GPKGProjectionTransform.h"
#import "GPKGProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGBoundedOverlay

-(instancetype) init{
    self = [super initWithURLTemplate:nil];
    return self;
}

-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (GPKGProjection *) projection{
    GPKGProjectionTransform * projectionToWebMercator = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    self.webMercatorBoundingBox = [projectionToWebMercator transformWithBoundingBox:boundingBox];
}

-(GPKGBoundingBox *) getBoundingBoxWithProjection: (GPKGProjection *) projection{
    GPKGProjectionTransform * webMercatorToProjection = [[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WEB_MERCATOR andToProjection:projection];
    return [webMercatorToProjection transformWithBoundingBox:self.webMercatorBoundingBox];
}

-(NSURL *)URLForTilePath:(MKTileOverlayPath)path{
    return [NSURL URLWithString:@""];
}

-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result{
    
    if(!result){
        return;
    }
    
    NSData * tileData = nil;
    
    // Check if there is a tile
    if([self hasTileWithX:path.x andY:path.y andZoom:path.z]){
        
        // Retrieve the tile
        tileData = [self retrieveTileWithX:(int)path.x andY:(int)path.y andZoom:(int)path.z];
    }
    
    if(tileData == nil){
        tileData = [[NSData alloc] init];
    }
    result(tileData, nil);
}

-(BOOL) hasTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    // Check if generating tiles for the zoom level and is within the bounding box
    BOOL hasTile = [self isWithinBoundsWithX:x andY:y andZoom:zoom];
    if(hasTile){
        // Check if there is a tile to retrieve
        hasTile = [self hasTileToRetrieveWithX:x andY:y andZoom:zoom];
    }
    
    return hasTile;
}

-(BOOL) hasTileToRetrieveWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    [self doesNotRecognizeSelector:_cmd];
    return false;
}

-(NSData *) retrieveTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(BOOL) isWithinBoundsWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    return [self isWithinZoom:zoom] && [self isWithinBoundingBoxWithX:x andY:y andZoom:zoom];
}

-(BOOL) isWithinZoom: (double) zoom{
    return (self.minZoom == nil || zoom >= [self.minZoom intValue]) && (self.maxZoom == nil || zoom <= [self.maxZoom intValue]);
}

-(BOOL) isWithinBoundingBoxWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
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
