//
//  GPKGStandardFormatOverlay.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGStandardFormatOverlay.h"
#import "GPKGStandardFormatTileRetriever.h"
#import "GPKGGeoPackageTile.h"

@interface GPKGStandardFormatOverlay ()

@property (nonatomic, strong) NSObject<GPKGTileRetriever> *retriever;

@end

@implementation GPKGStandardFormatOverlay

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao{
    self = [super init];
    if(self != nil){
        self.retriever = [[GPKGStandardFormatTileRetriever alloc] initWithTileDao:tileDao];
        
        [self setMinimumZ:tileDao.minZoom];
        [self setMaximumZ:tileDao.maxZoom];
    }
    return self;
}

-(BOOL) hasTileToRetrieveWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    return [self.retriever hasTileWithX:x andY:y andZoom:zoom];
}

-(NSData *) retrieveTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    NSData * tileData = nil;
    
    GPKGGeoPackageTile * geoPackageTile = [self.retriever getTileWithX:x andY:y andZoom:zoom];
    if(geoPackageTile != nil){
        tileData = geoPackageTile.data;
    }
    
    return tileData;
}

@end
