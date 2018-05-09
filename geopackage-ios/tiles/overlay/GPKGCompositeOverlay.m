//
//  GPKGCompositeOverlay.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/9/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGCompositeOverlay.h"

@interface GPKGCompositeOverlay ()

/**
 * Ordered list of overlays
 */
@property (nonatomic, strong) NSMutableArray<GPKGBoundedOverlay *> *overlays;

@end

@implementation GPKGCompositeOverlay

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.overlays = [[NSMutableArray alloc] init];
    }
    return self;
}

-(instancetype) initWithOverlay: (GPKGBoundedOverlay *) overlay{
    self = [super init];
    if(self != nil){
        self.overlays = [[NSMutableArray alloc] init];
        [self addOverlay:overlay];
    }
    return self;
}

-(instancetype) initWithOverlays: (NSArray<GPKGBoundedOverlay *> *) overlays{
    self = [super init];
    if(self != nil){
        self.overlays = [[NSMutableArray alloc] init];
        [self addOverlays:overlays];
    }
    return self;
}

-(void) addOverlay: (GPKGBoundedOverlay *) overlay{
    [self.overlays addObject:overlay];
}

-(void) addOverlays: (NSArray<GPKGBoundedOverlay *> *) overlays{
    [self.overlays addObjectsFromArray:overlays];
}

-(void) clearOverlays{
    [self.overlays removeAllObjects];
}

-(BOOL) hasTileToRetrieveWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    BOOL hasTile = NO;
    for (GPKGBoundedOverlay *overlay in self.overlays) {
        hasTile = [overlay hasTileToRetrieveWithX:x andY:y andZoom:zoom];
        if (hasTile) {
            break;
        }
    }
    return hasTile;
}

-(NSData *) retrieveTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    NSData *tileData = nil;
    for (GPKGBoundedOverlay *overlay in self.overlays) {
        tileData = [overlay retrieveTileWithX:x andY:y andZoom:zoom];
        if (tileData != nil) {
            break;
        }
    }
    return tileData;
}

@end
