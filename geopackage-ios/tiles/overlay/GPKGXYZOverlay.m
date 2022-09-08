//
//  GPKGXYZOverlay.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGXYZOverlay.h"
#import "GPKGXYZTileRetriever.h"
#import "GPKGGeoPackageTile.h"

@interface GPKGXYZOverlay ()

@property (nonatomic, strong) NSObject<GPKGTileRetriever> *retriever;

@end

@implementation GPKGXYZOverlay

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao{
    self = [super init];
    if(self != nil){
        self.retriever = [[GPKGXYZTileRetriever alloc] initWithTileDao:tileDao];
        
        [self setMinimumZ:tileDao.minZoom];
        [self setMaximumZ:tileDao.maxZoom];
        
        NSNumber *tileWidth = nil;
        NSNumber *tileHeight = nil;
        for(GPKGTileMatrix *tileMatrix in tileDao.tileMatrices){
            if(tileWidth == nil){
                tileWidth = tileMatrix.tileWidth;
            }else if([tileWidth intValue] != [tileMatrix.tileWidth intValue]){
                [NSException raise:@"Multiple Tile Sizes" format:@"Different Tile Matrix Tile widths exist in tile table: %@. Can not be used with standard format overlay. Widths: %d and %d", tileDao.tableName, [tileWidth intValue], [tileMatrix.tileWidth intValue]];
            }
            if(tileHeight == nil){
                tileHeight = tileMatrix.tileHeight;
            }else if([tileHeight intValue] != [tileMatrix.tileHeight intValue]){
                [NSException raise:@"Multiple Tile Sizes" format:@"Different Tile Matrix Tile heights exist in tile table: %@. Can not be used with standard format overlay. Heights: %d and %d", tileDao.tableName, [tileHeight intValue], [tileMatrix.tileHeight intValue]];
            }
        }
        self.tileSize = CGSizeMake([tileWidth intValue], [tileHeight intValue]);
    }
    return self;
}

-(BOOL) hasTileToRetrieveWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    return [self.retriever hasTileWithX:x andY:y andZoom:zoom];
}

-(NSData *) retrieveTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    NSData *tileData = nil;
    
    GPKGGeoPackageTile *geoPackageTile = [self.retriever tileWithX:x andY:y andZoom:zoom];
    if(geoPackageTile != nil){
        tileData = geoPackageTile.data;
    }
    
    return tileData;
}

@end
