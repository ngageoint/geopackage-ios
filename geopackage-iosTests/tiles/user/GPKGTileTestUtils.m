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

@implementation GPKGTileTestUtils

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
                    
                    GPKGBoundingBox * tileGridBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithWebMercatorTotalBoundingBox:totalBoundingBox andTileMatrix:tileMatrix andTileGrid:updatedTileGrid];
                    [GPKGTestUtils assertTrue:[tileGridBoundingBox equals:updatedBoundingBox]];
                }
            }
        }
        
        [results close];
    }
    
}

@end
