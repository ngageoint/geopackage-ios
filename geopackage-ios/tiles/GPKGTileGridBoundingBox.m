//
//  GPKGTileGridBoundingBox.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/7/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileGridBoundingBox.h"

@implementation GPKGTileGridBoundingBox

-(instancetype) initWithGrid: (GPKGTileGrid *) tileGrid andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self initWithZoom:nil andGrid:tileGrid andBoundingBox:boundingBox];
}

-(instancetype) initWithZoom: (NSNumber *) zoomLevel andGrid: (GPKGTileGrid *) tileGrid andBoundingBox: (GPKGBoundingBox *) boundingBox{
    self = [super init];
    if(self != nil){
        _zoomLevel = zoomLevel;
        _tileGrid = tileGrid;
        _boundingBox = boundingBox;
    }
    return self;
}

@end
