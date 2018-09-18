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
#import "SFPProjectionConstants.h"
#import "SFPProjectionFactory.h"

@implementation GPKGRTreeIndexExtensionUtils

+(void) testRTreeWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGRTreeIndexExtension *extension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
    
    NSArray<NSString *> *featureTables = [geoPackage getFeatureTables];
    for(NSString *featureTable in featureTables){
        
        GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureTable *table = [featureDao getFeatureTable];
        
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
            
            [GPKGTestUtils assertEqualWithValue:[row getId] andValue2:[featureRow getId]];
            
            double minX = row.minX;
            double maxX = row.maxX;
            double minY = row.minY;
            double maxY = row.maxY;
            
            SFGeometryEnvelope *envelope = [featureRow getGeometryEnvelope];
            
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
                    if([[queryFeatureRow getId] intValue] == [[featureRow getId] intValue]){
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
        
        GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithGeometryEnvelope:totalEnvelope];
        int bboxCount = [tableDao countWithBoundingBox:boundingBox];
        [GPKGTestUtils assertTrue:bboxCount >= expectedCount];
        results = [tableDao queryWithBoundingBox:boundingBox];
        [GPKGTestUtils assertEqualIntWithValue:bboxCount andValue2:results.count];
        [results close];
        [GPKGTestUtils assertEqualIntWithValue:envelopeCount andValue2:bboxCount];
        
        SFPProjection *projection = featureDao.projection;
        if(![[projection authority] isEqualToString:PROJ_AUTHORITY_NONE]){
            SFPProjection *queryProjection = nil;
            if([projection isEqualToAuthority:PROJ_AUTHORITY_EPSG andNumberCode:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]]){
                queryProjection = [SFPProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_EPSG andIntCode:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
            }else{
                queryProjection = [SFPProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_EPSG andIntCode:PROJ_EPSG_WEB_MERCATOR];
            }
            SFPProjectionTransform *transform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:queryProjection];
            
            GPKGBoundingBox *projectedBoundingBox = [boundingBox transform:transform];
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
