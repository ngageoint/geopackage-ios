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
    self = [super initWithURLTemplate:nil];
    if(self != nil){
        self.tileDao = tileDao;
    }
    return self;
}

-(NSURL *)URLForTilePath:(MKTileOverlayPath)path{
    return [NSURL URLWithString:@""];
}

-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *tileData, NSError *error))result{
    
    if(!result){
        return;
    }
    
    NSData * tileData = nil;
    
    GPKGTileRow * tileRow = [self.tileDao queryForTileWithColumn:(int)path.x andRow:(int)path.y andZoomLevel:(int)path.z];
    if(tileRow != nil){
        tileData = [tileRow getTileData];
    }
    
    if(tileData == nil){
        tileData = [[NSData alloc] init];
    }
    result(tileData, nil);
}

@end
