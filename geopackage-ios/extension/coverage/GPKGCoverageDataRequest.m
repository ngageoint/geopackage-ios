//
//  GPKGCoverageDataRequest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataRequest.h"
#import "GPKGTileBoundingBoxUtils.h"

@interface GPKGCoverageDataRequest()

/**
 * Bounding box
 */
@property (nonatomic, strong) GPKGBoundingBox *boundingBox;

/**
 * Point flag, true when a single point request
 */
@property (nonatomic) BOOL point;

@end

@implementation GPKGCoverageDataRequest

-(instancetype) initWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    self = [super init];
    if(self != nil){
        self.boundingBox = boundingBox;
    }
    return self;
}

-(instancetype) initWithLatitude: (double) latitude andLongitude: (double) longitude{
    self = [self initWithBoundingBox:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:longitude andMinLatitudeDouble:latitude andMaxLongitudeDouble:longitude andMaxLatitudeDouble:latitude]];
    if(self != nil){
        self.point = YES;
    }
    return self;
}

-(GPKGBoundingBox *) boundingBox{
    return _boundingBox;
}

-(BOOL) isPoint{
    return _point;
}


-(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) projectedCoverage{
    GPKGBoundingBox *overlap = nil;
    if(self.point){
        overlap = self.projectedBoundingBox;
    }else{
        overlap = [self.projectedBoundingBox overlap:projectedCoverage];
    }
    return overlap;
}

@end
