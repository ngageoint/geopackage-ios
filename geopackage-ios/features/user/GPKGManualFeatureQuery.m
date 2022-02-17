//
//  GPKGManualFeatureQuery.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/11/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGManualFeatureQuery.h"
#import "GPKGSqlUtils.h"

@interface GPKGManualFeatureQuery ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;

@end

@implementation GPKGManualFeatureQuery

-(instancetype)initWithFeatureDao:(GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self != nil){
        self.featureDao = featureDao;
        self.chunkLimit = 1000;
        self.tolerance = .00000000000001;
    }
    return self;
}

-(GPKGFeatureDao *) featureDao{
    return _featureDao;
}

-(GPKGResultSet *) query{
    return [self.featureDao query];
}

-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct{
    return [self.featureDao queryWithDistinct:distinct];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns{
    return [self.featureDao queryWithColumns:columns];
}

-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns{
    return [self.featureDao queryWithDistinct:distinct andColumns:columns];
}

-(int) count{
    return [self.featureDao count];
}

-(int) countWithGeometries{
    return [self.featureDao countWhere:[NSString stringWithFormat:@"%@ IS NOT NULL", [GPKGSqlUtils quoteWrapName:[self.featureDao geometryColumnName]]]];
}

-(int) countWithColumn: (NSString *) column{
    return [self.featureDao countWithColumn:column];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column{
    return [self.featureDao countWithDistinct:distinct andColumn:column];
}

-(GPKGResultSet *) queryWithFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self.featureDao queryWithDistinct:distinct andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andColumns:columns andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self.featureDao queryWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:NO andColumn:nil andFieldValues:fieldValues];
}

-(int) countWithColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:NO andColumn:column andFieldValues:fieldValues];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self.featureDao countWithDistinct:distinct andColumn:column andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryWhere: (NSString *) where{
    return [self.featureDao queryWhere:where];
}

-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andWhere: (NSString *) where{
    return [self.featureDao queryWithDistinct:distinct andWhere:where];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self.featureDao queryWithColumns:columns andWhere:where];
}

-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self.featureDao queryWithDistinct:distinct andColumns:columns andWhere:where];
}

-(int) countWhere: (NSString *) where{
    return [self.featureDao countWhere:where];
}

-(int) countWithColumn: (NSString *) column andWhere: (NSString *) where{
    return [self.featureDao countWithColumn:column andWhere:where];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where{
    return [self.featureDao countWithDistinct:distinct andColumn:column andWhere:where];
}

-(GPKGResultSet *) queryWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryWithDistinct:distinct andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryWithColumns:columns andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs];
}

-(int) countWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao countWhere:where andWhereArgs:whereArgs];
}

-(int) countWithColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao countWithColumn:column andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao countWithDistinct:distinct andColumn:column andWhere:where andWhereArgs:whereArgs];
}

-(GPKGBoundingBox *) boundingBox{

    SFGeometryEnvelope *envelope = nil;
    
    int offset = 0;
    BOOL hasResults = YES;
    
    NSArray<NSString *> *columns = [NSArray arrayWithObject:[self.featureDao geometryColumnName]];
    
    while (hasResults) {
        
        hasResults = NO;
        
        GPKGResultSet *resultSet = [self.featureDao queryForChunkWithColumns:columns andLimit:self.chunkLimit andOffset:offset];
        @try {
            while ([resultSet moveToNext]) {
                hasResults = YES;
                
                GPKGFeatureRow *featureRow = [self.featureDao row:resultSet];
                SFGeometryEnvelope *featureEnvelope = [featureRow geometryEnvelope];
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
        
        offset += self.chunkLimit;
    }
    
    GPKGBoundingBox *boundingBox = nil;
    if (envelope != nil) {
        boundingBox = [[GPKGBoundingBox alloc] initWithEnvelope:envelope];
    }
    
    return boundingBox;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (PROJProjection *) projection{
    GPKGBoundingBox *boundingBox = [self boundingBox];
    if(boundingBox != nil && projection != nil){
        SFPGeometryTransform *projectionTransform = [SFPGeometryTransform transformFromProjection:self.featureDao.projection andToProjection:projection];
        boundingBox = [boundingBox transform:projectionTransform];
    }
    return boundingBox;
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope]];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope]];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countWithEnvelope:[boundingBox buildEnvelope]];
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox andWhere:where];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andWhere:where];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self countWithBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:distinct andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox inProjection:projection];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andBoundingBox:featureBoundingBox];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self countWithBoundingBox:featureBoundingBox];
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self countWithBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self countWithBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self countWithBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryWithDistinct:NO andEnvelope:envelope];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryWithDistinct:distinct andMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue]];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryWithDistinct:NO andColumns:columns andEnvelope:envelope];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryWithDistinct:distinct andColumns:columns andMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue]];
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self countWithMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue]];
}

-(GPKGManualFeatureQueryResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andEnvelope:envelope andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:distinct andMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue] andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andColumns:columns andEnvelope:envelope andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:distinct andColumns:columns andMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue] andFieldValues:fieldValues];
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue] andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andEnvelope:envelope andWhere:where];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andColumns:columns andEnvelope:envelope andWhere:where];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self countWithEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(GPKGManualFeatureQueryResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:distinct andMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:distinct andColumns:columns andMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue] andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    return [self queryWithDistinct:NO andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    return [self queryWithDistinct:distinct andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:nil andWhereArgs:nil];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    return [self queryWithDistinct:NO andColumns:columns andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    return [self queryWithDistinct:distinct andColumns:columns andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:nil andWhereArgs:nil];
}

-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    return [[self queryWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY] count];
}

-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryWithDistinct:distinct andMinX:minX andMinY:minY andMaxX:maxY andMaxY:maxY andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andColumns:columns andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andFieldValues:fieldValues];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryWithDistinct:distinct andColumns:columns andMinX:minX andMinY:minY andMaxX:maxY andMaxY:maxY andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self countWithMinX:minX andMinY:minY andMaxX:maxY andMaxY:maxY andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:where];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:where andWhereArgs:nil];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andColumns:columns andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:where];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andColumns:columns andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:where andWhereArgs:nil];
}

-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where{
    return [self countWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:where andWhereArgs:nil];
}

-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:distinct andColumns:[self.featureDao columnNames] andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andColumns:columns andMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:where andWhereArgs:whereArgs];
}

-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    
    NSMutableArray<NSNumber *> *featureIds = [NSMutableArray array];
    
    int offset = 0;
    BOOL hasResults = YES;
    
    minX -= self.tolerance;
    maxX += self.tolerance;
    minY -= self.tolerance;
    maxY += self.tolerance;
    
    NSArray<NSString *> *queryColumns = [self.featureDao idAndGeometryColumnNames];
    
    while (hasResults) {
        
        hasResults = NO;
        
        GPKGResultSet *resultSet = [self.featureDao queryForChunkWithDistinct:distinct andColumns:queryColumns andWhere:where andWhereArgs:whereArgs andLimit:self.chunkLimit andOffset:offset];
        @try {
            while ([resultSet moveToNext]) {
                hasResults = YES;
                
                GPKGFeatureRow *featureRow = [self.featureDao row:resultSet];
                SFGeometryEnvelope *envelope = [featureRow geometryEnvelope];
                if (envelope != nil) {
                    
                    double minXMax = MAX(minX, [envelope.minX doubleValue]);
                    double maxXMin = MIN(maxX, [envelope.maxX doubleValue]);
                    double minYMax = MAX(minY, [envelope.minY doubleValue]);
                    double maxYMin = MIN(maxY, [envelope.maxY doubleValue]);
                    
                    if (minXMax <= maxXMin && minYMax <= maxYMin) {
                        [featureIds addObject:[featureRow id]];
                    }
                    
                }
            }
        } @finally {
            [resultSet close];
        }
        
        offset += self.chunkLimit;
    }
    
    GPKGManualFeatureQueryResults *results = [[GPKGManualFeatureQueryResults alloc] initWithFeatureDao:self.featureDao andColumns:columns andIds:featureIds];
    
    return results;
}

-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [[self queryWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY andWhere:where andWhereArgs:whereArgs] count];
}

@end
