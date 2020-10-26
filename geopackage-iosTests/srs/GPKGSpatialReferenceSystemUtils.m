//
//  GPKGSpatialReferenceSystemUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/26/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGSpatialReferenceSystemUtils.h"
#import "GPKGTestUtils.h"

@implementation GPKGSpatialReferenceSystemUtils

+(void) testReadWithGeoPackage: (GPKGGeoPackage *) geoPackage andExpectedResults: (NSNumber *) expectedResults{
    
    GPKGSpatialReferenceSystemDao *dao = [geoPackage spatialReferenceSystemDao];
    GPKGResultSet *results = [dao queryForAll];
    if (expectedResults != nil) {
        [GPKGTestUtils assertEqualIntWithValue:[expectedResults intValue] andValue2:results.count];
    }
    
    if (results.count > 0) {
        
        // Verify non nulls
        while([results moveToNext]){
            GPKGSpatialReferenceSystem *result = (GPKGSpatialReferenceSystem *)[dao object:results];
            [GPKGTestUtils assertNotNil:result.srsName];
            [GPKGTestUtils assertNotNil:result.srsId];
            [GPKGTestUtils assertNotNil:result.organization];
            [GPKGTestUtils assertNotNil:result.organizationCoordsysId];
            [GPKGTestUtils assertNotNil:result.definition];
        }
        
        // Choose random srs
        int random = (int) ([GPKGTestUtils randomDouble] * results.count);
        [results moveToFirst];
        [results moveToPosition:random];
        GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao object:results];
        [results close];

        // Query by id
        GPKGSpatialReferenceSystem *querySrs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:srs.srsId];
        [GPKGTestUtils assertNotNil:querySrs];
        [GPKGTestUtils assertEqualWithValue:srs.srsId andValue2:querySrs.srsId];
        
        // Query for equal
        GPKGResultSet *querySrsResults = [dao queryForEqWithField:GPKG_SRS_COLUMN_ORGANIZATION_COORDSYS_ID andValue:srs.organizationCoordsysId];
        
        [GPKGTestUtils assertNotNil:querySrsResults];
        [GPKGTestUtils assertTrue:querySrsResults.count >= 1];
        BOOL found = NO;
        while([querySrsResults moveToNext]){
            GPKGSpatialReferenceSystem *querySrsValue = (GPKGSpatialReferenceSystem *)[dao object:querySrsResults];
            [GPKGTestUtils assertEqualWithValue:srs.organizationCoordsysId andValue2:querySrsValue.organizationCoordsysId];
            if(!found){
                found = [srs.srsId intValue] == [querySrsValue.srsId intValue];
            }
        }
        [GPKGTestUtils assertTrue:found];
        [querySrsResults close];
        
        // Query for fields values
        GPKGColumnValues * fieldValues = [[GPKGColumnValues alloc] init];
        [fieldValues addColumn:GPKG_SRS_COLUMN_DEFINITION withValue:srs.definition];
        if(srs.theDescription != nil){
            [fieldValues addColumn:GPKG_SRS_COLUMN_DESCRIPTION withValue:srs.theDescription];
        }
        querySrsResults = [dao queryForFieldValues:fieldValues];
        [GPKGTestUtils assertNotNil:querySrsResults];
        [GPKGTestUtils assertTrue:querySrsResults.count > 0];
        found = NO;
        while ([querySrsResults moveToNext]) {
            GPKGSpatialReferenceSystem *querySrsValue = (GPKGSpatialReferenceSystem *)[dao object:querySrsResults];
            [GPKGTestUtils assertEqualWithValue:srs.definition andValue2:querySrsValue.definition];
            if(srs.theDescription != nil){
                [GPKGTestUtils assertEqualWithValue:srs.theDescription andValue2:querySrsValue.theDescription];
            }
            if (!found) {
                found = [srs.srsId intValue] == [querySrsValue.srsId intValue];
            }
        }
        [GPKGTestUtils assertTrue:found];
        [querySrsResults close];

    }
    
}

+(void) testUpdateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGSpatialReferenceSystemDao *dao = [geoPackage spatialReferenceSystemDao];
    GPKGResultSet *results = [dao queryForAll];
    
    if (results.count > 0) {
        
        // Choose random srs
        int random = (int) ([GPKGTestUtils randomDouble] * results.count);
        [results moveToFirst];
        [results moveToPosition:random];
        GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao object:results];
        [results close];
        
        // Update
        NSString *updatedOrganization = @"TEST_ORG";
        [srs setOrganization:updatedOrganization];
        [dao update:srs];
        
        // Verify update
        dao = [geoPackage spatialReferenceSystemDao];
        GPKGSpatialReferenceSystem *updatedSrs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:[dao id:srs]];
        [GPKGTestUtils assertEqualWithValue:updatedOrganization andValue2:updatedSrs.organization];
        
        // Prepared update
        NSString *updatedDescription = @"TEST_DESCRIPTION";
        GPKGContentValues *values = [[GPKGContentValues alloc] init];
        [values putKey:GPKG_SRS_COLUMN_DESCRIPTION withValue:updatedDescription];
        NSMutableString * where = [NSMutableString string];
        [where appendString:[dao buildWhereWithField:GPKG_SRS_COLUMN_PK andValue:[NSNumber numberWithInt:0] andOperation:@">="]];
        NSMutableArray * whereArgs = [NSMutableArray array];
        [whereArgs addObject:[NSNumber numberWithInt:0]];
        int updated = [dao updateWithValues:values andWhere:where andWhereArgs:whereArgs];
    
        // Verify prepared update
        results = [dao queryForAll];
        int count = 0;
        while([results moveToNext]){
            GPKGSpatialReferenceSystem *preparedUpdateSrs = (GPKGSpatialReferenceSystem *)[dao object:results];
            if ([preparedUpdateSrs.srsId intValue] >= 0) {
                [GPKGTestUtils assertEqualWithValue:updatedDescription andValue2:preparedUpdateSrs.theDescription];
                count++;
            }
        }
        [GPKGTestUtils assertEqualIntWithValue:updated andValue2:count];
        [results close];
    }else{
        [results close];
    }
    
}

+(void) testCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGSpatialReferenceSystemDao *dao = [geoPackage spatialReferenceSystemDao];
    
    // Get current count
    int count = [dao count];
    
    NSString *srsName = @"TEST_SRS_NAME";
    NSNumber *srsId = [NSNumber numberWithInt:123456];
    NSString *organization = @"TEST_ORG";
    NSNumber *organizationCoordsysId = [NSNumber numberWithInt:123456];
    NSString *definition = @"TEST_DEFINITION";
    NSString *description = @"TEST_DESCRIPTION";
    
    // Create new srs
    GPKGSpatialReferenceSystem *srs = [[GPKGSpatialReferenceSystem alloc] init];
    [srs setSrsName:srsName];
    [srs setSrsId:srsId];
    [srs setOrganization:organization];
    [srs setOrganizationCoordsysId:organizationCoordsysId];
    [srs setDefinition:definition];
    [srs setTheDescription:description];
    [dao create:srs];
    
    // Verify count
    int newCount = [dao count];
    [GPKGTestUtils assertEqualIntWithValue:count+1 andValue2:newCount];
    
    // Verify saved srs
    GPKGSpatialReferenceSystem *querySrs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:srsId];
    [GPKGTestUtils assertEqualWithValue:srsName andValue2:querySrs.srsName];
    [GPKGTestUtils assertEqualIntWithValue:[srsId intValue] andValue2:[querySrs.srsId intValue]];
    [GPKGTestUtils assertEqualWithValue:organization andValue2:querySrs.organization];
    [GPKGTestUtils assertEqualIntWithValue:[organizationCoordsysId intValue] andValue2:[querySrs.organizationCoordsysId intValue]];
    [GPKGTestUtils assertEqualWithValue:definition andValue2:querySrs.definition];
    [GPKGTestUtils assertEqualWithValue:description andValue2:querySrs.theDescription];
    
    // Test copied srs
    GPKGSpatialReferenceSystem *copySrs = [querySrs mutableCopy];
    [GPKGTestUtils assertEqualWithValue:querySrs.srsName andValue2:copySrs.srsName];
    [GPKGTestUtils assertEqualWithValue:[dao id:querySrs] andValue2:[dao id:copySrs]];
    [GPKGTestUtils assertEqualWithValue:querySrs.organization andValue2:copySrs.organization];
    [GPKGTestUtils assertEqualIntWithValue:[querySrs.organizationCoordsysId intValue] andValue2:[copySrs.organizationCoordsysId intValue]];
    [GPKGTestUtils assertEqualWithValue:querySrs.definition andValue2:copySrs.definition];
    [GPKGTestUtils assertEqualWithValue:querySrs.theDescription andValue2:copySrs.theDescription];
    [GPKGTestUtils assertEqualWithValue:querySrs.definition_12_063 andValue2:copySrs.definition_12_063];
    
    // Change pk
    NSNumber *copySrsId = [NSNumber numberWithInt:654321];
    [copySrs setSrsId:copySrsId];
    
    [dao create:copySrs];
    
    // Verify count
    int newCount2 = [dao count];
    [GPKGTestUtils assertEqualIntWithValue:count+2 andValue2:newCount2];
    
    // Verify saved contents
    GPKGSpatialReferenceSystem *queryCopiedSrs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:copySrsId];
    [GPKGTestUtils assertEqualWithValue:querySrs.srsName andValue2:queryCopiedSrs.srsName];
    [GPKGTestUtils assertEqualWithValue:copySrsId andValue2:[dao id:queryCopiedSrs]];
    [GPKGTestUtils assertEqualWithValue:querySrs.organization andValue2:queryCopiedSrs.organization];
    [GPKGTestUtils assertEqualIntWithValue:[querySrs.organizationCoordsysId intValue] andValue2:[queryCopiedSrs.organizationCoordsysId intValue]];
    [GPKGTestUtils assertEqualWithValue:querySrs.definition andValue2:queryCopiedSrs.definition];
    [GPKGTestUtils assertEqualWithValue:querySrs.theDescription andValue2:queryCopiedSrs.theDescription];
    [GPKGTestUtils assertEqualWithValue:querySrs.definition_12_063 andValue2:queryCopiedSrs.definition_12_063];
    
}

+(void) testDeleteWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [self testDeleteHelperWithGeoPackage:geoPackage andCascade:NO];
    
}

+(void) testDeleteCascadeWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [self testDeleteHelperWithGeoPackage:geoPackage andCascade:YES];
    
}

+(void) testDeleteHelperWithGeoPackage: (GPKGGeoPackage *) geoPackage andCascade: (BOOL) cascade{
    
    GPKGSpatialReferenceSystemDao *dao = [geoPackage spatialReferenceSystemDao];
    GPKGResultSet *results = [dao queryForAll];
    
    if (results.count > 0) {
        
        // Choose random srs
        int random = (int) ([GPKGTestUtils randomDouble] * results.count);
        [results moveToFirst];
        [results moveToPosition:random];
        GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao object:results];
        [results close];
        
        // Save the ids of contents
        GPKGResultSet *contentsResults = [dao contents:srs];
        GPKGContentsDao *contentsDao = [geoPackage contentsDao];
        NSMutableArray *contentsIds = [NSMutableArray array];
        while([contentsResults moveToNext]){
            GPKGContents *contents = (GPKGContents *) [contentsDao object:contentsResults];
            [contentsIds addObject:[contentsDao id:contents]];
        }
        [contentsResults close];
        
        // Save the ids of geometry columns
        NSMutableArray *geometryColumnsIds = [NSMutableArray array];
        GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage geometryColumnsDao];
        if([geometryColumnsDao tableExists]){
            GPKGResultSet *geometryColumnsResults = [dao geometryColumns:srs];
            while([geometryColumnsResults moveToNext]){
                GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *) [geometryColumnsDao object:geometryColumnsResults];
                [geometryColumnsIds addObject:[geometryColumnsDao multiId:geometryColumns]];
            }
            [geometryColumnsResults close];
        }
        
        // Delete the srs
        [geoPackage foreignKeysAsOn:NO];
        if (cascade) {
            [dao deleteCascade:srs];
        } else {
            [dao delete:srs];
        }
        
        // Verify deleted
        GPKGSpatialReferenceSystem *querySrs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:srs.srsId];
        [GPKGTestUtils assertNil:querySrs];
        
        // Verify that contents or foreign keys were deleted
        for(NSString *contentsId in contentsIds){
            GPKGContents *queryContents = (GPKGContents *)[contentsDao queryForIdObject:contentsId];
            if(cascade){
                [GPKGTestUtils assertNil:queryContents];
            }else{
                [GPKGTestUtils assertNil:[contentsDao srs:queryContents]];
            }
        }
        
        // Verify that geometry columns or foreign keys were deleted
        for(NSArray *geometryColumnsId in geometryColumnsIds){
            GPKGGeometryColumns *queryGeometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao queryForMultiIdObject:geometryColumnsId];
            if (cascade) {
                [GPKGTestUtils assertNil:queryGeometryColumns];
            } else {
                [GPKGTestUtils assertNil:[geometryColumnsDao srs:queryGeometryColumns]];
            }
        }
        
        // Choose prepared deleted
        results = [dao queryForAll];
        if (results.count > 0) {
            
            // Choose random srs
            int random = (int) ([GPKGTestUtils randomDouble] * results.count);
            [results moveToFirst];
            [results moveToPosition:random];
            GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao object:results];
            [results close];
            
            // Find which srs to delete and the contents
            GPKGResultSet *queryResults = [dao queryForEqWithField:GPKG_SRS_COLUMN_ORGANIZATION andValue:srs.organization];
            int count = queryResults.count;
            contentsIds = [NSMutableArray array];
            geometryColumnsIds = [NSMutableArray array];
            while([queryResults moveToNext]){
                GPKGSpatialReferenceSystem *queryResultsSrs = (GPKGSpatialReferenceSystem *)[dao object:queryResults];
                GPKGResultSet *contentsResults = [dao contents:queryResultsSrs];
                while([contentsResults moveToNext]){
                    GPKGContents *contents = (GPKGContents *)[contentsDao object:contentsResults];
                    [contentsIds addObject:[contentsDao id:contents]];
                }
                [contentsResults close];
                if ([geometryColumnsDao tableExists]) {
                    GPKGResultSet *geometryColumnsResults = [dao geometryColumns:queryResultsSrs];
                    while([geometryColumnsResults moveToNext]){
                        GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao object:geometryColumnsResults];
                        [geometryColumnsIds addObject:[geometryColumnsDao multiId:geometryColumns]];
                    }
                    [geometryColumnsResults close];
                }
            }
            [queryResults close];
            
            // Delete
            int deleted;
            NSMutableString * where = [NSMutableString string];
            [where appendString:[dao buildWhereWithField:GPKG_SRS_COLUMN_ORGANIZATION andValue:srs.organization]];
            NSMutableArray * whereArgs = [NSMutableArray array];
            [whereArgs addObject:srs.organization];
            if (cascade) {
                deleted = [dao deleteCascadeWhere:where andWhereArgs:whereArgs];
            } else {
                deleted = [dao deleteWhere:where andWhereArgs:whereArgs];
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:deleted];
            
            // Verify that contents or foreign keys were deleted
            for(NSString *contentsId in contentsIds){
                GPKGContents *queryContents = (GPKGContents *)[contentsDao queryForIdObject:contentsId];
                if(cascade){
                    [GPKGTestUtils assertNil:queryContents];
                }else{
                    [GPKGTestUtils assertNil:[contentsDao srs:queryContents]];
                }
            }
            
            // Verify that geometry columns or foreign keys were deleted
            for(NSArray *geometryColumnsId in geometryColumnsIds){
                GPKGGeometryColumns *queryGeometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao queryForMultiIdObject:geometryColumnsId];
                if (cascade) {
                    [GPKGTestUtils assertNil:queryGeometryColumns];
                } else {
                    [GPKGTestUtils assertNil:[geometryColumnsDao srs:queryGeometryColumns]];
                }
            }

        }else{
            [results close];
        }
        
    }else{
        [results close];
    }
    
}

@end
