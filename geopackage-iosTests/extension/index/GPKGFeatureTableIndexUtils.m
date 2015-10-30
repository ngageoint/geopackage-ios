//
//  GPKGFeatureTableIndexUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/19/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTableIndexUtils.h"
#import "GPKGFeatureTableIndex.h"
#import "GPKGTestUtils.h"
#import "GPKGTestGeoPackageProgress.h"
#import "WKBGeometryEnvelopeBuilder.h"
#import "GPKGProjectionConstants.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProjectionTransform.h"
#import "GPKGNGAExtensions.h"

@implementation GPKGFeatureTableIndexUtils

+(void) testIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Test indexing each feature table
    NSArray * featureTables = [geoPackage getFeatureTables];
    for(NSString * featureTable in featureTables){
        
        GPKGFeatureDao * featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureTableIndex * featureTableIndex = [[GPKGFeatureTableIndex alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        
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
        
        [GPKGTestUtils assertFalse:[featureTableIndex isIndexed]];
        [GPKGTestUtils assertNil:[featureTableIndex getLastIndexed]];
        NSDate * currentDate = [NSDate date];
        
        [NSThread sleepForTimeInterval:1];
        
        // Test indexing
        GPKGTestGeoPackageProgress * progress = [[GPKGTestGeoPackageProgress alloc] init];
        [featureTableIndex setProgress:progress];
        int indexCount = [featureTableIndex index];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:indexCount];
        [GPKGTestUtils assertEqualIntWithValue:featureDao.count andValue2:progress.progress];
        [GPKGTestUtils assertNotNil:[featureTableIndex getLastIndexed]];
        NSDate * lastIndexed = [featureTableIndex getLastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexed compare:currentDate] == NSOrderedDescending)];
        
        [GPKGTestUtils assertTrue:[featureTableIndex isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:featureTableIndex.count];
        
        // Test re-indexing, both ignored and forced
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[featureTableIndex index]];
        [NSThread sleepForTimeInterval:1];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:[featureTableIndex indexWithForce:true]];
        [GPKGTestUtils assertTrue:([[featureTableIndex getLastIndexed] compare:lastIndexed] == NSOrderedDescending)];
        
        // Query for all indexed geometries
        int resultCount = 0;
        GPKGResultSet * featureTableResults = [featureTableIndex query];
        while([featureTableResults moveToNext]){
            GPKGGeometryIndex * geometryIndex = [featureTableIndex getGeometryIndexWithResultSet:featureTableResults];
            [self validateGeometryIndexWithFeatureTableIndex:featureTableIndex andGeometryIndex:geometryIndex];
            resultCount++;
        }
        [featureTableResults close];
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
        [GPKGTestUtils assertTrue:[featureTableIndex countWithGeometryEnvelope:envelope] >= 1];
        featureTableResults = [featureTableIndex queryWithGeometryEnvelope:envelope];
        while([featureTableResults moveToNext]){
            GPKGGeometryIndex * geometryIndex = [featureTableIndex getGeometryIndexWithResultSet:featureTableResults];
            [self validateGeometryIndexWithFeatureTableIndex:featureTableIndex andGeometryIndex:geometryIndex];
            if([geometryIndex.geomId intValue] == [[testFeatureRow getId] intValue]){
                featureFound = true;
            }
            resultCount++;
        }
        [featureTableResults close];
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
        [GPKGTestUtils assertTrue:[featureTableIndex countWithBoundingBox:transformedBoundingBox andProjection:projection] >= 1];
        featureTableResults = [featureTableIndex queryWithBoundingBox:transformedBoundingBox andProjection:projection];
        while([featureTableResults moveToNext]){
            GPKGGeometryIndex * geometryIndex = [featureTableIndex getGeometryIndexWithResultSet:featureTableResults];
            [self validateGeometryIndexWithFeatureTableIndex:featureTableIndex andGeometryIndex:geometryIndex];
            if([geometryIndex.geomId intValue] == [[testFeatureRow getId] intValue]){
                featureFound = true;
            }
            resultCount++;
        }
        [featureTableResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Update a Geometry and update the index of a single feature row
        geometryData = [[GPKGGeometryData alloc] initWithSrsId:featureDao.geometryColumns.srsId];
        WKBPoint * point = [[WKBPoint alloc] initWithX:[[NSDecimalNumber alloc] initWithDouble:5.0] andY:[[NSDecimalNumber alloc] initWithDouble:5.0]];
        [geometryData setGeometry:point];
        [testFeatureRow setGeometry:geometryData];
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[featureDao update:testFeatureRow]];
        NSDate * lastIndexedBefore = [featureTableIndex getLastIndexed];
        [NSThread sleepForTimeInterval:1];
        [GPKGTestUtils assertTrue:[featureTableIndex indexFeatureRow:testFeatureRow]];
        NSDate * lastIndexedAfter = [featureTableIndex getLastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexedAfter compare:lastIndexedBefore] == NSOrderedDescending)];
        
        // Verify the index was updated for the feature row
        envelope = [WKBGeometryEnvelopeBuilder buildEnvelopeWithGeometry:point];
        resultCount = 0;
        featureFound = false;
        [GPKGTestUtils assertTrue:[featureTableIndex countWithGeometryEnvelope:envelope] >= 1];
        featureTableResults = [featureTableIndex queryWithGeometryEnvelope:envelope];
        while([featureTableResults moveToNext]){
            GPKGGeometryIndex * geometryIndex = [featureTableIndex getGeometryIndexWithResultSet:featureTableResults];
            [self validateGeometryIndexWithFeatureTableIndex:featureTableIndex andGeometryIndex:geometryIndex];
            if([geometryIndex.geomId intValue] == [[testFeatureRow getId] intValue]){
                featureFound = true;
            }
            resultCount++;
        }
        [featureTableResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
    }
    
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    GPKGGeometryIndexDao * geometryIndexDao = [geoPackage getGeometryIndexDao];
    GPKGTableIndexDao * tableIndexDao = [geoPackage getTableIndexDao];
    
    // Delete the extensions for the first half of the feature tables
    BOOL everyOther = false;
    for(NSString * featureTable in [featureTables subarrayWithRange:NSMakeRange(0, (int)ceil(featureTables.count * .5))]){
        GPKGFeatureDao * featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureTableIndex * featureTableIndex = [[GPKGFeatureTableIndex alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        
        int geometryCount = [geometryIndexDao countByTableName:featureTable];
        [GPKGTestUtils assertTrue:geometryCount > 0];
        [GPKGTestUtils assertNotNil:[tableIndexDao queryForIdObject:featureTable]];
        GPKGExtensions * extensions = [extensionsDao queryByExtension:[featureTableIndex getExtensionName] andTable:featureTable andColumnName:[featureDao getGeometryColumnName]];
        [GPKGTestUtils assertNotNil:extensions];
        [GPKGTestUtils assertEqualWithValue:extensions.tableName andValue2:featureTable];
        [GPKGTestUtils assertEqualWithValue:extensions.columnName andValue2:[featureDao getGeometryColumnName]];
        [GPKGTestUtils assertEqualWithValue:extensions.extensionName andValue2:[featureTableIndex getExtensionName]];
        [GPKGTestUtils assertEqualWithValue:[extensions getAuthor] andValue2:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR];
        [GPKGTestUtils assertEqualWithValue:[extensions getExtensionNameNoAuthor] andValue2:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
        [GPKGTestUtils assertEqualWithValue:extensions.definition andValue2:[featureTableIndex getExtensionDefinition]];
        [GPKGTestUtils assertEqualIntWithValue:[extensions getExtensionScopeType] andValue2:GPKG_EST_READ_WRITE];
        [GPKGTestUtils assertTrue:[featureTableIndex isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:geometryCount andValue2:[featureTableIndex count]];
        
        // Test deleting a single geometry index
        if(everyOther){
            GPKGResultSet * featureResults = [featureDao queryForAll];
            while([featureResults moveToNext]){
                GPKGFeatureRow * featureRow = [featureDao getFeatureRow:featureResults];
                GPKGGeometryData * geometryData = [featureRow getGeometry];
                if(geometryData != nil
                   && (geometryData.envelope != nil || geometryData.geometry != nil)){
                    [featureResults close];
                    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[featureTableIndex deleteIndexWithFeatureRow:featureRow]];
                    [GPKGTestUtils assertEqualIntWithValue:geometryCount-1 andValue2:featureTableIndex.count];
                    break;
                }
            }
            [featureResults close];
        }
        
        [GPKGNGAExtensions deleteTableExtensionsWithGeoPackage:geoPackage andTable:featureTable];
        
        [GPKGTestUtils assertFalse:[featureTableIndex isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[geometryIndexDao countByTableName:featureTable]];
        [GPKGTestUtils assertNil:[tableIndexDao queryForIdObject:featureTable]];
        extensions = [extensionsDao queryByExtension:[featureTableIndex getExtensionName] andTable:featureTable andColumnName:[featureDao getGeometryColumnName]];
        [GPKGTestUtils assertNil:extensions];
        everyOther = !everyOther;
    }
    
    [GPKGTestUtils assertTrue:[geometryIndexDao tableExists]];
    [GPKGTestUtils assertTrue:[tableIndexDao tableExists]];
    NSString * extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
    [GPKGTestUtils assertTrue:[extensionsDao countByExtension:extensionName] > 0];

     // Test deleting all NGA extensions
     [GPKGNGAExtensions deleteExtensionsWithGeoPackage:geoPackage];
     
     [GPKGTestUtils assertFalse:[geometryIndexDao tableExists]];
     [GPKGTestUtils assertFalse:[tableIndexDao tableExists]];
     [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extensionsDao countByExtension:extensionName]];
}

+(void) validateGeometryIndexWithFeatureTableIndex: (GPKGFeatureTableIndex *) featureTableIndex andGeometryIndex: (GPKGGeometryIndex *) geometryIndex{
    GPKGFeatureRow * featureRow = [featureTableIndex getFeatureRowWithGeometryIndex:geometryIndex];
    [GPKGTestUtils assertNotNil:featureRow];
    [GPKGTestUtils assertEqualWithValue:[featureTableIndex getTableName] andValue2:geometryIndex.tableName];
    [GPKGTestUtils assertEqualIntWithValue:[geometryIndex.geomId intValue] andValue2:[[featureRow getId] intValue]];
    GPKGGeometryData * geometryData = [featureRow getGeometry];
    WKBGeometryEnvelope * envelope = geometryData.envelope;
    if(envelope == nil){
        WKBGeometry * geometry = geometryData.geometry;
        if(geometry != nil){
            envelope = [WKBGeometryEnvelopeBuilder buildEnvelopeWithGeometry:geometry];
        }
    }
    
    [GPKGTestUtils assertNotNil:envelope];
    
    [GPKGTestUtils assertEqualDoubleWithValue:[envelope.minX doubleValue] andValue2:[geometryIndex.minX doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[envelope.maxX doubleValue] andValue2:[geometryIndex.maxX doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[envelope.minY doubleValue] andValue2:[geometryIndex.minY doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[envelope.maxY doubleValue] andValue2:[geometryIndex.maxY doubleValue]];
    if(envelope.hasZ){
        [GPKGTestUtils assertEqualDoubleWithValue:[envelope.minZ doubleValue] andValue2:[geometryIndex.minZ doubleValue]];
        [GPKGTestUtils assertEqualDoubleWithValue:[envelope.maxZ doubleValue] andValue2:[geometryIndex.maxZ doubleValue]];
    } else{
        [GPKGTestUtils assertNil:geometryIndex.minZ];
        [GPKGTestUtils assertNil:geometryIndex.maxZ];
    }
    if(envelope.hasM){
        [GPKGTestUtils assertEqualDoubleWithValue:[envelope.minM doubleValue] andValue2:[geometryIndex.minM doubleValue]];
        [GPKGTestUtils assertEqualDoubleWithValue:[envelope.maxM doubleValue] andValue2:[geometryIndex.maxM doubleValue]];
    } else{
        [GPKGTestUtils assertNil:geometryIndex.minM];
        [GPKGTestUtils assertNil:geometryIndex.maxM];
    }
}

@end
