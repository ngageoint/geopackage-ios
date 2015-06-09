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

@end
