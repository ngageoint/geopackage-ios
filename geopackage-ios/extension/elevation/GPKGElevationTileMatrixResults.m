//
//  GPKGElevationTileMatrixResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/18/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTileMatrixResults.h"

@interface GPKGElevationTileMatrixResults ()

/**
 * Tile matrix
 */
@property (nonatomic) GPKGTileMatrix * tileMatrix;

/**
 * Elevation tile results
 */
@property (nonatomic) GPKGResultSet * tileResults;

@end

@implementation GPKGElevationTileMatrixResults

-(instancetype) initWithTileMatrix: (GPKGTileMatrix *) tileMatrix andTileResults: (GPKGResultSet *) tileResults{
    self = [super init];
    if(self != nil){
        self.tileMatrix = tileMatrix;
        self.tileResults = tileResults;
    }
    return self;
}

-(GPKGTileMatrix *) tileMatrix{
    return _tileMatrix;
}

-(GPKGResultSet *) tileResults{
    return _tileResults;
}

@end
