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
#import "GPKGTestGeoPackageProgress.h"
#import "PROJProjectionFactory.h"
#import "PROJProjectionConstants.h"
#import "GPKGFeatureIndexTestEnvelope.h"
#import "GPKGGeoPackageTestUtils.h"

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
    NSArray * featureTables = [geoPackage featureTables];
    for(NSString * featureTable in featureTables){
     
        GPKGFeatureDao * featureDao = [geoPackage featureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager * featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager setContinueOnError:NO];
        [featureIndexManager setIndexLocation:type];
        [featureIndexManager deleteAllIndexes];
        
        // Determine how many features have geometry envelopes or geometries
        int expectedCount = 0;
        GPKGFeatureRow * testFeatureRow = nil;
        GPKGResultSet * featureResultSet = [featureDao query];
        while([featureResultSet moveToNext]){
            GPKGFeatureRow * featureRow = [featureDao row:featureResultSet];
            if([featureRow geometryEnvelope] != nil){
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
        [GPKGTestUtils assertNil:[featureIndexManager lastIndexed]];
        NSDate * currentDate = [NSDate date];
        
        [NSThread sleepForTimeInterval:1];
        
        // Test indexing
        GPKGTestGeoPackageProgress * progress = [[GPKGTestGeoPackageProgress alloc] init];
        [featureIndexManager setProgress:progress];
        int indexCount = [featureIndexManager index];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:indexCount];
        [GPKGTestUtils assertEqualIntWithValue:featureDao.count andValue2:progress.progress];
        [GPKGTestUtils assertNotNil:[featureIndexManager lastIndexed]];
        NSDate * lastIndexed = [featureIndexManager lastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexed compare:currentDate] == NSOrderedDescending)];
        
        [GPKGTestUtils assertTrue:[featureIndexManager isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:featureIndexManager.count];
        
        // Test re-indexing, both ignored and forced
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[featureIndexManager index]];
        [NSThread sleepForTimeInterval:1];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:[featureIndexManager indexWithForce:YES]];
        [GPKGTestUtils assertTrue:([[featureIndexManager lastIndexed] compare:lastIndexed] == NSOrderedDescending)];
        
        // Query for all indexed geometries
        int resultCount = 0;
        GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager query];
        for(GPKGFeatureRow *featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:nil andIncludeEmpty:includeEmpty];
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:resultCount];
        
        // Query for all indexed geometries with columns
        resultCount = 0;
        featureIndexResults = [featureIndexManager queryWithColumns:[featureDao idAndGeometryColumnNames]];
        for(GPKGFeatureRow *featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:nil andIncludeEmpty:includeEmpty];
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:resultCount];
        
        // Test the query by envelope
        SFGeometryEnvelope * envelope = [testFeatureRow geometryEnvelope];
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
        BOOL featureFound = NO;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithEnvelope:envelope];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        resultCount = 0;
        featureFound = NO;
        featureIndexResults = [featureIndexManager queryWithColumns:[featureDao idAndGeometryColumnNames] andEnvelope:envelope];
        for(GPKGFeatureRow *featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Test the query by envelope with id iteration
        resultCount = 0;
        featureFound = NO;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithEnvelope:envelope];
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
        PROJProjection * projection = nil;
        if(![featureDao.projection isEqualToAuthority:PROJ_AUTHORITY_EPSG andNumberCode:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]]){
            projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        }else{
            projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
        }
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromProjection:featureDao.projection andToProjection:projection];
        GPKGBoundingBox *transformedBoundingBox = [boundingBox transform:transform];
        
        // Test the query by projected bounding box
        resultCount = 0;
        featureFound = NO;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithBoundingBox:transformedBoundingBox inProjection:projection] >= 1];
        featureIndexResults = [featureIndexManager queryWithBoundingBox:transformedBoundingBox inProjection:projection];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        resultCount = 0;
        featureFound = NO;
        featureIndexResults = [featureIndexManager queryWithColumns:[featureDao idAndGeometryColumnNames] andBoundingBox:transformedBoundingBox inProjection:projection];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Test query by criteria
        GPKGFeatureTable *table = [featureDao featureTable];
        NSArray<GPKGUserColumn *> *columns = [table columns];
        
        NSMutableDictionary *numbers = [NSMutableDictionary dictionary];
        NSMutableDictionary *strings = [NSMutableDictionary dictionary];
        
        for(GPKGFeatureColumn *column in columns){
            if(column.primaryKey || column.isGeometry){
                continue;
            }
            enum GPKGDataType dataType = column.dataType;
            switch (dataType) {
                case GPKG_DT_DOUBLE:
                case GPKG_DT_FLOAT:
                case GPKG_DT_INT:
                case GPKG_DT_INTEGER:
                case GPKG_DT_TINYINT:
                case GPKG_DT_SMALLINT:
                case GPKG_DT_MEDIUMINT:
                case GPKG_DT_REAL:
                    [numbers setObject:[NSNull null] forKey:column.name];
                    break;
                case GPKG_DT_TEXT:
                    [strings setObject:[NSNull null] forKey:column.name];
                break;
            default:
                break;
            }
        }

        for(NSString *number in [numbers allKeys]){
            NSObject *value = [testFeatureRow valueWithColumnName:number];
            [numbers setObject:value forKey:number];
        }
        
        for(NSString *string in [strings allKeys]){
            NSString *value = [testFeatureRow valueStringWithColumnName:string];
            [strings setObject:value forKey:string];
        }

        for(NSString *column in [numbers allKeys]){
            
            double value = [((NSNumber *)[numbers objectForKey:column]) doubleValue];
            
            NSString *where = [NSString stringWithFormat:@"%@ >= ? AND %@ <= ?", column, column];
            NSArray *whereArgs = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", value - 0.001],
                                  [NSString stringWithFormat:@"%f", value + 0.001], nil];

            int count = [featureIndexManager countWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertTrue:count >= 1];
            featureIndexResults = [featureIndexManager queryWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
            }
            [featureIndexResults close];
            featureIndexResults = [featureIndexManager queryWithColumns:[NSArray arrayWithObject:column] andWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
            }
            [featureIndexResults close];

            resultCount = 0;
            featureFound = NO;

            count = [featureIndexManager countWithBoundingBox:transformedBoundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertTrue:count >= 1];
            featureIndexResults = [featureIndexManager queryWithBoundingBox:transformedBoundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                resultCount++;
            }
            [featureIndexResults close];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];

            resultCount = 0;
            featureFound = NO;

            featureIndexResults = [featureIndexManager queryWithColumns:
                                   [NSArray arrayWithObjects:[featureDao geometryColumnName], column, [featureDao idColumnName], nil]
                                 andBoundingBox:transformedBoundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                resultCount++;
            }
            [featureIndexResults close];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];
        }

        for(NSString *column in [strings allKeys]){
            
            NSString *value = (NSString *)[strings objectForKey:column];

            GPKGColumnValues *fieldValues = [[GPKGColumnValues alloc] init];
            [fieldValues addColumn:column withValue:value];

            int count = [featureIndexManager countWithFieldValues:fieldValues];
            [GPKGTestUtils assertTrue:count >= 1];
            featureIndexResults = [featureIndexManager queryWithFieldValues:fieldValues];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
            }
            [featureIndexResults close];
            featureIndexResults = [featureIndexManager queryWithColumns:[NSArray arrayWithObject:column] andFieldValues:fieldValues];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
            }
            [featureIndexResults close];

            resultCount = 0;
            featureFound = NO;

            count = [featureIndexManager countWithBoundingBox:transformedBoundingBox inProjection:projection andFieldValues:fieldValues];
            [GPKGTestUtils assertTrue:count >= 1];
            featureIndexResults = [featureIndexManager queryWithBoundingBox:transformedBoundingBox inProjection:projection andFieldValues:fieldValues];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                resultCount++;
            }
            [featureIndexResults close];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];

            resultCount = 0;
            featureFound = NO;

            featureIndexResults = [featureIndexManager queryWithColumns:
                                     [NSArray arrayWithObjects:column, [featureDao idColumnName], [featureDao geometryColumnName], nil]
                                     andBoundingBox:transformedBoundingBox inProjection:projection andFieldValues:fieldValues];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                resultCount++;
            }
            [featureIndexResults close];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];

        }
        
        // Update a Geometry and update the index of a single feature row
        SFPoint *point = [[SFPoint alloc] initWithX:[[NSDecimalNumber alloc] initWithDouble:5.0] andY:[[NSDecimalNumber alloc] initWithDouble:5.0]];
        GPKGGeometryData *geometryData = [GPKGGeometryData createWithSrsId:featureDao.geometryColumns.srsId andGeometry:point];
        [testFeatureRow setGeometry:geometryData];
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[featureDao update:testFeatureRow]];
        NSDate *lastIndexedBefore = [featureIndexManager lastIndexed];
        [NSThread sleepForTimeInterval:1];
        [GPKGTestUtils assertTrue:[featureIndexManager indexWithFeatureRow:testFeatureRow]];
        NSDate *lastIndexedAfter = [featureIndexManager lastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexedAfter compare:lastIndexedBefore] == NSOrderedDescending)];
        
        // Verify the index was updated for the feature row
        envelope = [point envelope];
        resultCount = 0;
        featureFound = NO;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithEnvelope:envelope];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        [featureIndexManager close];
    }
    
    // Delete the extensions
    BOOL everyOther = NO;
    for(NSString * featureTable in featureTables){
        GPKGFeatureDao * featureDao = [geoPackage featureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager * featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager setIndexLocation:type];
        [GPKGTestUtils assertTrue:[featureIndexManager isIndexed]];
        
        // Test deleting a single geometry index
        if (everyOther) {
            GPKGResultSet * featureResults = [featureDao query];
            while([featureResults moveToNext]){
                GPKGFeatureRow * featureRow = [featureDao row:featureResults];
                if([featureRow geometryEnvelope] != nil){
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

+(void) testIndexChunkWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    [self testIndexChunkWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_GEOPACKAGE andIncludeEmpty:NO];
    [self testIndexChunkWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_METADATA andIncludeEmpty:NO];
    [self testIndexChunkWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_RTREE andIncludeEmpty:YES];
}

+(void) testIndexChunkWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureIndexType: (enum GPKGFeatureIndexType) type andIncludeEmpty: (BOOL) includeEmpty{
    
    // Test indexing each feature table
    NSArray * featureTables = [geoPackage featureTables];
    for(NSString * featureTable in featureTables){
     
        GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager * featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager setContinueOnError:NO];
        [featureIndexManager setIndexLocation:type];
        [featureIndexManager deleteAllIndexes];
        
        // Determine how many features have geometry envelopes or geometries
        int expectedCount = 0;
        GPKGFeatureRow *testFeatureRow = nil;
        GPKGResultSet *featureResultSet = [featureDao query];
        while([featureResultSet moveToNext]){
            GPKGFeatureRow * featureRow = [featureDao row:featureResultSet];
            if([featureRow geometryEnvelope] != nil){
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
        
        // Test indexing
        int indexCount = [featureIndexManager index];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:indexCount];
        
        [GPKGTestUtils assertTrue:[featureIndexManager isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:featureIndexManager.count];
        
        // Query for all indexed geometries
        int resultCount = 0;
        int chunkLimit = 3;
        int offset = 0;
        int lastCount = -1;
        while(lastCount != 0){
            lastCount = 0;
            GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithLimit:chunkLimit andOffset:offset];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:nil andIncludeEmpty:includeEmpty];
                lastCount++;
            }
            [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
            [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
            [featureIndexResults close];
            resultCount += lastCount;
            offset += chunkLimit;
        }
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:resultCount];
        
        // Query for all indexed geometries with columns
        resultCount = 0;
        chunkLimit = 5;
        offset = 0;
        lastCount = -1;
        while(lastCount != 0){
            lastCount = 0;
            GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithColumns:[featureDao idAndGeometryColumnNames] andLimit:chunkLimit andOffset:offset];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:nil andIncludeEmpty:includeEmpty];
                lastCount++;
            }
            [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
            [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
            [featureIndexResults close];
            resultCount += lastCount;
            offset += chunkLimit;
        }
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:resultCount];
        
        // Test the query by envelope
        SFGeometryEnvelope * envelope = [testFeatureRow geometryEnvelope];
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
        BOOL featureFound = NO;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithEnvelope:envelope] >= 1];
        resultCount = 0;
        chunkLimit = 2;
        offset = 0;
        lastCount = -1;
        while(lastCount != 0){
            lastCount = 0;
            GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithEnvelope:envelope andLimit:chunkLimit andOffset:offset];
            for(GPKGFeatureRow * featureRow in featureIndexResults){
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                lastCount++;
            }
            [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
            [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
            [featureIndexResults close];
            resultCount += lastCount;
            offset += chunkLimit;
        }
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        featureFound = NO;
        resultCount = 0;
        chunkLimit = 4;
        offset = 0;
        lastCount = -1;
        while(lastCount != 0){
            lastCount = 0;
            GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithColumns:[featureDao idAndGeometryColumnNames] andEnvelope:envelope andLimit:chunkLimit andOffset:offset];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                lastCount++;
            }
            [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
            [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
            [featureIndexResults close];
            resultCount += lastCount;
            offset += chunkLimit;
        }
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Test the query by envelope with id iteration
        featureFound = NO;
        resultCount = 0;
        chunkLimit = 1;
        offset = 0;
        lastCount = -1;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithEnvelope:envelope] >= 1];
        while(lastCount != 0){
            lastCount = 0;
            GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithEnvelope:envelope andLimit:chunkLimit andOffset:offset];
            featureIndexResults.ids = YES;
            for(NSNumber *featureRowId in featureIndexResults){
                GPKGFeatureRow *featureRow = (GPKGFeatureRow *)[featureDao queryForIdObject:featureRowId];
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
                if ([featureRowId intValue] == [testFeatureRow idValue]) {
                    featureFound = YES;
                }
                lastCount++;
            }
            [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
            [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
            [featureIndexResults close];
            resultCount += lastCount;
            offset += chunkLimit;
        }
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Pick a projection different from the feature dao and project the
        // bounding box
        GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:[envelope.minX doubleValue] - 1.0
                                                                       andMinLatitudeDouble:[envelope.minY doubleValue] - 1.0
                                                                      andMaxLongitudeDouble:[envelope.maxX doubleValue] + 1.0
                                                                       andMaxLatitudeDouble:[envelope.maxY doubleValue] + 1.0];
        PROJProjection * projection = nil;
        if(![featureDao.projection isEqualToAuthority:PROJ_AUTHORITY_EPSG andNumberCode:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]]){
            projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        }else{
            projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
        }
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromProjection:featureDao.projection andToProjection:projection];
        GPKGBoundingBox *transformedBoundingBox = [boundingBox transform:transform];
        
        // Test the query by projected bounding box
        featureFound = NO;
        resultCount = 0;
        chunkLimit = 10;
        offset = 0;
        lastCount = -1;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithBoundingBox:transformedBoundingBox inProjection:projection] >= 1];
        while(lastCount != 0){
            lastCount = 0;
            GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithBoundingBox:transformedBoundingBox inProjection:projection andLimit:chunkLimit andOffset:offset];
            for(GPKGFeatureRow * featureRow in featureIndexResults){
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                lastCount++;
            }
            [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
            [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
            [featureIndexResults close];
            resultCount += lastCount;
            offset += chunkLimit;
        }
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        featureFound = NO;
        resultCount = 0;
        chunkLimit = 100;
        offset = 0;
        lastCount = -1;
        while (lastCount != 0) {
            lastCount = 0;
            GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithColumns:[featureDao idAndGeometryColumnNames] andBoundingBox:transformedBoundingBox inProjection:projection andLimit:chunkLimit andOffset:offset];
            for(GPKGFeatureRow * featureRow in featureIndexResults){
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                lastCount++;
            }
            [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
            [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
            [featureIndexResults close];
            resultCount += lastCount;
            offset += chunkLimit;
        }
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Test query by criteria
        GPKGFeatureTable *table = [featureDao featureTable];
        NSArray<GPKGUserColumn *> *columns = [table columns];
        
        NSMutableDictionary *numbers = [NSMutableDictionary dictionary];
        NSMutableDictionary *strings = [NSMutableDictionary dictionary];
        
        for(GPKGFeatureColumn *column in columns){
            if(column.primaryKey || column.isGeometry){
                continue;
            }
            enum GPKGDataType dataType = column.dataType;
            switch (dataType) {
                case GPKG_DT_DOUBLE:
                case GPKG_DT_FLOAT:
                case GPKG_DT_INT:
                case GPKG_DT_INTEGER:
                case GPKG_DT_TINYINT:
                case GPKG_DT_SMALLINT:
                case GPKG_DT_MEDIUMINT:
                case GPKG_DT_REAL:
                    [numbers setObject:[NSNull null] forKey:column.name];
                    break;
                case GPKG_DT_TEXT:
                    [strings setObject:[NSNull null] forKey:column.name];
                break;
            default:
                break;
            }
        }

        for(NSString *number in [numbers allKeys]){
            NSObject *value = [testFeatureRow valueWithColumnName:number];
            [numbers setObject:value forKey:number];
        }
        
        for(NSString *string in [strings allKeys]){
            NSString *value = [testFeatureRow valueStringWithColumnName:string];
            [strings setObject:value forKey:string];
        }

        for(NSString *column in [numbers allKeys]){
            
            double value = [((NSNumber *)[numbers objectForKey:column]) doubleValue];
            
            NSString *where = [NSString stringWithFormat:@"%@ >= ? AND %@ <= ?", column, column];
            NSArray *whereArgs = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", value - 0.001],
                                  [NSString stringWithFormat:@"%f", value + 0.001], nil];

            int count = [featureIndexManager countWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertTrue:count >= 1];
            resultCount = 0;
            chunkLimit = 5;
            offset = 0;
            lastCount = -1;
            while (lastCount != 0) {
                lastCount = 0;
                GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithWhere:where andWhereArgs:whereArgs andLimit:chunkLimit andOffset:offset];
                for(GPKGFeatureRow *featureRow in featureIndexResults){
                    [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
                    lastCount++;
                }
                [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
                [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
                [featureIndexResults close];
                resultCount += lastCount;
                offset += chunkLimit;
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:resultCount];
            resultCount = 0;
            chunkLimit = 25;
            offset = 0;
            lastCount = -1;
            while (lastCount != 0) {
                lastCount = 0;
                GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithColumns:[NSArray arrayWithObject:column] andWhere:where andWhereArgs:whereArgs andLimit:chunkLimit andOffset:offset];
                for(GPKGFeatureRow *featureRow in featureIndexResults){
                    [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
                    lastCount++;
                }
                [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
                [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
                [featureIndexResults close];
                resultCount += lastCount;
                offset += chunkLimit;
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:resultCount];

            count = [featureIndexManager countWithBoundingBox:transformedBoundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertTrue:count >= 1];
            featureFound = NO;
            resultCount = 0;
            chunkLimit = 1;
            offset = 0;
            lastCount = -1;
            while (lastCount != 0) {
                lastCount = 0;
                GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithBoundingBox:transformedBoundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andLimit:chunkLimit andOffset:offset];
                for(GPKGFeatureRow *featureRow in featureIndexResults){
                    [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
                    [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                    if([featureRow idValue] == [testFeatureRow idValue]){
                        featureFound = YES;
                    }
                    lastCount++;
                }
                [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
                [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
                [featureIndexResults close];
                resultCount += lastCount;
                offset += chunkLimit;
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:resultCount];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];

            featureFound = NO;
            resultCount = 0;
            chunkLimit = 3;
            offset = 0;
            lastCount = -1;
            while (lastCount != 0) {
                lastCount = 0;
                GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithColumns:
                                   [NSArray arrayWithObjects:[featureDao geometryColumnName], column, [featureDao idColumnName], nil]
                                 andBoundingBox:transformedBoundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andLimit:chunkLimit andOffset:offset];
                for(GPKGFeatureRow *featureRow in featureIndexResults){
                    [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
                    [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                    if([featureRow idValue] == [testFeatureRow idValue]){
                        featureFound = YES;
                    }
                    lastCount++;
                }
                [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
                [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
                [featureIndexResults close];
                resultCount += lastCount;
                offset += chunkLimit;
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:resultCount];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];
        }

        for(NSString *column in [strings allKeys]){
            
            NSString *value = (NSString *)[strings objectForKey:column];

            GPKGColumnValues *fieldValues = [[GPKGColumnValues alloc] init];
            [fieldValues addColumn:column withValue:value];

            int count = [featureIndexManager countWithFieldValues:fieldValues];
            [GPKGTestUtils assertTrue:count >= 1];
            resultCount = 0;
            chunkLimit = 4;
            offset = 0;
            lastCount = -1;
            while (lastCount != 0) {
                lastCount = 0;
                GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithFieldValues:fieldValues andLimit:chunkLimit andOffset:offset];
                for(GPKGFeatureRow *featureRow in featureIndexResults){
                    [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
                    lastCount++;
                }
                [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
                [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
                [featureIndexResults close];
                resultCount += lastCount;
                offset += chunkLimit;
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:resultCount];
            resultCount = 0;
            chunkLimit = 6;
            offset = 0;
            lastCount = -1;
            while (lastCount != 0) {
                lastCount = 0;
                GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithColumns:[NSArray arrayWithObject:column] andFieldValues:fieldValues andLimit:chunkLimit andOffset:offset];
                for(GPKGFeatureRow *featureRow in featureIndexResults){
                    [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
                    lastCount++;
                }
                [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
                [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
                [featureIndexResults close];
                resultCount += lastCount;
                offset += chunkLimit;
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:resultCount];

            count = [featureIndexManager countWithBoundingBox:transformedBoundingBox inProjection:projection andFieldValues:fieldValues];
            [GPKGTestUtils assertTrue:count >= 1];
            featureFound = NO;
            resultCount = 0;
            chunkLimit = 2;
            offset = 0;
            lastCount = -1;
            while (lastCount != 0) {
                lastCount = 0;
                GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithBoundingBox:transformedBoundingBox inProjection:projection andFieldValues:fieldValues andLimit:chunkLimit andOffset:offset];
                for(GPKGFeatureRow *featureRow in featureIndexResults){
                    [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
                    [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                    if([featureRow idValue] == [testFeatureRow idValue]){
                        featureFound = YES;
                    }
                    lastCount++;
                }
                [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
                [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
                [featureIndexResults close];
                resultCount += lastCount;
                offset += chunkLimit;
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:resultCount];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];

            featureFound = NO;
            resultCount = 0;
            chunkLimit = 2;
            offset = 0;
            lastCount = -1;
            while (lastCount != 0) {
                lastCount = 0;
                GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager queryForChunkWithColumns:
                                     [NSArray arrayWithObjects:column, [featureDao idColumnName], [featureDao geometryColumnName], nil]
                                     andBoundingBox:transformedBoundingBox inProjection:projection andFieldValues:fieldValues andLimit:chunkLimit andOffset:offset];
                for(GPKGFeatureRow *featureRow in featureIndexResults){
                    [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
                    [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                    if([featureRow idValue] == [testFeatureRow idValue]){
                        featureFound = YES;
                    }
                    lastCount++;
                }
                [GPKGTestUtils assertTrue:lastCount <= chunkLimit];
                [GPKGTestUtils assertTrue:[featureIndexResults count] <= expectedCount];
                [featureIndexResults close];
                resultCount += lastCount;
                offset += chunkLimit;
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:resultCount];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];

        }
        
        [featureIndexManager close];
    }
    
    // Delete the extensions
    BOOL everyOther = NO;
    for(NSString * featureTable in featureTables){
        GPKGFeatureDao * featureDao = [geoPackage featureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager * featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager setIndexLocation:type];
        [GPKGTestUtils assertTrue:[featureIndexManager isIndexed]];
        
        // Test deleting a single geometry index
        if (everyOther) {
            GPKGResultSet * featureResults = [featureDao query];
            while([featureResults moveToNext]){
                GPKGFeatureRow * featureRow = [featureDao row:featureResults];
                if([featureRow geometryEnvelope] != nil){
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

+(void) testIndexPaginationWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    [self testIndexPaginationWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_GEOPACKAGE andIncludeEmpty:NO];
    [self testIndexPaginationWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_METADATA andIncludeEmpty:NO];
    [self testIndexPaginationWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_RTREE andIncludeEmpty:YES];
}

+(void) testIndexPaginationWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureIndexType: (enum GPKGFeatureIndexType) type andIncludeEmpty: (BOOL) includeEmpty{
    
    // Test indexing each feature table
    NSArray * featureTables = [geoPackage featureTables];
    for(NSString * featureTable in featureTables){
     
        GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager * featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager setContinueOnError:NO];
        [featureIndexManager setIndexLocation:type];
        [featureIndexManager deleteAllIndexes];
        
        // Determine how many features have geometry envelopes or geometries
        int expectedCount = 0;
        GPKGFeatureRow *testFeatureRow = nil;
        GPKGResultSet *featureResultSet = [featureDao query];
        while([featureResultSet moveToNext]){
            GPKGFeatureRow * featureRow = [featureDao row:featureResultSet];
            if([featureRow geometryEnvelope] != nil){
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
        
        // Test indexing
        int indexCount = [featureIndexManager index];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:indexCount];
        
        [GPKGTestUtils assertTrue:[featureIndexManager isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:featureIndexManager.count];
        
        // TODO start converting to paginated queries
        
        // Query for all indexed geometries
        int resultCount = 0;
        GPKGFeatureIndexResults *featureIndexResults = [featureIndexManager query];
        for(GPKGFeatureRow *featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:nil andIncludeEmpty:includeEmpty];
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:resultCount];
        
        // Query for all indexed geometries with columns
        resultCount = 0;
        featureIndexResults = [featureIndexManager queryWithColumns:[featureDao idAndGeometryColumnNames]];
        for(GPKGFeatureRow *featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:nil andIncludeEmpty:includeEmpty];
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:resultCount];
        
        // Test the query by envelope
        SFGeometryEnvelope * envelope = [testFeatureRow geometryEnvelope];
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
        BOOL featureFound = NO;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithEnvelope:envelope];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        resultCount = 0;
        featureFound = NO;
        featureIndexResults = [featureIndexManager queryWithColumns:[featureDao idAndGeometryColumnNames] andEnvelope:envelope];
        for(GPKGFeatureRow *featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Test the query by envelope with id iteration
        resultCount = 0;
        featureFound = NO;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithEnvelope:envelope];
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
        PROJProjection * projection = nil;
        if(![featureDao.projection isEqualToAuthority:PROJ_AUTHORITY_EPSG andNumberCode:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]]){
            projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        }else{
            projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
        }
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromProjection:featureDao.projection andToProjection:projection];
        GPKGBoundingBox *transformedBoundingBox = [boundingBox transform:transform];
        
        // Test the query by projected bounding box
        resultCount = 0;
        featureFound = NO;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithBoundingBox:transformedBoundingBox inProjection:projection] >= 1];
        featureIndexResults = [featureIndexManager queryWithBoundingBox:transformedBoundingBox inProjection:projection];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        resultCount = 0;
        featureFound = NO;
        featureIndexResults = [featureIndexManager queryWithColumns:[featureDao idAndGeometryColumnNames] andBoundingBox:transformedBoundingBox inProjection:projection];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Test query by criteria
        GPKGFeatureTable *table = [featureDao featureTable];
        NSArray<GPKGUserColumn *> *columns = [table columns];
        
        NSMutableDictionary *numbers = [NSMutableDictionary dictionary];
        NSMutableDictionary *strings = [NSMutableDictionary dictionary];
        
        for(GPKGFeatureColumn *column in columns){
            if(column.primaryKey || column.isGeometry){
                continue;
            }
            enum GPKGDataType dataType = column.dataType;
            switch (dataType) {
                case GPKG_DT_DOUBLE:
                case GPKG_DT_FLOAT:
                case GPKG_DT_INT:
                case GPKG_DT_INTEGER:
                case GPKG_DT_TINYINT:
                case GPKG_DT_SMALLINT:
                case GPKG_DT_MEDIUMINT:
                case GPKG_DT_REAL:
                    [numbers setObject:[NSNull null] forKey:column.name];
                    break;
                case GPKG_DT_TEXT:
                    [strings setObject:[NSNull null] forKey:column.name];
                break;
            default:
                break;
            }
        }

        for(NSString *number in [numbers allKeys]){
            NSObject *value = [testFeatureRow valueWithColumnName:number];
            [numbers setObject:value forKey:number];
        }
        
        for(NSString *string in [strings allKeys]){
            NSString *value = [testFeatureRow valueStringWithColumnName:string];
            [strings setObject:value forKey:string];
        }

        for(NSString *column in [numbers allKeys]){
            
            double value = [((NSNumber *)[numbers objectForKey:column]) doubleValue];
            
            NSString *where = [NSString stringWithFormat:@"%@ >= ? AND %@ <= ?", column, column];
            NSArray *whereArgs = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", value - 0.001],
                                  [NSString stringWithFormat:@"%f", value + 0.001], nil];

            int count = [featureIndexManager countWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertTrue:count >= 1];
            featureIndexResults = [featureIndexManager queryWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
            }
            [featureIndexResults close];
            featureIndexResults = [featureIndexManager queryWithColumns:[NSArray arrayWithObject:column] andWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
            }
            [featureIndexResults close];

            resultCount = 0;
            featureFound = NO;

            count = [featureIndexManager countWithBoundingBox:transformedBoundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertTrue:count >= 1];
            featureIndexResults = [featureIndexManager queryWithBoundingBox:transformedBoundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                resultCount++;
            }
            [featureIndexResults close];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];

            resultCount = 0;
            featureFound = NO;

            featureIndexResults = [featureIndexManager queryWithColumns:
                                   [NSArray arrayWithObjects:[featureDao geometryColumnName], column, [featureDao idColumnName], nil]
                                 andBoundingBox:transformedBoundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualDoubleWithValue:value andValue2:[((NSNumber *)[featureRow valueWithColumnName:column]) doubleValue]];
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                resultCount++;
            }
            [featureIndexResults close];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];
        }

        for(NSString *column in [strings allKeys]){
            
            NSString *value = (NSString *)[strings objectForKey:column];

            GPKGColumnValues *fieldValues = [[GPKGColumnValues alloc] init];
            [fieldValues addColumn:column withValue:value];

            int count = [featureIndexManager countWithFieldValues:fieldValues];
            [GPKGTestUtils assertTrue:count >= 1];
            featureIndexResults = [featureIndexManager queryWithFieldValues:fieldValues];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
            }
            [featureIndexResults close];
            featureIndexResults = [featureIndexManager queryWithColumns:[NSArray arrayWithObject:column] andFieldValues:fieldValues];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
            }
            [featureIndexResults close];

            resultCount = 0;
            featureFound = NO;

            count = [featureIndexManager countWithBoundingBox:transformedBoundingBox inProjection:projection andFieldValues:fieldValues];
            [GPKGTestUtils assertTrue:count >= 1];
            featureIndexResults = [featureIndexManager queryWithBoundingBox:transformedBoundingBox inProjection:projection andFieldValues:fieldValues];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                resultCount++;
            }
            [featureIndexResults close];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];

            resultCount = 0;
            featureFound = NO;

            featureIndexResults = [featureIndexManager queryWithColumns:
                                     [NSArray arrayWithObjects:column, [featureDao idColumnName], [featureDao geometryColumnName], nil]
                                     andBoundingBox:transformedBoundingBox inProjection:projection andFieldValues:fieldValues];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[featureIndexResults count]];
            for(GPKGFeatureRow *featureRow in featureIndexResults){
                [GPKGTestUtils assertEqualWithValue:value andValue2:[featureRow valueStringWithColumnName:column]];
                [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope] andIncludeEmpty:includeEmpty];
                if([featureRow idValue] == [testFeatureRow idValue]){
                    featureFound = YES;
                }
                resultCount++;
            }
            [featureIndexResults close];
            [GPKGTestUtils assertTrue:featureFound];
            [GPKGTestUtils assertTrue:resultCount >= 1];

        }
        
        // Update a Geometry and update the index of a single feature row
        SFPoint *point = [[SFPoint alloc] initWithX:[[NSDecimalNumber alloc] initWithDouble:5.0] andY:[[NSDecimalNumber alloc] initWithDouble:5.0]];
        GPKGGeometryData *geometryData = [GPKGGeometryData createWithSrsId:featureDao.geometryColumns.srsId andGeometry:point];
        [testFeatureRow setGeometry:geometryData];
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[featureDao update:testFeatureRow]];
        NSDate *lastIndexedBefore = [featureIndexManager lastIndexed];
        [NSThread sleepForTimeInterval:1];
        [GPKGTestUtils assertTrue:[featureIndexManager indexWithFeatureRow:testFeatureRow]];
        NSDate *lastIndexedAfter = [featureIndexManager lastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexedAfter compare:lastIndexedBefore] == NSOrderedDescending)];
        
        // Verify the index was updated for the feature row
        envelope = [point envelope];
        resultCount = 0;
        featureFound = NO;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithEnvelope:envelope];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope andIncludeEmpty:includeEmpty];
            if([featureRow idValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        [featureIndexManager close];
    }
    
    // Delete the extensions
    BOOL everyOther = NO;
    for(NSString * featureTable in featureTables){
        GPKGFeatureDao * featureDao = [geoPackage featureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager * featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager setIndexLocation:type];
        [GPKGTestUtils assertTrue:[featureIndexManager isIndexed]];
        
        // Test deleting a single geometry index
        if (everyOther) {
            GPKGResultSet * featureResults = [featureDao query];
            while([featureResults moveToNext]){
                GPKGFeatureRow * featureRow = [featureDao row:featureResults];
                if([featureRow geometryEnvelope] != nil){
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
    SFGeometryEnvelope * envelope = [featureRow geometryEnvelope];
    
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

+(void) testLargeIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andNumFeatures: (int) numFeatures andVerbose: (BOOL) verbose{
    
    NSString *featureTable = @"large_index";
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage spatialReferenceSystemDao] srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:featureTable];
    [geometryColumns setColumnName:@"geom"];
    [geometryColumns setGeometryType:SF_POLYGON];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-180 andMinLatitudeDouble:-90 andMaxLongitudeDouble:180 andMaxLatitudeDouble:90];
    
    NSArray* additionalColumns = [GPKGGeoPackageTestUtils featureColumns];
    [geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andAdditionalColumns:additionalColumns andBoundingBox:boundingBox]];
    
    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
    
    NSLog(@"Inserting Feature Rows: %d", numFeatures);
    [GPKGTestUtils addRowsToFeatureTableWithGeoPackage:geoPackage andGeometryColumns:geometryColumns andFeatureTable:[featureDao featureTable] andNumRows:numFeatures andHasZ:NO andHasM:NO andAllowEmptyFeatures:NO];
    
    [self testTimedIndexWithGeoPackage:geoPackage andFeatureTable:featureTable andCompareProjectionCounts:YES andVerbose:verbose];
    
}

+(void) testTimedIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andCompareProjectionCounts: (BOOL) compareProjectionCounts andVerbose: (BOOL) verbose{
    for(NSString *featureTable in [geoPackage featureTables]){
        [self testTimedIndexWithGeoPackage:geoPackage andFeatureTable:featureTable andCompareProjectionCounts:compareProjectionCounts andVerbose:verbose];
    }
}

+(void) testTimedIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureTable: (NSString *) featureTable andCompareProjectionCounts: (BOOL) compareProjectionCounts andVerbose: (BOOL) verbose{
    
    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
    
    NSLog(@"Timed Index Test");
    NSLog(@"%@", featureTable);
    NSLog(@"Features: %d, Columns: %d", [featureDao count], [featureDao columnCount]);
    
    SFGeometryEnvelope *envelope = nil;
    GPKGResultSet *resultSet = [featureDao query];
    while([resultSet moveToNext]){
        GPKGFeatureRow *featureRow = [featureDao row:resultSet];
        SFGeometryEnvelope *rowEnvelope = [featureRow geometryEnvelope];
        if(envelope == nil){
            envelope = rowEnvelope;
        }else if(rowEnvelope != nil){
            envelope = [envelope unionWithEnvelope:rowEnvelope];
        }
    }
    [resultSet close];
    
    NSArray<GPKGFeatureIndexTestEnvelope *> *envelopes = [self createEnvelopesWithEnvelope:envelope];

    resultSet = [featureDao query];
    while([resultSet moveToNext]){
        GPKGFeatureRow *featureRow = [featureDao row:resultSet];
        SFGeometryEnvelope *rowEnvelope = [featureRow geometryEnvelope];
        if(rowEnvelope != nil){
            GPKGBoundingBox *rowBoundingBox = [[GPKGBoundingBox alloc] initWithEnvelope:rowEnvelope];
            for(GPKGFeatureIndexTestEnvelope *testEnvelope in envelopes){
                if([rowBoundingBox intersects:[[GPKGBoundingBox alloc] initWithEnvelope:testEnvelope.envelope] withAllowEmpty:YES]){
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
    NSMutableArray<GPKGFeatureIndexTestEnvelope *> *envelopes = [NSMutableArray array];
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
    
    int geometryFeatureCount = [featureDao countWhere:[NSString stringWithFormat:@"%@ IS NOT NULL", [featureDao geometryColumnName]]];
    int totalFeatureCount = [featureDao count];
    
    GPKGFeatureIndexManager *featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
    [featureIndexManager setContinueOnError:NO];
    
    @try{
        
        [featureIndexManager setIndexLocation:type];
        [featureIndexManager prioritizeQueryLocationWithType:type];
        
        if(type != GPKG_FIT_NONE){
            [featureIndexManager deleteIndexWithFeatureIndexType:type];
            [GPKGTestUtils assertFalse:[featureIndexManager isIndexedWithFeatureIndexType:type]];
        }else{
            [featureIndexManager setIndexLocationOrderWithTypes:[NSArray arrayWithObjects:[GPKGFeatureIndexTypes name:type], nil]];
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
        
        PROJProjection *projection = featureDao.projection;
        PROJProjection *webMercatorProjection = [PROJProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_EPSG andIntCode:PROJ_EPSG_WEB_MERCATOR];
        SFPGeometryTransform *transformToWebMercator = [SFPGeometryTransform transformFromProjection:projection andToProjection:webMercatorProjection];
        SFPGeometryTransform *transformToProjection = [SFPGeometryTransform transformFromProjection:webMercatorProjection andToProjection:projection];
        
        [timerCount start];
        GPKGBoundingBox *bounds = [featureIndexManager boundingBox];
        [timerCount endWithOutput:@"Bounds Query"];
        [GPKGTestUtils assertNotNil:bounds];
        GPKGFeatureIndexTestEnvelope *firstEnvelope = [envelopes objectAtIndex:0];
        GPKGBoundingBox *firstBounds = [[GPKGBoundingBox alloc] initWithEnvelope:firstEnvelope.envelope];

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
        GPKGTestTimer *timerIteration = [[GPKGTestTimer alloc] init];
        GPKGTestTimer *timerColumnsIteration = [[GPKGTestTimer alloc] init];
        
        timerIteration.print = timerCount.print;
        timerColumnsIteration.print = timerCount.print;
        timerQuery.print = timerCount.print;
        
        NSArray<NSString *> *columns = [featureDao idAndGeometryColumnNames];
        
        for(GPKGFeatureIndexTestEnvelope *testEnvelope in envelopes){
            
            NSString *percentage = [NSString stringWithFormat:@"%d", testEnvelope.percentage];
            SFGeometryEnvelope *envelope = testEnvelope.envelope;
            int expectedCount = testEnvelope.count;
            
            if(verbose){
                NSLog(@"%@%% Feature Count: %d", percentage, expectedCount);
            }
            
            [timerCount start];
            int fullCount = [featureIndexManager countWithEnvelope:envelope];
            [timerCount endWithOutput:[NSString stringWithFormat:@"%@%% Envelope Count Query", percentage]];
            [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:fullCount];
            
            [timerQuery start];
            GPKGFeatureIndexResults *results = [featureIndexManager queryWithEnvelope:envelope];
            [timerQuery endWithOutput:[NSString stringWithFormat:@"%@%% Envelope Query", percentage]];
            [self iterateResultsWithTimer:timerIteration andMessage:[NSString stringWithFormat:@"%@%% Envelope Query Iteration", percentage] andResults:results];
            [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:[results count]];
            [results close];

            [timerQuery start];
            results = [featureIndexManager queryWithColumns:columns andEnvelope:envelope];
            [timerQuery endWithOutput:[NSString stringWithFormat:@"%@%% Envelope Columns Query", percentage]];
            [self iterateResultsWithTimer:timerColumnsIteration andMessage:[NSString stringWithFormat:@"%@%% Envelope Columns Query Iteration", percentage] andResults:results];
            [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:[results count]];
            [results close];
            
            GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithEnvelope:envelope];
            [timerCount start];
            fullCount = [featureIndexManager countWithBoundingBox:boundingBox];
            [timerCount endWithOutput:[NSString stringWithFormat:@"%@%% Bounding Box Count Query", percentage]];
            [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:fullCount];
            
            [timerQuery start];
            results = [featureIndexManager queryWithBoundingBox:boundingBox];
            [timerQuery endWithOutput:[NSString stringWithFormat:@"%@%% Bounding Box Query", percentage]];
            [self iterateResultsWithTimer:timerIteration andMessage:[NSString stringWithFormat:@"%@%% Bounding Box Query Iteration", percentage] andResults:results];
            [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:[results count]];
            [results close];

            [timerQuery start];
            results = [featureIndexManager queryWithColumns:columns andBoundingBox:boundingBox];
            [timerQuery endWithOutput:[NSString stringWithFormat:@"%@%% Bounding Box Columns Query", percentage]];
            [self iterateResultsWithTimer:timerColumnsIteration andMessage:[NSString stringWithFormat:@"%@%% Bounding Box Columns Query Iteration", percentage] andResults:results];
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
            [self iterateResultsWithTimer:timerIteration andMessage:[NSString stringWithFormat:@"%@%% Projected Bounding Box Query Iteration", percentage] andResults:results];
            if (compareProjectionCounts) {
                [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:[results count]];
            }
            [results close];

            [timerQuery start];
            results = [featureIndexManager queryWithColumns:columns andBoundingBox:webMercatorBoundingBox inProjection:webMercatorProjection];
            [timerQuery endWithOutput:[NSString stringWithFormat:@"%@%% Projected Bounding Box Columns Query", percentage]];
            [self iterateResultsWithTimer:timerColumnsIteration andMessage:[NSString stringWithFormat:@"%@%% Projected Bounding Box Columns Query Iteration", percentage] andResults:results];
            if (compareProjectionCounts) {
                [self assertCountsWithManager:featureIndexManager andEnvelope:testEnvelope andType:type andPrecision:outerPrecision andExpected:expectedCount andFull:[results count]];
            }
            [results close];
        }
        
        NSLog(@"Average Count: %@ s", [timerCount averageString]);
        NSLog(@"Average Query: %@ s", [timerQuery averageString]);
        NSLog(@"Average Iteration: %@ s", [timerIteration averageString]);
        NSLog(@"Average %lu Column Iteration: %@ s", columns.count, [timerColumnsIteration averageString]);
    }@finally{
        [featureIndexManager close];
    }
    
}

+(void) iterateResultsWithTimer: (GPKGTestTimer *) timerIteration andMessage: (NSString *) message andResults: (GPKGFeatureIndexResults *) results{
    [timerIteration start];
    for(GPKGFeatureRow __unused *featureRow in results){
    }
    [timerIteration endWithOutput:message];
}

+(void) assertCountsWithManager: (GPKGFeatureIndexManager *) featureIndexManager andEnvelope: (GPKGFeatureIndexTestEnvelope *) testEnvelope andType: (enum GPKGFeatureIndexType) type andPrecision: (double) precision andExpected: (int) expectedCount andFull: (int) fullCount{
    
    switch (type) {
        case GPKG_FIT_RTREE:
            
            if (expectedCount != fullCount) {
                int count = 0;
                GPKGFeatureIndexResults *results = [featureIndexManager queryWithColumns:
                                                    [NSArray arrayWithObject:[[featureIndexManager featureDao] geometryColumnName]]
                                                    andEnvelope:testEnvelope.envelope];
                for (GPKGFeatureRow *featureRow in results) {
                    SFGeometryEnvelope *envelope = [featureRow geometryEnvelope];
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
