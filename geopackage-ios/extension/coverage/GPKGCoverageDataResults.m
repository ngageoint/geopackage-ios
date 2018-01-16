//
//  GPKGCoverageDataResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataResults.h"
#import "GPKGUtils.h"

@interface GPKGCoverageDataResults()

/**
 * Double array of elevations stored as [row][column]
 */
@property (nonatomic, strong) NSArray *values;

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

@implementation GPKGCoverageDataResults

-(instancetype) initWithValues: (NSArray *) values andTileMatrix: (GPKGTileMatrix *) tileMatrix{
    self = [super init];
    if(self != nil){
        self.values = values;
        self.tileMatrix = tileMatrix;
        self.height = (int)[values count];
        self.width = (int)[((NSArray *)[values objectAtIndex:0]) count];
    }
    return self;
}

-(NSArray *) values{
    return _values;
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

-(NSDecimalNumber *) valueAtRow: (int) row andColumn: (int) column{
    NSArray * rowArray = (NSArray *)[self.values objectAtIndex:row];
    NSDecimalNumber * value = (NSDecimalNumber *)[GPKGUtils objectAtIndex:column inArray:rowArray];
    return value;
}

-(NSNumber *) zoomLevel{
    return self.tileMatrix.zoomLevel;
}

@end
