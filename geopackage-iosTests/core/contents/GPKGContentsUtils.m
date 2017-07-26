//
//  GPKGContentsUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/25/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGContentsUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGDateTimeUtils.h"

@implementation GPKGContentsUtils

+(void) testReadWithGeoPackage: (GPKGGeoPackage *) geoPackage andExpectedResults: (NSNumber *) expectedResults{
    
    GPKGContentsDao *dao = [geoPackage getContentsDao];
    GPKGResultSet *results = [dao queryForAll];
    if (expectedResults != nil) {
        [GPKGTestUtils assertEqualIntWithValue:[expectedResults intValue] andValue2:results.count];
    }
    
    if (results.count > 0) {
        
        int count = results.count;
        
        // Verify non nulls
        while([results moveToNext]){
            GPKGContents *result = (GPKGContents *)[dao getObject:results];
            [GPKGTestUtils assertNotNil:result.tableName];
            [GPKGTestUtils assertNotNil:result.dataType];
            [GPKGTestUtils assertEqualWithValue:result.dataType andValue2:[GPKGContentsDataTypes name:[result getContentsDataType]]];
            [GPKGTestUtils assertNotNil:result.lastChange];
            GPKGSpatialReferenceSystem *srs = [dao getSrs:result];
            if (srs != nil) {
                [GPKGTestUtils assertNotNil:srs.srsName];
                [GPKGTestUtils assertNotNil:srs.srsId];
                [GPKGTestUtils assertNotNil:srs.organization];
                [GPKGTestUtils assertNotNil:srs.organizationCoordsysId];
                [GPKGTestUtils assertNotNil:srs.definition];
            }
        }
        
        // Choose random contents
        int random = (int) ([GPKGTestUtils randomDouble] * results.count);
        [results moveToFirst];
        [results moveToPosition:random];
        GPKGContents *contents = (GPKGContents *)[dao getObject:results];
        [results close];
        
        // Query by id
        GPKGContents *queryContents = (GPKGContents *)[dao queryForIdObject:contents.tableName];
        [GPKGTestUtils assertNotNil:queryContents];
        [GPKGTestUtils assertEqualWithValue:contents.tableName andValue2:queryContents.tableName];
        
        // Query for equal
        GPKGResultSet *queryContentsResults = [dao queryForEqWithField:GPKG_CON_COLUMN_IDENTIFIER andValue:contents.identifier];
        
        [GPKGTestUtils assertNotNil:queryContentsResults];
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:queryContentsResults.count];
        contents = (GPKGContents *)[dao getFirstObject:queryContentsResults];
        [GPKGTestUtils assertEqualWithValue:contents.identifier andValue2:contents.identifier];
        [queryContentsResults close];
        
        // Query for field values
        GPKGColumnValues * fieldValues = [[GPKGColumnValues alloc] init];
        [fieldValues addColumn:GPKG_CON_COLUMN_DATA_TYPE withValue:contents.dataType];
        if(contents.srsId != nil){
            [fieldValues addColumn:GPKG_CON_COLUMN_SRS_ID withValue:contents.srsId];
        }
        queryContentsResults = [dao queryForFieldValues:fieldValues];
        [GPKGTestUtils assertNotNil:queryContentsResults];
        [GPKGTestUtils assertTrue:queryContentsResults.count > 0];
        BOOL found = false;
        while ([queryContentsResults moveToNext]) {
            GPKGContents *queryContentsValue = (GPKGContents *)[dao getObject:queryContentsResults];
            [GPKGTestUtils assertEqualWithValue:contents.dataType andValue2:queryContentsValue.dataType];
            if(contents.srsId != nil){
                [GPKGTestUtils assertEqualWithValue:contents.srsId andValue2:queryContentsValue.srsId];
            }
            if (!found) {
                found = [contents.tableName isEqualToString:queryContentsValue.tableName];
            }
        }
        [GPKGTestUtils assertTrue:found];
        [queryContentsResults close];
        
        // Prepared query, less than equal date
        NSMutableString * where = [[NSMutableString alloc] init];
        [where appendString:[dao buildWhereWithField:GPKG_CON_COLUMN_LAST_CHANGE andValue:contents.lastChange andOperation:@"<="]];
        NSMutableArray * whereArgs = [[NSMutableArray alloc] init];
        [whereArgs addObject:contents.lastChange];
        queryContentsResults = [dao queryWhere:where andWhereArgs:whereArgs];
        
        int queryCount = queryContentsResults.count;
        
        found = false;
        while ([queryContentsResults moveToNext]) {
            GPKGContents *queryContentsValue = (GPKGContents *)[dao getObject:queryContentsResults];
            if([contents.tableName isEqualToString:queryContentsValue.tableName]){
                found = true;
                break;
            }
        }
        [GPKGTestUtils assertTrue:found];
        [queryContentsResults close];
        
        // Prepared query, greater than date
        where = [[NSMutableString alloc] init];
        [where appendString:[dao buildWhereWithField:GPKG_CON_COLUMN_LAST_CHANGE andValue:contents.lastChange andOperation:@">"]];
        whereArgs = [[NSMutableArray alloc] init];
        [whereArgs addObject:contents.lastChange];
        queryContentsResults = [dao queryWhere:where andWhereArgs:whereArgs];
        
        found = false;
        while ([queryContentsResults moveToNext]) {
            GPKGContents *queryContentsValue = (GPKGContents *)[dao getObject:queryContentsResults];
            if([contents.tableName isEqualToString:queryContentsValue.tableName]){
                found = true;
                break;
            }
        }
        [GPKGTestUtils assertFalse:found];
        [queryContentsResults close];
        
        queryCount += queryContentsResults.count;
        [GPKGTestUtils assertEqualIntWithValue:count andValue2:queryCount];
        
    }else{
        [results close];
    }
}

+(void) testUpdateWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGContentsDao *dao = [geoPackage getContentsDao];
    GPKGResultSet *results = [dao queryForAll];
    
    if (results.count > 0) {
        
        // Choose random contents
        int random = (int) ([GPKGTestUtils randomDouble] * results.count);
        [results moveToPosition:random];
        GPKGContents *contents = (GPKGContents *)[dao getObject:results];
        [results close];
        
        // Update
        NSDate *updatedLastChange = [NSDate date];
        updatedLastChange = [GPKGDateTimeUtils convertToDateWithString:[GPKGDateTimeUtils convertToDateTimeStringWithDate:updatedLastChange]];
        [contents setLastChange:updatedLastChange];
        [dao update:contents];
        
        // Verify update
        dao = [geoPackage getContentsDao];
        GPKGContents *updatedContents = (GPKGContents *)[dao queryForIdObject:[dao getId:contents]];
        [GPKGTestUtils assertTrue:[updatedLastChange compare:updatedContents.lastChange] == NSOrderedSame];
        
        // Find expected results for prepared update
        NSDecimalNumber *updatedMinimum = [[NSDecimalNumber alloc] initWithDouble:-90.0];
        NSMutableString * where = [[NSMutableString alloc] init];
        [where appendString:[dao buildWhereWithField:GPKG_CON_COLUMN_MIN_X andValue:[NSNumber numberWithInt:0] andOperation:@">="]];
        [where appendString:@" or "];
        [where appendString:[dao buildWhereWithField:GPKG_CON_COLUMN_MIN_Y andValue:[NSNumber numberWithInt:0] andOperation:@">="]];
        NSMutableArray * whereArgs = [[NSMutableArray alloc] init];
        [whereArgs addObject:[NSNumber numberWithInt:0]];
        [whereArgs addObject:[NSNumber numberWithInt:0]];
        GPKGResultSet *queryResults = [dao queryWhere:where andWhereArgs:whereArgs];

        // Prepared update
        GPKGContentValues *values = [[GPKGContentValues alloc] init];
        [values putKey:GPKG_CON_COLUMN_MIN_X withValue:updatedMinimum];
        [values putKey:GPKG_CON_COLUMN_MIN_Y withValue:updatedMinimum];
        int updated = [dao updateWithValues:values andWhere:where andWhereArgs:whereArgs];
        [GPKGTestUtils assertEqualIntWithValue:queryResults.count andValue2:updated];
        
        while([queryResults moveToNext]){
            GPKGContents *updatedContent = (GPKGContents *)[dao getObject:queryResults];
            GPKGContents *reloadedContents = (GPKGContents *)[dao queryForSameId:updatedContent];
            [GPKGTestUtils assertEqualDoubleWithValue:[updatedMinimum doubleValue] andValue2:[reloadedContents.minX doubleValue]];
            [GPKGTestUtils assertEqualDoubleWithValue:[updatedMinimum doubleValue] andValue2:[reloadedContents.minY doubleValue]];
        }
        
        [queryResults close];
    }else{
        [results close];
    }
    
}

+(void) testCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage getSpatialReferenceSystemDao];
    GPKGContentsDao *dao = [geoPackage getContentsDao];
    
    // Get current count
    int count = [dao count];
    
    // Retrieve a random srs
    GPKGResultSet *results = [srsDao queryForAll];
    GPKGSpatialReferenceSystem *srs = nil;
    if(results.count > 0){
        int random = (int) ([GPKGTestUtils randomDouble] * results.count);
        [results moveToPosition:random];
        srs = (GPKGSpatialReferenceSystem *)[srsDao getObject:results];
    }
    [results close];
    
    NSString *tableName = @"TEST_TABLE_NAME";
    enum GPKGContentsDataType dataType = GPKG_CDT_FEATURES;
    NSString *identifier = @"TEST_IDENTIFIER";
    NSString *description = @"TEST_IDENTIFIER";
    NSDate *lastChange = [NSDate date];
    lastChange = [GPKGDateTimeUtils convertToDateWithString:[GPKGDateTimeUtils convertToDateTimeStringWithDate:lastChange]];
    NSDecimalNumber *minX = [[NSDecimalNumber alloc] initWithDouble:-180.0];
    NSDecimalNumber *minY = [[NSDecimalNumber alloc] initWithDouble:-90.0];
    NSDecimalNumber *maxX = [[NSDecimalNumber alloc] initWithDouble:180.0];
    NSDecimalNumber *maxY = [[NSDecimalNumber alloc] initWithDouble:90.0];
    
    // Create new contents
    GPKGContents *contents = [[GPKGContents alloc] init];
    [contents setTableName:tableName];
    [contents setContentsDataType:dataType];
    [contents setIdentifier:identifier];
    [contents setTheDescription:description];
    [contents setLastChange:lastChange];
    [contents setMinX:minX];
    [contents setMinY:minY];
    [contents setMaxX:maxX];
    [contents setMaxY:maxY];
    [contents setSrs:srs];
    
    // Create the feature table
    [geoPackage createFeatureTable:[GPKGTestUtils buildFeatureTableWithTableName:contents.tableName andGeometryColumn:@"geom" andGeometryType:WKB_GEOMETRY]];
    
    [geoPackage createGeometryColumnsTable];
    
    [dao create:contents];
    
    // Verify count
    int newCount = [dao count];
    [GPKGTestUtils assertEqualIntWithValue:count+1 andValue2:newCount];
    
    // Verify saved contents
    GPKGContents *queryContents = (GPKGContents *)[dao queryForIdObject:tableName];
    NSString *queryContentsId = (NSString *)[dao getId:queryContents];
    [GPKGTestUtils assertEqualWithValue:tableName andValue2:queryContents.tableName];
    [GPKGTestUtils assertEqualWithValue:[GPKGContentsDataTypes name:dataType] andValue2:queryContents.dataType];
    [GPKGTestUtils assertEqualWithValue:identifier andValue2:queryContents.identifier];
    [GPKGTestUtils assertEqualWithValue:description andValue2:queryContents.theDescription];
    [GPKGTestUtils assertTrue:[lastChange compare:queryContents.lastChange] == NSOrderedSame];
    [GPKGTestUtils assertEqualDoubleWithValue:[minX doubleValue] andValue2:[queryContents.minX doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[minY doubleValue] andValue2:[queryContents.minY doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[maxX doubleValue] andValue2:[queryContents.maxX doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[maxY doubleValue] andValue2:[queryContents.maxY doubleValue]];
    if(srs != nil){
        [GPKGTestUtils assertEqualIntWithValue:[srs.srsId intValue] andValue2:[queryContents.srsId intValue]];
    }else{
        [GPKGTestUtils assertNil:queryContents.srsId];
    }
    
    // Test copied contents
    GPKGContents *copyContents = [queryContents mutableCopy];
    [GPKGTestUtils assertEqualWithValue:[dao getId:queryContents] andValue2:[dao getId:copyContents]];
    [GPKGTestUtils assertEqualWithValue:queryContents.tableName andValue2:copyContents.tableName];
    [GPKGTestUtils assertEqualWithValue:queryContents.dataType andValue2:copyContents.dataType];
    [GPKGTestUtils assertEqualWithValue:queryContents.identifier andValue2:copyContents.identifier];
    [GPKGTestUtils assertEqualWithValue:queryContents.theDescription andValue2:copyContents.theDescription];
    [GPKGTestUtils assertTrue:[queryContents.lastChange compare:copyContents.lastChange] == NSOrderedSame];
    [GPKGTestUtils assertEqualWithValue:queryContents.minX andValue2:copyContents.minX];
    [GPKGTestUtils assertEqualWithValue:queryContents.minY andValue2:copyContents.minY];
    [GPKGTestUtils assertEqualWithValue:queryContents.maxX andValue2:copyContents.maxX];
    [GPKGTestUtils assertEqualWithValue:queryContents.maxY andValue2:copyContents.maxY];
    [GPKGTestUtils assertEqualWithValue:queryContents.srsId andValue2:copyContents.srsId];
    
    // Change pk and unique
    NSString *copyTableName = @"CopyContents";
    NSString *copyIdentifier = @"CopyIdentifier";
    [dao setId:copyContents withIdValue:copyTableName];
    [copyContents setIdentifier:copyIdentifier];
    
    [GPKGTestUtils assertEqualWithValue:queryContentsId andValue2:[dao getId:queryContents]];
    [GPKGTestUtils assertEqualWithValue:identifier andValue2:queryContents.identifier];
    [GPKGTestUtils assertEqualWithValue:copyTableName andValue2:[dao getId:copyContents]];
    [GPKGTestUtils assertEqualWithValue:copyIdentifier andValue2:copyContents.identifier];
    [GPKGTestUtils assertFalse:[[dao getId:queryContents] isEqual:[dao getId:copyContents]]];
    [GPKGTestUtils assertFalse:[queryContents.identifier isEqual:copyContents.identifier]];
    
    [geoPackage createFeatureTable:[GPKGTestUtils buildFeatureTableWithTableName:copyContents.tableName andGeometryColumn:@"geom" andGeometryType:WKB_GEOMETRY]];
    
    [dao create:copyContents];
    
    // Verify count
    int newCount2 = [dao count];
    [GPKGTestUtils assertEqualIntWithValue:count+2 andValue2:newCount2];
    
    // Verify saved contents
    GPKGContents *queryCopiedContents = (GPKGContents *)[dao queryForIdObject:copyTableName];
    [GPKGTestUtils assertEqualWithValue:copyTableName andValue2:queryCopiedContents.tableName];
    [GPKGTestUtils assertEqualWithValue:queryContents.dataType andValue2:queryCopiedContents.dataType];
    [GPKGTestUtils assertEqualWithValue:copyIdentifier andValue2:queryCopiedContents.identifier];
    [GPKGTestUtils assertEqualWithValue:queryContents.theDescription andValue2:queryCopiedContents.theDescription];
    [GPKGTestUtils assertTrue:[queryContents.lastChange compare:queryCopiedContents.lastChange] == NSOrderedSame];
    [GPKGTestUtils assertEqualDoubleWithValue:[queryContents.minX doubleValue] andValue2:[queryCopiedContents.minX doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[queryContents.minY doubleValue] andValue2:[queryCopiedContents.minY doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[queryContents.maxX doubleValue] andValue2:[queryCopiedContents.maxX doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[queryContents.maxY doubleValue] andValue2:[queryCopiedContents.maxY doubleValue]];
    if(srs != nil){
        [GPKGTestUtils assertEqualIntWithValue:[srs.srsId intValue] andValue2:[queryCopiedContents.srsId intValue]];
    }else{
        [GPKGTestUtils assertNil:queryCopiedContents.srsId];
    }
    
    // Verify initial saved contents again
    queryContents = (GPKGContents *)[dao queryForIdObject:tableName];
    [GPKGTestUtils assertEqualWithValue:queryContentsId andValue2:[dao getId:queryContents]];
    [GPKGTestUtils assertEqualWithValue:tableName andValue2:queryContents.tableName];
    [GPKGTestUtils assertEqualWithValue:[GPKGContentsDataTypes name:dataType] andValue2:queryContents.dataType];
    [GPKGTestUtils assertEqualWithValue:identifier andValue2:queryContents.identifier];
    [GPKGTestUtils assertEqualWithValue:description andValue2:queryContents.theDescription];
    [GPKGTestUtils assertTrue:[lastChange compare:queryContents.lastChange] == NSOrderedSame];
    [GPKGTestUtils assertEqualDoubleWithValue:[minX doubleValue] andValue2:[queryContents.minX doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[minY doubleValue] andValue2:[queryContents.minY doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[maxX doubleValue] andValue2:[queryContents.maxX doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:[maxY doubleValue] andValue2:[queryContents.maxY doubleValue]];
    if(srs != nil){
        [GPKGTestUtils assertEqualIntWithValue:[srs.srsId intValue] andValue2:[queryContents.srsId intValue]];
    }else{
        [GPKGTestUtils assertNil:queryContents.srsId];
    }
    
}

+(void) testDeleteWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [self testDeleteHelperWithGeoPackage:geoPackage andCascade:false];
    
}

+(void) testDeleteCascadeWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [self testDeleteHelperWithGeoPackage:geoPackage andCascade:true];
    
}

+(void) testDeleteHelperWithGeoPackage: (GPKGGeoPackage *) geoPackage andCascade: (BOOL) cascade{
    
    GPKGContentsDao *dao = [geoPackage getContentsDao];
    GPKGResultSet *results = [dao queryForAll];
    
    if (results.count > 0) {
        
        // Choose random contents
        int random = (int) ([GPKGTestUtils randomDouble] * results.count);
        [results moveToPosition:random];
        GPKGContents *contents = (GPKGContents *)[dao getObject:results];
        [results close];
        
        // Save the ids of geometry columns
        NSMutableArray *geometryColumnsIds = [[NSMutableArray alloc] init];
        GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage getGeometryColumnsDao];
        if([geometryColumnsDao tableExists]){
            GPKGGeometryColumns *geometryColumns = [dao getGeometryColumns:contents];
            if (geometryColumns != nil) {
                [geometryColumnsIds addObject:[dao getId:geometryColumns]];
            }
        }
        
        // Delete the contents
        if (cascade) {
            [dao deleteCascade:contents];
        } else {
            [dao delete:contents];
        }
        
        // Verify deleted
        GPKGContents *queryContents = (GPKGContents *)[dao queryForIdObject:[dao getId:contents]];
        [GPKGTestUtils assertNil:queryContents];
        
        // Verify that geometry columns or foreign keys were deleted
        for(NSString *geometryColumnsId in geometryColumnsIds){
            GPKGGeometryColumns *queryGeometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao queryForIdObject:geometryColumnsId];
            if (cascade) {
                [GPKGTestUtils assertNil:queryGeometryColumns];
            } else {
                [GPKGTestUtils assertNil:[geometryColumnsDao getContents:queryGeometryColumns]];
            }
        }
        
        
        // Choose prepared deleted
        results = [dao queryForAll];
        if (results.count > 0) {
            
            // Choose random contents
            int random = (int) ([GPKGTestUtils randomDouble] * results.count);
            [results moveToPosition:random];
            GPKGContents *contents = (GPKGContents *)[dao getObject:results];
            [results close];
            
            // Find which contents to delete and the geometry columns
            GPKGResultSet *queryResults = [dao queryForEqWithField:GPKG_CON_COLUMN_DATA_TYPE andValue:contents.dataType];
            int count = queryResults.count;
            geometryColumnsIds = [[NSMutableArray alloc] init];
            while([queryResults moveToNext]){
                GPKGContents *queryResultsContenst = (GPKGContents *)[dao getObject:queryResults];
                if([geometryColumnsDao tableExists]){
                    GPKGGeometryColumns *geometryColumns = [dao getGeometryColumns:queryResultsContenst];
                    if (geometryColumns != nil) {
                        [geometryColumnsIds addObject:[dao getId:geometryColumns]];
                    }
                }
            }
            [queryResults close];
            
            // Delete
            int deleted;
            NSMutableString * where = [[NSMutableString alloc] init];
            [where appendString:[dao buildWhereWithField:GPKG_CON_COLUMN_DATA_TYPE andValue:contents.dataType]];
            NSMutableArray * whereArgs = [[NSMutableArray alloc] init];
            [whereArgs addObject:contents.dataType];
            if (cascade) {
                deleted = [dao deleteCascadeWhere:where andWhereArgs:whereArgs];
            } else {
                deleted = [dao deleteWhere:where andWhereArgs:whereArgs];
            }
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:deleted];
            
            // Verify that geometry columns or foreign keys were deleted
            for(NSString *geometryColumnsId in geometryColumnsIds){
                GPKGGeometryColumns *queryGeometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao queryForIdObject:geometryColumnsId];
                if (cascade) {
                    [GPKGTestUtils assertNil:queryGeometryColumns];
                } else {
                    [GPKGTestUtils assertNil:[geometryColumnsDao getContents:queryGeometryColumns]];
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
