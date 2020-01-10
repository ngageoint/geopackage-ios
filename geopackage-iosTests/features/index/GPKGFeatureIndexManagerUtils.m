//
//  GPKGFeatureIndexManagerUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/20/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexManagerUtils.h"
#import "GPKGFeatureIndexTypes.h"
#import "GPKGFeatureIndexManager.h"
#import "GPKGTestUtils.h"
#import "SFGeometryEnvelopeBuilder.h"
#import "GPKGTestGeoPackageProgress.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionTransform.h"
#import "SFPProjectionConstants.h"
#import "GPKGFeatureIndexTestEnvelope.h"

@interface GPKGTestTimer : NSObject

@property (nonatomic) int count;
@property (nonatomic) double totalTime;
@property (nonatomic, strong) NSDate *before;
@property (nonatomic) BOOL print;
-(instancetype) init;
-(void) start;
-(void) endWithOutput: (NSString *) output;
-(double) average;
-(NSString *) averageString;
-(void) reset;

@end

@implementation GPKGFeatureIndexManagerUtils

+(void) testIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    [self testIndexWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_GEOPACKAGE andIncludeEmpty:NO];
    [self testIndexWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_METADATA andIncludeEmpty:NO];
    [self testIndexWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_RTREE andIncludeEmpty:YES];
}

+(void) testIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureIndexType: (enum GPKGFeatureIndexType) type andIncludeEmpty: (BOOL) includeEmpty{
    
    // Test indexing each feature table
    NSArray * featureTables = [geoPackage getFeatureTables];
    for(NSString * featureTable in featureTables){
     
        GPKGFeatureDao * featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager * featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager setIndexLocation:type];
        [featureIndexManager deleteAllIndexes];
        
        // Determine how many features have geometry envelopes or geometries
        int expectedCount = 0;
        GPKGFeatureRow * testFeatureRow = nil;
        GPKGResultSet * featureResultSet = [featureDao queryForAll];
        while([featureResultSet moveToNext]){
            GPKGFeatureRow * featureRow = [featureDao getFeatureRow:featureResultSet];
            if([featureRow getGeometryEnvelope] != nil){
                expectedCount++;
                // Randomly choose a feature row with Geometry for testing
                // queries later
                if(testFeatureRow == nil){
                    testFeatureRow = featureRow;
                }else if([GPKGTestUtils randomDouble] < (1.0 / featureResultSet.count)){
                    testFeatureRow = featureRow;
                }
            }else if(includeEmpty){
                expectedCount++;
            }
        }
        [featureResultSet close];

        [GPKGTestUtils assertFalse:[featureIndexManager isIndexed]];
        [GPKGTestUtils assertNil:[featureIndexManager getLastIndexed]];
        NSDate * currentDate = [NSDate date];
        
        [NSThread sleepForTimeInterval:1];
        
        // Test indexing
        GPKGTestGeoPackageProgress * progress = [[GPKGTestGeoPackageProgress alloc] init];
        [featureIndexManager setProgress:progress];
        int indexCount = [featureIndexManager index];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:indexCount];
        [GPKGTestUtils assertEqualIntWithValue:featureDao.count andValue2:progress.progress];
        [GPKGTestUtils assertNotNil:[featureIndexManager getLastIndexed]];
        NSDate * lastIndexed = [featureIndexManager getLastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexed compare:currentDate] == NSOrderedDescending)];
        
        [GPKGTestUtils assertTrue:[featureIndexManager isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:featureIndexManager.count];
        
        // Test re-indexing, both ignored and forced
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[featureIndexManager index]];
        [NSThread sleepForTimeInterval:1];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:[featureIndexManager indexWithForce:true]];
        [GPKGTestUtils assertTrue:([[featureIndexManager getLastIndexed] compare:lastIndexed] == NSOrderedDescending)];
        
        // Query for all indexed geometries
        int resultCount = 0;
        GPKGFeatureIndexResults * featureIndexResults = [featureIndexManager query];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:nil andIncludeEmpty:includeEmpty];
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:resultCount];
        
        // Test the query by envelope
        SFGeometryEnvelope * envelope = [testFeatureRow getGeometryEnvelope];
        double difference = .000001;
        [envelope setMinX:[[NSDecimalNumber alloc ] initWithDouble:([envelope.minX doubleValue] - difference)]];
        [envelope setMaxX:[[NSDecimalNumber alloc ] initWithDouble:([envelope.maxX doubleValue] + difference)]];
        [envelope setMinY:[[NSDecimalNumber alloc ] initWithDouble:([envelope.minY doubleValue] - difference)]];
        [envelope setMaxY:[[NSDecimalNumber alloc ] initWithDouble:([envelope.maxY doubleValue] + difference)]];
        if(envelope.hasZ){
            [envelope setMinZ:[[NSDecimalNumber alloc ] initWithDouble:([envelope.minZ doubleValue] - difference)]];
            [envelope setMaxZ:[[NSDecimalNumber alloc ] initWithDouble:([envelope.maxZ doubleValue] + difference)]];
        }
        if(envelope.hasM){
            [envelope setMinM:[[NSDecimalNumber alloc ] initWithDouble:([envelope.minM doubleValue] - difference)]];
            [envelope setMaxM:[[NSDecimalNumber alloc ] initWithDouble:([envelope.maxM doubleValue] + difference)]];
        }
        resultCount = 0;
        BOOL featureFound = false;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithGeometryEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithGeometryEnvelope:envelope];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = true;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Test the query by envelope with id iteration
        resultCount = 0;
        featureFound = NO;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithGeometryEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithGeometryEnvelope:envelope];
        featureIndexResults.ids = YES;
        for(NSNumber *featureRowId in featureIndexResults){
            GPKGFeatureRow *featureRow = (GPKGFeatureRow *)[featureDao queryForIdObject:featureRowId];
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
            if ([featureRowId intValue] == [testFeatureRow idValue]) {
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Pick a projection different from the feature dao and project the
        // bounding box
        GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:[envelope.minX doubleValue] - 1.0
                                                                       andMinLatitudeDouble:[envelope.minY doubleValue] - 1.0
                                                                      andMaxLongitudeDouble:[envelope.maxX doubleValue] + 1.0
                                                                       andMaxLatitudeDouble:[envelope.maxY doubleValue] + 1.0];
        SFPProjection * projection = nil;
        if(![featureDao.projection isEqualToAuthority:PROJ_AUTHORITY_EPSG andNumberCode:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]]){
            projection = [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        }else{
            projection = [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
        }
        SFPProjectionTransform * transform = [[SFPProjectionTransform alloc] initWithFromProjection:featureDao.projection andToProjection:projection];
        GPKGBoundingBox * transformedBoundingBox = [boundingBox transform:transform];
        
        // Test the query by projected bounding box
        resultCount = 0;
        featureFound = false;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithBoundingBox:transformedBoundingBox inProjection:projection] >= 1];
        featureIndexResults = [featureIndexManager queryWithBoundingBox:transformedBoundingBox inProjection:projection];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = true;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Update a Geometry and update the index of a single feature row
        GPKGGeometryData *geometryData = [[GPKGGeometryData alloc] initWithSrsId:featureDao.geometryColumns.srsId];
        SFPoint * point = [[SFPoint alloc] initWithX:[[NSDecimalNumber alloc] initWithDouble:5.0] andY:[[NSDecimalNumber alloc] initWithDouble:5.0]];
        [geometryData setGeometry:point];
        [testFeatureRow setGeometry:geometryData];
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[featureDao update:testFeatureRow]];
        NSDate * lastIndexedBefore = [featureIndexManager getLastIndexed];
        [NSThread sleepForTimeInterval:1];
        [GPKGTestUtils assertTrue:[featureIndexManager indexWithFeatureRow:testFeatureRow]];
        NSDate * lastIndexedAfter = [featureIndexManager getLastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexedAfter compare:lastIndexedBefore] == NSOrderedDescending)];
        
        // Verify the index was updated for the feature row
        envelope = [SFGeometryEnvelopeBuilder buildEnvelopeWithGeometry:point];
        resultCount = 0;
        featureFound = false;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithGeometryEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithGeometryEnvelope:envelope];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = true;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        [featureIndexManager close];
    }
    
    // Delete the extensions
    BOOL everyOther = false;
    for(NSString * featureTable in featureTables){
        GPKGFeatureDao * featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager * featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager setIndexLocation:type];
        [GPKGTestUtils assertTrue:[featureIndexManager isIndexed]];
        
        // Test deleting a single geometry index
        if (everyOther) {
            GPKGResultSet * featureResults = [featureDao queryForAll];
            while([featureResults moveToNext]){
                GPKGFeatureRow * featureRow = [featureDao getFeatureRow:featureResults];
                if([featureRow getGeometryEnvelope] != nil){
                    [featureResults close];
                    [GPKGTestUtils assertTrue:[featureIndexManager deleteIndexWithFeatureRow:featureRow]];
                    break;
                }
            }
            [featureResults close];
        }
        
        [featureIndexManager deleteIndex];
        
        [GPKGTestUtils assertFalse:[featureIndexManager isIndexed]];
        everyOther = !everyOther;
        
        [featureIndexManager close];
    }
    
}

+(void) validateFeatureRow: (GPKGFeatureRow *) featureRow withFeatureIndexManager: (GPKGFeatureIndexManager *) featureIndexManager andEnvelope: (SFGeometryEnvelope *) queryEnvelope andIncludeEmpty: (BOOL) includeEmpty{
    [GPKGTestUtils assertNotNil:featureRow];
    SFGeometryEnvelope * envelope = [featureRow getGeometryEnvelope];
    
    if(!includeEmpty){
        [GPKGTestUtils assertNotNil:envelope];
        
        if(queryEnvelope != nil){
            [GPKGTestUtils assertTrue:[envelope.minX doubleValue] <= [queryEnvelope.maxX doubleValue]];
            [GPKGTestUtils assertTrue:[envelope.maxX doubleValue] >= [queryEnvelope.minX doubleValue]];
            [GPKGTestUtils assertTrue:[envelope.minY doubleValue] <= [queryEnvelope.maxY doubleValue]];
            [GPKGTestUtils assertTrue:[envelope.maxY doubleValue] >= [queryEnvelope.minY doubleValue]];
            if(envelope.hasZ){
                if(queryEnvelope.hasZ){
                    [GPKGTestUtils assertTrue:[envelope.minZ doubleValue] <= [queryEnvelope.maxZ doubleValue]];
                    [GPKGTestUtils assertTrue:[envelope.maxZ doubleValue] >= [queryEnvelope.minZ doubleValue]];
                }
            }
            if(envelope.hasM){
                if(queryEnvelope.hasM){
                    [GPKGTestUtils assertTrue:[envelope.minM doubleValue] <= [queryEnvelope.maxM doubleValue]];
                    [GPKGTestUtils assertTrue:[envelope.maxM doubleValue] >= [queryEnvelope.minM doubleValue]];
                }
            }
        }
    }
}

+(void) testLargeIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andNumFeatures: (int) numFeatures{
    
    NSString *featureTable = @"large_index";
    
    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:featureTable];
    [geometryColumns setColumnName:@"geom"];
    [geometryColumns setGeometryType:SF_POLYGON];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-180 andMinLatitudeDouble:-90 andMaxLongitudeDouble:180 andMaxLatitudeDouble:90];
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage getSpatialReferenceSystemDao] getOrCreateWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    geometryColumns = [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andBoundingBox:boundingBox andSrsId:srs.srsId];
    
    GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
    
    NSLog(@"Inserting Feature Rows: %d", numFeatures);
    [GPKGTestUtils addRowsToFeatureTableWithGeoPackage:geoPackage andGeometryColumns:geometryColumns andFeatureTable:[featureDao getFeatureTable] andNumRows:numFeatures andHasZ:NO andHasM:NO andAllowEmptyFeatures:NO];
    
    [self testTimedIndexWithGeoPackage:geoPackage andFeatureTable:featureTable andCompareProjectionCounts:YES andVerbose:NO];
    
}

+(void) testTimedIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andCompareProjectionCounts: (BOOL) compareProjectionCounts andVerbose: (BOOL) verbose{
    for(NSString *featureTable in [geoPackage getFeatureTables]){
        [self testTimedIndexWithGeoPackage:geoPackage andFeatureTable:featureTable andCompareProjectionCounts:compareProjectionCounts andVerbose:verbose];
    }
}

+(void) testTimedIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureTable: (NSString *) featureTable andCompareProjectionCounts: (BOOL) compareProjectionCounts andVerbose: (BOOL) verbose{
    
    GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
    
    NSLog(@"Timed Index Test");
    NSLog(@"%@, Features: %d", featureTable, [featureDao count]);
    
    SFGeometryEnvelope *envelope = nil;
    GPKGResultSet *resultSet = [featureDao queryForAll];
    while([resultSet moveToNext]){
        GPKGFeatureRow *featureRow = [featureDao getFeatureRow:resultSet];
        SFGeometryEnvelope *rowEnvelope = [featureRow getGeometryEnvelope];
        if(envelope == nil){
            envelope = rowEnvelope;
        }else if(rowEnvelope != nil){
            envelope = [envelope unionWithEnvelope:rowEnvelope];
        }
    }
    [resultSet close];
    
    NSArray<GPKGFeatureIndexTestEnvelope *> *envelopes = [self createEnvelopesWithEnvelope:envelope];

    resultSet = [featureDao queryForAll];
    while([resultSet moveToNext]){
        GPKGFeatureRow *featureRow = [featureDao getFeatureRow:resultSet];
        SFGeometryEnvelope *rowEnvelope = [featureRow getGeometryEnvelope];
        if(rowEnvelope != nil){
            GPKGBoundingBox *rowBoundingBox = [[GPKGBoundingBox alloc] initWithGeometryEnvelope:rowEnvelope];
            for(GPKGFeatureIndexTestEnvelope *testEnvelope in envelopes){
                if([rowBoundingBox intersects:[[GPKGBoundingBox alloc] initWithGeometryEnvelope:testEnvelope.envelope] withAllowEmpty:YES]){
                    testEnvelope.count++;
                }
            }
        }
    }
    [resultSet close];
    
    [self testTimedIndexWithGeoPackage:geoPackage andType:GPKG_FIT_GEOPACKAGE andDao:featureDao andEnvelopes:envelopes andPrecision:.0000000001 andCompare:compareProjectionCounts andProjectionPrecision:.001 andVerbose:verbose];
    [self testTimedIndexWithGeoPackage:geoPackage andType:GPKG_FIT_METADATA andDao:featureDao andEnvelopes:envelopes andPrecision:.0000000001 andCompare:compareProjectionCounts andProjectionPrecision:.001 andVerbose:verbose];
    [self testTimedIndexWithGeoPackage:geoPackage andType:GPKG_FIT_RTREE andDao:featureDao andEnvelopes:envelopes andInnerPrecision:.0000000001 andOuterPrecision:.0001 andCompare:compareProjectionCounts andProjectionPrecision:.001 andVerbose:verbose];
    [self testTimedIndexWithGeoPackage:geoPackage andType:GPKG_FIT_NONE andDao:featureDao andEnvelopes:envelopes andPrecision:.0000000001 andCompare:compareProjectionCounts andProjectionPrecision:.001 andVerbose:verbose];
}

+(NSArray<GPKGFeatureIndexTestEnvelope *> *) createEnvelopesWithEnvelope: (SFGeometryEnvelope *) envelope{
    NSMutableArray<GPKGFeatureIndexTestEnvelope *> *envelopes = [[NSMutableArray alloc] init];
    for (int percentage = 100; percentage >= 0; percentage -= 10) {
        [envelopes addObject:[self createEnvelopeWithEnvelope:envelope andPercentage:percentage]];
    }
    return envelopes;
}

+(GPKGFeatureIndexTestEnvelope *) createEnvelopeWithEnvelope: (SFGeometryEnvelope *) envelope andPercentage: (int) percentage{
    
    GPKGFeatureIndexTestEnvelope *testEnvelope = [[GPKGFeatureIndexTestEnvelope alloc] init];
    
    double minX;
    double maxX;
    double minY;
    double maxY;
    
    if(percentage < 100){
    
        float percentageRatio = percentage / 100.0f;
        
        double width = [envelope.maxX doubleValue] - [envelope.minX doubleValue];
        double height = [envelope.maxY doubleValue] - [envelope.minY doubleValue];
        
        minX = [envelope.minX doubleValue] + ([GPKGTestUtils randomDouble] * width * (1.0 - percentageRatio));
        minY = [envelope.minY doubleValue] + ([GPKGTestUtils randomDouble] * height * (1.0 - percentageRatio));
        
        maxX = minX + (width * percentageRatio);
        maxY = minY + (height * percentageRatio);
        
    }else{
        minX = [envelope.minX doubleValue];
        maxX = [envelope.maxX doubleValue];
        minY = [envelope.minY doubleValue];
        maxY = [envelope.maxY doubleValue];
    }
    
    testEnvelope.envelope = [[SFGeometryEnvelope alloc] initWithMinXDouble:minX andMinYDouble:minY andMaxXDouble:maxX andMaxYDouble:maxY];
    testEnvelope.percentage = percentage;
    
    return testEnvelope;
}

+(void) testTimedIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andType: (enum GPKGFeatureIndexType) type andDao: (GPKGFeatureDao *) featureDao andEnvelopes: (NSArray<GPKGFeatureIndexTestEnvelope *> *) envelopes andPrecision: (double) precision andCompare: (BOOL) compareProjectionCounts andProjectionPrecision: (double) projectionPrecision andVerbose: (BOOL) verbose{
    [self testTimedIndexWithGeoPackage:geoPackage andType:type andDao:featureDao andEnvelopes:envelopes andInnerPrecision:precision andOuterPrecision:precision andCompare:compareProjectionCounts andProjectionPrecision:projectionPrecision andVerbose:verbose];
}

+(void) testTimedIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andType: (enum GPKGFeatureIndexType) type andDao: (GPKGFeatureDao *) featureDao andEnvelopes: (NSArray<GPKGFeatureIndexTestEnvelope *> *) envelopes andInnerPrecision: (double) innerPrecision andOuterPrecision: (double) outerPrecision andCompare: (BOOL) compareProjectionCounts andProjectionPrecision: (double) projectionPrecision andVerbose: (BOOL) verbose{
    
    NSLog(@"Type: %@", [GPKGFeatureIndexTypes name:type]);
    
    int geometryFeatureCount = [featureDao countWhere:[NSString stringWithFormat:@"%@ IS NOT NULL", [featureDao getGeometryColumnName]]];
    int totalFeatureCount = [featureDao count];
    
    GPKGFeatureIndexManager *featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
    
    @try{
        
        [featureIndexManager setIndexLocation:type];
        [featureIndexManager prioritizeQueryLocationWithType:type];
        
        if(type != GPKG_FIT_NONE){
            [featureIndexManager deleteIndexWithFeatureIndexType:type];
            [GPKGTestUtils assertFalse:[featureIndexManager isIndexedWithFeatureIndexType:type]];
        }else{
            [featureIndexManager setIndexLocationOrderWithTypes:[[NSArray alloc] initWithObjects:[GPKGFeatureIndexTypes name:type], nil]];
            [GPKGTestUtils assertFalse:[featureIndexManager isIndexed]];
        }
        
        GPKGTestTimer *timerQuery = [[GPKGTestTimer alloc] init];
        GPKGTestTimer *timerCount = [[GPKGTestTimer alloc] init];
        timerCount.print = verbose;
        
        if (type != GPKG_FIT_NONE && ![featureIndexManager isIndexedWithFeatureIndexType:type]) {
            [timerQuery start];
            int indexCount = [featureIndexManager index];
            [timerQuery endWithOutput:@"Index"];
            [GPKGTestUtils assertEqualIntWithValue:geometryFeatureCount andValue2:indexCount];
            [GPKGTestUtils assertTrue:[featureIndexManager isIndexed]];
        }
        
        [timerCount start];
        int queryCount = [featureIndexManager count];
        [timerCount endWithOutput:@"Count Query"];
        [GPKGTestUtils assertTrue:queryCount == geometryFeatureCount || queryCount == totalFeatureCount];
        
        SFPProjection *projection = featureDao.projection;
        SFPProjection *webMercatorProjection = [SFPProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_EPSG andIntCode:PROJ_EPSG_WEB_MERCATOR];
        SFPProjectionTransform *transformToWebMercator = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:webMercatorProjection];
        SFPProjectionTransform *transformToProjection = [[SFPProjectionTransform alloc] initWithFromProjection:webMercatorProjection andToProjection:projection];
        
        [timerCount start];
        GPKGBoundingBox *bounds = [featureIndexManager boundingBox];
        [timerCount endWithOutput:@"Bounds Query"];
        [GPKGTestUtils assertNotNil:bounds];
        GPKGFeatureIndexTestEnvelope *firstEnvelope = [envelopes objectAtIndex:0];
        GPKGBoundingBox *firstBounds = [[GPKGBoundingBox alloc] initWithGeometryEnvelope:firstEnvelope.envelope];

        [self assertRangeWithExpected:firstBounds.minLongitude andActual:bounds.minLongitude andLowPrecision:outerPrecision andHighPrecision:innerPrecision];
        [self assertRangeWithExpected:firstBounds.minLatitude andActual:bounds.minLatitude andLowPrecision:outerPrecision andHighPrecision:innerPrecision];
        [self assertRangeWithExpected:firstBounds.maxLongitude andActual:bounds.maxLongitude andLowPrecision:innerPrecision andHighPrecision:outerPrecision];
        [self assertRangeWithExpected:firstBounds.maxLatitude andActual:bounds.maxLatitude andLowPrecision:innerPrecision andHighPrecision:outerPrecision];

        [timerCount start];
        GPKGBoundingBox *projectedBounds = [featureIndexManager boundingBoxInProjection:webMercatorProjection];
        [timerCount endWithOutput:@"Bounds Projection Query"];
        [GPKGTestUtils assertNotNil:projectedBounds];
        GPKGBoundingBox *reprojectedBounds = [projectedBounds transform:transformToProjection];
        
        [self assertRangeWithExpected:firstBounds.minLongitude andActual:reprojectedBounds.minLongitude andLowPrecision:projectionPrecision andHighPrecision:projectionPrecision];
        [self assertRangeWithExpected:firstBounds.minLatitude andActual:reprojectedBounds.minLatitude andLowPrecision:projectionPrecision andHighPrecision:projectionPrecision];
        [self assertRangeWithExpected:firstBounds.maxLongitude andActual:reprojectedBounds.maxLongitude andLowPrecision:projectionPrecision andHighPrecision:projectionPrecision];
        [self assertRangeWithExpected:firstBounds.maxLatitude andActual:reprojectedBounds.maxLatitude andLowPrecision:projectionPrecision andHighPrecision:projectionPrecision];
        
        [timerQuery reset];
        [timerCount reset];
        
        timerQuery.print = timerCount.print;
        
        for(GPKGFeatureIndexTestEnvelope *testEnvelope in envelopes){
            
            NSString *percentage = [NSString stringWithFormat:@"%d", testEnvelope.percentage];
            SFGeometryEnvelope *envelope = testEnvelope.envelope;
            int expectedCount = testEnvelope.count;
            
            if(verbose){
                NSLog(@"%@%% Feature Count: %d", percentage, expectedCount);
            }
            
            [timerCount start];
            int fullCount = [featureIndexManager countWithGeometryEnvelope:envelope];
            [timerCount endWithOutput:[NSString stringWithFormat:@"%@%% Envelope Count Query", percentage]];
            [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:fullCount];
            
            [timerQuery start];
            GPKGFeatureIndexResults *results = [featureIndexManager queryWithGeometryEnvelope:envelope];
            [timerQuery endWithOutput:[NSString stringWithFormat:@"%@%% Envelope Query", percentage]];
            [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:[results count]];
            [results close];
            
            GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithGeometryEnvelope:envelope];
            [timerCount start];
            fullCount = [featureIndexManager countWithBoundingBox:boundingBox];
            [timerCount endWithOutput:[NSString stringWithFormat:@"%@%% Bounding Box Count Query", percentage]];
            [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:fullCount];
            
            [timerQuery start];
            results = [featureIndexManager queryWithBoundingBox:boundingBox];
            [timerQuery endWithOutput:[NSString stringWithFormat:@"%@%% Bounding Box Query", percentage]];
            [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:[results count]];
            [results close];
            
            GPKGBoundingBox *webMercatorBoundingBox = [boundingBox transform:transformToWebMercator];
            [timerCount start];
            fullCount = [featureIndexManager countWithBoundingBox:webMercatorBoundingBox inProjection:webMercatorProjection];
            [timerCount endWithOutput:[NSString stringWithFormat:@"%@%% Projected Bounding Box Count Query", percentage]];
            if (compareProjectionCounts) {
                [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:fullCount];
            }
            
            [timerQuery start];
            results = [featureIndexManager queryWithBoundingBox:webMercatorBoundingBox inProjection:webMercatorProjection];
            [timerQuery endWithOutput:[NSString stringWithFormat:@"%@%% Projected Bounding Box Query", percentage]];
            if (compareProjectionCounts) {
                [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:[results count]];
            }
            [results close];
        }
        
        NSLog(@"Average Count: %@ s", [timerCount averageString]);
        NSLog(@"Average Query: %@ s", [timerQuery averageString]);
    }@finally{
        [featureIndexManager close];
    }
    
}

+(void) assertCountsWithManager: (GPKGFeatureIndexManager *) featureIndexManager andEnvelope: (GPKGFeatureIndexTestEnvelope *) testEnvelope andType: (enum GPKGFeatureIndexType) type andPrecision: (double) precision andExpected: (int) expectedCount andFull: (int) fullCount{
    
    switch (type) {
        case GPKG_FIT_RTREE:
            
            if (expectedCount != fullCount) {
                int count = 0;
                GPKGFeatureIndexResults *results = [featureIndexManager queryWithGeometryEnvelope:testEnvelope.envelope];
                for (GPKGFeatureRow *featureRow in results) {
                    SFGeometryEnvelope *envelope = [featureRow getGeometryEnvelope];
                    if([envelope intersectsWithEnvelope:testEnvelope.envelope withAllowEmpty:YES]){
                        count++;
                    } else {
                        SFGeometryEnvelope *adjustedEnvelope = [[SFGeometryEnvelope alloc] initWithMinXDouble:[envelope.minX doubleValue] - precision andMinYDouble:[envelope.minY doubleValue] - precision andMaxXDouble:[envelope.maxX doubleValue] + precision andMaxYDouble:[envelope.maxY doubleValue] + precision];
                        [GPKGTestUtils assertTrue:[adjustedEnvelope intersectsWithEnvelope:testEnvelope.envelope withAllowEmpty:YES]];
                    }
                }
                [results close];
                [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:count];
            }
            
            break;
        default:
            [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:fullCount];
    }
    
}

+(void) assertRangeWithExpected: (NSDecimalNumber *) expected andActual: (NSDecimalNumber *) actual andLowPrecision: (double) lowPrecision andHighPrecision: (double) highPrecision{
    double low = [expected doubleValue] - lowPrecision;
    double high = [expected doubleValue]  + highPrecision;
    [GPKGTestUtils assertTrue:low <= [actual doubleValue]  && [actual doubleValue] <= high];
}

@end

@implementation GPKGTestTimer

-(instancetype) init{
    self = [super init];
    if(self != nil){
        [self reset];
        self.print = YES;
    }
    return self;
}

-(void) start{
    self.before = [NSDate date];
}

-(void) endWithOutput: (NSString *) output{
    double time = -[self.before timeIntervalSinceNow];
    self.count++;
    self.totalTime += time;
    self.before = nil;
    if(self.print){
        NSLog(@"%@: %f s", output, time);
    }
}

-(double) average{
    return (double) self.totalTime / self.count;
}

-(NSString *) averageString{
    return [NSString stringWithFormat:@"%.2f", [self average]];
}

-(void) reset{
    self.count = 0;
    self.totalTime = 0;
    self.before = nil;
}

@end
