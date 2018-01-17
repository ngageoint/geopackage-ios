//
//  GPKGCoverageDataTiffTestUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataTiffTestUtils.h"
#import "GPKGCoverageDataTiff.h"
#import "GPKGProjectionFactory.h"
#import "GPKGTestUtils.h"
#import "GPKGUtils.h"
#import "GPKGProjectionConstants.h"
#import "GPKGProjectionTransform.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGCoverageDataTiffTestUtils

+(void) testCoverageDataWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGCoverageDataValues *) coverageDataValues andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    
    // Verify the elevation shows up as an elevation table and not a tile table
    NSArray * tilesTables = [geoPackage getTileTables];
    NSArray * coverageDataTables = [GPKGCoverageDataTiff tablesForGeoPackage:geoPackage];
    [GPKGTestUtils assertTrue:coverageDataTables.count > 0];
    for (NSString * tilesTable in tilesTables) {
        [GPKGTestUtils assertFalse:[coverageDataTables containsObject:tilesTable]];
    }
    
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    [GPKGTestUtils assertTrue:[dao tableExists]];
    
    for(NSString * coverageDataTable in coverageDataTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:coverageDataTable];
        [GPKGTestUtils assertNotNil:tileMatrixSet];
        
        // Test the tile matrix set
        [GPKGTestUtils assertNotNil:tileMatrixSet.tableName];
        [GPKGTestUtils assertNotNil:tileMatrixSet.srsId];
        [GPKGTestUtils assertNotNil:tileMatrixSet.minX];
        [GPKGTestUtils assertNotNil:tileMatrixSet.minY];
        [GPKGTestUtils assertNotNil:tileMatrixSet.maxX];
        [GPKGTestUtils assertNotNil:tileMatrixSet.maxY];
        
        GPKGTileMatrixSetDao * tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
        GPKGContentsDao * contentsDao = [geoPackage getContentsDao];
        
        // Test the tile matrix set SRS
        GPKGSpatialReferenceSystem * srs = [tileMatrixSetDao getSrs:tileMatrixSet];
        [GPKGTestUtils assertNotNil:srs];
        [GPKGTestUtils assertNotNil:srs.srsName];
        [GPKGTestUtils assertNotNil:srs.srsId];
        [GPKGTestUtils assertTrue:[srs.organization caseInsensitiveCompare:@"epsg"] == NSOrderedSame];
        [GPKGTestUtils assertNotNil:srs.organizationCoordsysId];
        [GPKGTestUtils assertNotNil:srs.definition];
        
        // Test the contents
        GPKGContents * contents = [tileMatrixSetDao getContents:tileMatrixSet];
        [GPKGTestUtils assertNotNil:contents];
        [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:contents.tableName];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_CDT_GRIDDED_COVERAGE andValue2:[contents getContentsDataType]];
        [GPKGTestUtils assertEqualWithValue:GPKG_CDT_GRIDDED_COVERAGE_NAME andValue2:contents.dataType];
        [GPKGTestUtils assertNotNil:contents.lastChange];
        
        // Test the contents SRS
        GPKGSpatialReferenceSystem * contentsSrs = [contentsDao getSrs:contents];
        [GPKGTestUtils assertNotNil:contentsSrs];
        [GPKGTestUtils assertNotNil:contentsSrs.srsName];
        [GPKGTestUtils assertNotNil:contentsSrs.srsId];
        [GPKGTestUtils assertNotNil:contentsSrs.organization];
        [GPKGTestUtils assertNotNil:contentsSrs.organizationCoordsysId];
        [GPKGTestUtils assertNotNil:contentsSrs.definition];
        
        // Test the elevation tiles extension is on
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        GPKGCoverageDataTiff * coverageData = [[GPKGCoverageDataTiff alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
        [GPKGTestUtils assertTrue:[coverageData has]];
        [coverageData setAlgorithm:algorithm];
        
        // Test the 3 extension rows
        GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
        
        GPKGExtensions * griddedCoverageExtension = [extensionsDao queryByExtension:coverageData.extensionName andTable:GPKG_EGC_TABLE_NAME andColumnName:nil];
        [GPKGTestUtils assertNotNil:griddedCoverageExtension];
        [GPKGTestUtils assertEqualWithValue:GPKG_EGC_TABLE_NAME andValue2:griddedCoverageExtension.tableName];
        [GPKGTestUtils assertNil:griddedCoverageExtension.columnName];
        [GPKGTestUtils assertEqualWithValue:coverageData.extensionName andValue2:griddedCoverageExtension.extensionName];
        [GPKGTestUtils assertEqualWithValue:coverageData.definition andValue2:griddedCoverageExtension.definition];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_EST_READ_WRITE andValue2:[griddedCoverageExtension getExtensionScopeType]];
        
        GPKGExtensions * griddedTileExtension = [extensionsDao queryByExtension:coverageData.extensionName andTable:GPKG_EGT_TABLE_NAME andColumnName:nil];
        [GPKGTestUtils assertNotNil:griddedTileExtension];
        [GPKGTestUtils assertEqualWithValue:GPKG_EGT_TABLE_NAME andValue2:griddedTileExtension.tableName];
        [GPKGTestUtils assertNil:griddedTileExtension.columnName];
        [GPKGTestUtils assertEqualWithValue:coverageData.extensionName andValue2:griddedTileExtension.extensionName];
        [GPKGTestUtils assertEqualWithValue:coverageData.definition andValue2:griddedTileExtension.definition];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_EST_READ_WRITE andValue2:[griddedTileExtension getExtensionScopeType]];
        
        GPKGExtensions * tileTableExtension = [extensionsDao queryByExtension:coverageData.extensionName andTable:tileMatrixSet.tableName andColumnName:GPKG_TT_COLUMN_TILE_DATA];
        [GPKGTestUtils assertNotNil:tileTableExtension];
        [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:tileTableExtension.tableName];
        [GPKGTestUtils assertEqualWithValue:GPKG_TT_COLUMN_TILE_DATA andValue2:tileTableExtension.columnName];
        [GPKGTestUtils assertEqualWithValue:coverageData.extensionName andValue2:tileTableExtension.extensionName];
        [GPKGTestUtils assertEqualWithValue:coverageData.definition andValue2:tileTableExtension.definition];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_EST_READ_WRITE andValue2:[tileTableExtension getExtensionScopeType]];
        
        GPKGGriddedCoverageDao * griddedCoverageDao = [geoPackage getGriddedCoverageDao];
        
        // Test the Gridded Coverage
        GPKGGriddedCoverage * griddedCoverage = [coverageData griddedCoverage];
        [GPKGTestUtils assertNotNil:griddedCoverage];
        [GPKGTestUtils assertTrue:[griddedCoverage.id intValue] >= 0];
        [GPKGTestUtils assertNotNil:griddedCoverage.tileMatrixSetName];
        [GPKGTestUtils assertNotNil:[griddedCoverageDao getTileMatrixSet:griddedCoverage]];
        [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:griddedCoverage.tileMatrixSetName];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_GCDT_FLOAT andValue2:[griddedCoverage getGriddedCoverageDataType]];
        [GPKGTestUtils assertEqualDoubleWithValue:1.0 andValue2:[griddedCoverage.scale doubleValue]];
        [GPKGTestUtils assertEqualDoubleWithValue:0.0 andValue2:[griddedCoverage.offset doubleValue]];
        [GPKGTestUtils assertTrue:[griddedCoverage.precision doubleValue] >= 0];
        
        // Test the Gridded Tile
        GPKGResultSet * griddedTiles = [coverageData griddedTile];
        [GPKGTestUtils assertNotNil:griddedTiles];
        [GPKGTestUtils assertTrue:griddedTiles.count > 0];
        while([griddedTiles moveToNext]){
            GPKGGriddedTile * griddedTile = [coverageData griddedTileWithResultSet:griddedTiles];
            GPKGTileRow * tileRow = (GPKGTileRow *)[tileDao queryForIdObject:griddedTile.tableId];
            [self testTileRowWithGeoPackage:geoPackage andValues:coverageDataValues andCoverageData:coverageData andTileMatrixSet:tileMatrixSet andGriddedTile:griddedTile andTileRow:tileRow andAlgorithm:algorithm andAllowNils:allowNils];
        }
        [griddedTiles close];
        
        GPKGResultSet * tileResultSet = [tileDao queryForAll];
        [GPKGTestUtils assertNotNil:tileResultSet];
        [GPKGTestUtils assertTrue:tileResultSet.count > 0];
        while ([tileResultSet moveToNext]) {
            GPKGTileRow * tileRow = [tileDao getTileRow:tileResultSet];
            GPKGGriddedTile * griddedTile = [coverageData griddedTileWithTileId:[[tileRow getId] intValue]];
            [self testTileRowWithGeoPackage:geoPackage andValues:coverageDataValues andCoverageData:coverageData andTileMatrixSet:tileMatrixSet andGriddedTile:griddedTile andTileRow:tileRow andAlgorithm:algorithm andAllowNils:allowNils];
        }
        [tileResultSet close];
        
        // Perform elevation query tests
        [self testElevationQueriesWithGeoPackage:geoPackage andCoverageData:coverageData andTileMatrixSet:tileMatrixSet andAlgorithm:algorithm andAllowNils:allowNils];
    }
}

/**
 * Perform tests on the tile row
 *
 * @param geoPackage
 * @param coverageDataValues
 * @param coverageData
 * @param tileMatrixSet
 * @param griddedTile
 * @param tileRow
 * @param algorithm
 * @param allowNils
 */
+(void) testTileRowWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGCoverageDataValues *) coverageDataValues andCoverageData: (GPKGCoverageDataTiff *) coverageData andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andGriddedTile: (GPKGGriddedTile *) griddedTile andTileRow: (GPKGTileRow *) tileRow andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    
    GPKGGriddedTileDao * griddedTileDao = [geoPackage getGriddedTileDao];
    
    [GPKGTestUtils assertNotNil:griddedTile];
    [GPKGTestUtils assertTrue:[griddedTile.id intValue] >= 0];
    [GPKGTestUtils assertNotNil:[griddedTileDao getContents:griddedTile]];
    [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:griddedTile.tableName];
    NSNumber * tableId = griddedTile.tableId;
    [GPKGTestUtils assertTrue:[tableId intValue] >= 0];
    [GPKGTestUtils assertEqualDoubleWithValue:1.0 andValue2:[griddedTile.scale doubleValue]];
    [GPKGTestUtils assertEqualDoubleWithValue:0.0 andValue2:[griddedTile.offset doubleValue]];
    [GPKGTestUtils assertNotNil:tileRow];
    
    NSData * tileData = [tileRow getTileData];
    [GPKGTestUtils assertTrue:tileData.length > 0];
    GPKGCoverageDataTiffImage * image = [[GPKGCoverageDataTiffImage alloc] initWithTileRow:tileRow];
    
    // Get all the pixel values of the image
    NSArray * arrayValues = [coverageData pixelArrayValuesWithData: tileData];
    float * pixelValues = [coverageData pixelValuesArrayToFloat:arrayValues];
    if (coverageDataValues != nil) {
        for (int i = 0; i < arrayValues.count; i++) {
            [GPKGTestUtils assertEqualDoubleWithValue:[coverageDataValues tilePixelFlatAsFloatWithIndex:i] andValue2:pixelValues[i]];
        }
    }
    
    int width = [image width];
    int height = [image height];
    
    // Get each individual image pixel value
    NSMutableArray * pixelValuesList = [[NSMutableArray alloc] init];
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            float pixelValue = [image pixelAtX:x andY:y];
            [pixelValuesList addObject:[NSNumber numberWithFloat:pixelValue]];
            
            // Test getting the pixel value from the pixel values array
            float pixelValue2 = [coverageData pixelValueWithRawFloatValues:pixelValues andWidth:width andX:x andY:y];
            [GPKGTestUtils assertEqualDoubleWithValue:pixelValue andValue2:pixelValue2];
            
            // Test getting the elevation value
            NSDecimalNumber * value = [coverageData valueWithGriddedTile:griddedTile andPixelFloatValue:pixelValue];
            GPKGGriddedCoverage * griddedCoverage = [coverageData griddedCoverage];
            if(coverageDataValues != nil){
                [GPKGTestUtils assertEqualDoubleWithValue:[coverageDataValues tilePixelAsFloatWithY:y andX:x] andValue2:pixelValue];
                [GPKGTestUtils assertEqualDoubleWithValue:[coverageDataValues tilePixelFlatAsFloatWithWidth:width andY:y andX:x] andValue2:pixelValue];
            }
            if (griddedCoverage.dataNull != nil && pixelValue == [griddedCoverage.dataNull floatValue]) {
                [GPKGTestUtils assertNil:value];
            } else {
                [GPKGTestUtils assertEqualDoubleWithValue:pixelValue andValue2:[value doubleValue] andDelta:.000001];
            }
        }
    }
    
    // Test the individually built list of pixel values vs the full returned array
    [GPKGTestUtils assertEqualIntWithValue:(int)pixelValuesList.count andValue2:(int)arrayValues.count];
    for (int i = 0; i < pixelValuesList.count; i++) {
        [GPKGTestUtils assertEqualDoubleWithValue:[((NSDecimalNumber *)[pixelValuesList objectAtIndex:i]) floatValue] andValue2:pixelValues[i]];
    }
    
    free(pixelValues);
    
    GPKGTileMatrix * tileMatrix = [coverageData.tileDao getTileMatrixWithZoomLevel:[tileRow getZoomLevel]];
    double xDistance = [tileMatrixSet.maxX doubleValue] - [tileMatrixSet.minX doubleValue];
    double xDistance2 = [tileMatrix.matrixWidth intValue] * [tileMatrix.tileWidth intValue] * [tileMatrix.pixelXSize doubleValue];
    [GPKGTestUtils assertEqualDoubleWithValue:xDistance andValue2:xDistance2 andDelta:.001];
    double yDistance = [tileMatrixSet.maxY doubleValue] - [tileMatrixSet.minY doubleValue];
    double yDistance2 = [tileMatrix.matrixHeight intValue] * [tileMatrix.tileHeight intValue] * [tileMatrix.pixelYSize doubleValue];
    [GPKGTestUtils assertEqualDoubleWithValue:yDistance andValue2:yDistance2 andDelta:.001];
    GPKGBoundingBox * boundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:[tileMatrixSet getBoundingBox] andTileMatrix:tileMatrix andTileColumn:[tileRow getTileColumn] andTileRow:[tileRow getTileRow]];
    GPKGCoverageDataResults * coverageDataResults = [coverageData elevationsWithBoundingBox:boundingBox];
    if(coverageDataValues != nil){
        [GPKGTestUtils assertEqualIntWithValue:[coverageDataValues height] andValue2:[coverageDataResults height]];
        [GPKGTestUtils assertEqualIntWithValue:[coverageDataValues width] andValue2:[coverageDataResults width]];
        [GPKGTestUtils assertEqualIntWithValue:[coverageDataValues count] andValue2:[coverageDataResults height] * [coverageDataResults width]];
        for (int y = 0; y < [coverageDataResults height]; y++) {
            for (int x = 0; x < [coverageDataResults width]; x++) {
                switch(algorithm) {
                    case GPKG_ETA_BICUBIC:
                    {
                        // Don't test the edges
                        if (y > 1
                            && y < [coverageDataValues height] - 2
                            && x > 1
                            && x < [coverageDataValues width] - 2) {
                            if (!allowNils) {
                                // No nils allowed, check for equality
                                [GPKGTestUtils assertEqualDecimalNumberWithValue:[coverageDataValues tileElevationWithY:y andX:x] andValue2:[coverageDataResults valueAtRow:y andColumn:x] andDelta:.000001];
                            } else {
                                // Verify there is nil neighbor value
                                NSDecimalNumber * value1 = [coverageDataValues tileElevationWithY:y andX:x];
                                NSDecimalNumber * value2 = [coverageDataResults valueAtRow:y andColumn:x];
                                if(value1 == nil ? value2 != nil : ![GPKGTestUtils equalDoubleWithValue:[value1 doubleValue] andValue2:[value2 doubleValue] andDelta:.000001]){
                                    BOOL nilValue = false;
                                    for (int yLocation = y - 2; !nilValue && yLocation <= y + 2; yLocation++) {
                                        for (int xLocation = x - 2; xLocation <= x + 2; xLocation++) {
                                            if ([coverageDataValues tileElevationWithY:yLocation andX:xLocation] == nil) {
                                                nilValue = true;
                                                break;
                                            }
                                        }
                                    }
                                    [GPKGTestUtils assertTrue:nilValue];
                                }
                            }
                            
                        }
                    }
                        break;
                    case GPKG_ETA_BILINEAR:
                    {
                        // Don't test the edges
                        if (y > 0
                            && y < [coverageDataValues height] - 1
                            && x > 0
                            && x < [coverageDataValues width] - 1) {
                            if (!allowNils) {
                                // No nils allowed, check for equality
                                [GPKGTestUtils assertEqualDecimalNumberWithValue:[coverageDataValues tileElevationWithY:y andX:x] andValue2:[coverageDataResults valueAtRow:y andColumn:x] andDelta:.000001];
                            } else {
                                // Verify there is nil neighbor value
                                NSDecimalNumber * value1 = [coverageDataValues tileElevationWithY:y andX:x];
                                NSDecimalNumber * value2 = [coverageDataResults valueAtRow:y andColumn:x];
                                if(value1 == nil ? value2 != nil : ![GPKGTestUtils equalDoubleWithValue:[value1 doubleValue] andValue2:[value2 doubleValue] andDelta:.000001]){
                                    BOOL nilValue = false;
                                    for (int yLocation = y - 1; !nilValue && yLocation <= y + 1; yLocation++) {
                                        for (int xLocation = x - 1; xLocation <= x + 1; xLocation++) {
                                            if ([coverageDataValues tileElevationWithY:yLocation andX:xLocation] == nil) {
                                                nilValue = true;
                                                break;
                                            }
                                        }
                                    }
                                    [GPKGTestUtils assertTrue:nilValue];
                                }
                            }
                            
                        }
                    }
                        break;
                    case GPKG_ETA_NEAREST_NEIGHBOR:
                    {
                        if (!allowNils) {
                            [GPKGTestUtils assertEqualDecimalNumberWithValue:[coverageDataValues tileElevationWithY:y andX:x] andValue2:[coverageDataResults valueAtRow:y andColumn:x] andDelta:.000001];
                        } else {
                            NSDecimalNumber * value1 = [coverageDataValues tileElevationWithY:y andX:x];
                            NSDecimalNumber * value2 = [coverageDataResults valueAtRow:y andColumn:x];
                            if(value1 == nil ? value2 != nil : ![GPKGTestUtils equalDoubleWithValue:[value1 doubleValue] andValue2:[value2 doubleValue] andDelta:.000001]){
                                // Find a matching neighbor
                                BOOL nonNil = false;
                                BOOL match = false;
                                for (int yLocation = MAX(0, y - 1); !match && yLocation <= y + 1 && yLocation < [coverageDataValues height]; yLocation++) {
                                    for (int xLocation = MAX(0, x - 1); xLocation <= x + 1 && xLocation < [coverageDataValues width]; xLocation++) {
                                        NSDecimalNumber * value = [coverageDataValues tileElevationWithY:yLocation andX:xLocation];
                                        if (value != nil) {
                                            nonNil = true;
                                            match = [GPKGTestUtils equalDoubleWithValue:[value doubleValue] andValue2:[value2 doubleValue] andDelta:.000001];
                                            if (match) {
                                                break;
                                            }
                                        }
                                    }
                                }
                                if (!match) {
                                    if (nonNil) {
                                        [GPKGTestUtils assertNotNil:value2];
                                    } else {
                                        [GPKGTestUtils assertNil:value2];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/**
 * Test performing elevation queries
 *
 * @param geoPackage
 * @param coverageData
 * @param tileMatrixSet
 * @param algorithm
 * @param allowNils
 */
+(void) testElevationQueriesWithGeoPackage: (GPKGGeoPackage *) geoPackage andCoverageData: (GPKGCoverageDataTiff *) coverageData andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    
    // Determine an alternate projection
    GPKGBoundingBox * boundingBox = [tileMatrixSet getBoundingBox];
    GPKGSpatialReferenceSystemDao * srsDao = [geoPackage getSpatialReferenceSystemDao];
    NSNumber * srsId = tileMatrixSet.srsId;
    GPKGSpatialReferenceSystem * srs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:srsId];
    
    NSNumber * epsg = srs.organizationCoordsysId;
    GPKGProjection * projection = [GPKGProjectionFactory projectionWithSrs:srs];
    int requestEpsg = -1;
    if ([epsg intValue] == PROJ_EPSG_WORLD_GEODETIC_SYSTEM) {
        requestEpsg = PROJ_EPSG_WEB_MERCATOR;
    } else {
        requestEpsg = PROJ_EPSG_WORLD_GEODETIC_SYSTEM;
    }
    GPKGProjection * requestProjection = [GPKGProjectionFactory projectionWithEpsgInt:requestEpsg];
    GPKGProjectionTransform * elevationToRequest = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToProjection:requestProjection];
    GPKGBoundingBox * projectedBoundingBox = [elevationToRequest transformWithBoundingBox:boundingBox];
    
    // Get a random coordinate
    double latDistance = [projectedBoundingBox.maxLatitude doubleValue] - [projectedBoundingBox.minLatitude doubleValue];
    double latitude = latDistance * .9 * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLatitude doubleValue] + (.05 * latDistance);
    double lonDistance = [projectedBoundingBox.maxLongitude doubleValue] - [projectedBoundingBox.minLongitude doubleValue];
    double longitude = lonDistance * .9 * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLongitude doubleValue] + (.05 * lonDistance);
    
    // Test getting the elevation of a single coordinate
    GPKGCoverageDataTiff * coverageData2 = [[GPKGCoverageDataTiff alloc] initWithGeoPackage:geoPackage andTileDao:[coverageData tileDao] andProjection:requestProjection];
    [coverageData2 setAlgorithm:algorithm];
    NSDecimalNumber * value = [coverageData2 elevationWithLatitude:latitude andLongitude:longitude];
    if (!allowNils) {
        [GPKGTestUtils assertNotNil:value];
    }
    
    // Build a random bounding box
    double minLatitude = ([projectedBoundingBox.maxLatitude doubleValue] - [projectedBoundingBox.minLatitude doubleValue]) * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLatitude doubleValue];
    double minLongitude = ([projectedBoundingBox.maxLongitude doubleValue] - [projectedBoundingBox.minLongitude doubleValue]) * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLongitude doubleValue];
    double maxLatitude = ([projectedBoundingBox.maxLatitude doubleValue] - minLatitude) * [GPKGTestUtils randomDouble] + minLatitude;
    double maxLongitude = ([projectedBoundingBox.maxLongitude doubleValue] - minLongitude) * [GPKGTestUtils randomDouble] + minLongitude;
    
    GPKGBoundingBox * requestBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
    GPKGCoverageDataResults * values = [coverageData2 elevationsWithBoundingBox:requestBoundingBox];
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
            NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[values values] objectAtIndex:y]];
            [GPKGTestUtils assertEqualDecimalNumberWithValue:elevation andValue2:[values valueAtRow:y andColumn:x] andDelta:.000001];
        }
    }
    
    int specifiedWidth = 50;
    int specifiedHeight = 100;
    [coverageData2 setWidth:[NSNumber numberWithInt:specifiedWidth]];
    [coverageData2 setHeight:[NSNumber numberWithInt:specifiedHeight]];
    
    values = [coverageData2 elevationsWithBoundingBox:requestBoundingBox];
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
            NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[values values] objectAtIndex:y]];
            [GPKGTestUtils assertEqualDecimalNumberWithValue:elevation andValue2:[values valueAtRow:y andColumn:x] andDelta:.000001];
        }
    }
    
    values = [coverageData2 elevationsUnboundedWithBoundingBox:requestBoundingBox];
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
            NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[values values] objectAtIndex:y]];
            [GPKGTestUtils assertEqualDecimalNumberWithValue:elevation andValue2:[values valueAtRow:y andColumn:x] andDelta:.000001];
        }
    }
    
}

+(void) testRandomBoundingBoxWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGCoverageDataValues *) coverageDataValues andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    
    // Verify the elevation shows up as an elevation table and not a tile table
    NSArray * tilesTables = [geoPackage getTileTables];
    NSArray * elevationTables = [GPKGCoverageDataTiff tablesForGeoPackage:geoPackage];
    [GPKGTestUtils assertTrue:elevationTables.count > 0];
    for (NSString * tilesTable in tilesTables) {
        [GPKGTestUtils assertFalse:[elevationTables containsObject:tilesTable]];
    }
    
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    [GPKGTestUtils assertTrue:[dao tableExists]];
    
    for(NSString * elevationTable in elevationTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:elevationTable];
        
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        GPKGCoverageDataTiff * coverageData = [[GPKGCoverageDataTiff alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
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
        
        GPKGCoverageDataResults * values = [coverageData elevationsWithBoundingBox:requestBoundingBox];
        
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
                NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[values values] objectAtIndex:y]];
                [GPKGTestUtils assertEqualDecimalNumberWithValue:elevation andValue2:[values valueAtRow:y andColumn:x] andDelta:.000001];
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
                NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[values values] objectAtIndex:y]];
                [GPKGTestUtils assertEqualDecimalNumberWithValue:elevation andValue2:[values valueAtRow:y andColumn:x] andDelta:.000001];
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
    
    NSDecimalNumber * elevation = nil;
    
    NSArray * coverageDataTables = [GPKGCoverageDataTiff tablesForGeoPackage:geoPackage];
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    
    for(NSString * elevationTable in coverageDataTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:elevationTable];
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        
        GPKGProjection * requestProjection = [GPKGProjectionFactory  projectionWithEpsgInt:epsg];
        
        // Test getting the elevation of a single coordinate
        GPKGCoverageDataTiff * coverageData = [[GPKGCoverageDataTiff alloc] initWithGeoPackage:geoPackage andTileDao:tileDao andProjection:requestProjection];
        [coverageData setAlgorithm:algorithm];
        elevation = [coverageData elevationWithLatitude:latitude andLongitude:longitude];
    }
    
    return elevation;
}

+(GPKGCoverageDataResults *) valuesWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andBoundingBox: (GPKGBoundingBox *) boundingBox andWidth: (int) width andHeight: (int) height andEpsg: (int) epsg{
    
    GPKGCoverageDataResults * values = nil;
    
    NSArray * coverageDataTables = [GPKGCoverageDataTiff tablesForGeoPackage:geoPackage];
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    
    for(NSString * elevationTable in coverageDataTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:elevationTable];
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        
        GPKGProjection * requestProjection = [GPKGProjectionFactory projectionWithEpsgInt:epsg];
        
        // Test getting the elevation of a single coordinate
        GPKGCoverageDataTiff * coverageData = [[GPKGCoverageDataTiff alloc] initWithGeoPackage:geoPackage andTileDao:tileDao andProjection:requestProjection];
        [coverageData setAlgorithm:algorithm];
        [coverageData setWidth:[NSNumber numberWithInt:width]];
        [coverageData setHeight:[NSNumber numberWithInt:height]];
        values = [coverageData elevationsWithBoundingBox:boundingBox];
    }
    
    return values;
}

@end
