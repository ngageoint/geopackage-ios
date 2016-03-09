//
//  GPKGStandardFormatTileRetriever.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGStandardFormatTileRetriever.h"
#import "GPKGGeoPackageTile.h"

@interface GPKGStandardFormatTileRetriever ()

@property (nonatomic, strong) GPKGTileDao *tileDao;

@end

@implementation GPKGStandardFormatTileRetriever

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao{
    self = [super init];
    if(self != nil){
        self.tileDao = tileDao;
    }
    return self;
}

-(BOOL) hasTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    return [self retrieveTileRowWithX:x andY:y andZoom:zoom] != nil;
}

-(GPKGGeoPackageTile *) getTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    GPKGGeoPackageTile * tile = nil;
    
    GPKGTileRow * tileRow = [self retrieveTileRowWithX:x andY:y andZoom:zoom];
    if(tileRow != nil){
        GPKGTileMatrix * tileMatrix = [self.tileDao getTileMatrixWithZoomLevel:(int)zoom];
        int tileWidth = [tileMatrix.tileWidth intValue];
        int tileHeight = [tileMatrix.tileHeight intValue];
        tile = [[GPKGGeoPackageTile alloc] initWithWidth:tileWidth andHeight:tileHeight andData:[tileRow getTileData]];
    }
    
    return tile;
}

-(GPKGTileRow *) retrieveTileRowWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    return [self.tileDao queryForTileWithColumn:(int)x andRow:(int)y andZoomLevel:(int)zoom];
}

@end
