//
//  GPKGManualFeatureQuery.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/11/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGManualFeatureQuery.h"

@interface GPKGManualFeatureQuery ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;

@end

@implementation GPKGManualFeatureQuery

-(instancetype)initWithFeatureDao:(GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self != nil){
        self.featureDao = featureDao;
    }
    return self;
}

-(GPKGFeatureDao *) featureDao{
    return _featureDao;
}

-(int) count{
    return [self.featureDao count];
}

-(int) countWithGeometries{
    return [self.featureDao countWhere:[NSString stringWithFormat:@"%@ IS NOT NULL", [self.featureDao getGeometryColumnName]]];
}

-(GPKGBoundingBox *) boundingBox{
    return nil; // TODO
}

-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection{
    GPKGBoundingBox *boundingBox = [self boundingBox];
    if(boundingBox != nil && projection != nil){
        SFPProjectionTransform *projectionTransform = [[SFPProjectionTransform alloc] initWithFromProjection:self.featureDao.projection andToProjection:projection];
        boundingBox = [boundingBox transform:projectionTransform];
    }
    return boundingBox;
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return nil; // TODO
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    return nil; // TODO
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return -1; // TODO
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    return -1; // TODO
}

-(GPKGManualFeatureQueryResults *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    return nil; // TODO
}

-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    return -1; // TODO
}

-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minxX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    return nil; // TODO
}

-(int) countWithMinX: (double) minxX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    return -1; // TODO
}

@end
