//
//  GPKGElevationTileResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTileResults.h"
#import "GPKGUtils.h"

@interface GPKGElevationTileResults()

/**
 * Double array of elevations stored as [row][column]
 */
@property (nonatomic, strong) NSArray *elevations;

/**
 * Tile matrix used to find the elevations
 */
@property (nonatomic, strong) GPKGTileMatrix *tileMatrix;

/**
 * Elevation results height
 */
@property (nonatomic) int height;

/**
 * Elevation results width
 */
@property (nonatomic) int width;

@end

@implementation GPKGElevationTileResults

-(instancetype) initWithElevations: (NSArray *) elevations andTileMatrix: (GPKGTileMatrix *) tileMatrix{
    self = [super init];
    if(self != nil){
        self.elevations = elevations;
        self.tileMatrix = tileMatrix;
        self.height = (int)[elevations count];
        self.width = (int)[((NSArray *)[elevations objectAtIndex:0]) count];
    }
    return self;
}

-(NSArray *) elevations{
    return _elevations;
}

-(GPKGTileMatrix *) tileMatrix{
    return _tileMatrix;
}

-(int) height{
    return _height;
}

-(int) width{
    return _width;
}

-(NSDecimalNumber *) elevationAtRow: (int) row andColumn: (int) column{
    NSArray * rowArray = (NSArray *)[self.elevations objectAtIndex:row];
    NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:column inArray:rowArray];
    return elevation;
}

-(NSNumber *) zoomLevel{
    return self.tileMatrix.zoomLevel;
}

@end
