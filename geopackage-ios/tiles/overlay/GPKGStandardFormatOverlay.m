//
//  GPKGStandardFormatOverlay.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGStandardFormatOverlay.h"

@interface GPKGStandardFormatOverlay ()

@property (nonatomic, strong) GPKGTileDao *tileDao;

@end

@implementation GPKGStandardFormatOverlay

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao{
    self = [super init];
    if(self != nil){
        self.tileDao = tileDao;
        
        [self setMinimumZ:tileDao.minZoom];
        [self setMaximumZ:tileDao.maxZoom];
    }
    return self;
}

-(NSData *) retrieveTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    NSData * tileData = nil;
    
    GPKGTileRow * tileRow = [self.tileDao queryForTileWithColumn:(int)x andRow:(int)y andZoomLevel:(int)zoom];
    if(tileRow != nil){
        tileData = [tileRow getTileData];
    }
    
    return tileData;
}

@end
