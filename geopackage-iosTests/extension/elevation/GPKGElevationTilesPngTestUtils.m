//
//  GPKGElevationTilesPngTestUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTilesPngTestUtils.h"
#import "GPKGElevationTilesPng.h"
#import "GPKGProjectionFactory.h"
#import "GPKGTestUtils.h"
#import "GPKGUtils.h"
#import "GPKGProjectionConstants.h"
#import "GPKGProjectionTransform.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGElevationTilesPngTestUtils

+(void) testElevationsWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGElevationTileValues *) elevationTileValues andAlgorithm: (enum GPKGElevationTilesAlgorithm) algorithm andAllowNils: (BOOL) allowNils{

    // Verify the elevation shows up as an elevation table and not a tile table
    NSArray * tilesTables = [geoPackage getTileTables];
    NSArray * elevationTables = [GPKGElevationTilesPng tablesForGeoPackage:geoPackage];
    [GPKGTestUtils assertTrue:elevationTables.count > 0];
    for (NSString * tilesTable in tilesTables) {
        [GPKGTestUtils assertFalse:[elevationTables containsObject:tilesTable]];
    }
    
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    [GPKGTestUtils assertTrue:[dao tableExists]];
    
    for(NSString * elevationTable in elevationTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:elevationTable];
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
        [GPKGTestUtils assertEqualIntWithValue:GPKG_CDT_ELEVATION_TILES andValue2:[contents getContentsDataType]];
        [GPKGTestUtils assertEqualWithValue:GPKG_CDT_ELEVATION_TILES_NAME andValue2:contents.dataType];
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
        GPKGElevationTilesPng * elevationTiles = [[GPKGElevationTilesPng alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
        [GPKGTestUtils assertTrue:[elevationTiles has]];
        [elevationTiles setAlgorithm:algorithm];

        // Test the 3 extension rows
        GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
        
        GPKGExtensions * griddedCoverageExtension = [extensionsDao queryByExtension:elevationTiles.extensionName andTable:GPKG_EGC_TABLE_NAME andColumnName:nil];
        [GPKGTestUtils assertNotNil:griddedCoverageExtension];
        [GPKGTestUtils assertEqualWithValue:GPKG_EGC_TABLE_NAME andValue2:griddedCoverageExtension.tableName];
        [GPKGTestUtils assertNil:griddedCoverageExtension.columnName];
        [GPKGTestUtils assertEqualWithValue:elevationTiles.extensionName andValue2:griddedCoverageExtension.extensionName];
        [GPKGTestUtils assertEqualWithValue:elevationTiles.definition andValue2:griddedCoverageExtension.definition];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_EST_READ_WRITE andValue2:[griddedCoverageExtension getExtensionScopeType]];
        
        GPKGExtensions * griddedTileExtension = [extensionsDao queryByExtension:elevationTiles.extensionName andTable:GPKG_EGT_TABLE_NAME andColumnName:nil];
        [GPKGTestUtils assertNotNil:griddedTileExtension];
        [GPKGTestUtils assertEqualWithValue:GPKG_EGT_TABLE_NAME andValue2:griddedTileExtension.tableName];
        [GPKGTestUtils assertNil:griddedTileExtension.columnName];
        [GPKGTestUtils assertEqualWithValue:elevationTiles.extensionName andValue2:griddedTileExtension.extensionName];
        [GPKGTestUtils assertEqualWithValue:elevationTiles.definition andValue2:griddedTileExtension.definition];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_EST_READ_WRITE andValue2:[griddedTileExtension getExtensionScopeType]];
        
        GPKGExtensions * tileTableExtension = [extensionsDao queryByExtension:elevationTiles.extensionName andTable:tileMatrixSet.tableName andColumnName:GPKG_TT_COLUMN_TILE_DATA];
        [GPKGTestUtils assertNotNil:tileTableExtension];
        [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:tileTableExtension.tableName];
        [GPKGTestUtils assertEqualWithValue:GPKG_TT_COLUMN_TILE_DATA andValue2:tileTableExtension.columnName];
        [GPKGTestUtils assertEqualWithValue:elevationTiles.extensionName andValue2:tileTableExtension.extensionName];
        [GPKGTestUtils assertEqualWithValue:elevationTiles.definition andValue2:tileTableExtension.definition];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_EST_READ_WRITE andValue2:[tileTableExtension getExtensionScopeType]];
        
        GPKGGriddedCoverageDao * griddedCoverageDao = [geoPackage getGriddedCoverageDao];
        
        // Test the Gridded Coverage
        GPKGGriddedCoverage * griddedCoverage = [elevationTiles griddedCoverage];
        [GPKGTestUtils assertNotNil:griddedCoverage];
        [GPKGTestUtils assertTrue:[griddedCoverage.id intValue] >= 0];
        [GPKGTestUtils assertNotNil:griddedCoverage.tileMatrixSetName];
        [GPKGTestUtils assertNotNil:[griddedCoverageDao getTileMatrixSet:griddedCoverage]];
        [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:griddedCoverage.tileMatrixSetName];
        [GPKGTestUtils assertEqualIntWithValue:GPKG_GCDT_INTEGER andValue2:[griddedCoverage getGriddedCoverageDataType]];
        [GPKGTestUtils assertTrue:[griddedCoverage.scale doubleValue] >= 0];
        [GPKGTestUtils assertTrue:[griddedCoverage.offset doubleValue] >= 0];
        [GPKGTestUtils assertTrue:[griddedCoverage.precision doubleValue] >= 0];
        
        // Test the Gridded Tile
        GPKGResultSet * griddedTiles = [elevationTiles griddedTile];
        [GPKGTestUtils assertNotNil:griddedTiles];
        [GPKGTestUtils assertTrue:griddedTiles.count > 0];
        while([griddedTiles moveToNext]){
            GPKGGriddedTile * griddedTile = [elevationTiles griddedTileWithResultSet:griddedTiles];
            GPKGTileRow * tileRow = (GPKGTileRow *)[tileDao queryForIdObject:griddedTile.tableId];
            [self testTileRowWithGeoPackage:geoPackage andValues:elevationTileValues andElevationTiles:elevationTiles andTileMatrixSet:tileMatrixSet andGriddedTile:griddedTile andTileRow:tileRow andAlgorithm:algorithm andAllowNils:allowNils];
        }
        [griddedTiles close];
        
        GPKGResultSet * tileResultSet = [tileDao queryForAll];
        [GPKGTestUtils assertNotNil:tileResultSet];
        [GPKGTestUtils assertTrue:tileResultSet.count > 0];
        while ([tileResultSet moveToNext]) {
            GPKGTileRow * tileRow = [tileDao getTileRow:tileResultSet];
            GPKGGriddedTile * griddedTile = [elevationTiles griddedTileWithTileId:[[tileRow getId] intValue]];
            [self testTileRowWithGeoPackage:geoPackage andValues:elevationTileValues andElevationTiles:elevationTiles andTileMatrixSet:tileMatrixSet andGriddedTile:griddedTile andTileRow:tileRow andAlgorithm:algorithm andAllowNils:allowNils];
        }
        [tileResultSet close];
        
        // Perform elevation query tests
        [self testElevationQueriesWithGeoPackage:geoPackage andElevationTiles:elevationTiles andTileMatrixSet:tileMatrixSet andAlgorithm:algorithm andAllowNils:allowNils];
    }
}

/**
 * Perform tests on the tile row
 *
 * @param geoPackage
 * @param elevationTileValues
 * @param elevationTiles
 * @param tileMatrixSet
 * @param griddedTile
 * @param tileRow
 * @param algorithm
 * @param allowNils
 */
+(void) testTileRowWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGElevationTileValues *) elevationTileValues andElevationTiles: (GPKGElevationTilesPng *) elevationTiles andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andGriddedTile: (GPKGGriddedTile *) griddedTile andTileRow: (GPKGTileRow *) tileRow andAlgorithm: (enum GPKGElevationTilesAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    
    GPKGGriddedTileDao * griddedTileDao = [geoPackage getGriddedTileDao];
    
    [GPKGTestUtils assertNotNil:griddedTile];
    [GPKGTestUtils assertTrue:[griddedTile.id intValue] >= 0];
    [GPKGTestUtils assertNotNil:[griddedTileDao getContents:griddedTile]];
    [GPKGTestUtils assertEqualWithValue:tileMatrixSet.tableName andValue2:griddedTile.tableName];
    NSNumber * tableId = griddedTile.tableId;
    [GPKGTestUtils assertTrue:[tableId intValue] >= 0];
    [GPKGTestUtils assertTrue:[griddedTile getScaleOrDefault] >= 0];
    [GPKGTestUtils assertTrue:[griddedTile getOffsetOrDefault] >= 0];
    [GPKGTestUtils assertNotNil:tileRow];
    
    NSData * tileData = [tileRow getTileData];
    [GPKGTestUtils assertTrue:tileData.length > 0];
    UIImage * image = [tileRow getTileDataImage];
    
    int width = (int) image.size.width;
    int height = (int) image.size.height;
    int pixelCount = width * height;
    
    // Get all the pixel values of the image
    unsigned short * pixelValues = [elevationTiles pixelValuesWithImage:image];
    if (elevationTileValues != nil) {
        for (int i = 0; i < pixelCount; i++) {
            [GPKGTestUtils assertEqualIntWithValue:[elevationTileValues tilePixelFlatAsUnsignedShortWithIndex:i] andValue2:pixelValues[i]];
        }
    }
    
    // Get each individual image pixel value
    NSMutableArray * pixelValuesList = [[NSMutableArray alloc] init];
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            unsigned short pixelValue = [elevationTiles pixelValueWithImage:image andX:x andY:y];
            [pixelValuesList addObject:[NSNumber numberWithUnsignedShort:pixelValue]];
            
            // Test getting the pixel value from the pixel values array
            unsigned short pixelValue2 = [elevationTiles pixelValueWithUnsignedShortValues:pixelValues andWidth:width andX:x andY:y];
            [GPKGTestUtils assertEqualIntWithValue:pixelValue andValue2:pixelValue2];
            
            // Test getting the elevation value
            NSDecimalNumber * elevationValue = [elevationTiles elevationValueWithGriddedTile:griddedTile andPixelValue:pixelValue];
            GPKGGriddedCoverage * griddedCoverage = [elevationTiles griddedCoverage];
            if(elevationTileValues != nil){
                [GPKGTestUtils assertEqualIntWithValue:[elevationTileValues tilePixelAsUnsignedShortWithY:y andX:x] andValue2:pixelValue];
                [GPKGTestUtils assertEqualIntWithValue:[elevationTileValues tilePixelFlatAsUnsignedShortWithWidth:width andY:y andX:x] andValue2:pixelValue];
            }
            if (griddedCoverage.dataNull != nil && pixelValue == [griddedCoverage.dataNull unsignedShortValue]) {
                [GPKGTestUtils assertNil:elevationValue];
            } else {
                [GPKGTestUtils assertEqualDoubleWithValue:(pixelValue * [griddedTile getScaleOrDefault] + [griddedTile getOffsetOrDefault]) * [griddedCoverage getScaleOrDefault] + [griddedCoverage getOffsetOrDefault]
                                                andValue2:[elevationValue doubleValue] andDelta:.000001];
            }
        }
    }
    
    // Test the individually built list of pixel values vs the full returned array
    [GPKGTestUtils assertEqualIntWithValue:(int)pixelValuesList.count andValue2:pixelCount];
    for (int i = 0; i < pixelValuesList.count; i++) {
        [GPKGTestUtils assertEqualIntWithValue:[((NSNumber *)[pixelValuesList objectAtIndex:i]) unsignedShortValue] andValue2:pixelValues[i]];
    }
    
    free(pixelValues);
    
    GPKGTileMatrix * tileMatrix = [elevationTiles.tileDao getTileMatrixWithZoomLevel:[tileRow getZoomLevel]];
    GPKGBoundingBox * boundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:[tileMatrixSet getBoundingBox] andTileMatrix:tileMatrix andTileColumn:[tileRow getTileColumn] andTileRow:[tileRow getTileRow]];
    GPKGElevationTileResults * elevationTileResults = [elevationTiles elevationsWithBoundingBox:boundingBox];
    if(elevationTileValues != nil){
        [GPKGTestUtils assertEqualIntWithValue:[elevationTileValues height] andValue2:[elevationTileResults height]];
        [GPKGTestUtils assertEqualIntWithValue:[elevationTileValues width] andValue2:[elevationTileResults width]];
        [GPKGTestUtils assertEqualIntWithValue:[elevationTileValues count] andValue2:[elevationTileResults height] * [elevationTileResults width]];
        for (int y = 0; y < [elevationTileResults height]; y++) {
            for (int x = 0; x < [elevationTileResults width]; x++) {
                switch(algorithm) {
                    case GPKG_ETA_BICUBIC:
                        {
                            // Don't test the edges
                            if (y > 1
                                && y < [elevationTileValues height] - 2
                                && x > 1
                                && x < [elevationTileValues width] - 2) {
                                if (!allowNils) {
                                    // No nils allowed, check for equality
                                    [GPKGTestUtils assertEqualDecimalNumberWithValue:[elevationTileValues tileElevationWithY:y andX:x] andValue2:[elevationTileResults elevationAtRow:y andColumn:x] andDelta:.000001];
                                } else {
                                    // Verify there is nil neighbor value
                                    NSDecimalNumber * value1 = [elevationTileValues tileElevationWithY:y andX:x];
                                    NSDecimalNumber * value2 = [elevationTileResults elevationAtRow:y andColumn:x];
                                    if(value1 == nil ? value2 != nil : ![GPKGTestUtils equalDoubleWithValue:[value1 doubleValue] andValue2:[value2 doubleValue] andDelta:.000001]){
                                        BOOL nilValue = false;
                                        for (int yLocation = y - 2; !nilValue && yLocation <= y + 2; yLocation++) {
                                            for (int xLocation = x - 2; xLocation <= x + 2; xLocation++) {
                                                if ([elevationTileValues tileElevationWithY:yLocation andX:xLocation] == nil) {
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
                                && y < [elevationTileValues height] - 1
                                && x > 0
                                && x < [elevationTileValues width] - 1) {
                                if (!allowNils) {
                                    // No nils allowed, check for equality
                                    [GPKGTestUtils assertEqualDecimalNumberWithValue:[elevationTileValues tileElevationWithY:y andX:x] andValue2:[elevationTileResults elevationAtRow:y andColumn:x] andDelta:.000001];
                                } else {
                                    // Verify there is nil neighbor value
                                    NSDecimalNumber * value1 = [elevationTileValues tileElevationWithY:y andX:x];
                                    NSDecimalNumber * value2 = [elevationTileResults elevationAtRow:y andColumn:x];
                                    if(value1 == nil ? value2 != nil : ![GPKGTestUtils equalDoubleWithValue:[value1 doubleValue] andValue2:[value2 doubleValue] andDelta:.000001]){
                                        BOOL nilValue = false;
                                        for (int yLocation = y - 1; !nilValue && yLocation <= y + 1; yLocation++) {
                                            for (int xLocation = x - 1; xLocation <= x + 1; xLocation++) {
                                                if ([elevationTileValues tileElevationWithY:yLocation andX:xLocation] == nil) {
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
                                [GPKGTestUtils assertEqualDecimalNumberWithValue:[elevationTileValues tileElevationWithY:y andX:x] andValue2:[elevationTileResults elevationAtRow:y andColumn:x] andDelta:.000001];
                            } else {
                                NSDecimalNumber * value1 = [elevationTileValues tileElevationWithY:y andX:x];
                                NSDecimalNumber * value2 = [elevationTileResults elevationAtRow:y andColumn:x];
                                if(value1 == nil ? value2 != nil : ![GPKGTestUtils equalDoubleWithValue:[value1 doubleValue] andValue2:[value2 doubleValue] andDelta:.000001]){
                                    // Find a matching neighbor
                                    BOOL nonNil = false;
                                    BOOL match = false;
                                    for (int yLocation = MAX(0, y - 1); !match && yLocation <= y + 1 && yLocation < [elevationTileValues height]; yLocation++) {
                                        for (int xLocation = MAX(0, x - 1); xLocation <= x + 1 && xLocation < [elevationTileValues width]; xLocation++) {
                                            NSDecimalNumber * value = [elevationTileValues tileElevationWithY:yLocation andX:xLocation];
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
 * @param elevationTiles
 * @param tileMatrixSet
 * @param algorithm
 * @param allowNils
 */
+(void) testElevationQueriesWithGeoPackage: (GPKGGeoPackage *) geoPackage andElevationTiles: (GPKGElevationTilesPng *) elevationTiles andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andAlgorithm: (enum GPKGElevationTilesAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    
    // Determine an alternate projection
    GPKGBoundingBox * boundingBox = [tileMatrixSet getBoundingBox];
    GPKGSpatialReferenceSystemDao * srsDao = [geoPackage getSpatialReferenceSystemDao];
    NSNumber * srsId = tileMatrixSet.srsId;
    GPKGSpatialReferenceSystem * srs = [srsDao getOrCreateWithSrsId:srsId];
    
    NSNumber * epsg = srs.organizationCoordsysId;
    GPKGProjection * projection = [GPKGProjectionFactory getProjectionWithSrs:srs];
    int requestEpsg = -1;
    if ([epsg intValue] == PROJ_EPSG_WORLD_GEODETIC_SYSTEM) {
        requestEpsg = PROJ_EPSG_WEB_MERCATOR;
    } else {
        requestEpsg = PROJ_EPSG_WORLD_GEODETIC_SYSTEM;
    }
    GPKGProjection * requestProjection = [GPKGProjectionFactory getProjectionWithInt:requestEpsg];
    GPKGProjectionTransform * elevationToRequest = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToProjection:requestProjection];
    GPKGBoundingBox * projectedBoundingBox = [elevationToRequest transformWithBoundingBox:boundingBox];
    
    // Get a random coordinate
    double latDistance = [projectedBoundingBox.maxLatitude doubleValue] - [projectedBoundingBox.minLatitude doubleValue];
    double latitude = latDistance * .9 * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLatitude doubleValue] + (.05 * latDistance);
    double lonDistance = [projectedBoundingBox.maxLongitude doubleValue] - [projectedBoundingBox.minLongitude doubleValue];
    double longitude = lonDistance * .9 * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLongitude doubleValue] + (.05 * lonDistance);
    
    // Test getting the elevation of a single coordinate
    GPKGElevationTilesPng * elevationTiles2 = [[GPKGElevationTilesPng alloc] initWithGeoPackage:geoPackage andTileDao:[elevationTiles tileDao] andProjection:requestProjection];
    [elevationTiles2 setAlgorithm:algorithm];
    NSDecimalNumber * elevation = [elevationTiles2 elevationWithLatitude:latitude andLongitude:longitude];
    if (!allowNils) {
        [GPKGTestUtils assertNotNil:elevation];
    }
    
    // Build a random bounding box
    double minLatitude = ([projectedBoundingBox.maxLatitude doubleValue] - [projectedBoundingBox.minLatitude doubleValue]) * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLatitude doubleValue];
    double minLongitude = ([projectedBoundingBox.maxLongitude doubleValue] - [projectedBoundingBox.minLongitude doubleValue]) * [GPKGTestUtils randomDouble] + [projectedBoundingBox.minLongitude doubleValue];
    double maxLatitude = ([projectedBoundingBox.maxLatitude doubleValue] - minLatitude) * [GPKGTestUtils randomDouble] + minLatitude;
    double maxLongitude = ([projectedBoundingBox.maxLongitude doubleValue] - minLongitude) * [GPKGTestUtils randomDouble] + minLongitude;
    
    GPKGBoundingBox * requestBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMaxLongitudeDouble:maxLongitude andMinLatitudeDouble:minLatitude andMaxLatitudeDouble:maxLatitude];
    GPKGElevationTileResults * elevations = [elevationTiles2 elevationsWithBoundingBox:requestBoundingBox];
    [GPKGTestUtils assertNotNil:elevations];
    [GPKGTestUtils assertNotNil:[elevations elevations]];
    [GPKGTestUtils assertEqualIntWithValue:(int)((NSArray *)[[elevations elevations] objectAtIndex:0]).count andValue2:[elevations width]];
    [GPKGTestUtils assertEqualIntWithValue:(int)[elevations elevations].count andValue2:[elevations height]];
    [GPKGTestUtils assertNotNil:[elevations tileMatrix]];
    [GPKGTestUtils assertTrue:[elevations zoomLevel] >= 0];
    [GPKGTestUtils assertTrue:[elevations elevations].count > 0];
    [GPKGTestUtils assertTrue:((NSArray *)[[elevations elevations] objectAtIndex:0]).count > 0];
    for (int y = 0; y < [elevations height]; y++) {
        for (int x = 0; x < [elevations width]; x++) {
            NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[elevations elevations] objectAtIndex:y]];
            [GPKGTestUtils assertEqualDecimalNumberWithValue:elevation andValue2:[elevations elevationAtRow:y andColumn:x] andDelta:.000001];
        }
    }
    
    int specifiedWidth = 50;
    int specifiedHeight = 100;
    [elevationTiles2 setWidth:[NSNumber numberWithInt:specifiedWidth]];
    [elevationTiles2 setHeight:[NSNumber numberWithInt:specifiedHeight]];
    
    elevations = [elevationTiles2 elevationsWithBoundingBox:requestBoundingBox];
    [GPKGTestUtils assertNotNil:elevations];
    [GPKGTestUtils assertNotNil:[elevations elevations]];
    [GPKGTestUtils assertEqualIntWithValue:(int)((NSArray *)[[elevations elevations] objectAtIndex:0]).count andValue2:[elevations width]];
    [GPKGTestUtils assertEqualIntWithValue:(int)[elevations elevations].count andValue2:[elevations height]];
    [GPKGTestUtils assertNotNil:[elevations tileMatrix]];
    [GPKGTestUtils assertTrue:[elevations zoomLevel] >= 0];
    [GPKGTestUtils assertTrue:[elevations elevations].count > 0];
    [GPKGTestUtils assertTrue:((NSArray *)[[elevations elevations] objectAtIndex:0]).count > 0];
    [GPKGTestUtils assertEqualIntWithValue:specifiedHeight andValue2:[elevations height]];
    [GPKGTestUtils assertEqualIntWithValue:specifiedWidth andValue2:[elevations width]];
    for (int y = 0; y < specifiedHeight; y++) {
        for (int x = 0; x < specifiedWidth; x++) {
            NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[elevations elevations] objectAtIndex:y]];
            [GPKGTestUtils assertEqualDecimalNumberWithValue:elevation andValue2:[elevations elevationAtRow:y andColumn:x] andDelta:.000001];
        }
    }
    
    elevations = [elevationTiles2 elevationsUnboundedWithBoundingBox:requestBoundingBox];
    [GPKGTestUtils assertNotNil:elevations];
    [GPKGTestUtils assertNotNil:[elevations elevations]];
    [GPKGTestUtils assertEqualIntWithValue:(int)((NSArray *)[[elevations elevations] objectAtIndex:0]).count andValue2:[elevations width]];
    [GPKGTestUtils assertEqualIntWithValue:(int)[elevations elevations].count andValue2:[elevations height]];
    [GPKGTestUtils assertNotNil:[elevations tileMatrix]];
    [GPKGTestUtils assertTrue:[elevations zoomLevel] >= 0];
    [GPKGTestUtils assertTrue:[elevations elevations].count > 0];
    [GPKGTestUtils assertTrue:((NSArray *)[[elevations elevations] objectAtIndex:0]).count > 0];
    [GPKGTestUtils assertEqualIntWithValue:(int)((NSArray *)[[elevations elevations] objectAtIndex:0]).count andValue2:(int)((NSArray *)[[elevations elevations] objectAtIndex:[elevations elevations].count - 1]).count];
    for (int y = 0; y < [elevations height]; y++) {
        for (int x = 0; x < [elevations width]; x++) {
            NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[elevations elevations] objectAtIndex:y]];
            [GPKGTestUtils assertEqualDecimalNumberWithValue:elevation andValue2:[elevations elevationAtRow:y andColumn:x] andDelta:.000001];
        }
    }
    
}

+(void) testRandomBoundingBoxWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGElevationTileValues *) elevationTileValues andAlgorithm: (enum GPKGElevationTilesAlgorithm) algorithm andAllowNils: (BOOL) allowNils{

    // Verify the elevation shows up as an elevation table and not a tile table
    NSArray * tilesTables = [geoPackage getTileTables];
    NSArray * elevationTables = [GPKGElevationTilesPng tablesForGeoPackage:geoPackage];
    [GPKGTestUtils assertTrue:elevationTables.count > 0];
    for (NSString * tilesTable in tilesTables) {
        [GPKGTestUtils assertFalse:[elevationTables containsObject:tilesTable]];
    }
    
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    [GPKGTestUtils assertTrue:[dao tableExists]];
    
    for(NSString * elevationTable in elevationTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:elevationTable];
        
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        GPKGElevationTilesPng * elevationTiles = [[GPKGElevationTilesPng alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
        [elevationTiles setAlgorithm:algorithm];
        
        int specifiedWidth = (int) ([GPKGTestUtils randomDouble] * 100.0) + 1;
        int specifiedHeight = (int) ([GPKGTestUtils randomDouble] * 100.0) + 1;
        [elevationTiles setWidth:[NSNumber numberWithInt:specifiedWidth]];
        [elevationTiles setHeight:[NSNumber numberWithInt:specifiedHeight]];
        
        GPKGBoundingBox * boundingBox = [tileMatrixSet getBoundingBox];
        
        // Build a random bounding box
        double minLatitude = ([boundingBox.maxLatitude doubleValue] - [boundingBox.minLatitude doubleValue]) * [GPKGTestUtils randomDouble] + [boundingBox.minLatitude doubleValue];
        double minLongitude = ([boundingBox.maxLongitude doubleValue] - [boundingBox.minLongitude doubleValue]) * [GPKGTestUtils randomDouble] + [boundingBox.minLongitude doubleValue];
        double maxLatitude = ([boundingBox.maxLatitude doubleValue] - minLatitude) * [GPKGTestUtils randomDouble] + minLatitude;
        double maxLongitude = ([boundingBox.maxLongitude doubleValue] - minLongitude) * [GPKGTestUtils randomDouble] + minLongitude;
        
        GPKGBoundingBox * requestBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMaxLongitudeDouble:maxLongitude andMinLatitudeDouble:minLatitude andMaxLatitudeDouble:maxLatitude];
        
        GPKGElevationTileResults * elevations = [elevationTiles elevationsWithBoundingBox:requestBoundingBox];
        
        [GPKGTestUtils assertNotNil:elevations];
        [GPKGTestUtils assertNotNil:[elevations elevations]];
        [GPKGTestUtils assertEqualIntWithValue:(int)((NSArray *)[[elevations elevations] objectAtIndex:0]).count andValue2:[elevations width]];
        [GPKGTestUtils assertEqualIntWithValue:(int)[elevations elevations].count andValue2:[elevations height]];
        [GPKGTestUtils assertNotNil:[elevations tileMatrix]];
        [GPKGTestUtils assertTrue:[elevations zoomLevel] >= 0];
        [GPKGTestUtils assertTrue:[elevations elevations].count > 0];
        [GPKGTestUtils assertTrue:((NSArray *)[[elevations elevations] objectAtIndex:0]).count > 0];
        [GPKGTestUtils assertEqualIntWithValue:specifiedHeight andValue2:[elevations height]];
        [GPKGTestUtils assertEqualIntWithValue:specifiedWidth andValue2:[elevations width]];
        
        for (int y = 0; y < specifiedHeight; y++) {
            BOOL nonNilFound = false;
            BOOL secondNilsFound = false;
            for (int x = 0; x < specifiedWidth; x++) {
                NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[elevations elevations] objectAtIndex:y]];
                [GPKGTestUtils assertEqualDecimalNumberWithValue:elevation andValue2:[elevations elevationAtRow:y andColumn:x] andDelta:.000001];
                if (!allowNils) {
                    if ([elevations elevationAtRow:y andColumn:x] != nil) {
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
                NSDecimalNumber * elevation = (NSDecimalNumber *)[GPKGUtils objectAtIndex:x inArray:(NSArray *)[[elevations elevations] objectAtIndex:y]];
                [GPKGTestUtils assertEqualDecimalNumberWithValue:elevation andValue2:[elevations elevationAtRow:y andColumn:x] andDelta:.000001];
                if (!allowNils) {
                    if ([elevations elevationAtRow:y andColumn:x] != nil) {
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

+(NSDecimalNumber *) elevationWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGElevationTilesAlgorithm) algorithm andLatitude: (double) latitude andLongitude: (double) longitude andEpsg: (int) epsg{
    
    NSDecimalNumber * elevation = nil;
    
    NSArray * elevationTables = [GPKGElevationTilesPng tablesForGeoPackage:geoPackage];
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    
    for(NSString * elevationTable in elevationTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:elevationTable];
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        
        GPKGProjection * requestProjection = [GPKGProjectionFactory  getProjectionWithInt:epsg];
        
        // Test getting the elevation of a single coordinate
        GPKGElevationTilesPng * elevationTiles = [[GPKGElevationTilesPng alloc] initWithGeoPackage:geoPackage andTileDao:tileDao andProjection:requestProjection];
        [elevationTiles setAlgorithm:algorithm];
        elevation = [elevationTiles elevationWithLatitude:latitude andLongitude:longitude];
    }
    
    return elevation;
}

+(GPKGElevationTileResults *) elevationsWithGeoPackage: (GPKGGeoPackage *) geoPackage andAlgorithm: (enum GPKGElevationTilesAlgorithm) algorithm andBoundingBox: (GPKGBoundingBox *) boundingBox andWidth: (int) width andHeight: (int) height andEpsg: (int) epsg{
    
    GPKGElevationTileResults * elevations = nil;
    
    NSArray * elevationTables = [GPKGElevationTilesPng tablesForGeoPackage:geoPackage];
    GPKGTileMatrixSetDao * dao = [geoPackage getTileMatrixSetDao];
    
    for(NSString * elevationTable in elevationTables){
        
        GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:elevationTable];
        GPKGTileDao * tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        
        GPKGProjection * requestProjection = [GPKGProjectionFactory getProjectionWithInt:epsg];
        
        // Test getting the elevation of a single coordinate
        GPKGElevationTilesPng * elevationTiles = [[GPKGElevationTilesPng alloc] initWithGeoPackage:geoPackage andTileDao:tileDao andProjection:requestProjection];
        [elevationTiles setAlgorithm:algorithm];
        [elevationTiles setWidth:[NSNumber numberWithInt:width]];
        [elevationTiles setHeight:[NSNumber numberWithInt:height]];
        elevations = [elevationTiles elevationsWithBoundingBox:boundingBox];
    }
    
    return elevations;
}

@end
