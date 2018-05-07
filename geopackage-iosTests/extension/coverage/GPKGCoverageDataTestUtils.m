//
//  GPKGCoverageDataTestUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 1/25/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGCoverageDataTestUtils.h"
#import "SFPProjectionFactory.h"
#import "GPKGTestUtils.h"
#import "GPKGUtils.h"
#import "SFPProjectionConstants.h"
#import "SFPProjectionTransform.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGCoverageDataTestUtils

/**
 * Test performing coverage data queries
 *
 * @param geoPackage
 * @param coverageData
 * @param tileMatrixSet
 * @param algorithm
 * @param allowNils
 */
+(void) testCoverageDataQueriesWithGeoPackage: (GPKGGeoPackage *) geoPackage andCoverageData: (GPKGCoverageData *) coverageData andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    
    // Determine an alternate projection
    GPKGBoundingBox * boundingBox = [tileMatrixSet getBoundingBox];
    GPKGSpatialReferenceSystemDao * srsDao = [geoPackage getSpatialReferenceSystemDao];
    NSNumber * srsId = tileMatrixSet.srsId;
    GPKGSpatialReferenceSystem * srs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:srsId];
    
    NSNumber * epsg = srs.organizationCoordsysId;
    SFPProjection * projection = [SFPProjectionFactory projectionWithSrs:srs];
    int requestEpsg = -1;
    if ([epsg intValue] == PROJ_EPSG_WORLD_GEODETIC_SYSTEM) {
        requestEpsg = PROJ_EPSG_WEB_MERCATOR;
    } else {
        requestEpsg = PROJ_EPSG_WORLD_GEODETIC_SYSTEM;
    }
    SFPProjection * requestProjection = [SFPProjectionFactory projectionWithEpsgInt:requestEpsg];
    SFPProjectionTransform * coverageToRequest = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:requestProjection];
    GPKGBoundingBox * projectedBoundingBox = [coverageToRequest transformWithBoundingBox:boundingBox];
    
    // Get a random coordinate
    double latDistance = [projectedBoundingBox.maxLatitude doubleValue] - [projectedBoundingBox.minLatitude doubleValue];
    double latitude = latDistance * .9 * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLatitude doubleValue] + (.05 * latDistance);
    double lonDistance = [projectedBoundingBox.maxLongitude doubleValue] - [projectedBoundingBox.minLongitude doubleValue];
    double longitude = lonDistance * .9 * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLongitude doubleValue] + (.05 * lonDistance);
    
    // Test getting the coverage data value of a single coordinate
    GPKGCoverageData * coverageData2 = [GPKGCoverageData coverageDataWithGeoPackage:geoPackage andTileDao:[coverageData tileDao] andProjection:requestProjection];
    [coverageData2 setAlgorithm:algorithm];
    NSDecimalNumber * value = [coverageData2 valueWithLatitude:latitude andLongitude:longitude];
    if (!allowNils) {
        [GPKGTestUtils assertNotNil:value];
    }
    
    // Build a random bounding box
    double minLatitude = ([projectedBoundingBox.maxLatitude doubleValue] - [projectedBoundingBox.minLatitude doubleValue]) * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLatitude doubleValue];
    double minLongitude = ([projectedBoundingBox.maxLongitude doubleValue] - [projectedBoundingBox.minLongitude doubleValue]) * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLongitude doubleValue];
    double maxLatitude = ([projectedBoundingBox.maxLatitude doubleValue] - minLatitude) * [GPKGTestUtils randomDouble] + minLatitude;
    double maxLongitude = ([projectedBoundingBox.maxLongitude doubleValue] - minLongitude) * [GPKGTestUtils randomDouble] + minLongitude;
    
    GPKGBoundingBox * requestBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
    GPKGCoverageDataResults * values = [coverageData2 valuesWithBoundingBox:requestBoundingBox];
    [GPKGTestUtils assertNotNil:values];
    [GPKGTestUtils assertNotNil:[values values]];
    [GPKGTestUtils assertEqualIntWithValue:(int)((NSArray *)[[values values] objectAtIndex:0]).count andValue2:[values width]];
    [GPKGTestUtils assertEqualIntWithValue:(int)[values values].count andValue2:[values height]];
    [GPKGTestUtils assertNotNil:[values tileMatrix]];
    [GPKGTestUtils assertTrue:[values zoomLevel] >= 0];
    [GPKGTestUtils assertTrue:[values values].count > 0];
    [GPKGTestUtils assertTrue:((NSArray *)[[values values] objectAtIndex:0]).count > 0];
    for (int y = 0; y < [values height]; y++) {
        for (int x = 0; x < [values width]; x++) {
            NSDecimalNumber * value = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[values values] objectAtIndex:y]];
            [GPKGTestUtils assertEqualDecimalNumberWithValue:value andValue2:[values valueAtRow:y andColumn:x] andDelta:.000001];
        }
    }
    
    int specifiedWidth = 50;
    int specifiedHeight = 100;
    [coverageData2 setWidth:[NSNumber numberWithInt:specifiedWidth]];
    [coverageData2 setHeight:[NSNumber numberWithInt:specifiedHeight]];
    
    values = [coverageData2 valuesWithBoundingBox:requestBoundingBox];
    [GPKGTestUtils assertNotNil:values];
    [GPKGTestUtils assertNotNil:[values values]];
    [GPKGTestUtils assertEqualIntWithValue:(int)((NSArray *)[[values values] objectAtIndex:0]).count andValue2:[values width]];
    [GPKGTestUtils assertEqualIntWithValue:(int)[values values].count andValue2:[values height]];
    [GPKGTestUtils assertNotNil:[values tileMatrix]];
    [GPKGTestUtils assertTrue:[values zoomLevel] >= 0];
    [GPKGTestUtils assertTrue:[values values].count > 0];
    [GPKGTestUtils assertTrue:((NSArray *)[[values values] objectAtIndex:0]).count > 0];
    [GPKGTestUtils assertEqualIntWithValue:specifiedHeight andValue2:[values height]];
    [GPKGTestUtils assertEqualIntWithValue:specifiedWidth andValue2:[values width]];
    for (int y = 0; y < specifiedHeight; y++) {
        for (int x = 0; x < specifiedWidth; x++) {
            NSDecimalNumber * value = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[values values] objectAtIndex:y]];
            [GPKGTestUtils assertEqualDecimalNumberWithValue:value andValue2:[values valueAtRow:y andColumn:x] andDelta:.000001];
        }
    }
    
    values = [coverageData2 valuesUnboundedWithBoundingBox:requestBoundingBox];
    [GPKGTestUtils assertNotNil:values];
    [GPKGTestUtils assertNotNil:[values values]];
    [GPKGTestUtils assertEqualIntWithValue:(int)((NSArray *)[[values values] objectAtIndex:0]).count andValue2:[values width]];
    [GPKGTestUtils assertEqualIntWithValue:(int)[values values].count andValue2:[values height]];
    [GPKGTestUtils assertNotNil:[values tileMatrix]];
    [GPKGTestUtils assertTrue:[values zoomLevel] >= 0];
    [GPKGTestUtils assertTrue:[values values].count > 0];
    [GPKGTestUtils assertTrue:((NSArray *)[[values values] objectAtIndex:0]).count > 0];
    [GPKGTestUtils assertEqualIntWithValue:(int)((NSArray *)[[values values] objectAtIndex:0]).count andValue2:(int)((NSArray *)[[values values] objectAtIndex:[values values].count - 1]).count];
    for (int y = 0; y < [values height]; y++) {
        for (int x = 0; x < [values width]; x++) {
            NSDecimalNumber * value = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[values values] objectAtIndex:y]];
            [GPKGTestUtils assertEqualDecimalNumberWithValue:value andValue2:[values valueAtRow:y andColumn:x] andDelta:.000001];
        }
    }
    
}

+(void) testRandomBoundingBoxWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGCoverageDataValues *) coverageDataValues andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    
    // Verify the coverage data shows up as a coverage data table and not a tile table
    NSArray * tilesTables = [geoPackage getTileTables];
    NSArray * coverageDataTables = [GPKGCoverageData tablesForGeoPackage:geoPackage];
    [GPKGTestUtils assertTrue:coverageDataTables.count > 0];
    for (NSString * tilesTable in tilesTables) {
        [GPKGTestUtils assertFalse:[coverageDataTables containsObject:tilesTable]];
    }
    
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    [GPKGTestUtils assertTrue:[dao tableExists]];
    
    for(NSString * coverageDataTable in coverageDataTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:coverageDataTable];
        
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        GPKGCoverageData * coverageData = [GPKGCoverageData coverageDataWithGeoPackage:geoPackage andTileDao:tileDao];
        [coverageData setAlgorithm:algorithm];
        
        int specifiedWidth = (int) ([GPKGTestUtils randomDouble] * 100.0) + 1;
        int specifiedHeight = (int) ([GPKGTestUtils randomDouble] * 100.0) + 1;
        [coverageData setWidth:[NSNumber numberWithInt:specifiedWidth]];
        [coverageData setHeight:[NSNumber numberWithInt:specifiedHeight]];
        
        GPKGBoundingBox * boundingBox = [tileMatrixSet getBoundingBox];
        
        // Build a random bounding box
        double minLatitude = ([boundingBox.maxLatitude doubleValue] - [boundingBox.minLatitude doubleValue]) * [GPKGTestUtils randomDouble] + [boundingBox.minLatitude doubleValue];
        double minLongitude = ([boundingBox.maxLongitude doubleValue] - [boundingBox.minLongitude doubleValue]) * [GPKGTestUtils randomDouble] + [boundingBox.minLongitude doubleValue];
        double maxLatitude = ([boundingBox.maxLatitude doubleValue] - minLatitude) * [GPKGTestUtils randomDouble] + minLatitude;
        double maxLongitude = ([boundingBox.maxLongitude doubleValue] - minLongitude) * [GPKGTestUtils randomDouble] + minLongitude;
        
        GPKGBoundingBox * requestBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
        
        GPKGCoverageDataResults * values = [coverageData valuesWithBoundingBox:requestBoundingBox];
        
        [GPKGTestUtils assertNotNil:values];
        [GPKGTestUtils assertNotNil:[values values]];
        [GPKGTestUtils assertEqualIntWithValue:(int)((NSArray *)[[values values] objectAtIndex:0]).count andValue2:[values width]];
        [GPKGTestUtils assertEqualIntWithValue:(int)[values values].count andValue2:[values height]];
        [GPKGTestUtils assertNotNil:[values tileMatrix]];
        [GPKGTestUtils assertTrue:[values zoomLevel] >= 0];
        [GPKGTestUtils assertTrue:[values values].count > 0];
        [GPKGTestUtils assertTrue:((NSArray *)[[values values] objectAtIndex:0]).count > 0];
        [GPKGTestUtils assertEqualIntWithValue:specifiedHeight andValue2:[values height]];
        [GPKGTestUtils assertEqualIntWithValue:specifiedWidth andValue2:[values width]];
        
        for (int y = 0; y < specifiedHeight; y++) {
            BOOL nonNilFound = false;
            BOOL secondNilsFound = false;
            for (int x = 0; x < specifiedWidth; x++) {
                NSDecimalNumber * value = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[values values] objectAtIndex:y]];
                [GPKGTestUtils assertEqualDecimalNumberWithValue:value andValue2:[values valueAtRow:y andColumn:x] andDelta:.000001];
                if (!allowNils) {
                    if ([values valueAtRow:y andColumn:x] != nil) {
                        [GPKGTestUtils assertFalse:secondNilsFound];
                        nonNilFound = true;
                    } else if (nonNilFound) {
                        secondNilsFound = true;
                    }
                }
            }
        }
        
        for (int x = 0; x < specifiedWidth; x++) {
            BOOL nonNilFound = false;
            BOOL secondNilsFound = false;
            for (int y = 0; y < specifiedHeight; y++) {
                NSDecimalNumber * value = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[values values] objectAtIndex:y]];
                [GPKGTestUtils assertEqualDecimalNumberWithValue:value andValue2:[values valueAtRow:y andColumn:x] andDelta:.000001];
                if (!allowNils) {
                    if ([values valueAtRow:y andColumn:x] != nil) {
                        [GPKGTestUtils assertFalse:secondNilsFound];
                        nonNilFound = true;
                    } else if (nonNilFound) {
                        secondNilsFound = true;
                    }
                }
            }
        }
        
    }
}

+(NSDecimalNumber *) valueWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andLatitude: (double) latitude andLongitude: (double) longitude andEpsg: (int) epsg{
    
    NSDecimalNumber * value = nil;
    
    NSArray * coverageDataTables = [GPKGCoverageData tablesForGeoPackage:geoPackage];
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    
    for(NSString * coverageDataTable in coverageDataTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:coverageDataTable];
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        
        SFPProjection * requestProjection = [SFPProjectionFactory  projectionWithEpsgInt:epsg];
        
        // Test getting the coverage data value of a single coordinate
        GPKGCoverageData * coverageData = [GPKGCoverageData coverageDataWithGeoPackage:geoPackage andTileDao:tileDao andProjection:requestProjection];
        [coverageData setAlgorithm:algorithm];
        value = [coverageData valueWithLatitude:latitude andLongitude:longitude];
    }
    
    return value;
}

+(GPKGCoverageDataResults *) valuesWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andBoundingBox: (GPKGBoundingBox *) boundingBox andWidth: (int) width andHeight: (int) height andEpsg: (int) epsg{
    
    GPKGCoverageDataResults * values = nil;
    
    NSArray * coverageDataTables = [GPKGCoverageData tablesForGeoPackage:geoPackage];
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    
    for(NSString * coverageDataTable in coverageDataTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:coverageDataTable];
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        
        SFPProjection * requestProjection = [SFPProjectionFactory projectionWithEpsgInt:epsg];
        
        // Test getting the coverage data value of a single coordinate
        GPKGCoverageData * coverageData = [GPKGCoverageData coverageDataWithGeoPackage:geoPackage andTileDao:tileDao andProjection:requestProjection];
        [coverageData setAlgorithm:algorithm];
        [coverageData setWidth:[NSNumber numberWithInt:width]];
        [coverageData setHeight:[NSNumber numberWithInt:height]];
        values = [coverageData valuesWithBoundingBox:boundingBox];
    }
    
    return values;
}

+(void) testPixelEncodingWithGeoPackage: (GPKGGeoPackage *) geoPackage andAllowNils: (BOOL) allowNils{

    NSArray * coverageDataTables = [GPKGCoverageData tablesForGeoPackage:geoPackage];
    [GPKGTestUtils assertFalse:coverageDataTables.count == 0];
    
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    [GPKGTestUtils assertTrue:[tileMatrixSetDao tableExists]];
    GPKGTileMatrixDao *tileMatrixDao = [geoPackage getTileMatrixDao];
    [GPKGTestUtils assertTrue:[tileMatrixDao tableExists]];
    
    for (NSString *coverageTable in coverageDataTables) {
        
        GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *)[tileMatrixSetDao queryForIdObject:coverageTable];
        
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        GPKGCoverageData * coverageData = [GPKGCoverageData coverageDataWithGeoPackage:geoPackage andTileDao:tileDao];
        GPKGGriddedCoverage *griddedCoverage = [coverageData griddedCoverage];
        enum GPKGGriddedCoverageEncodingType encoding = [griddedCoverage getGridCellEncodingType];
        
        GPKGResultSet *tileResultSet = [tileDao queryforTileWithZoomLevel:tileDao.maxZoom];
        [GPKGTestUtils assertNotNil:tileResultSet];
        @try{
            [GPKGTestUtils assertTrue:tileResultSet.count > 0];
            while([tileResultSet moveToNext]){
                GPKGTileRow * tileRow = [tileDao getTileRow:tileResultSet];
                
                GPKGTileMatrix *tileMatrix = [tileDao getTileMatrixWithZoomLevel:[tileRow getZoomLevel]];
                [GPKGTestUtils assertNotNil:tileMatrix];
                
                GPKGGriddedTile *griddedTile = [coverageData griddedTileWithTileId:[[tileRow getId] intValue]];
                [GPKGTestUtils assertNotNil:griddedTile];
                
                NSData *tileData = [tileRow getTileData];
                [GPKGTestUtils assertNotNil:tileData];
                
                GPKGBoundingBox *boundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:[tileMatrixSet getBoundingBox] andTileMatrix:tileMatrix andTileColumn:[tileRow getTileColumn] andTileRow:[tileRow getTileRow]];
                
                int tileHeight = [tileMatrix.tileHeight intValue];
                int tileWidth = [tileMatrix.tileWidth intValue];
                
                int heightChunk = MAX(tileHeight / 10, 1);
                int widthChunk = MAX(tileWidth / 10, 1);
                
                for (int y = 0; y < tileHeight; y = MIN(y + heightChunk,
                                                             y == tileHeight - 1 ? tileHeight : tileHeight - 1)) {
                    for (int x = 0; x < tileWidth; x = MIN(x + widthChunk,
                                                                x == tileWidth - 1 ? tileWidth : tileWidth - 1)) {
                        
                        NSDecimalNumber *pixelValue = [coverageData valueWithGriddedTile:griddedTile andData:tileData andX:x andY:y];
                        double pixelLongitude = [boundingBox.minLongitude doubleValue] + (x * [tileMatrix.pixelXSize doubleValue]);
                        double pixelLatitude = [boundingBox.maxLatitude doubleValue] - (y * [tileMatrix.pixelYSize doubleValue]);
                        switch (encoding) {
                            case GPKG_GCET_CENTER:
                            case GPKG_GCET_AREA:
                                pixelLongitude += ([tileMatrix.pixelXSize doubleValue] / 2.0);
                                pixelLatitude -= ([tileMatrix.pixelYSize doubleValue] / 2.0);
                                break;
                            case GPKG_GCET_CORNER:
                                pixelLatitude -= [tileMatrix.pixelYSize doubleValue];
                                break;
                        }
                        NSDecimalNumber *value = [coverageData valueWithLatitude:pixelLatitude andLongitude:pixelLongitude];
                        
                        if (!allowNils || pixelValue != nil) {
                            [GPKGTestUtils assertEqualDecimalNumberWithValue:pixelValue andValue2:value andDelta:0];
                        }
                    }
                }
                
                break;
            }
        }@finally{
            [tileResultSet close];
        }
    }
    
}

@end
