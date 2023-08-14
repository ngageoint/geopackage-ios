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
#import "PROJProjectionConstants.h"
#import "PROJProjectionFactory.h"
#import "GPKGExtensionManager.h"
#import "GPKGNGAExtensions.h"

@implementation GPKGFeatureTableIndexUtils

+(void) testIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Test indexing each feature table
    NSArray *featureTables = [geoPackage featureTables];
    for(NSString *featureTable in featureTables){
        
        GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
        GPKGFeatureTableIndex *featureTableIndex = [[GPKGFeatureTableIndex alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        
        // Determine how many features have geometry envelopes or geometries
        int expectedCount = 0;
        GPKGFeatureRow *testFeatureRow = nil;
        GPKGResultSet *featureResultSet = [featureDao queryForAll];
        while([featureResultSet moveToNext]){
            GPKGFeatureRow *featureRow = [featureDao row:featureResultSet];
            if([featureRow geometryEnvelope] != nil){
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
        
        if([featureTableIndex isIndexed]){
            [featureTableIndex deleteIndex];
        }
        
        [GPKGTestUtils assertFalse:[featureTableIndex isIndexed]];
        [GPKGTestUtils assertNil:[featureTableIndex lastIndexed]];
        NSDate *currentDate = [NSDate date];
        
        [NSThread sleepForTimeInterval:1];
        
        [GPKGTestUtils validateGeoPackage:geoPackage];
        
        // Test indexing
        GPKGTestGeoPackageProgress *progress = [[GPKGTestGeoPackageProgress alloc] init];
        [featureTableIndex setProgress:progress];
        int indexCount = [featureTableIndex index];
        [GPKGTestUtils validateGeoPackage:geoPackage];
        
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:indexCount];
        [GPKGTestUtils assertEqualIntWithValue:featureDao.count andValue2:progress.progress];
        [GPKGTestUtils assertNotNil:[featureTableIndex lastIndexed]];
        NSDate *lastIndexed = [featureTableIndex lastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexed compare:currentDate] == NSOrderedDescending)];
        
        [GPKGTestUtils assertTrue:[featureTableIndex isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:featureTableIndex.count];
        
        // Test re-indexing, both ignored and forced
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[featureTableIndex index]];
        [NSThread sleepForTimeInterval:1];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:[featureTableIndex indexWithForce:YES]];
        [GPKGTestUtils assertTrue:([[featureTableIndex lastIndexed] compare:lastIndexed] == NSOrderedDescending)];
        
        // Query for all indexed geometries
        int resultCount = 0;
        GPKGResultSet *featureTableResults = [featureTableIndex query];
        while([featureTableResults moveToNext]){
            GPKGGeometryIndex *geometryIndex = [featureTableIndex geometryIndexWithResultSet:featureTableResults];
            [self validateGeometryIndexWithFeatureTableIndex:featureTableIndex andGeometryIndex:geometryIndex];
            resultCount++;
        }
        [featureTableResults close];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:resultCount];
        
        // Test the query by envelope
        SFGeometryEnvelope *envelope = [testFeatureRow geometryEnvelope];
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
        BOOL featureFound = NO;
        [GPKGTestUtils assertTrue:[featureTableIndex countWithEnvelope:envelope] >= 1];
        featureTableResults = [featureTableIndex queryWithEnvelope:envelope];
        while([featureTableResults moveToNext]){
            GPKGGeometryIndex *geometryIndex = [featureTableIndex geometryIndexWithResultSet:featureTableResults];
            [self validateGeometryIndexWithFeatureTableIndex:featureTableIndex andGeometryIndex:geometryIndex];
            if([geometryIndex.geomId intValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureTableResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Pick a projection different from the feature dao and project the
        // bounding box
        GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:[envelope.minX doubleValue] - 1.0
                                                                       andMinLatitudeDouble:[envelope.minY doubleValue] - 1.0
                                                                      andMaxLongitudeDouble:[envelope.maxX doubleValue] + 1.0
                                                                       andMaxLatitudeDouble:[envelope.maxY doubleValue] + 1.0];
        PROJProjection *projection = nil;
        if(![featureDao.projection isEqualToAuthority:PROJ_AUTHORITY_EPSG andNumberCode:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]]){
            projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        }else{
            projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
        }
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromProjection:featureDao.projection andToProjection:projection];
        GPKGBoundingBox *transformedBoundingBox = [boundingBox transform:transform];
        [transform destroy];
        
        // Test the query by projected bounding box
        resultCount = 0;
        featureFound = NO;
        [GPKGTestUtils assertTrue:[featureTableIndex countWithBoundingBox:transformedBoundingBox inProjection:projection] >= 1];
        featureTableResults = [featureTableIndex queryWithBoundingBox:transformedBoundingBox inProjection:projection];
        while([featureTableResults moveToNext]){
            GPKGGeometryIndex *geometryIndex = [featureTableIndex geometryIndexWithResultSet:featureTableResults];
            [self validateGeometryIndexWithFeatureTableIndex:featureTableIndex andGeometryIndex:geometryIndex];
            if([geometryIndex.geomId intValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureTableResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
        
        // Update a Geometry and update the index of a single feature row
        SFPoint *point = [SFPoint pointWithXValue:5.0 andYValue:5.0];
        GPKGGeometryData *geometryData = [GPKGGeometryData createWithSrsId:featureDao.geometryColumns.srsId andGeometry:point];
        [testFeatureRow setGeometry:geometryData];
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[featureDao update:testFeatureRow]];
        NSDate *lastIndexedBefore = [featureTableIndex lastIndexed];
        [NSThread sleepForTimeInterval:1];
        [GPKGTestUtils assertTrue:[featureTableIndex indexFeatureRow:testFeatureRow]];
        NSDate *lastIndexedAfter = [featureTableIndex lastIndexed];
        [GPKGTestUtils assertTrue:([lastIndexedAfter compare:lastIndexedBefore] == NSOrderedDescending)];
        
        // Verify the index was updated for the feature row
        envelope = [point envelope];
        resultCount = 0;
        featureFound = NO;
        [GPKGTestUtils assertTrue:[featureTableIndex countWithEnvelope:envelope] >= 1];
        featureTableResults = [featureTableIndex queryWithEnvelope:envelope];
        while([featureTableResults moveToNext]){
            GPKGGeometryIndex *geometryIndex = [featureTableIndex geometryIndexWithResultSet:featureTableResults];
            [self validateGeometryIndexWithFeatureTableIndex:featureTableIndex andGeometryIndex:geometryIndex];
            if([geometryIndex.geomId intValue] == [testFeatureRow idValue]){
                featureFound = YES;
            }
            resultCount++;
        }
        [featureTableResults close];
        [GPKGTestUtils assertTrue:featureFound];
        [GPKGTestUtils assertTrue:resultCount >= 1];
    }
    
    GPKGExtensionsDao *extensionsDao = [geoPackage extensionsDao];
    GPKGGeometryIndexDao *geometryIndexDao = [GPKGFeatureTableIndex geometryIndexDaoWithGeoPackage:geoPackage];
    GPKGTableIndexDao *tableIndexDao = [GPKGFeatureTableIndex tableIndexDaoWithGeoPackage:geoPackage];
    
    // Delete the extensions for the first half of the feature tables
    BOOL everyOther = NO;
    for(NSString *featureTable in [featureTables subarrayWithRange:NSMakeRange(0, (int)ceil(featureTables.count * .5))]){
        GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
        GPKGFeatureTableIndex *featureTableIndex = [[GPKGFeatureTableIndex alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        
        int geometryCount = [geometryIndexDao countByTableName:featureTable];
        [GPKGTestUtils assertTrue:geometryCount > 0];
        [GPKGTestUtils assertNotNil:[tableIndexDao queryForIdObject:featureTable]];
        GPKGExtensions *extensions = [extensionsDao queryByExtension:[featureTableIndex extensionName] andTable:featureTable andColumnName:[featureDao geometryColumnName]];
        [GPKGTestUtils assertNotNil:extensions];
        [GPKGTestUtils assertEqualWithValue:extensions.tableName andValue2:featureTable];
        [GPKGTestUtils assertEqualWithValue:extensions.columnName andValue2:[featureDao geometryColumnName]];
        [GPKGTestUtils assertEqualWithValue:extensions.extensionName andValue2:[featureTableIndex extensionName]];
        [GPKGTestUtils assertEqualWithValue:[extensions author] andValue2:GPKG_NGA_EXTENSION_AUTHOR];
        [GPKGTestUtils assertEqualWithValue:[extensions extensionNameNoAuthor] andValue2:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
        [GPKGTestUtils assertEqualWithValue:extensions.definition andValue2:[featureTableIndex extensionDefinition]];
        [GPKGTestUtils assertEqualIntWithValue:[extensions extensionScopeType] andValue2:GPKG_EST_READ_WRITE];
        [GPKGTestUtils assertTrue:[featureTableIndex isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:geometryCount andValue2:[featureTableIndex count]];
        
        // Test deleting a single geometry index
        if(everyOther){
            GPKGResultSet *featureResults = [featureDao queryForAll];
            while([featureResults moveToNext]){
                GPKGFeatureRow *featureRow = [featureDao row:featureResults];
                GPKGGeometryData *geometryData = [featureRow geometry];
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
        
        [[GPKGExtensionManager createWithGeoPackage:geoPackage] deleteExtensionsForTable:featureTable];
        
        [GPKGTestUtils assertFalse:[featureTableIndex isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[geometryIndexDao countByTableName:featureTable]];
        [GPKGTestUtils assertNil:[tableIndexDao queryForIdObject:featureTable]];
        extensions = [extensionsDao queryByExtension:[featureTableIndex extensionName] andTable:featureTable andColumnName:[featureDao geometryColumnName]];
        [GPKGTestUtils assertNil:extensions];
        everyOther = !everyOther;
    }
    
    [GPKGTestUtils assertTrue:[geometryIndexDao tableExists]];
    [GPKGTestUtils assertTrue:[tableIndexDao tableExists]];
    NSString *extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_NGA_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
    [GPKGTestUtils assertTrue:[extensionsDao countByExtension:extensionName] > 0];

    // Test deleting all NGA extensions
    [[GPKGExtensionManager createWithGeoPackage:geoPackage] deleteExtensions];
     
    [GPKGTestUtils assertFalse:[geometryIndexDao tableExists]];
    [GPKGTestUtils assertFalse:[tableIndexDao tableExists]];
    [GPKGTestUtils assertFalse:[extensionsDao tableExists]];
    
}

+(void) testDeleteAllWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Test indexing each feature table
    NSArray *featureTables = [geoPackage featureTables];
    for(NSString *featureTable in featureTables){
        
        GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
        GPKGFeatureTableIndex *featureTableIndex = [[GPKGFeatureTableIndex alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        
        if([featureTableIndex isIndexed]){
            [featureTableIndex deleteIndex];
        }
        
        [GPKGTestUtils assertFalse:[featureTableIndex isIndexed]];
        
        [GPKGTestUtils validateGeoPackage:geoPackage];
        
        // Test indexing
        [featureTableIndex index];
        [GPKGTestUtils validateGeoPackage:geoPackage];
        
        [GPKGTestUtils assertTrue:[featureTableIndex isIndexed]];
        
    }
    
    GPKGExtensionsDao *extensionsDao = [geoPackage extensionsDao];
    GPKGGeometryIndexDao *geometryIndexDao = [GPKGFeatureTableIndex geometryIndexDaoWithGeoPackage:geoPackage];
    GPKGTableIndexDao *tableIndexDao = [GPKGFeatureTableIndex tableIndexDaoWithGeoPackage:geoPackage];

    [GPKGTestUtils assertTrue:[geometryIndexDao tableExists]];
    [GPKGTestUtils assertTrue:[tableIndexDao tableExists]];
    NSString *extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_NGA_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
    [GPKGTestUtils assertTrue:[extensionsDao countByExtension:extensionName] > 0];

    [GPKGTestUtils assertTrue:[geometryIndexDao count] > 0];
    int count = [tableIndexDao count];
    [GPKGTestUtils assertTrue:count > 0];
    
    int deleteCount = [tableIndexDao deleteAllCascade];
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:deleteCount];
    
    [GPKGTestUtils assertTrue:[geometryIndexDao count] == 0];
    [GPKGTestUtils assertTrue:[tableIndexDao count] == 0];

}

+(void) validateGeometryIndexWithFeatureTableIndex: (GPKGFeatureTableIndex *) featureTableIndex andGeometryIndex: (GPKGGeometryIndex *) geometryIndex{
    GPKGFeatureRow *featureRow = [featureTableIndex featureRowWithGeometryIndex:geometryIndex];
    [GPKGTestUtils assertNotNil:featureRow];
    [GPKGTestUtils assertEqualWithValue:[featureTableIndex tableName] andValue2:geometryIndex.tableName];
    [GPKGTestUtils assertEqualIntWithValue:[geometryIndex.geomId intValue] andValue2:[featureRow idValue]];
    SFGeometryEnvelope *envelope = [featureRow geometryEnvelope];
    
    [GPKGTestUtils assertNotNil:envelope];
    
    [GPKGTestUtils assertEqualDoubleWithValue:[envelope.minX doubleValue] andValue2:[geometryIndex.minX doubleValue] andDelta:.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:[envelope.maxX doubleValue] andValue2:[geometryIndex.maxX doubleValue] andDelta:.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:[envelope.minY doubleValue] andValue2:[geometryIndex.minY doubleValue] andDelta:.00000001];
    [GPKGTestUtils assertEqualDoubleWithValue:[envelope.maxY doubleValue] andValue2:[geometryIndex.maxY doubleValue] andDelta:.00000001];
    if(envelope.hasZ){
        [GPKGTestUtils assertEqualDoubleWithValue:[envelope.minZ doubleValue] andValue2:[geometryIndex.minZ doubleValue] andDelta:.00000001];
        [GPKGTestUtils assertEqualDoubleWithValue:[envelope.maxZ doubleValue] andValue2:[geometryIndex.maxZ doubleValue] andDelta:.00000001];
    } else{
        [GPKGTestUtils assertNil:geometryIndex.minZ];
        [GPKGTestUtils assertNil:geometryIndex.maxZ];
    }
    if(envelope.hasM){
        [GPKGTestUtils assertEqualDoubleWithValue:[envelope.minM doubleValue] andValue2:[geometryIndex.minM doubleValue] andDelta:.00000001];
        [GPKGTestUtils assertEqualDoubleWithValue:[envelope.maxM doubleValue] andValue2:[geometryIndex.maxM doubleValue] andDelta:.00000001];
    } else{
        [GPKGTestUtils assertNil:geometryIndex.minM];
        [GPKGTestUtils assertNil:geometryIndex.maxM];
    }
}

@end
