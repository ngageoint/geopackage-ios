//
//  GPKGTileGrid.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileGrid.h"

@implementation GPKGTileGrid

-(instancetype) initWithMinX: (int) minX andMinY: (int) minY andMaxX: (int) maxX andMaxY: (int) maxY{
    self = [super init];
    if(self != nil){
        self.minX = minX;
        self.minY = minY;
        self.maxX = maxX;
        self.maxY = maxY;
    }
    return self;
}

-(int) count{
    return ((self.maxX + 1) - self.minX) * ((self.maxY + 1) - self.minY);
}

-(int) width{
    return _maxX + 1 - _minX;
}

-(int) height{
    return _maxY + 1 - _minY;
}

-(BOOL) equals: (GPKGTileGrid *) tileGrid{
    if(self == tileGrid){
        return YES;
    }
    if(tileGrid == nil){
        return NO;
    }
    if(self.minX != tileGrid.minX){
        return NO;
    }
    if(self.maxX != tileGrid.maxX){
        return NO;
    }
    if(self.minY != tileGrid.minY){
        return NO;
    }
    if(self.maxY != tileGrid.maxY){
        return NO;
    }
    return YES;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[GPKGTileGrid class]]) {
        return NO;
    }
    
    return [self equals:(GPKGTileGrid *)object];
}

@end
