//
//  GPKGElevationRequest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationRequest.h"
#import "GPKGTileBoundingBoxUtils.h"

@interface GPKGElevationRequest()

/**
 * Bounding box
 */
@property (nonatomic, strong) GPKGBoundingBox *boundingBox;

/**
 * Point flag, true when a single point request
 */
@property (nonatomic) BOOL point;

@end

@implementation GPKGElevationRequest

-(instancetype) initWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    self = [super init];
    if(self != nil){
        self.boundingBox = boundingBox;
    }
    return self;
}

-(instancetype) initWithLatitude: (double) latitude andLongitude: (double) longitude{
    self = [self initWithBoundingBox:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:longitude andMaxLongitudeDouble:longitude andMinLatitudeDouble:latitude andMaxLatitudeDouble:latitude]];
    if(self != nil){
        self.point = true;
    }
    return self;
}

-(GPKGBoundingBox *) boundingBox{
    return _boundingBox;
}

-(BOOL) isPoint{
    return _point;
}


-(GPKGBoundingBox *) overlapWithBoundingBox: (GPKGBoundingBox *) projectedElevation{
    GPKGBoundingBox * overlap = nil;
    if(self.point){
        overlap = self.projectedBoundingBox;
    }else{
        overlap = [GPKGTileBoundingBoxUtils overlapWithBoundingBox:self.projectedBoundingBox andBoundingBox:projectedElevation];
    }
    return overlap;
}

@end
