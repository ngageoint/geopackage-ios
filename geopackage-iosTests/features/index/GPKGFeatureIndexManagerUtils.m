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
            if([[featureRow getId] intValue] == [[testFeatureRow getId] intValue]){
                featureFound = true;
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
            if([[featureRow getId] intValue] == [[testFeatureRow getId] intValue]){
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
            if([[featureRow getId] intValue] == [[testFeatureRow getId] intValue]){
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
    
}

+(void) testTimedIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andCompareProjectionCounts: (BOOL) compareProjectionCounts andVerbose: (BOOL) verbose{
    
}

+(void) testTimedIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureTable: (NSString *) featureTable andCompareProjectionCounts: (BOOL) compareProjectionCounts andVerbose: (BOOL) verbose{
    
}

@end
