//
//  GPKGRTreeIndexExtensionUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/18/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRTreeIndexExtensionUtils.h"
#import "GPKGRTreeIndexExtension.h"
#import "GPKGTestUtils.h"
#import "PROJProjectionConstants.h"
#import "PROJProjectionFactory.h"

@implementation GPKGRTreeIndexExtensionUtils

+(void) testRTreeWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGRTreeIndexExtension *extension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
    
    NSArray<NSString *> *featureTables = [geoPackage featureTables];
    for(NSString *featureTable in featureTables){
        
        GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
        GPKGFeatureTable *table = [featureDao featureTable];
        
        if(![extension hasWithFeatureTable:table]){
            GPKGExtensions *createdExtension = [extension createWithFeatureTable:table];
            [GPKGTestUtils assertNotNil:createdExtension];
        }
        
        GPKGRTreeIndexTableDao *tableDao = [extension tableDaoWithFeatureDao:featureDao];
        [GPKGTestUtils assertTrue:[tableDao has]];
        
        [GPKGTestUtils assertEqualIntWithValue:[featureDao count] andValue2:[tableDao count]];
        
        SFGeometryEnvelope *totalEnvelope = nil;
        
        int expectedCount = 0;
        
        GPKGResultSet *resultSet = [tableDao queryForAll];
        while([resultSet moveToNext]){
            
            GPKGRTreeIndexTableRow *row = [tableDao row:resultSet];
            [GPKGTestUtils assertNotNil:row];
            
            GPKGFeatureRow *featureRow = [tableDao featureRowFromRTreeRow:row];
            [GPKGTestUtils assertNotNil:featureRow];
            
            [GPKGTestUtils assertEqualWithValue:[row id] andValue2:[featureRow id]];
            
            double minX = row.minX;
            double maxX = row.maxX;
            double minY = row.minY;
            double maxY = row.maxY;
            
            SFGeometryEnvelope *envelope = [featureRow geometryEnvelope];
            
            if (envelope != nil) {
                [GPKGTestUtils assertTrue:[envelope.minX doubleValue] >= minX];
                [GPKGTestUtils assertTrue:[envelope.maxX doubleValue] <= maxX];
                [GPKGTestUtils assertTrue:[envelope.minY doubleValue] >= minY];
                [GPKGTestUtils assertTrue:[envelope.maxY doubleValue] <= maxY];
                
                GPKGResultSet *results = [tableDao queryWithEnvelope:envelope];
                [GPKGTestUtils assertTrue:results.count > 0];
                BOOL found = NO;
                while([results moveToNext]){
                    GPKGFeatureRow *queryFeatureRow = [tableDao featureRow:results];
                    if([queryFeatureRow idValue] == [featureRow idValue]){
                        found = YES;
                        break;
                    }
                }
                [GPKGTestUtils assertTrue:found];
                [results close];
                
                expectedCount++;
                if (totalEnvelope == nil) {
                    totalEnvelope = envelope;
                } else {
                    totalEnvelope = [totalEnvelope unionWithEnvelope:envelope];
                }
            }
        }
        [resultSet close];
            
        int envelopeCount = [tableDao countWithEnvelope:totalEnvelope];
        [GPKGTestUtils assertTrue:envelopeCount >= expectedCount];
        GPKGResultSet *results = [tableDao queryWithEnvelope:totalEnvelope];
        [GPKGTestUtils assertEqualIntWithValue:envelopeCount andValue2:results.count];
        [results close];
        
        GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithEnvelope:totalEnvelope];
        int bboxCount = [tableDao countWithBoundingBox:boundingBox];
        [GPKGTestUtils assertTrue:bboxCount >= expectedCount];
        results = [tableDao queryWithBoundingBox:boundingBox];
        [GPKGTestUtils assertEqualIntWithValue:bboxCount andValue2:results.count];
        [results close];
        [GPKGTestUtils assertEqualIntWithValue:envelopeCount andValue2:bboxCount];
        
        PROJProjection *projection = featureDao.projection;
        if(![[projection authority] isEqualToString:PROJ_AUTHORITY_NONE]){
            PROJProjection *queryProjection = nil;
            if([projection isEqualToAuthority:PROJ_AUTHORITY_EPSG andNumberCode:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]]){
                queryProjection = [PROJProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_EPSG andIntCode:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
            }else{
                queryProjection = [PROJProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_EPSG andIntCode:PROJ_EPSG_WEB_MERCATOR];
            }
            SFPGeometryTransform *transform = [SFPGeometryTransform transformFromProjection:projection andToProjection:queryProjection];
            
            GPKGBoundingBox *projectedBoundingBox = [boundingBox transform:transform];
            [transform destroy];
            [tableDao setTolerance:.0000000000001];
            int projectedBboxCount = [tableDao countWithBoundingBox:projectedBoundingBox inProjection:queryProjection];
            [GPKGTestUtils assertTrue:projectedBboxCount >= expectedCount];
            results = [tableDao queryWithBoundingBox:projectedBoundingBox inProjection:queryProjection];
            [GPKGTestUtils assertEqualIntWithValue:projectedBboxCount andValue2:results.count];
            [results close];
            [GPKGTestUtils assertTrue:projectedBboxCount >= expectedCount];
        }
    }
    
}

@end
