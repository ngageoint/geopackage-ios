//
//  GPKGFeatureUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/27/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGFeatureUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGGeoPackageGeometryDataUtils.h"
#import "PROJProjectionConstants.h"

@implementation GPKGFeatureUtils

+(void) testCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage geometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet *geometryColumnsResults = [geometryColumnsDao queryForAll];
        
        while([geometryColumnsResults moveToNext]){
            GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao object:geometryColumnsResults];
            
            GPKGFeatureDao *dao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet *featureResults = [dao queryForAll];
            int count = featureResults.count;
            if (count > 0) {
                
                // Choose random feature
                int random = (int) ([GPKGTestUtils randomDouble] * count);
                [featureResults moveToPosition:random];
                
                GPKGFeatureRow *featureRow = (GPKGFeatureRow *)[dao object:featureResults];
                [featureResults close];
                
                // Create new row from existing
                NSNumber *id = [featureRow id];
                [featureRow resetId];
                NSNumber *newRowId = [NSNumber numberWithLongLong:[dao create:featureRow]];
                [GPKGTestUtils assertEqualIntWithValue:[newRowId intValue] andValue2:[featureRow idValue]];
                
                // Verify original still exists and new was created
                featureRow = (GPKGFeatureRow *)[dao queryForIdObject:id];
                [GPKGTestUtils assertNotNil:featureRow];
                GPKGFeatureRow *queryFeatureRow = (GPKGFeatureRow *)[dao queryForIdObject:newRowId];
                [GPKGTestUtils assertNotNil:queryFeatureRow];
                featureResults = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count+1 andValue2:featureResults.count];
                [featureResults close];
                
                // Create new row with copied values from another
                GPKGFeatureRow *newRow = [dao newRow];
                for(GPKGFeatureColumn *column in dao.table.columns){
                    
                    if(column.primaryKey){
                        @try {
                            [newRow setValueWithColumnName:column.name andValue:[NSNumber numberWithInt:10]];
                            [GPKGTestUtils fail:@"Set primary key on new row"];
                        } @catch (NSException *e) {
                            // Expected
                        }
                    } else {
                        [newRow setValueWithColumnName:column.name andValue:[featureRow valueWithColumnName:column.name]];
                    }
                }
                
                NSNumber *newRowId2 = [NSNumber numberWithLongLong:[dao create:newRow]];
                [GPKGTestUtils assertEqualIntWithValue:[newRowId2 intValue] andValue2:[newRow idValue]];
                
                // Verify new was created
                GPKGFeatureRow *queryFeatureRow2 = (GPKGFeatureRow *)[dao queryForIdObject:newRowId2];
                [GPKGTestUtils assertNotNil:queryFeatureRow2];
                featureResults = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count+2 andValue2:featureResults.count];
                [featureResults close];
                
                // Test copied row
                GPKGFeatureRow *copyRow = [queryFeatureRow2 mutableCopy];
                for(GPKGFeatureColumn *column in dao.table.columns){
                    if(column.index == [queryFeatureRow2 geometryColumnIndex]){
                        GPKGGeometryData *geometry1 = [queryFeatureRow2 geometry];
                        GPKGGeometryData *geometry2 = [copyRow geometry];
                        if (geometry1 == nil) {
                            [GPKGTestUtils assertNil:geometry2];
                        } else {
                            [GPKGTestUtils assertFalse:[geometry1 isEqual:geometry2]];
                            [GPKGGeoPackageGeometryDataUtils compareGeometryDataWithExpected:geometry1 andActual:geometry2];
                        }
                    } else if (column.dataType == GPKG_DT_BLOB) {
                        NSData *blob1 = (NSData *) [queryFeatureRow2 valueWithColumnName:column.name];
                        NSData *blob2 = (NSData *) [copyRow valueWithColumnName:column.name];
                        if (blob1 == nil) {
                            [GPKGTestUtils assertNil:blob2];
                        } else {
                            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:blob1 andActual:blob2];
                        }
                    } else {
                        [GPKGTestUtils assertEqualWithValue:[queryFeatureRow2 valueWithColumnName:column.name] andValue2:[copyRow valueWithColumnName:column.name]];
                    }
                }
                
                [copyRow resetId];
                
                NSNumber *newRowId3 = [NSNumber numberWithLongLong:[dao create:copyRow]];
                [GPKGTestUtils assertEqualIntWithValue:[newRowId3 intValue] andValue2:[copyRow idValue]];
                
                // Verify new was created
                GPKGFeatureRow *queryFeatureRow3 = (GPKGFeatureRow *)[dao queryForIdObject:newRowId3];
                [GPKGTestUtils assertNotNil:queryFeatureRow3];
                featureResults = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count+3 andValue2:featureResults.count];
                [featureResults close];
                
                for(GPKGFeatureColumn *column in dao.table.columns){
                    if(column.primaryKey){
                        [GPKGTestUtils assertFalse:[[queryFeatureRow2 valueWithColumnName:column.name] isEqual:[queryFeatureRow3 valueWithColumnName:column.name]]];
                    } else if (column.index == [queryFeatureRow2 geometryColumnIndex]) {
                        GPKGGeometryData *geometry1 = [queryFeatureRow2 geometry];
                        GPKGGeometryData *geometry2 = [queryFeatureRow3 geometry];
                        if (geometry1 == nil) {
                            [GPKGTestUtils assertNil:geometry2];
                        } else {
                            [GPKGGeoPackageGeometryDataUtils compareGeometryDataWithExpected:geometry1 andActual:geometry2];
                        }
                    } else if (column.dataType == GPKG_DT_BLOB) {
                        NSData *blob1 = (NSData *) [queryFeatureRow2 valueWithColumnName:column.name];
                        NSData *blob2 = (NSData *) [queryFeatureRow3 valueWithColumnName:column.name];
                        if (blob1 == nil) {
                            [GPKGTestUtils assertNil:blob2];
                        } else {
                            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:blob1 andActual:blob2];
                        }
                    } else {
                        [GPKGTestUtils assertEqualWithValue:[queryFeatureRow2 valueWithColumnName:column.name] andValue2:[queryFeatureRow3 valueWithColumnName:column.name]];
                    }
                }
            }else{
                [featureResults close];
            }
        }
        [geometryColumnsResults close];
    }
}

+(void) testDeleteWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage geometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet *geometryColumnsResults = [geometryColumnsDao queryForAll];
        
        while([geometryColumnsResults moveToNext]){
            GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao object:geometryColumnsResults];
            
            GPKGFeatureDao *dao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet *featureResults = [dao queryForAll];
            int count = featureResults.count;
            if (count > 0) {
                
                // Choose random feature
                int random = (int) ([GPKGTestUtils randomDouble] * count);
                [featureResults moveToPosition:random];
                
                GPKGFeatureRow *featureRow = (GPKGFeatureRow *)[dao object:featureResults];
                [featureResults close];
                
                // Delete row
                [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[dao delete:featureRow]];
                
                // Verify deleted
                GPKGFeatureRow *queryFeatureRow = (GPKGFeatureRow *)[dao queryForIdObject:[featureRow id]];
                [GPKGTestUtils assertNil:queryFeatureRow];
                featureResults = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count - 1 andValue2:featureResults.count];
                [featureResults close];
            }else{
                [featureResults close];
            }
        }
        [geometryColumnsResults close];
    }
    
}

+(void) testPkModifiableAndValueValidationWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage spatialReferenceSystemDao] srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];

    GPKGGeometryData *geometryData = [GPKGGeometryData createWithSrsId:srs.srsId andGeometry:[SFPoint pointWithXValue:0 andYValue:0]];

    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"test_features"];
    [geometryColumns setColumnName:@"geom"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];

    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-180 andMinLatitudeDouble:-90 andMaxLongitudeDouble:180 andMaxLatitudeDouble:90];

    NSString *idColumn = @"test_id";
    NSString *realColumn = @"test_real";

    NSMutableArray<GPKGFeatureColumn *> *additionalColumns = [NSMutableArray array];
    [additionalColumns addObject:[GPKGFeatureColumn createColumnWithName:realColumn andDataType:GPKG_DT_REAL]];
    [geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andIdColumn:idColumn andAdditionalColumns:additionalColumns andBoundingBox:boundingBox]];

    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
    [GPKGTestUtils assertFalse:[featureDao isPkModifiable]];
    [GPKGTestUtils assertTrue:[featureDao isValueValidation]];

    [featureDao setPkModifiable:YES];
    [featureDao setValueValidation:NO];
    [GPKGTestUtils assertTrue:[featureDao isPkModifiable]];
    [GPKGTestUtils assertFalse:[featureDao isValueValidation]];

    int idValue = 15;
    int realValue = 20;

    GPKGFeatureRow *featureRow = [featureDao newRow];
    [featureRow setId:[NSNumber numberWithInt:idValue]];
    [featureRow setValueWithColumnName:realColumn andValue:[NSNumber numberWithInt:realValue]];
    [featureRow setGeometry:geometryData];

    [featureDao insert:featureRow];
    
    GPKGResultSet *results = [featureDao query];
    @try {
        [GPKGTestUtils assertTrue:[results moveToNext]];
        GPKGFeatureRow *feature = [featureDao row:results];
        [GPKGTestUtils assertEqualIntWithValue:idValue andValue2:[feature idValue]];
        [GPKGTestUtils assertNotNil:[feature geometry]];
        [GPKGTestUtils assertEqualDoubleWithValue:realValue andValue2:[(NSNumber *)[feature valueWithColumnName:realColumn] doubleValue]];
    } @finally {
        [results close];
    }

    GPKGFeatureDao *featureDao2 = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
    [GPKGTestUtils assertFalse:[featureDao2 isPkModifiable]];
    [GPKGTestUtils assertTrue:[featureDao2 isValueValidation]];

    GPKGFeatureRow *featureRow2 = [featureDao2 newRow];
    @try {
        [featureRow2 setId:[NSNumber numberWithInt:16]];
        [GPKGTestUtils fail:@"Expected exception did not occur"];
    } @catch (NSException *exception) {
        // expected
    }
    @try {
        [featureRow2 setValueWithColumnName:idColumn andValue:[NSNumber numberWithInt:16]];
        [GPKGTestUtils fail:@"Expected exception did not occur"];
    } @catch (NSException *exception) {
        // expected
    }
    [featureRow2 setValueWithColumnName:realColumn andValue:[NSNumber numberWithInt:21]];
    @try {
        [featureDao2 insert:featureRow2];
        [GPKGTestUtils fail:@"Expected exception did not occur"];
    } @catch (NSException *exception) {
        // expected
    }
    
}

@end
