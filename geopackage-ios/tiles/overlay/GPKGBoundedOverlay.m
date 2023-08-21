//
//  GPKGBoundedOverlay.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBoundedOverlay.h"
#import "PROJProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGBoundedOverlay

-(instancetype) init{
    self = [super initWithURLTemplate:nil];
    return self;
}

-(void) close{

}

-(void) setBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    SFPGeometryTransform *projectionToWebMercator = [SFPGeometryTransform transformFromProjection:projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    self.webMercatorBoundingBox = [boundingBox transform:projectionToWebMercator];
    [projectionToWebMercator destroy];
}

-(GPKGBoundingBox *) boundingBoxInProjection: (PROJProjection *) projection{
    SFPGeometryTransform *webMercatorToProjection = [SFPGeometryTransform transformFromEpsg:PROJ_EPSG_WEB_MERCATOR andToProjection:projection];
    GPKGBoundingBox *boundingBox = [self.webMercatorBoundingBox transform:webMercatorToProjection];
    [webMercatorToProjection destroy];
    return boundingBox;
}

/**
 * Get the bounded overlay web mercator bounding box expanded as needed by the requested bounding box dimensions
 *
 * @param requestWebMercatorBoundingBox requested web mercator bounding box
 * @return web mercator bounding box
 */
-(GPKGBoundingBox *) webMercatorBoundingBoxWithRequestBoundingBox: (GPKGBoundingBox *) requestWebMercatorBoundingBox{
    return _webMercatorBoundingBox;
}

-(NSURL *)URLForTilePath:(MKTileOverlayPath)path{
    return [NSURL URLWithString:@""];
}

-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result{
    
    if(!result){
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        
        NSData *tileData = nil;
        
        // Check if there is a tile
        if([self hasTileWithX:path.x andY:path.y andZoom:path.z]){
            
            // Retrieve the tile
            tileData = [self retrieveTileWithX:(int)path.x andY:(int)path.y andZoom:(int)path.z];
        }
        
        if(tileData == nil){
            tileData = [[NSData alloc] init];
        }
        result(tileData, nil);
        
    });
    
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
    return NO;
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
    BOOL withinBounds = YES;
    
    // If a bounding box is set, check if it overlaps with the request
    if(self.webMercatorBoundingBox != nil){
        
        // Get the bounding box of the requested tile
        GPKGBoundingBox *tileWebMercatorBoundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithX:(int)x andY:(int)y andZoom:(int)zoom];
        
        // Adjust the bounding box if needed
        GPKGBoundingBox *adjustedWebMercatorBoundingBox = [self webMercatorBoundingBoxWithRequestBoundingBox:tileWebMercatorBoundingBox];
        
        // Check if the request overlaps
        withinBounds = [adjustedWebMercatorBoundingBox intersects:tileWebMercatorBoundingBox withAllowEmpty:YES];
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
