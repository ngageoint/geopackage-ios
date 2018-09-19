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
        self.chunkLimit = [NSNumber numberWithInt:1000];
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

    SFGeometryEnvelope *envelope = nil;
    
    int offset = 0;
    BOOL hasResults = YES;
    
    while (hasResults) {
        
        hasResults = NO;
        
        GPKGResultSet *resultSet = [self.featureDao queryForChunkWithLimit:[self.chunkLimit intValue] andOffset:offset];
        @try {
            while ([resultSet moveToNext]) {
                hasResults = YES;
                
                GPKGFeatureRow *featureRow = [self.featureDao getFeatureRow:resultSet];
                SFGeometryEnvelope *featureEnvelope = [featureRow getGeometryEnvelope];
                if (featureEnvelope != nil) {
                    
                    if (envelope == nil) {
                        envelope = featureEnvelope;
                    } else {
                        envelope = [envelope unionWithEnvelope:featureEnvelope];
                    }
                    
                }
            }
        } @finally {
            [resultSet close];
        }
        
        offset += [self.chunkLimit intValue];
    }
    
    GPKGBoundingBox *boundingBox = nil;
    if (envelope != nil) {
        boundingBox = [[GPKGBoundingBox alloc] initWithGeometryEnvelope:envelope];
    }
    
    return boundingBox;
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
    return [self queryWithGeometryEnvelope:[boundingBox buildEnvelope]];
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithBoundingBox:featureBoundingBox];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countWithGeometryEnvelope:[boundingBox buildEnvelope]];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self countWithBoundingBox:featureBoundingBox];
}

-(GPKGManualFeatureQueryResults *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryWithMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue]];
}

-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    return [self countWithMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue]];
}

-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{

    NSMutableArray<NSNumber *> *featureIds = [[NSMutableArray alloc] init];
    
    int offset = 0;
    BOOL hasResults = YES;
    
    while (hasResults) {
        
        hasResults = NO;
        
        GPKGResultSet *resultSet = [self.featureDao queryForChunkWithLimit:[self.chunkLimit intValue] andOffset:offset];
        @try {
            while ([resultSet moveToNext]) {
                hasResults = YES;
                
                GPKGFeatureRow *featureRow = [self.featureDao getFeatureRow:resultSet];
                SFGeometryEnvelope *envelope = [featureRow getGeometryEnvelope];
                if (envelope != nil) {
                    
                    double minXMax = MAX(minX, [envelope.minX doubleValue]);
                    double maxXMin = MIN(maxX, [envelope.maxX doubleValue]);
                    double minYMax = MAX(minY, [envelope.minY doubleValue]);
                    double maxYMin = MIN(maxY, [envelope.maxY doubleValue]);
                    
                    if (minXMax <= maxXMin && minYMax <= maxYMin) {
                        [featureIds addObject:[featureRow getId]];
                    }
                    
                }
            }
        } @finally {
            [resultSet close];
        }
        
        offset += [self.chunkLimit intValue];
    }
    
    GPKGManualFeatureQueryResults *results = [[GPKGManualFeatureQueryResults alloc] initWithFeatureDao:self.featureDao andIds:featureIds];
    
    return results;
}

-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    return [[self queryWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY] count];
}

@end
