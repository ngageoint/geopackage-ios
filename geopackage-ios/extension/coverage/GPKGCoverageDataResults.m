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
 * Double array of coverage data values stored as [row][column]
 */
@property (nonatomic, strong) NSArray *values;

/**
 * Tile matrix used to find the coverage data values
 */
@property (nonatomic, strong) GPKGTileMatrix *tileMatrix;

/**
 * Coverage Data results height
 */
@property (nonatomic) int height;

/**
 * Coverage Data results width
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
    return _tileMatrix.zoomLevel;
}

@end
