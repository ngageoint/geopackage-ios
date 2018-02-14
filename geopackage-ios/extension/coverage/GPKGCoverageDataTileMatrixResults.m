//
//  GPKGCoverageDataTileMatrixResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/18/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataTileMatrixResults.h"

@interface GPKGCoverageDataTileMatrixResults ()

/**
 * Tile matrix
 */
@property (nonatomic) GPKGTileMatrix * tileMatrix;

/**
 * Coverage Data tile results
 */
@property (nonatomic) GPKGResultSet * tileResults;

@end

@implementation GPKGCoverageDataTileMatrixResults

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
