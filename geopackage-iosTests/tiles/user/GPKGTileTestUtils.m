//
//  GPKGTileTestUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGTileTestUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGGeoPackageGeometryDataUtils.h"

@implementation GPKGTileTestUtils

+(void) testCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    
    if ([tileMatrixSetDao tableExists]) {
        GPKGResultSet *results = [tileMatrixSetDao queryForAll];
        
        while([results moveToNext]){
            GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *)[tileMatrixSetDao getObject:results];
            
            GPKGTileDao *dao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet *tileResults = [dao queryForAll];
            int count = tileResults.count;
            if (count > 0) {
                
                // Choose random tile
                int random = (int) ([GPKGTestUtils randomDouble] * count);
                [tileResults moveToPosition:random];
                
                GPKGTileRow *tileRow = (GPKGTileRow *)[dao getObject:tileResults];
                [tileResults close];
                
                // Find the largest zoom level
                GPKGTileMatrixDao *tileMatrixDao = [geoPackage getTileMatrixDao];
                GPKGResultSet *tileMatrixResults = [tileMatrixDao queryForEqWithField:GPKG_TM_COLUMN_TABLE_NAME andValue:tileMatrixSet.tableName andGroupBy:nil andHaving:nil andOrderBy:[NSString stringWithFormat:@"%@ DESC", GPKG_TM_COLUMN_ZOOM_LEVEL]];
                GPKGTileMatrix *tileMatrix = (GPKGTileMatrix *)[tileMatrixDao getFirstObject:tileMatrixResults];
                NSNumber *highestZoomLevel = tileMatrix.zoomLevel;
                
                // Create new row from existing
                NSNumber *id = [tileRow getId];
                [tileRow resetId];
                [tileRow setZoomLevel:[highestZoomLevel intValue] + 1];
                int newRowId = (int)[dao create:tileRow];
                [GPKGTestUtils assertEqualIntWithValue:newRowId andValue2:[[tileRow getId] intValue]];
                
                // Verify original still exists and new was created
                tileRow = (GPKGTileRow *)[dao queryForIdObject:id];
                [GPKGTestUtils assertNotNil:tileRow];
                GPKGTileRow *queryTileRow = (GPKGTileRow *)[dao queryForIdObject:[NSNumber numberWithInt:newRowId]];
                [GPKGTestUtils assertNotNil:queryTileRow];
                tileResults = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count+1 andValue2:tileResults.count];
                [tileResults close];
                
                // Create new row with copied values from another
                GPKGTileRow *newRow = [dao newRow];
                for(GPKGTileColumn *column in dao.table.columns){
                    
                    if(column.primaryKey){
                        @try {
                            [newRow setValueWithColumnName:column.name andValue:[NSNumber numberWithInt:10]];
                            [GPKGTestUtils fail:@"Set primary key on new row"];
                        } @catch (NSException *e) {
                            // Expected
                        }
                    } else {
                        [newRow setValueWithColumnName:column.name andValue:[tileRow getValueWithColumnName:column.name]];
                    }
                }
                
                [newRow setZoomLevel:[queryTileRow getZoomLevel] + 1];
                int newRowId2 = (int)[dao create:newRow];
                [GPKGTestUtils assertEqualIntWithValue:newRowId2 andValue2:[[newRow getId] intValue]];
                
                // Verify new was created
                GPKGTileRow *queryTileRow2 = (GPKGTileRow *)[dao queryForIdObject:[NSNumber numberWithInt:newRowId2]];
                [GPKGTestUtils assertNotNil:queryTileRow2];
                tileResults = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count+2 andValue2:tileResults.count];
                [tileResults close];
                
                // Test copied row
                GPKGTileRow *copyRow = [queryTileRow2 mutableCopy];
                for(GPKGTileColumn *column in dao.table.columns){
                    if(column.index == [queryTileRow2 getTileDataColumnIndex]){
                        NSData *tileData1 = [queryTileRow2 getTileData];
                        NSData *tileData2 = [copyRow getTileData];
                        [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:tileData1 andActual:tileData2];
                    } else {
                        [GPKGTestUtils assertEqualWithValue:[queryTileRow2 getValueWithColumnName:column.name] andValue2:[copyRow getValueWithColumnName:column.name]];
                    }
                }
                
                [copyRow resetId];
                [copyRow setZoomLevel:[queryTileRow2 getZoomLevel] + 1];
                
                NSNumber *newRowId3 = [NSNumber numberWithLongLong:[dao create:copyRow]];
                [GPKGTestUtils assertEqualIntWithValue:[newRowId3 intValue] andValue2:[[copyRow getId] intValue]];
                
                // Verify new was created
                GPKGTileRow *queryTileRow3 = (GPKGTileRow *)[dao queryForIdObject:newRowId3];
                [GPKGTestUtils assertNotNil:queryTileRow3];
                tileResults = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count+3 andValue2:tileResults.count];
                [tileResults close];
                
                for(GPKGTileColumn *column in dao.table.columns){
                    if(column.primaryKey){
                        [GPKGTestUtils assertFalse:[[queryTileRow2 getId] isEqual:[queryTileRow3 getId]]];
                    } else if (column.index == [queryTileRow3 getZoomLevelColumnIndex]) {
                        [GPKGTestUtils assertEqualIntWithValue:[queryTileRow2 getZoomLevel] andValue2:[queryTileRow3 getZoomLevel]-1];
                    } else if (column.index == [queryTileRow3 getTileDataColumnIndex]) {
                        NSData *tileData1 = [queryTileRow2 getTileData];
                        NSData *tileData2 = [queryTileRow3 getTileData];
                        [GPKGGeoPackageGeometryDataUtils compareByteArrayWithExpected:tileData1 andActual:tileData2];
                    } else {
                        [GPKGTestUtils assertEqualWithValue:[queryTileRow2 getValueWithColumnName:column.name] andValue2:[queryTileRow3 getValueWithColumnName:column.name]];
                    }
                }

            }else{
                [tileResults close];
            }
        }
        [results close];
    }
    
}

+(void) testDeleteWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    
    if ([tileMatrixSetDao tableExists]) {
        GPKGResultSet *results = [tileMatrixSetDao queryForAll];
        
        while([results moveToNext]){
            GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *)[tileMatrixSetDao getObject:results];
            
            GPKGTileDao *dao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGResultSet *tileResults = [dao queryForAll];
            int count = tileResults.count;
            if (count > 0) {
                
                // Choose random tile
                int random = (int) ([GPKGTestUtils randomDouble] * count);
                [tileResults moveToPosition:random];
                
                GPKGTileRow *tileRow = (GPKGTileRow *)[dao getObject:tileResults];
                [tileResults close];
                
                // Delete row
                [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[dao delete:tileRow]];
                
                // Verify deleted
                GPKGTileRow *queryTileRow = (GPKGTileRow *)[dao queryForIdObject:[tileRow getId]];
                [GPKGTestUtils assertNil:queryTileRow];
                tileResults = [dao queryForAll];
                [GPKGTestUtils assertEqualIntWithValue:count-1 andValue2:tileResults.count];
                [tileResults close];
            }else{
                [tileResults close];
            }
        }
        [results close];
        
    }
    
}

+(void) testGetZoomLevelWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    
    if ([tileMatrixSetDao tableExists]) {
        GPKGResultSet *results = [tileMatrixSetDao queryForAll];
        
        while([results moveToNext]){
            GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *)[tileMatrixSetDao getObject:results];
            
            GPKGTileDao *dao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
            
            for(GPKGTileMatrix *tileMatrix in dao.tileMatrices){
                
                double width = [tileMatrix.pixelXSize doubleValue] * [tileMatrix.tileWidth doubleValue];
                double height = [tileMatrix.pixelYSize doubleValue] * [tileMatrix.tileHeight doubleValue];
                
                NSNumber *zoomLevel = [dao zoomLevelWithLength:width];
                [GPKGTestUtils assertEqualWithValue:tileMatrix.zoomLevel andValue2:zoomLevel];
                
                zoomLevel = [dao zoomLevelWithWidth:width andHeight:height];
                [GPKGTestUtils assertEqualWithValue:tileMatrix.zoomLevel andValue2:zoomLevel];
                
                zoomLevel = [dao zoomLevelWithLength:width+1];
                [GPKGTestUtils assertEqualWithValue:tileMatrix.zoomLevel andValue2:zoomLevel];
                
                zoomLevel = [dao zoomLevelWithWidth:width+1 andHeight:height+1];
                [GPKGTestUtils assertEqualWithValue:tileMatrix.zoomLevel andValue2:zoomLevel];
                
                zoomLevel = [dao zoomLevelWithLength:width-1];
                [GPKGTestUtils assertEqualWithValue:tileMatrix.zoomLevel andValue2:zoomLevel];
                
                zoomLevel = [dao zoomLevelWithWidth:width-1 andHeight:height-1];
                [GPKGTestUtils assertEqualWithValue:tileMatrix.zoomLevel andValue2:zoomLevel];
                
            }
            
        }
        [results close];
        
    }
    
}

+(void)testTileMatrixBoundingBox: (GPKGGeoPackage *) geoPackage{
    
    GPKGTileMatrixSetDao * tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    
    if([tileMatrixSetDao tableExists]){
        GPKGResultSet * results = [tileMatrixSetDao queryForAll];
        
        while([results moveToNext]){
            GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[tileMatrixSetDao getObject:results];
            
            GPKGTileDao * dao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
            [GPKGTestUtils assertNotNil:dao];
            
            GPKGBoundingBox * totalBoundingBox = [tileMatrixSet getBoundingBox];
            [GPKGTestUtils assertTrue:[totalBoundingBox equals:[dao getBoundingBox]]];
            
            NSArray * tileMatrices = dao.tileMatrices;
            
            for(GPKGTileMatrix * tileMatrix in tileMatrices){
                
                int zoomLevel = [tileMatrix.zoomLevel intValue];
                int count = [dao countWithZoomLevel:zoomLevel];
                GPKGTileGrid * totalTileGrid = [dao getTileGridWithZoomLevel:zoomLevel];
                GPKGTileGrid * tileGrid = [dao queryForTileGridWithZoomLevel:zoomLevel];
                GPKGBoundingBox * boundingBox = [dao getBoundingBoxWithZoomLevel:zoomLevel];
                
                if([totalTileGrid equals:tileGrid]){
                    [GPKGTestUtils assertTrue:[totalBoundingBox equals:boundingBox]];
                }else{
                    [GPKGTestUtils assertTrue:[totalBoundingBox.minLongitude doubleValue] <= [boundingBox.minLongitude doubleValue]];
                    [GPKGTestUtils assertTrue:[totalBoundingBox.maxLongitude doubleValue] >= [boundingBox.maxLongitude doubleValue]];
                    [GPKGTestUtils assertTrue:[totalBoundingBox.minLatitude doubleValue] <= [boundingBox.minLatitude doubleValue]];
                    [GPKGTestUtils assertTrue:[totalBoundingBox.maxLatitude doubleValue] >= [boundingBox.maxLatitude doubleValue]];
                }
                int deleted = 0;
                if([tileMatrix.matrixHeight intValue] > 1 || [tileMatrix.matrixWidth intValue] > 1){
                    
                    for(int column = 0; column < [tileMatrix.matrixWidth intValue]; column++){
                        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[dao deleteTileWithColumn:column andRow:0 andZoomLevel:zoomLevel]];
                        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[dao deleteTileWithColumn:column andRow:([tileMatrix.matrixHeight intValue] - 1) andZoomLevel:zoomLevel]];
                        deleted += 2;
                    }
                    
                    for(int row = 1; row < [tileMatrix.matrixHeight intValue] - 1; row++){
                        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[dao deleteTileWithColumn:0 andRow:row andZoomLevel:zoomLevel]];
                        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[dao deleteTileWithColumn:([tileMatrix.matrixWidth intValue] - 1) andRow:row andZoomLevel:zoomLevel]];
                        deleted += 2;
                    }
                }else{
                    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[dao deleteTileWithColumn:0 andRow:0 andZoomLevel:zoomLevel]];
                    deleted++;
                }
                
                int updatedCount = [dao countWithZoomLevel:zoomLevel];
                [GPKGTestUtils assertEqualIntWithValue:count - deleted andValue2:updatedCount];
                
                GPKGTileGrid * updatedTileGrid = [dao queryForTileGridWithZoomLevel:zoomLevel];
                GPKGBoundingBox * updatedBoundingBox = [dao getBoundingBoxWithZoomLevel:zoomLevel];
                
                if([tileMatrix.matrixHeight intValue] <= 2 && [tileMatrix.matrixWidth intValue] <= 2){
                    [GPKGTestUtils assertNil:updatedTileGrid];
                    [GPKGTestUtils assertNil:updatedBoundingBox];
                }else{
                    [GPKGTestUtils assertNotNil:updatedTileGrid];
                    [GPKGTestUtils assertNotNil:updatedBoundingBox];
                    
                    [GPKGTestUtils assertEqualIntWithValue:(tileGrid.minX + 1) andValue2:updatedTileGrid.minX];
                    [GPKGTestUtils assertEqualIntWithValue:(tileGrid.maxX - 1) andValue2:updatedTileGrid.maxX];
                    [GPKGTestUtils assertEqualIntWithValue:(tileGrid.minY + 1) andValue2:updatedTileGrid.minY];
                    [GPKGTestUtils assertEqualIntWithValue:(tileGrid.maxY - 1) andValue2:updatedTileGrid.maxY];
                    
                    GPKGBoundingBox * tileGridBoundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:totalBoundingBox andTileMatrix:tileMatrix andTileGrid:updatedTileGrid];
                    [GPKGTestUtils assertTrue:[tileGridBoundingBox equals:updatedBoundingBox]];
                }
            }
        }
        
        [results close];
    }
    
}

@end
