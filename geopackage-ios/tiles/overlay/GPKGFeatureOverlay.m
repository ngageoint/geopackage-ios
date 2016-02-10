//
//  GPKGFeatureOverlay.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureOverlay.h"
#import "GPKGGeoPackageOverlay.h"

@interface GPKGFeatureOverlay ()

@property (nonatomic, strong) NSMutableArray<GPKGGeoPackageOverlay *> *linkedOverlays;

@end

@implementation GPKGFeatureOverlay

-(instancetype) initWithFeatureTiles: (GPKGFeatureTiles *) featureTiles{
    self = [super init];
    if(self != nil){
        self.featureTiles = featureTiles;
        self.linkedOverlays = [[NSMutableArray alloc] init];
    }
    return self;
}

-(BOOL) hasTileToRetrieveWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    // Determine if the tile should be drawn
    BOOL drawTile = true;
    for(GPKGGeoPackageOverlay * geoPackageOverlay in self.linkedOverlays){
        if([geoPackageOverlay hasTileWithX:x andY:y andZoom:zoom]){
            drawTile = false;
            break;
        }
    }
    
    return drawTile;
}

-(NSData *) retrieveTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    NSData * tileData = [self.featureTiles drawTileDataWithX:(int)x andY:(int)y andZoom:(int)zoom];
    
    return tileData;
}

-(void) ignoreTileDaos: (NSArray<GPKGTileDao *> *) tileDaos{
    
    for(GPKGTileDao * tileDao in tileDaos){
        [self ignoreTileDao:tileDao];
    }
    
}

-(void) ignoreTileDao: (GPKGTileDao *) tileDao{
 
    GPKGGeoPackageOverlay *tileOverlay = [[GPKGGeoPackageOverlay alloc] initWithTileDao:tileDao];
    [self.linkedOverlays addObject:tileOverlay];
    
}

-(void) clearIgnored{
    self.linkedOverlays = [[NSMutableArray alloc] init];
}

@end
