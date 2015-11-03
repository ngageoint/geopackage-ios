//
//  GPKGFeatureIndexerTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/30/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexerTest.h"
#import "GPKGFeatureTileUtils.h"
#import "GPKGMetadataDb.h"
#import "GPKGTestUtils.h"

@implementation GPKGFeatureIndexerTest

- (void)testIndexer {
    
    GPKGFeatureDao * featureDao = [GPKGFeatureTileUtils createFeatureDaoWithGeoPackage:self.geoPackage];
    
    int initialFeatures = [GPKGFeatureTileUtils insertFeaturesWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    
    GPKGFeatureIndexer * indexer = [[GPKGFeatureIndexer alloc] initWithFeatureDao:featureDao];
    
    GPKGMetadataDb * db= [[GPKGMetadataDb alloc] init];
    @try {
        GPKGTableMetadataDao * tableMetadataDao = [[GPKGTableMetadataDao alloc] initWithDatabase:db.connection];
        [GPKGTestUtils assertNil:[tableMetadataDao getMetadataByGeoPackageName:self.geoPackage.name andTableName:featureDao.tableName]];
    }
    @finally {
        [db close];
    }

    // Verify not indexed
    [GPKGTestUtils assertFalse:[indexer isIndexed]];
    
    NSDate * currentTime = [NSDate date];
    NSDate * lastIndexed = nil;
    
    [NSThread sleepForTimeInterval:1];
    
    // Index
    [indexer index];
    
    db = [[GPKGMetadataDb alloc] init];
    @try {
        GPKGTableMetadataDao * tableMetadataDao = [[GPKGTableMetadataDao alloc] initWithDatabase:db.connection];
        GPKGTableMetadata * metadata = [tableMetadataDao getMetadataByGeoPackageName:self.geoPackage.name andTableName:featureDao.tableName];
        [GPKGTestUtils assertNotNil:metadata];
        lastIndexed = metadata.lastIndexed;
        [GPKGTestUtils assertNotNil:lastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexed compare:currentTime] == NSOrderedDescending)];
    }
    @finally {
        [db close];
    }
    
    // Verify indexed
    [GPKGTestUtils assertTrue:[indexer isIndexed]];
    
    [NSThread sleepForTimeInterval:1];
    
    // Try to index when not needed
    [indexer index];
    
    db= [[GPKGMetadataDb alloc] init];
    @try {
        GPKGTableMetadataDao * tableMetadataDao = [[GPKGTableMetadataDao alloc] initWithDatabase:db.connection];
        GPKGTableMetadata * metadata = [tableMetadataDao getMetadataByGeoPackageName:self.geoPackage.name andTableName:featureDao.tableName];
        [GPKGTestUtils assertNotNil:metadata];
        // Index date should not change
        [GPKGTestUtils assertTrue:([lastIndexed compare:metadata.lastIndexed] == NSOrderedSame)];
    }
    @finally {
        [db close];
    }
    
    // Verify indexed
    [GPKGTestUtils assertTrue:[indexer isIndexed]];
    
    // Force indexing again
    [indexer indexWithForce:true];
    
    db= [[GPKGMetadataDb alloc] init];
    @try {
        GPKGTableMetadataDao * tableMetadataDao = [[GPKGTableMetadataDao alloc] initWithDatabase:db.connection];
        GPKGTableMetadata * metadata = [tableMetadataDao getMetadataByGeoPackageName:self.geoPackage.name andTableName:featureDao.tableName];
        [GPKGTestUtils assertNotNil:metadata];
        [GPKGTestUtils assertNotNil:metadata.lastIndexed];
        [GPKGTestUtils assertTrue:([metadata.lastIndexed compare:lastIndexed] == NSOrderedDescending)];
    }
    @finally {
        [db close];
    }
    
    // Verify indexed
    [GPKGTestUtils assertTrue:[indexer isIndexed]];
    
    // Insert a point and line and make sure it is no longer indexed
    double minX = 5.8921;
    double maxX = 8.38495;
    double minY = 6.82645;
    double maxY = 9.134445;
    long long id1 = [GPKGFeatureTileUtils insertPointWithFeatureDao:featureDao andX:minX andY:maxY];
    NSArray * linePoints = [[NSArray alloc] initWithObjects:
                        [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:minX], [[NSDecimalNumber alloc] initWithDouble:minY], nil],
                        [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:maxX], [[NSDecimalNumber alloc] initWithDouble:maxY], nil],
                        nil];
    long long id2 = [GPKGFeatureTileUtils insertLineWithFeatureDao:featureDao andPoints:linePoints];
    [NSThread sleepForTimeInterval:1];
    [GPKGFeatureTileUtils updateLastChangeWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    
    // Verify no longer indexed
    [GPKGTestUtils assertFalse:[indexer isIndexed]];
    
    // Index again
    [indexer index];
    [GPKGTestUtils assertTrue:[indexer isIndexed]];
    
    // Insert a polygon and index manually
    NSArray * polygonPoints = [[NSArray alloc] initWithObjects:
                            [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:minX], [[NSDecimalNumber alloc] initWithDouble:minY], nil],
                            [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:maxX], [[NSDecimalNumber alloc] initWithDouble:minY], nil],
                            [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:maxX], [[NSDecimalNumber alloc] initWithDouble:maxY], nil],
                            nil];
    long long id3 = [GPKGFeatureTileUtils insertPolygonWithFeatureDao:featureDao andLines:[[NSArray alloc] initWithObjects:polygonPoints, nil]];
    [NSThread sleepForTimeInterval:1];
    [GPKGFeatureTileUtils updateLastChangeWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    GPKGFeatureRow * polygonRow = (GPKGFeatureRow * )[featureDao queryForIdObject:[NSNumber numberWithLongLong:id3]];
    [GPKGTestUtils assertNotNil:polygonRow];
    [GPKGTestUtils assertTrue:[indexer indexFeatureRow:polygonRow]];
    [GPKGTestUtils assertTrue:[indexer isIndexed]];
    
    // Update the point coordinates
    GPKGFeatureRow * pointRow = (GPKGFeatureRow * )[featureDao queryForIdObject:[NSNumber numberWithLongLong:id1]];
    [GPKGTestUtils assertNotNil:pointRow];
    [GPKGFeatureTileUtils setPointWithFeatureRow:pointRow andX:maxX andY:minY];
    [GPKGTestUtils assertTrue:[featureDao update:pointRow] > 0];
    [NSThread sleepForTimeInterval:1];
    [GPKGFeatureTileUtils updateLastChangeWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    [GPKGTestUtils assertTrue:[indexer indexFeatureRow:pointRow]];
    [GPKGTestUtils assertTrue:[indexer isIndexed]];

    WKBGeometryEnvelope * envelope = [[WKBGeometryEnvelope alloc] init];
    [envelope setMinX:[[NSDecimalNumber alloc] initWithDouble:minX]];
    [envelope setMaxX:[[NSDecimalNumber alloc] initWithDouble:maxX]];
    [envelope setMinY:[[NSDecimalNumber alloc] initWithDouble:minY]];
    [envelope setMaxY:[[NSDecimalNumber alloc] initWithDouble:maxY]];
    
    BOOL id1Found = false;
    BOOL id2Found = false;
    BOOL id3Found = false;
    
    int count = 0;
    
    db= [[GPKGMetadataDb alloc] init];
    @try {
        GPKGGeometryMetadataDao * geometryMetadataDao = [[GPKGGeometryMetadataDao alloc] initWithDatabase:db.connection];
        GPKGResultSet * results = [geometryMetadataDao queryByGeoPackageName:self.geoPackage.name andTableName:featureDao.tableName andEnvelope:envelope];
        @try {
            [GPKGTestUtils assertNotNil:results];
            count = results.count;
            [GPKGTestUtils assertTrue:count >= 3];
            while([results moveToNext]){
                
                GPKGGeometryMetadata * metadata = (GPKGGeometryMetadata *)[geometryMetadataDao getObject:results];
                NSNumber * id = metadata.id;
                
                GPKGFeatureRow * queryRow = (GPKGFeatureRow *)[featureDao queryForIdObject:id];
                [GPKGTestUtils assertNotNil:queryRow];
                
                enum WKBGeometryType geometryType = [queryRow getGeometry].geometry.geometryType;
                
                if([id intValue] == id1){
                    id1Found = true;
                    [GPKGTestUtils assertEqualWithValue:WKB_POINT_NAME andValue2:[WKBGeometryTypes name:geometryType]];
                    [GPKGTestUtils assertEqualDoubleWithValue:maxX andValue2:[metadata.minX doubleValue]];
                    [GPKGTestUtils assertEqualDoubleWithValue:maxX andValue2:[metadata.maxX doubleValue]];
                    [GPKGTestUtils assertEqualDoubleWithValue:minY andValue2:[metadata.minY doubleValue]];
                    [GPKGTestUtils assertEqualDoubleWithValue:minY andValue2:[metadata.maxY doubleValue]];
                } else if([id intValue] == id2){
                    id2Found = true;
                    [GPKGTestUtils assertEqualWithValue:WKB_LINESTRING_NAME andValue2:[WKBGeometryTypes name:geometryType]];
                    [GPKGTestUtils assertEqualDoubleWithValue:minX andValue2:[metadata.minX doubleValue]];
                    [GPKGTestUtils assertEqualDoubleWithValue:maxX andValue2:[metadata.maxX doubleValue]];
                    [GPKGTestUtils assertEqualDoubleWithValue:minY andValue2:[metadata.minY doubleValue]];
                    [GPKGTestUtils assertEqualDoubleWithValue:maxY andValue2:[metadata.maxY doubleValue]];
                } else if([id intValue] == id3){
                    id3Found = true;
                    [GPKGTestUtils assertEqualWithValue:WKB_POLYGON_NAME andValue2:[WKBGeometryTypes name:geometryType]];
                    [GPKGTestUtils assertEqualDoubleWithValue:minX andValue2:[metadata.minX doubleValue]];
                    [GPKGTestUtils assertEqualDoubleWithValue:maxX andValue2:[metadata.maxX doubleValue]];
                    [GPKGTestUtils assertEqualDoubleWithValue:minY andValue2:[metadata.minY doubleValue]];
                    [GPKGTestUtils assertEqualDoubleWithValue:maxY andValue2:[metadata.maxY doubleValue]];
                }
            }
        }
        @finally {
            [results close];
        }
    }
    @finally {
        [db close];
    }
    
    [GPKGTestUtils assertTrue:id1Found];
    [GPKGTestUtils assertTrue:id2Found];
    [GPKGTestUtils assertTrue:id3Found];
    
    // Verify querying for all geometry metadata gets more results
    db= [[GPKGMetadataDb alloc] init];
    @try {
        GPKGGeometryMetadataDao * geometryMetadataDao = [[GPKGGeometryMetadataDao alloc] initWithDatabase:db.connection];
        GPKGResultSet * results = [geometryMetadataDao queryByGeoPackageName:self.geoPackage.name andTableName:featureDao.tableName];
        @try {
            [GPKGTestUtils assertNotNil:results];
            [GPKGTestUtils assertEqualIntWithValue:initialFeatures + 3 andValue2:results.count];
        }
        @finally {
            [results close];
        }
    }
    @finally {
        [db close];
    }
    
}

@end
