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
#import "WKBGeometryEnvelopeBuilder.h"
#import "GPKGTestGeoPackageProgress.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProjectionTransform.h"
#import "GPKGProjectionConstants.h"

@implementation GPKGFeatureIndexManagerUtils

+(void) testIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    [self testIndexWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_GEOPACKAGE];
    [self testIndexWithGeoPackage:geoPackage andFeatureIndexType:GPKG_FIT_METADATA];
}

+(void) testIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureIndexType: (enum GPKGFeatureIndexType) type{
    
    // Test indexing each feature table
    NSArray * featureTables = [geoPackage getFeatureTables];
    for(NSString * featureTable in featureTables){
     
        GPKGFeatureDao * featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager * featureIndexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureIndexManager setIndexLocation:type];
        
        // Determine how many features have geometry envelopes or geometries
        int expectedCount = 0;
        GPKGFeatureRow * testFeatureRow = nil;
        GPKGResultSet * featureResultSet = [featureDao queryForAll];
        while([featureResultSet moveToNext]){
            GPKGFeatureRow * featureRow = [featureDao getFeatureRow:featureResultSet];
            GPKGGeometryData * geometryData = [featureRow getGeometry];
            if(geometryData != nil
               && (geometryData.envelope != nil || geometryData.geometry != nil)){
                expectedCount++;
                // Randomly choose a feature row with Geometry for testing
                // queries later
                if(testFeatureRow == nil){
                    testFeatureRow = featureRow;
                }else if([GPKGTestUtils randomDouble] < (1.0 / featureResultSet.count)){
                    testFeatureRow = featureRow;
                }
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
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:nil];
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:resultCount];
        
        // Test the query by envelope
        GPKGGeometryData * geometryData = [testFeatureRow getGeometry];
        WKBGeometryEnvelope * envelope = geometryData.envelope;
        if(envelope == nil){
            envelope = [WKBGeometryEnvelopeBuilder buildEnvelopeWithGeometry:geometryData.geometry];
        }
        [envelope setMinX:[[NSDecimalNumber alloc ] initWithDouble:([envelope.minX doubleValue] - .000001)]];
        [envelope setMaxX:[[NSDecimalNumber alloc ] initWithDouble:([envelope.maxX doubleValue] + .000001)]];
        [envelope setMinY:[[NSDecimalNumber alloc ] initWithDouble:([envelope.minY doubleValue] - .000001)]];
        [envelope setMaxY:[[NSDecimalNumber alloc ] initWithDouble:([envelope.maxY doubleValue] + .000001)]];
        if(envelope.hasZ){
            [envelope setMinZ:[[NSDecimalNumber alloc ] initWithDouble:([envelope.minZ doubleValue] - .000001)]];
            [envelope setMaxZ:[[NSDecimalNumber alloc ] initWithDouble:([envelope.maxZ doubleValue] + .000001)]];
        }
        if(envelope.hasM){
            [envelope setMinM:[[NSDecimalNumber alloc ] initWithDouble:([envelope.minM doubleValue] - .000001)]];
            [envelope setMaxM:[[NSDecimalNumber alloc ] initWithDouble:([envelope.maxM doubleValue] + .000001)]];
        }
        resultCount = 0;
        BOOL featureFound = false;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithGeometryEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithGeometryEnvelope:envelope];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope];
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
                                                                      andMaxLongitudeDouble:[envelope.maxX doubleValue] + 1.0
                                                                       andMinLatitudeDouble:[envelope.minY doubleValue] - 1.0
                                                                       andMaxLatitudeDouble:[envelope.maxY doubleValue] + 1.0];
        GPKGProjection * projection = nil;
        if([featureDao.projection.epsg intValue] != PROJ_EPSG_WORLD_GEODETIC_SYSTEM){
            projection = [GPKGProjectionFactory getProjectionWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        }else{
            projection = [GPKGProjectionFactory getProjectionWithInt:PROJ_EPSG_WEB_MERCATOR];
        }
        GPKGProjectionTransform * transform = [[GPKGProjectionTransform alloc] initWithFromProjection:featureDao.projection andToProjection:projection];
        GPKGBoundingBox * transformedBoundingBox = [transform transformWithBoundingBox:boundingBox];
        
        // Test the query by projected bounding box
        resultCount = 0;
        featureFound = false;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithBoundingBox:transformedBoundingBox andProjection:projection] >= 1];
        featureIndexResults = [featureIndexManager queryWithBoundingBox:transformedBoundingBox andProjection:projection];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:[boundingBox buildEnvelope]];
            if([[featureRow getId] intValue] == [[testFeatureRow getId] intValue]){
                featureFound = true;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Update a Geometry and update the index of a single feature row
        geometryData = [[GPKGGeometryData alloc] initWithSrsId:featureDao.geometryColumns.srsId];
        WKBPoint * point = [[WKBPoint alloc] initWithX:[[NSDecimalNumber alloc] initWithDouble:5.0] andY:[[NSDecimalNumber alloc] initWithDouble:5.0]];
        [geometryData setGeometry:point];
        [testFeatureRow setGeometry:geometryData];
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[featureDao update:testFeatureRow]];
        NSDate * lastIndexedBefore = [featureIndexManager getLastIndexed];
        [NSThread sleepForTimeInterval:1];
        [GPKGTestUtils assertTrue:[featureIndexManager indexWithFeatureRow:testFeatureRow]];
        NSDate * lastIndexedAfter = [featureIndexManager getLastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexedAfter compare:lastIndexedBefore] == NSOrderedDescending)];
        
        // Verify the index was updated for the feature row
        envelope = [WKBGeometryEnvelopeBuilder buildEnvelopeWithGeometry:point];
        resultCount = 0;
        featureFound = false;
        [GPKGTestUtils assertTrue:[featureIndexManager countWithGeometryEnvelope:envelope] >= 1];
        featureIndexResults = [featureIndexManager queryWithGeometryEnvelope:envelope];
        for(GPKGFeatureRow * featureRow in featureIndexResults){
            [self validateFeatureRow:featureRow withFeatureIndexManager:featureIndexManager andEnvelope:envelope];
            if([[featureRow getId] intValue] == [[testFeatureRow getId] intValue]){
                featureFound = true;
            }
            resultCount++;
        }
        [featureIndexResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
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
                GPKGGeometryData * geometryData = [featureRow getGeometry];
                if(geometryData != nil
                   && (geometryData.envelope != nil || geometryData.geometry != nil)){
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
    }
    
}

+(void) validateFeatureRow: (GPKGFeatureRow *) featureRow withFeatureIndexManager: (GPKGFeatureIndexManager *) featureIndexManager andEnvelope: (WKBGeometryEnvelope *) queryEnvelope{
    [GPKGTestUtils assertNotNil:featureRow];
    GPKGGeometryData * geometryData = [featureRow getGeometry];
    WKBGeometryEnvelope * envelope = geometryData.envelope;
    if(envelope == nil){
        WKBGeometry * geometry = geometryData.geometry;
        if(geometry != nil){
            envelope = [WKBGeometryEnvelopeBuilder buildEnvelopeWithGeometry:geometry];
        }
    }
    
    [GPKGTestUtils assertNotNil:envelope];
    
    if(queryEnvelope != nil){
        BOOL minXLessThanMaxX = [queryEnvelope.minX compare:queryEnvelope.maxX] == NSOrderedAscending;
        if(minXLessThanMaxX){
            [GPKGTestUtils assertTrue:[envelope.minX doubleValue] <= [queryEnvelope.maxX doubleValue]];
            [GPKGTestUtils assertTrue:[envelope.maxX doubleValue] >= [queryEnvelope.minX doubleValue]];
        }else{
            [GPKGTestUtils assertTrue:[envelope.minX doubleValue] <= [queryEnvelope.maxX doubleValue]
                || [envelope.maxX doubleValue] >= [queryEnvelope.minX doubleValue]
                || [envelope.minX doubleValue] >= [queryEnvelope.minX doubleValue]
             || [envelope.maxX doubleValue] <= [queryEnvelope.maxX doubleValue]];
        }
        [GPKGTestUtils assertTrue:[envelope.minY doubleValue] <= [queryEnvelope.maxY doubleValue]];
        [GPKGTestUtils assertTrue:[envelope.maxY doubleValue] >= [queryEnvelope.minY doubleValue]];
        if(envelope.hasZ){
            if(queryEnvelope.hasZ){
                [GPKGTestUtils assertTrue:[envelope.minZ doubleValue] <= [queryEnvelope.maxZ doubleValue]];
                [GPKGTestUtils assertTrue:[envelope.maxZ doubleValue] >= [queryEnvelope.minZ doubleValue]];
            }
        } else{
            [GPKGTestUtils assertFalse:queryEnvelope.hasZ];
            [GPKGTestUtils assertNil:queryEnvelope.minZ];
            [GPKGTestUtils assertNil:queryEnvelope.maxZ];
        }
        if(envelope.hasM){
            if(queryEnvelope.hasM){
                [GPKGTestUtils assertTrue:[envelope.minM doubleValue] <= [queryEnvelope.maxM doubleValue]];
                [GPKGTestUtils assertTrue:[envelope.maxM doubleValue] >= [queryEnvelope.minM doubleValue]];
            }
        } else{
            [GPKGTestUtils assertFalse:queryEnvelope.hasM];
            [GPKGTestUtils assertNil:queryEnvelope.minM];
            [GPKGTestUtils assertNil:queryEnvelope.maxM];
        }
    }
}

@end
