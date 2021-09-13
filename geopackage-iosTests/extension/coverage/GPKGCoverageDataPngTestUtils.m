//
//  GPKGCoverageDataPngTestUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageDataPngTestUtils.h"
#import "GPKGCoverageDataPng.h"
#import "PROJProjectionFactory.h"
#import "GPKGTestUtils.h"
#import "GPKGUtils.h"
#import "PROJProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGCoverageDataTestUtils.h"
#import "GPKGCoverageData.h"

@implementation GPKGCoverageDataPngTestUtils

+(void) testCoverageDataWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGCoverageDataValues *) coverageDataValues andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils{

    // Verify the coverage data shows up as a coverage data table and not a tile table
    NSArray * tilesTables = [geoPackage tileTables];
    NSArray * coverageDataTables = [GPKGCoverageDataPng tablesForGeoPackage:geoPackage];
    [GPKGTestUtils assertTrue:coverageDataTables.count > 0];
    for (NSString * tilesTable in tilesTables) {
        [GPKGTestUtils assertFalse:[coverageDataTables containsObject:tilesTable]];
    }
    
    GPKGTileMatrixSetDao * dao = [geoPackage tileMatrixSetDao];
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
        
        GPKGTileMatrixSetDao * tileMatrixSetDao = [geoPackage tileMatrixSetDao];
        GPKGContentsDao * contentsDao = [geoPackage contentsDao];
        
        // Test the tile matrix set SRS
        GPKGSpatialReferenceSystem * srs = [tileMatrixSetDao srs:tileMatrixSet];
        [GPKGTestUtils assertNotNil:srs];
        [GPKGTestUtils assertNotNil:srs.srsName];
        [GPKGTestUtils assertNotNil:srs.srsId];
        [GPKGTestUtils assertTrue:[srs.organization caseInsensitiveCompare:@"epsg"] == NSOrderedSame];
        [GPKGTestUtils assertNotNil:srs.organizationCoordsysId];
        [GPKGTestUtils assertNotNil:srs.definition];
        
        // Test the contents
        GPKGContents * contents = [tileMatrixSetDao contents:tileMatrixSet];
        [GPKGTestUtils assertNotNil:contents];
        [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:contents.tableName];
        [GPKGTestUtils assertEqualWithValue:GPKG_CD_GRIDDED_COVERAGE andValue2:contents.dataType];
        [GPKGTestUtils assertNotNil:contents.lastChange];
        
        // Test the contents SRS
        GPKGSpatialReferenceSystem * contentsSrs = [contentsDao srs:contents];
        [GPKGTestUtils assertNotNil:contentsSrs];
        [GPKGTestUtils assertNotNil:contentsSrs.srsName];
        [GPKGTestUtils assertNotNil:contentsSrs.srsId];
        [GPKGTestUtils assertNotNil:contentsSrs.organization];
        [GPKGTestUtils assertNotNil:contentsSrs.organizationCoordsysId];
        [GPKGTestUtils assertNotNil:contentsSrs.definition];
        
        // Test if the coverage data extension is on
        GPKGTileDao * tileDao = [geoPackage tileDaoWithTileMatrixSet:tileMatrixSet];
        GPKGCoverageDataPng * coverageData = [[GPKGCoverageDataPng alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
        [GPKGTestUtils assertTrue:[coverageData has]];
        [coverageData setAlgorithm:algorithm];
        enum GPKGGriddedCoverageEncodingType encoding = [[coverageData griddedCoverage] gridCellEncodingType];
        [coverageData setEncoding:encoding];

        // Test the 3 extension rows
        GPKGExtensionsDao * extensionsDao = [geoPackage extensionsDao];
        
        GPKGExtensions * griddedCoverageExtension = [extensionsDao queryByExtension:coverageData.extensionName andTable:GPKG_CDGC_TABLE_NAME andColumnName:nil];
        [GPKGTestUtils assertNotNil:griddedCoverageExtension];
        [GPKGTestUtils assertEqualWithValue:GPKG_CDGC_TABLE_NAME andValue2:griddedCoverageExtension.tableName];
        [GPKGTestUtils assertNil:griddedCoverageExtension.columnName];
        [GPKGTestUtils assertEqualWithValue:coverageData.extensionName andValue2:griddedCoverageExtension.extensionName];
        [GPKGTestUtils assertEqualWithValue:coverageData.definition andValue2:griddedCoverageExtension.definition];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_EST_READ_WRITE andValue2:[griddedCoverageExtension extensionScopeType]];
        
        GPKGExtensions * griddedTileExtension = [extensionsDao queryByExtension:coverageData.extensionName andTable:GPKG_CDGT_TABLE_NAME andColumnName:nil];
        [GPKGTestUtils assertNotNil:griddedTileExtension];
        [GPKGTestUtils assertEqualWithValue:GPKG_CDGT_TABLE_NAME andValue2:griddedTileExtension.tableName];
        [GPKGTestUtils assertNil:griddedTileExtension.columnName];
        [GPKGTestUtils assertEqualWithValue:coverageData.extensionName andValue2:griddedTileExtension.extensionName];
        [GPKGTestUtils assertEqualWithValue:coverageData.definition andValue2:griddedTileExtension.definition];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_EST_READ_WRITE andValue2:[griddedTileExtension extensionScopeType]];
        
        GPKGExtensions * tileTableExtension = [extensionsDao queryByExtension:coverageData.extensionName andTable:tileMatrixSet.tableName andColumnName:GPKG_TC_COLUMN_TILE_DATA];
        [GPKGTestUtils assertNotNil:tileTableExtension];
        [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:tileTableExtension.tableName];
        [GPKGTestUtils assertEqualWithValue:GPKG_TC_COLUMN_TILE_DATA andValue2:tileTableExtension.columnName];
        [GPKGTestUtils assertEqualWithValue:coverageData.extensionName andValue2:tileTableExtension.extensionName];
        [GPKGTestUtils assertEqualWithValue:coverageData.definition andValue2:tileTableExtension.definition];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_EST_READ_WRITE andValue2:[tileTableExtension extensionScopeType]];
        
        GPKGGriddedCoverageDao *griddedCoverageDao = [GPKGCoverageData griddedCoverageDaoWithGeoPackage:geoPackage];
        
        // Test the Gridded Coverage
        GPKGGriddedCoverage * griddedCoverage = [coverageData griddedCoverage];
        [GPKGTestUtils assertNotNil:griddedCoverage];
        [GPKGTestUtils assertTrue:[griddedCoverage.id intValue] >= 0];
        [GPKGTestUtils assertNotNil:griddedCoverage.tileMatrixSetName];
        [GPKGTestUtils assertNotNil:[griddedCoverageDao tileMatrixSet:griddedCoverage]];
        [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:griddedCoverage.tileMatrixSetName];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_GCDT_INTEGER andValue2:[griddedCoverage griddedCoverageDataType]];
        [GPKGTestUtils assertTrue:[griddedCoverage.scale doubleValue] >= 0];
        if(coverageDataValues != nil){
            [GPKGTestUtils assertTrue:[griddedCoverage.offset doubleValue] >= 0];
        }
        [GPKGTestUtils assertTrue:[griddedCoverage.precision doubleValue] >= 0];
        if(coverageDataValues != nil){
            [GPKGTestUtils assertEqualIntWithValue:encoding andValue2:[griddedCoverage gridCellEncodingType]];
            [GPKGTestUtils assertEqualWithValue:[GPKGGriddedCoverageEncodingTypes name:encoding] andValue2:griddedCoverage.gridCellEncoding];
            [GPKGTestUtils assertEqualWithValue:@"Height" andValue2:griddedCoverage.fieldName];
            [GPKGTestUtils assertEqualWithValue:@"Height" andValue2:griddedCoverage.quantityDefinition];
        }else{
            [GPKGTestUtils assertTrue:(int)[griddedCoverage gridCellEncodingType] > -1];
        }
        
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
            GPKGTileRow * tileRow = [tileDao tileRow:tileResultSet];
            GPKGGriddedTile * griddedTile = [coverageData griddedTileWithTileId:[tileRow idValue]];
            [self testTileRowWithGeoPackage:geoPackage andValues:coverageDataValues andCoverageData:coverageData andTileMatrixSet:tileMatrixSet andGriddedTile:griddedTile andTileRow:tileRow andAlgorithm:algorithm andAllowNils:allowNils];
        }
        [tileResultSet close];
        
        // Perform coverage data query tests
        [GPKGCoverageDataTestUtils testCoverageDataQueriesWithGeoPackage:geoPackage andCoverageData:coverageData andTileMatrixSet:tileMatrixSet andAlgorithm:algorithm andAllowNils:allowNils];
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
+(void) testTileRowWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGCoverageDataValues *) coverageDataValues andCoverageData: (GPKGCoverageDataPng *) coverageData andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andGriddedTile: (GPKGGriddedTile *) griddedTile andTileRow: (GPKGTileRow *) tileRow andAlgorithm: (enum GPKGCoverageDataAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    
    GPKGGriddedTileDao *griddedTileDao = [GPKGCoverageData griddedTileDaoWithGeoPackage:geoPackage];
    
    [GPKGTestUtils assertNotNil:griddedTile];
    [GPKGTestUtils assertTrue:[griddedTile.id intValue] >= 0];
    [GPKGTestUtils assertNotNil:[griddedTileDao contents:griddedTile]];
    [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:griddedTile.tableName];
    NSNumber * tableId = griddedTile.tableId;
    [GPKGTestUtils assertTrue:[tableId intValue] >= 0];
    [GPKGTestUtils assertTrue:[griddedTile scaleOrDefault] >= 0];
    if(coverageDataValues != nil){
        [GPKGTestUtils assertTrue:[griddedTile offsetOrDefault] >= 0];
    }
    [GPKGTestUtils assertNotNil:tileRow];
    
    NSData * tileData = [tileRow tileData];
    [GPKGTestUtils assertTrue:tileData.length > 0];
    UIImage * image = [tileRow tileDataImage];
    
    int width = (int) image.size.width;
    int height = (int) image.size.height;
    int pixelCount = width * height;
    
    // Get all the pixel values of the image
    unsigned short * pixelValues = [coverageData pixelValuesWithImage:image];
    if (coverageDataValues != nil) {
        for (int i = 0; i < pixelCount; i++) {
            [GPKGTestUtils assertEqualIntWithValue:[coverageDataValues tilePixelFlatAsUnsignedShortWithIndex:i] andValue2:pixelValues[i]];
        }
    }
    
    // Get each individual image pixel value
    NSMutableArray * pixelValuesList = [NSMutableArray array];
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            unsigned short pixelValue = [coverageData pixelValueWithImage:image andX:x andY:y];
            [pixelValuesList addObject:[NSNumber numberWithUnsignedShort:pixelValue]];
            
            // Test getting the pixel value from the pixel values array
            unsigned short pixelValue2 = [coverageData pixelValueWithUnsignedShortValues:pixelValues andWidth:width andX:x andY:y];
            [GPKGTestUtils assertEqualIntWithValue:pixelValue andValue2:pixelValue2];
            
            // Test getting the coverage data value
            NSDecimalNumber * value = [coverageData valueWithGriddedTile:griddedTile andPixelValue:pixelValue];
            GPKGGriddedCoverage * griddedCoverage = [coverageData griddedCoverage];
            if(coverageDataValues != nil){
                [GPKGTestUtils assertEqualIntWithValue:[coverageDataValues tilePixelAsUnsignedShortWithY:y andX:x] andValue2:pixelValue];
                [GPKGTestUtils assertEqualIntWithValue:[coverageDataValues tilePixelFlatAsUnsignedShortWithWidth:width andY:y andX:x] andValue2:pixelValue];
            }
            if (griddedCoverage.dataNull != nil && pixelValue == [griddedCoverage.dataNull unsignedShortValue]) {
                [GPKGTestUtils assertNil:value];
            } else {
                [GPKGTestUtils assertEqualDoubleWithValue:(pixelValue * [griddedTile scaleOrDefault] + [griddedTile offsetOrDefault]) * [griddedCoverage scaleOrDefault] + [griddedCoverage offsetOrDefault]
                                                andValue2:[value doubleValue] andDelta:.000001];
            }
        }
    }
    
    // Test the individually built list of pixel values vs the full returned array
    [GPKGTestUtils assertEqualIntWithValue:(int)pixelValuesList.count andValue2:pixelCount];
    for (int i = 0; i < pixelValuesList.count; i++) {
        [GPKGTestUtils assertEqualIntWithValue:[((NSNumber *)[pixelValuesList objectAtIndex:i]) unsignedShortValue] andValue2:pixelValues[i]];
    }
    
    free(pixelValues);
    
    GPKGTileMatrix * tileMatrix = [coverageData.tileDao tileMatrixWithZoomLevel:[tileRow zoomLevel]];
    
    double xDistance = [tileMatrixSet.maxX doubleValue] - [tileMatrixSet.minX doubleValue];
    double xDistance2 = [tileMatrix.matrixWidth intValue] * [tileMatrix.tileWidth intValue] * [tileMatrix.pixelXSize doubleValue];
    [GPKGTestUtils assertEqualDoubleWithValue:xDistance andValue2:xDistance2 andDelta:.00000001];
    double yDistance = [tileMatrixSet.maxY doubleValue] - [tileMatrixSet.minY doubleValue];
    double yDistance2 = [tileMatrix.matrixHeight intValue] * [tileMatrix.tileHeight intValue] * [tileMatrix.pixelYSize doubleValue];
    [GPKGTestUtils assertEqualDoubleWithValue:yDistance andValue2:yDistance2 andDelta:.00000001];
    
    GPKGBoundingBox * boundingBox = [GPKGTileBoundingBoxUtils boundingBoxWithTotalBoundingBox:[tileMatrixSet boundingBox] andTileMatrix:tileMatrix andTileColumn:[tileRow tileColumn] andTileRow:[tileRow tileRow]];
    GPKGCoverageDataResults * coverageDataResults = [coverageData valuesWithBoundingBox:boundingBox];
    if(coverageDataValues != nil){
        [GPKGTestUtils assertEqualIntWithValue:[coverageDataValues height] andValue2:[coverageDataResults height]];
        [GPKGTestUtils assertEqualIntWithValue:[coverageDataValues width] andValue2:[coverageDataResults width]];
        [GPKGTestUtils assertEqualIntWithValue:[coverageDataValues count] andValue2:[coverageDataResults height] * [coverageDataResults width]];
        for (int y = 0; y < [coverageDataResults height]; y++) {
            for (int x = 0; x < [coverageDataResults width]; x++) {
                switch(algorithm) {
                    case GPKG_CDA_BICUBIC:
                        {
                            // Don't test the edges
                            if (y > 1
                                && y < [coverageDataValues height] - 2
                                && x > 1
                                && x < [coverageDataValues width] - 2) {
                                if (!allowNils) {
                                    // No nils allowed, check for equality
                                    [GPKGTestUtils assertEqualDecimalNumberWithValue:[coverageDataValues valueWithY:y andX:x] andValue2:[coverageDataResults valueAtRow:y andColumn:x] andDelta:.000001];
                                } else {
                                    // Verify there is nil neighbor value
                                    NSDecimalNumber * value1 = [coverageDataValues valueWithY:y andX:x];
                                    NSDecimalNumber * value2 = [coverageDataResults valueAtRow:y andColumn:x];
                                    if(value1 == nil ? value2 != nil : ![GPKGTestUtils equalDoubleWithValue:[value1 doubleValue] andValue2:[value2 doubleValue] andDelta:.000001]){
                                        BOOL nilValue = NO;
                                        for (int yLocation = y - 2; !nilValue && yLocation <= y + 2; yLocation++) {
                                            for (int xLocation = x - 2; xLocation <= x + 2; xLocation++) {
                                                if ([coverageDataValues valueWithY:yLocation andX:xLocation] == nil) {
                                                    nilValue = YES;
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
                    case GPKG_CDA_BILINEAR:
                        {
                            // Don't test the edges
                            if (y > 0
                                && y < [coverageDataValues height] - 1
                                && x > 0
                                && x < [coverageDataValues width] - 1) {
                                if (!allowNils) {
                                    // No nils allowed, check for equality
                                    [GPKGTestUtils assertEqualDecimalNumberWithValue:[coverageDataValues valueWithY:y andX:x] andValue2:[coverageDataResults valueAtRow:y andColumn:x] andDelta:.000001];
                                } else {
                                    // Verify there is nil neighbor value
                                    NSDecimalNumber * value1 = [coverageDataValues valueWithY:y andX:x];
                                    NSDecimalNumber * value2 = [coverageDataResults valueAtRow:y andColumn:x];
                                    if(value1 == nil ? value2 != nil : ![GPKGTestUtils equalDoubleWithValue:[value1 doubleValue] andValue2:[value2 doubleValue] andDelta:.000001]){
                                        BOOL nilValue = NO;
                                        for (int yLocation = y - 1; !nilValue && yLocation <= y + 1; yLocation++) {
                                            for (int xLocation = x - 1; xLocation <= x + 1; xLocation++) {
                                                if ([coverageDataValues valueWithY:yLocation andX:xLocation] == nil) {
                                                    nilValue = YES;
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
                    case GPKG_CDA_NEAREST_NEIGHBOR:
                        {
                            if (!allowNils) {
                                [GPKGTestUtils assertEqualDecimalNumberWithValue:[coverageDataValues valueWithY:y andX:x] andValue2:[coverageDataResults valueAtRow:y andColumn:x] andDelta:.000001];
                            } else {
                                NSDecimalNumber * value1 = [coverageDataValues valueWithY:y andX:x];
                                NSDecimalNumber * value2 = [coverageDataResults valueAtRow:y andColumn:x];
                                if(value1 == nil ? value2 != nil : ![GPKGTestUtils equalDoubleWithValue:[value1 doubleValue] andValue2:[value2 doubleValue] andDelta:.000001]){
                                    // Find a matching neighbor
                                    BOOL nonNil = NO;
                                    BOOL match = NO;
                                    for (int yLocation = MAX(0, y - 1); !match && yLocation <= y + 1 && yLocation < [coverageDataValues height]; yLocation++) {
                                        for (int xLocation = MAX(0, x - 1); xLocation <= x + 1 && xLocation < [coverageDataValues width]; xLocation++) {
                                            NSDecimalNumber * value = [coverageDataValues valueWithY:yLocation andX:xLocation];
                                            if (value != nil) {
                                                nonNil = YES;
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

@end
