//
//  GPKGTileReprojectionZoom.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/4/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojectionZoom.h"

@interface GPKGTileReprojectionZoom ()

@property (nonatomic) int zoom;

@end

@implementation GPKGTileReprojectionZoom

-(instancetype) initWithZoom: (int) zoom{
    self = [super init];
    if(self != nil){
        _zoom = zoom;
    }
    return self;
}

-(int) zoom{
    return _zoom;
}

-(BOOL) hasToZoom{
    return _toZoom != nil;
}

-(BOOL) hasMatrixWidth{
    return _matrixWidth != nil;
}

-(BOOL) hasMatrixHeight{
    return _matrixHeight != nil;
}

-(BOOL) hasTileWidth{
    return _tileWidth != nil;
}

-(BOOL) hasTileHeight{
    return _tileHeight != nil;
}

@end
