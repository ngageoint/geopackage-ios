//
//  GPKGTileGrid.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileGrid.h"

@implementation GPKGTileGrid

-(instancetype) initWithMinX: (int) minX andMaxX: (int) maxX andMinY: (int) minY andMaxY: (int) maxY{
    self = [super init];
    if(self != nil){
        self.minX = minX;
        self.maxX = maxX;
        self.minY = minY;
        self.maxY = maxY;
    }
    return self;
}

-(int) count{
    return ((self.maxX + 1) - self.minX) * ((self.maxY + 1) - self.minY);
}

-(BOOL) equals: (GPKGTileGrid *) tileGrid{
    if(self == tileGrid){
        return true;
    }
    if(tileGrid == nil){
        return false;
    }
    if(self.minX != tileGrid.minX){
        return false;
    }
    if(self.maxX != tileGrid.maxX){
        return false;
    }
    if(self.minY != tileGrid.minY){
        return false;
    }
    if(self.maxY != tileGrid.maxY){
        return false;
    }
    return true;
}

@end
