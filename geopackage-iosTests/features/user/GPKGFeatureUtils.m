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

@implementation GPKGFeatureUtils

+(void) testCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet *geometryColumnsResults = [geometryColumnsDao queryForAll];
        
        while([geometryColumnsResults moveToNext]){
            GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao getObject:geometryColumnsResults];
            
            GPKGFeatureDao *dao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet *featureResults = [dao queryForAll];
            int count = featureResults.count;
            if (count > 0) {
                
                // Choose random feature
                int random = (int) ([GPKGTestUtils randomDouble] * count);
                [featureResults moveToPosition:random];
                
                GPKGFeatureRow *featureRow = (GPKGFeatureRow *)[dao getObject:featureResults];
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
                        [newRow setValueWithColumnName:column.name andValue:[featureRow getValueWithColumnName:column.name]];
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
                    if(column.index == [queryFeatureRow2 getGeometryColumnIndex]){
                        GPKGGeometryData *geometry1 = [queryFeatureRow2 getGeometry];
                        GPKGGeometryData *geometry2 = [copyRow getGeometry];
                        if (geometry1 == nil) {
                            [GPKGTestUtils assertNil:geometry2];
                        } else {
                            [GPKGTestUtils assertFalse:[geometry1 isEqual:geometry2]];
                            [GPKGGeoPackageGeometryDataUtils compareGeometryDataWithExpected:geometry1 andActual:geometry2];
                        }
                    } else if (column.dataType == GPKG_DT_BLOB) {
                        NSData *blob1 = (NSData *) [queryFeatureRow2 getValueWithColumnName:column.name];
                        NSData *blob2 = (NSData *) [copyRow getValueWithColumnName:column.name];
                        if (blob1 == nil) {
                            [GPKGTestUtils assertNil:blob2];
                        } else {
                            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:blob1 andActual:blob2];
                        }
                    } else {
                        [GPKGTestUtils assertEqualWithValue:[queryFeatureRow2 getValueWithColumnName:column.name] andValue2:[copyRow getValueWithColumnName:column.name]];
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
                        [GPKGTestUtils assertFalse:[[queryFeatureRow2 getValueWithColumnName:column.name] isEqual:[queryFeatureRow3 getValueWithColumnName:column.name]]];
                    } else if (column.index == [queryFeatureRow2 getGeometryColumnIndex]) {
                        GPKGGeometryData *geometry1 = [queryFeatureRow2 getGeometry];
                        GPKGGeometryData *geometry2 = [queryFeatureRow3 getGeometry];
                        if (geometry1 == nil) {
                            [GPKGTestUtils assertNil:geometry2];
                        } else {
                            [GPKGGeoPackageGeometryDataUtils compareGeometryDataWithExpected:geometry1 andActual:geometry2];
                        }
                    } else if (column.dataType == GPKG_DT_BLOB) {
                        NSData *blob1 = (NSData *) [queryFeatureRow2 getValueWithColumnName:column.name];
                        NSData *blob2 = (NSData *) [queryFeatureRow3 getValueWithColumnName:column.name];
                        if (blob1 == nil) {
                            [GPKGTestUtils assertNil:blob2];
                        } else {
                            [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:blob1 andActual:blob2];
                        }
                    } else {
                        [GPKGTestUtils assertEqualWithValue:[queryFeatureRow2 getValueWithColumnName:column.name] andValue2:[queryFeatureRow3 getValueWithColumnName:column.name]];
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
    
    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet *geometryColumnsResults = [geometryColumnsDao queryForAll];
        
        while([geometryColumnsResults moveToNext]){
            GPKGGeometryColumns *geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao getObject:geometryColumnsResults];
            
            GPKGFeatureDao *dao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet *featureResults = [dao queryForAll];
            int count = featureResults.count;
            if (count > 0) {
                
                // Choose random feature
                int random = (int) ([GPKGTestUtils randomDouble] * count);
                [featureResults moveToPosition:random];
                
                GPKGFeatureRow *featureRow = (GPKGFeatureRow *)[dao getObject:featureResults];
                [featureResults close];
                
                // Delete row
                [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[dao delete:featureRow]];
                
                // Verify deleted
                GPKGFeatureRow *queryFeatureRow = (GPKGFeatureRow *)[dao queryForIdObject:[featureRow getId]];
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

@end
