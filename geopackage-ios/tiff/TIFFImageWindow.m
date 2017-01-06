//
//  TIFFImageWindow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFImageWindow.h"

@implementation TIFFImageWindow

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

-(instancetype) initWithX: (int) x andY: (int) y{
    return [self initWithMinX:x andMinY:y andMaxX:x+1 andMaxY:y+1];
}

-(instancetype) initWithFileDirectory: (TIFFFileDirectory *) fileDirectory{
    self = [super init];
    if(self != nil){
        self.minX = 0;
        self.minY = 0;
// TODO
//        self.maxX = [fileDirectory imageWidth];
//        self.maxY = [fileDirectory imageHeight];
    }
    return self;
}

@end
