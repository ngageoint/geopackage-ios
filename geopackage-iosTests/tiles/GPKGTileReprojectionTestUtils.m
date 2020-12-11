//
//  GPKGTileReprojectionTestUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 11/19/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojectionTestUtils.h"
#import "GPKGTileReprojection.h"
#import "GPKGTestUtils.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGTileReprojectionTestUtils

+(void) testReprojectWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    for(NSString *table in [self randomTileTablesWithGeoPackage:geoPackage]){
        
        NSString *reprojectTable = [NSString stringWithFormat:@"%@_reproject", table];
        SFPProjection *projection = [geoPackage projectionOfTable:table];
        SFPProjection *reprojectProjection = [self alternateProjection:projection];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        int count = [tileDao count];
        NSDictionary<NSNumber *, NSNumber *> *counts = [self zoomCountsWithDao:tileDao];
        
        int tiles = [GPKGTileReprojection reprojectFromGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:tiles > 0];
        
        [GPKGTestUtils assertTrue:[projection isEqualToProjection:[geoPackage projectionOfTable:table]]];
        [GPKGTestUtils assertTrue:[reprojectProjection isEqualToProjection:[geoPackage projectionOfTable:reprojectTable]]];
        
        tileDao = [geoPackage tileDaoWithTableName:table];
        [self compareZoomCountsWithCount:count andCounts:counts andDao:tileDao];
        
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:reprojectTable];
        [self checkZoomCountsWithCount:count andCounts:counts andDao:reprojectTileDao andTiles:tiles];
        
        NSMutableArray<NSNumber *> *zoomLevels = [NSMutableArray arrayWithArray:tileDao.zoomLevels];
        NSArray<NSNumber *> *reprojectZoomLevels = reprojectTileDao.zoomLevels;
        [zoomLevels removeObjectsInArray:reprojectZoomLevels];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)zoomLevels.count];
        
        [self compareBoundingBox:[geoPackage boundingBoxOfTable:table inProjection:reprojectProjection] withBoundingBox:[geoPackage contentsBoundingBoxOfTable:reprojectTable] andDelta:.0000001];
    }
    
}

+(void) testReprojectReplaceWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    for(NSString *table in [self randomTileTablesWithGeoPackage:geoPackage]){
        
        SFPProjection *projection = [geoPackage projectionOfTable:table];
        SFPProjection *reprojectProjection = [self alternateProjection:projection];
        
        GPKGBoundingBox *boundingBox = [geoPackage boundingBoxOfTable:table inProjection:reprojectProjection];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        NSMutableArray<NSNumber *> *zoomLevels = [NSMutableArray arrayWithArray:tileDao.zoomLevels];
        int count = [tileDao count];
        NSDictionary<NSNumber *, NSNumber *> *counts = [self zoomCountsWithDao:tileDao];
        
        int tiles = [GPKGTileReprojection reprojectGeoPackage:geoPackage andTable:table inProjection:reprojectProjection];
        
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:tiles > 0];
        
        [GPKGTestUtils assertTrue:[reprojectProjection isEqualToProjection:[geoPackage projectionOfTable:table]]];
        
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:table];
        [self checkZoomCountsWithCount:count andCounts:counts andDao:reprojectTileDao andTiles:tiles];
        
        NSArray<NSNumber *> *reprojectZoomLevels = reprojectTileDao.zoomLevels;
        [zoomLevels removeObjectsInArray:reprojectZoomLevels];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)zoomLevels.count];
        
        [self compareBoundingBox:boundingBox withBoundingBox:[geoPackage contentsBoundingBoxOfTable:table] andDelta:.0000001];
    }
    
}

+(void) testReprojectZoomLevelsWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    for(NSString *table in [self randomTileTablesWithGeoPackage:geoPackage]){
        
        NSString *reprojectTable = [NSString stringWithFormat:@"%@_reproject", table];
        SFPProjection *projection = [geoPackage projectionOfTable:table];
        SFPProjection *reprojectProjection = [self alternateProjection:projection];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        NSDictionary<NSNumber *, NSNumber *> *counts = [self zoomCountsWithDao:tileDao];
        
        GPKGTileReprojection *tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        for(NSNumber *zoom in [counts allKeys]){
            
            int tiles = [tileReprojection reprojectWithZoom:[zoom intValue]];
            [GPKGTestUtils assertEqualBoolWithValue:[[counts objectForKey:zoom] intValue] > 0 andValue2:tiles > 0];
        }
        
        [GPKGTestUtils assertTrue:[projection isEqualToProjection:[geoPackage projectionOfTable:table]]];
        [GPKGTestUtils assertTrue:[reprojectProjection isEqualToProjection:[geoPackage projectionOfTable:reprojectTable]]];
        
        NSMutableArray<NSNumber *> *zoomLevels = [NSMutableArray arrayWithArray:tileDao.zoomLevels];
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:reprojectTable];
        NSArray<NSNumber *> *reprojectZoomLevels = reprojectTileDao.zoomLevels;
        [zoomLevels removeObjectsInArray:reprojectZoomLevels];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)zoomLevels.count];
        
        [self compareBoundingBox:[geoPackage boundingBoxOfTable:table inProjection:reprojectProjection] withBoundingBox:[geoPackage contentsBoundingBoxOfTable:reprojectTable] andDelta:.0000001];
    }
    
}

+(void) testReprojectZoomOverwriteWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    for(NSString *table in [self randomTileTablesWithGeoPackage:geoPackage]){
        
        NSString *reprojectTable = [NSString stringWithFormat:@"%@_reproject", table];
        SFPProjection *projection = [geoPackage projectionOfTable:table];
        SFPProjection *reprojectProjection = [self alternateProjection:projection];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        NSDictionary<NSNumber *, NSNumber *> *counts = [self zoomCountsWithDao:tileDao];
        
        NSNumber *zoom = [[counts allKeys] objectAtIndex:[GPKGTestUtils randomIntLessThan:(int)counts.count]];
        GPKGTileMatrix *tileMatrix = [tileDao tileMatrixWithZoomLevel:[zoom intValue]];
        
        GPKGTileReprojection *tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        int tiles = [tileReprojection reprojectWithZoom:[zoom intValue]];
        [GPKGTestUtils assertEqualBoolWithValue:[[counts objectForKey:zoom] intValue] > 0 andValue2:tiles > 0];
        
        tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        int tiles2 = [tileReprojection reprojectWithZoom:[zoom intValue]];
        [GPKGTestUtils assertEqualIntWithValue:tiles andValue2:tiles2];
        
        tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        tileReprojection.tileWidth = [NSNumber numberWithInt:[tileMatrix.tileWidth intValue] * 2];
        tileReprojection.tileHeight = [NSNumber numberWithInt:[tileMatrix.tileHeight intValue] * 2];
        
        @try {
            [tileReprojection reprojectWithZoom:[zoom intValue]];
            [GPKGTestUtils fail:@"Reprojection of existing zoom level with new geographic properties did not fail"];
        } @catch (NSException *exception) {
            // expected
        }
        
        [tileReprojection setOverwrite:YES];
        int tiles3 = [tileReprojection reprojectWithZoom:[zoom intValue]];
        [GPKGTestUtils assertEqualIntWithValue:tiles andValue2:tiles3];
        
        NSMutableArray<NSNumber *> *zoomLevels = [NSMutableArray arrayWithArray:tileDao.zoomLevels];
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:reprojectTable];
        NSArray<NSNumber *> *reprojectZoomLevels = reprojectTileDao.zoomLevels;
        [GPKGTestUtils assertTrue:[zoomLevels containsObject:zoom]];
        [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)reprojectZoomLevels.count];
        [GPKGTestUtils assertTrue:[reprojectZoomLevels containsObject:zoom]];
        
        GPKGTileMatrix *reprojectTileMatrix = [reprojectTileDao tileMatrixWithZoomLevel:[zoom intValue]];
        [GPKGTestUtils assertEqualWithValue:zoom andValue2:reprojectTileMatrix.zoomLevel];
        [GPKGTestUtils assertEqualWithValue:tileReprojection.tileWidth andValue2:reprojectTileMatrix.tileWidth];
        [GPKGTestUtils assertEqualWithValue:tileReprojection.tileHeight andValue2:reprojectTileMatrix.tileHeight];
        [GPKGTestUtils assertEqualWithValue:tileMatrix.matrixWidth andValue2:reprojectTileMatrix.matrixWidth];
        [GPKGTestUtils assertEqualWithValue:tileMatrix.matrixHeight andValue2:reprojectTileMatrix.matrixHeight];
        
        GPKGResultSet *tileResults = [reprojectTileDao queryForAll];
        [GPKGTestUtils assertTrue:[tileResults moveToNext]];
        GPKGTileRow *tileRow = [reprojectTileDao tileRow:tileResults];
        UIImage *tileImage = [tileRow tileDataImage];
        [GPKGTestUtils assertEqualDoubleWithValue:[tileReprojection.tileWidth doubleValue] andValue2:tileImage.size.width];
        [GPKGTestUtils assertEqualDoubleWithValue:[tileReprojection.tileHeight doubleValue] andValue2:tileImage.size.height];
        [tileResults close];
        
        [self compareBoundingBox:[geoPackage boundingBoxOfTable:table inProjection:reprojectProjection] withBoundingBox:[geoPackage contentsBoundingBoxOfTable:reprojectTable] andDelta:.0000001];
    }
    
}

+(void) testReprojectOverwriteWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    for(NSString *table in [self randomTileTablesWithGeoPackage:geoPackage]){
        
        NSString *reprojectTable = [NSString stringWithFormat:@"%@_reproject", table];
        SFPProjection *projection = [geoPackage projectionOfTable:table];
        SFPProjection *reprojectProjection = [self alternateProjection:projection];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        int count = [tileDao count];
        NSDictionary<NSNumber *, NSNumber *> *counts = [self zoomCountsWithDao:tileDao];
        
        int tiles = [GPKGTileReprojection reprojectFromGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:tiles > 0];
        
        [GPKGTestUtils assertTrue:[projection isEqualToProjection:[geoPackage projectionOfTable:table]]];
        [GPKGTestUtils assertTrue:[reprojectProjection isEqualToProjection:[geoPackage projectionOfTable:reprojectTable]]];
        
        tileDao = [geoPackage tileDaoWithTableName:table];
        [self compareZoomCountsWithCount:count andCounts:counts andDao:tileDao];
        
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:reprojectTable];
        [self checkZoomCountsWithCount:count andCounts:counts andDao:reprojectTileDao andTiles:tiles];
        
        int tiles2 = [GPKGTileReprojection reprojectFromGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        [GPKGTestUtils assertEqualIntWithValue:tiles andValue2:tiles2];
        
        GPKGTileMatrixSet *tileMatrixSet = reprojectTileDao.tileMatrixSet;
        NSDecimalNumber *multiplier = [[NSDecimalNumber alloc] initWithDouble:0.5];
        [tileMatrixSet setMinX:[tileMatrixSet.minX decimalNumberByMultiplyingBy:multiplier]];
        [tileMatrixSet setMinY:[tileMatrixSet.minY decimalNumberByMultiplyingBy:multiplier]];
        [tileMatrixSet setMaxX:[tileMatrixSet.maxX decimalNumberByMultiplyingBy:multiplier]];
        [tileMatrixSet setMaxY:[tileMatrixSet.maxY decimalNumberByMultiplyingBy:multiplier]];
        [[reprojectTileDao tileMatrixSetDao] update:tileMatrixSet];
        
        GPKGTileReprojection *tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        @try {
            [tileReprojection reproject];
            [GPKGTestUtils fail:@"Reprojection of existing table with new geographic properties did not fail"];
        } @catch (NSException *exception) {
            // expected
        }
        
        [tileReprojection setOverwrite:YES];
        [tileReprojection reproject];
        
        [tileMatrixSet setMinX:[tileMatrixSet.minX decimalNumberByDividingBy:multiplier]];
        [tileMatrixSet setMinY:[tileMatrixSet.minY decimalNumberByDividingBy:multiplier]];
        [tileMatrixSet setMaxX:[tileMatrixSet.maxX decimalNumberByDividingBy:multiplier]];
        [tileMatrixSet setMaxY:[tileMatrixSet.maxY decimalNumberByDividingBy:multiplier]];
        [[reprojectTileDao tileMatrixSetDao] update:tileMatrixSet];
        
        tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        @try {
            [tileReprojection reproject];
            [GPKGTestUtils fail:@"Reprojection of existing table with new geographic properties did not fail"];
        } @catch (NSException *exception) {
            // expected
        }
        
        [tileReprojection setOverwrite:YES];
        int tiles3 = [tileReprojection reproject];
        [GPKGTestUtils assertEqualIntWithValue:tiles andValue2:tiles3];
        
        NSMutableArray<NSNumber *> *zoomLevels = [NSMutableArray arrayWithArray:tileDao.zoomLevels];
        NSArray<NSNumber *> *reprojectZoomLevels = reprojectTileDao.zoomLevels;
        [zoomLevels removeObjectsInArray:reprojectZoomLevels];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)zoomLevels.count];
        
        [self compareBoundingBox:[geoPackage boundingBoxOfTable:table inProjection:reprojectProjection] withBoundingBox:[geoPackage contentsBoundingBoxOfTable:reprojectTable] andDelta:.0000001];
    }
    
}

+(void) testReprojectToZoomWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    for(NSString *table in [self randomTileTablesWithGeoPackage:geoPackage]){
        
        NSString *reprojectTable = [NSString stringWithFormat:@"%@_reproject", table];
        SFPProjection *projection = [geoPackage projectionOfTable:table];
        SFPProjection *reprojectProjection = [self alternateProjection:projection];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        int count = [tileDao count];
        NSDictionary<NSNumber *, NSNumber *> *counts = [self zoomCountsWithDao:tileDao];
        
        GPKGTileReprojection *tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        NSMutableDictionary<NSNumber *, NSNumber *> *zoomMap = [NSMutableDictionary dictionary];
        
        NSArray<NSNumber *> *zoomLevels = tileDao.zoomLevels;
        NSNumber *fromZoom = [zoomLevels objectAtIndex:0];
        int toZoom = MAX([fromZoom intValue] - 2, 0);
        [tileReprojection setToZoom:toZoom forZoom:[fromZoom intValue]];
        [zoomMap setObject:[NSNumber numberWithInt:toZoom] forKey:fromZoom];
        
        for(int i = 1; i < zoomLevels.count; i++){
            fromZoom = [zoomLevels objectAtIndex:i];
            toZoom += 2;
            [tileReprojection setToZoom:toZoom forZoom:[fromZoom intValue]];
            [zoomMap setObject:[NSNumber numberWithInt:toZoom] forKey:fromZoom];
        }
        
        int tiles = [tileReprojection reproject];
        
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:tiles > 0];
        
        [GPKGTestUtils assertTrue:[projection isEqualToProjection:[geoPackage projectionOfTable:table]]];
        [GPKGTestUtils assertTrue:[reprojectProjection isEqualToProjection:[geoPackage projectionOfTable:reprojectTable]]];
        
        tileDao = [geoPackage tileDaoWithTableName:table];
        [self compareZoomCountsWithCount:count andCounts:counts andDao:tileDao];
        
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:reprojectTable];
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:[reprojectTileDao count]];
        [GPKGTestUtils assertEqualIntWithValue:tiles andValue2:[reprojectTileDao count]];
        NSDictionary<NSNumber *, NSNumber *> *countsAfter = [self zoomCountsWithDao:reprojectTileDao];
        [GPKGTestUtils assertEqualIntWithValue:(int)counts.count andValue2:(int)countsAfter.count];
        for(NSNumber *zoomLevel in reprojectTileDao.zoomLevels){
            NSNumber *toZoomLevel = [zoomMap objectForKey:zoomLevel];
            [GPKGTestUtils assertEqualBoolWithValue:[[counts objectForKey:zoomLevel] intValue] > 0 andValue2:[[countsAfter objectForKey:toZoomLevel] intValue] > 0];
        }
        
        NSMutableArray<NSNumber *> *fromZoomLevels = [NSMutableArray arrayWithArray:tileDao.zoomLevels];
        NSMutableArray<NSNumber *> *reprojectZoomLevels = [NSMutableArray arrayWithArray:reprojectTileDao.zoomLevels];
        [GPKGTestUtils assertEqualIntWithValue:(int)fromZoomLevels.count andValue2:(int)reprojectZoomLevels.count];
        [fromZoomLevels removeObjectsInArray:[zoomMap allKeys]];
        [reprojectZoomLevels removeObjectsInArray:[zoomMap allValues]];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)fromZoomLevels.count];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)reprojectZoomLevels.count];
        
        [self compareBoundingBox:[geoPackage boundingBoxOfTable:table inProjection:reprojectProjection] withBoundingBox:[geoPackage contentsBoundingBoxOfTable:reprojectTable] andDelta:.0000001];
    }
    
}

+(void) testReprojectMatrixAndTileLengthsWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    for(NSString *table in [self randomTileTablesWithGeoPackage:geoPackage]){
        
        NSString *reprojectTable = [NSString stringWithFormat:@"%@_reproject", table];
        SFPProjection *projection = [geoPackage projectionOfTable:table];
        SFPProjection *reprojectProjection = [self alternateProjection:projection];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        int count = [tileDao count];
        NSDictionary<NSNumber *, NSNumber *> *counts = [self zoomCountsWithDao:tileDao];
        
        GPKGTileReprojection *tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        for(GPKGTileMatrix *tileMatrix in tileDao.tileMatrices){
            int zoom = [tileMatrix.zoomLevel intValue];
            [tileReprojection setMatrixWidth:[tileMatrix.matrixWidth intValue] * 2 forZoom:zoom];
            [tileReprojection setMatrixHeight:[tileMatrix.matrixHeight intValue] * 2 forZoom:zoom];
            [tileReprojection setTileWidth:[tileMatrix.tileWidth intValue] + zoom forZoom:zoom];
            [tileReprojection setTileHeight:[tileMatrix.tileHeight intValue] + zoom forZoom:zoom];
        }
        
        int tiles = [tileReprojection reproject];
        
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:tiles > 0];
        
        [GPKGTestUtils assertTrue:[projection isEqualToProjection:[geoPackage projectionOfTable:table]]];
        [GPKGTestUtils assertTrue:[reprojectProjection isEqualToProjection:[geoPackage projectionOfTable:reprojectTable]]];
        
        tileDao = [geoPackage tileDaoWithTableName:table];
        [self compareZoomCountsWithCount:count andCounts:counts andDao:tileDao];
        
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:reprojectTable];
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:[reprojectTileDao count]];
        [GPKGTestUtils assertEqualIntWithValue:tiles andValue2:[reprojectTileDao count]];
        NSDictionary<NSNumber *, NSNumber *> *countsAfter = [self zoomCountsWithDao:reprojectTileDao];
        [GPKGTestUtils assertEqualIntWithValue:(int)counts.count andValue2:(int)countsAfter.count];
        
        NSMutableArray<NSNumber *> *zoomLevels = [NSMutableArray arrayWithArray:tileDao.zoomLevels];
        [zoomLevels removeObjectsInArray:reprojectTileDao.zoomLevels];
        [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)zoomLevels.count];
        
        for(GPKGTileMatrix *reprojectTileMatrix in reprojectTileDao.tileMatrices){
            int zoom = [reprojectTileMatrix.zoomLevel intValue];
            GPKGTileMatrix *tileMatrix = [tileDao tileMatrixWithZoomLevel:zoom];
            [GPKGTestUtils assertEqualIntWithValue:[tileMatrix.matrixWidth intValue] * 2 andValue2:[reprojectTileMatrix.matrixWidth intValue]];
            [GPKGTestUtils assertEqualIntWithValue:[tileMatrix.matrixHeight intValue] * 2 andValue2:[reprojectTileMatrix.matrixHeight intValue]];
            [GPKGTestUtils assertEqualIntWithValue:[tileMatrix.tileWidth intValue] + zoom andValue2:[reprojectTileMatrix.tileWidth intValue]];
            [GPKGTestUtils assertEqualIntWithValue:[tileMatrix.tileHeight intValue] + zoom andValue2:[reprojectTileMatrix.tileHeight intValue]];
            
            GPKGResultSet *tileResults = [reprojectTileDao queryforTileWithZoomLevel:zoom];
            [GPKGTestUtils assertTrue:[tileResults moveToNext]];
            GPKGTileRow *tileRow = [reprojectTileDao tileRow:tileResults];
            UIImage *tileImage = [tileRow tileDataImage];
            [GPKGTestUtils assertEqualDoubleWithValue:[reprojectTileMatrix.tileWidth doubleValue] andValue2:tileImage.size.width];
            [GPKGTestUtils assertEqualDoubleWithValue:[reprojectTileMatrix.tileHeight doubleValue] andValue2:tileImage.size.height];
            [tileResults close];
            
            GPKGTileGrid *tileGrid = [tileDao queryForTileGridWithZoomLevel:zoom];
            GPKGTileGrid *reprojectTileGrid = [reprojectTileDao queryForTileGridWithZoomLevel:zoom];
            [GPKGTestUtils assertTrue:tileGrid.maxX < reprojectTileGrid.maxX];
            [GPKGTestUtils assertTrue:tileGrid.maxY < reprojectTileGrid.maxY];
        }
        
        [self compareBoundingBox:[geoPackage boundingBoxOfTable:table inProjection:reprojectProjection] withBoundingBox:[geoPackage contentsBoundingBoxOfTable:reprojectTable] andDelta:.0000001];
    }
    
}

+(void) testReprojectOptimizeWithGeoPackage: (GPKGGeoPackage *) geoPackage andWorld: (BOOL) world{
    
    for(NSString *table in [self randomTileTablesWithGeoPackage:geoPackage]){
        
        NSString *reprojectTable = [NSString stringWithFormat:@"%@_reproject", table];
        SFPProjection *projection = [geoPackage projectionOfTable:table];
        SFPProjection *reprojectProjection = [self alternateProjection:projection];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        int count = [tileDao count];
        NSDictionary<NSNumber *, NSNumber *> *counts = [self zoomCountsWithDao:tileDao];
        
        GPKGTileReprojection *tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        GPKGTileReprojectionOptimize *optimize = nil;
        BOOL webMercator = [reprojectProjection isEqualToAuthority:PROJ_AUTHORITY_EPSG andNumberCode:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
        if(webMercator){
            if(world){
                optimize = [GPKGTileReprojectionOptimize webMercatorWorld];
            }else{
                optimize = [GPKGTileReprojectionOptimize webMercator];
            }
        }else{
            if(world){
                optimize = [GPKGTileReprojectionOptimize platteCarreWorld];
            }else{
                optimize = [GPKGTileReprojectionOptimize platteCarre];
            }
        }
        [tileReprojection setOptimize:optimize];
        
        int tiles = [tileReprojection reproject];
        
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:tiles > 0];
        
        [GPKGTestUtils assertTrue:[projection isEqualToProjection:[geoPackage projectionOfTable:table]]];
        [GPKGTestUtils assertTrue:[reprojectProjection isEqualToProjection:[geoPackage projectionOfTable:reprojectTable]]];
        
        tileDao = [geoPackage tileDaoWithTableName:table];
        [self compareZoomCountsWithCount:count andCounts:counts andDao:tileDao];
        
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:reprojectTable];
        
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:[reprojectTileDao count]];
        [GPKGTestUtils assertEqualIntWithValue:tiles andValue2:[reprojectTileDao count]];
        NSDictionary<NSNumber *, NSNumber *> *countsAfter = [self zoomCountsWithDao:reprojectTileDao];
        [GPKGTestUtils assertEqualIntWithValue:(int)counts.count andValue2:(int)countsAfter.count];
        [GPKGTestUtils assertEqualIntWithValue:(int)tileDao.zoomLevels.count andValue2:(int)reprojectTileDao.zoomLevels.count];
        for(int i = 0; i < tileDao.zoomLevels.count; i++){
            NSNumber *zoomLevel = [tileDao.zoomLevels objectAtIndex:i];
            NSNumber *toZoomLevel = [reprojectTileDao.zoomLevels objectAtIndex:i];
            [GPKGTestUtils assertEqualBoolWithValue:[[counts objectForKey:zoomLevel] intValue] > 0 andValue2:[[countsAfter objectForKey:toZoomLevel] intValue] > 0];
        }
        
        for(NSNumber *zoomLevel in reprojectTileDao.zoomLevels){
            int zoom = [zoomLevel intValue];
            GPKGTileMatrix *tileMatrix = [reprojectTileDao tileMatrixWithZoomLevel:zoom];
            GPKGBoundingBox *boundingBox = [reprojectTileDao boundingBox];
            GPKGTileGrid *zoomTileGrid = [reprojectTileDao tileGridWithZoomLevel:zoom];
            GPKGTileGrid *tileGrid = [reprojectTileDao queryForTileGridWithZoomLevel:zoom];
            GPKGBoundingBox *tilesBoundingBox = [GPKGTileBoundingBoxUtils boundingBoxWithTotalBoundingBox:boundingBox andTileMatrix:tileMatrix andTileGrid:tileGrid];
            [GPKGTestUtils assertTrue:tileGrid.minX >= zoomTileGrid.minX];
            [GPKGTestUtils assertTrue:tileGrid.maxX <= zoomTileGrid.maxX];
            [GPKGTestUtils assertTrue:tileGrid.minY >= zoomTileGrid.minY];
            [GPKGTestUtils assertTrue:tileGrid.maxY <= zoomTileGrid.maxY];
            GPKGResultSet *tileResults = [reprojectTileDao queryforTileWithZoomLevel:zoom];
            int tileIndex = [GPKGTestUtils randomIntLessThan:tileResults.count];
            for(int i = 0; i <= tileIndex; i++){
                [GPKGTestUtils assertTrue:[tileResults moveToNext]];
            }
            GPKGTileRow *tile = [reprojectTileDao tileRow:tileResults];
            int tileColumn = [tile tileColumn];
            int tileRow = [tile tileRow];
            GPKGBoundingBox *tileBoundingBox = [GPKGTileBoundingBoxUtils boundingBoxWithTotalBoundingBox:boundingBox andTileMatrix:tileMatrix andTileColumn:tileColumn andTileRow:tileRow];
            [tileResults close];
            
            GPKGBoundingBox *optimizeBoundingBox = tileBoundingBox;
            GPKGTileGrid *optimizeTileGrid = nil;
            GPKGTileGrid *localTileGrid = nil;
            SFPProjection *projection = reprojectTileDao.projection;
            
            switch(optimize.type){
                case GPKG_TRO_WEB_MERCATOR:
                    {
                        SFPProjectionTransform *transform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:[SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR]];
                        if(![transform isSameProjection]){
                            optimizeBoundingBox = [optimizeBoundingBox transform:transform];
                        }
                        double midLongitude = [optimizeBoundingBox.minLongitude doubleValue] + ([optimizeBoundingBox longitudeRangeValue] / 2.0);
                        double midLatitude = [optimizeBoundingBox.minLatitude doubleValue] + ([optimizeBoundingBox latitudeRangeValue] / 2.0);
                        GPKGBoundingBox *optimizeBoundingBoxPoint = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:midLongitude andMinLatitudeDouble:midLatitude andMaxLongitudeDouble:midLongitude andMaxLatitudeDouble:midLatitude];
                        optimizeTileGrid = [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:optimizeBoundingBoxPoint andZoom:zoom];
                        localTileGrid = [GPKGTileBoundingBoxUtils tileGridWithTotalBoundingBox:boundingBox andMatrixWidth:[tileMatrix.matrixWidth intValue] andMatrixHeight:[tileMatrix.matrixHeight intValue] andBoundingBox:optimizeBoundingBoxPoint];
                        GPKGBoundingBox *webMercatorBoundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithTileGrid:optimizeTileGrid andZoom:zoom];
                        [self compareBoundingBox:optimizeBoundingBox withBoundingBox:webMercatorBoundingBox andTileMatrix:tileMatrix];
                        optimizeBoundingBox = webMercatorBoundingBox;
                        if(world){
                            GPKGTileGrid *worldTileGrid = [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:boundingBox andZoom:zoom];
                            [GPKGTestUtils assertEqualIntWithValue:zoomTileGrid.minX andValue2:worldTileGrid.minX];
                            [GPKGTestUtils assertEqualIntWithValue:zoomTileGrid.maxX andValue2:worldTileGrid.maxX];
                            [GPKGTestUtils assertEqualIntWithValue:zoomTileGrid.minY andValue2:worldTileGrid.minY];
                            [GPKGTestUtils assertEqualIntWithValue:zoomTileGrid.maxY andValue2:worldTileGrid.maxY];
                            GPKGTileGrid *worldTilesTileGrid = [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:tilesBoundingBox andZoom:zoom];
                            [GPKGTestUtils assertTrue:tileGrid.minX == worldTilesTileGrid.minX || tileGrid.minX - 1 == worldTilesTileGrid.minX];
                            [GPKGTestUtils assertTrue:tileGrid.maxX == worldTilesTileGrid.maxX || tileGrid.maxX + 1 == worldTilesTileGrid.maxX];
                            [GPKGTestUtils assertTrue:tileGrid.minY == worldTilesTileGrid.minY || tileGrid.minY - 1 == worldTilesTileGrid.minY];
                            [GPKGTestUtils assertTrue:tileGrid.maxY == worldTilesTileGrid.maxY || tileGrid.maxY + 1 == worldTilesTileGrid.maxY];
                        }
                        if(![transform isSameProjection]){
                            optimizeBoundingBox = [optimizeBoundingBox transform:transform];
                        }
                    }
                    break;
                case GPKG_TRO_PLATTE_CARRE:
                    {
                        SFPProjectionTransform *transform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:[SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
                        if(![transform isSameProjection]){
                            optimizeBoundingBox = [optimizeBoundingBox transform:transform];
                        }
                        double midLongitude = [optimizeBoundingBox.minLongitude doubleValue] + ([optimizeBoundingBox longitudeRangeValue] / 2.0);
                        double midLatitude = [optimizeBoundingBox.minLatitude doubleValue] + ([optimizeBoundingBox latitudeRangeValue] / 2.0);
                        GPKGBoundingBox *optimizeBoundingBoxPoint = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:midLongitude andMinLatitudeDouble:midLatitude andMaxLongitudeDouble:midLongitude andMaxLatitudeDouble:midLatitude];
                        optimizeTileGrid = [GPKGTileBoundingBoxUtils tileGridWithWgs84BoundingBox:optimizeBoundingBoxPoint andZoom:zoom];
                        localTileGrid = [GPKGTileBoundingBoxUtils tileGridWithTotalBoundingBox:boundingBox andMatrixWidth:[tileMatrix.matrixWidth intValue] andMatrixHeight:[tileMatrix.matrixHeight intValue] andBoundingBox:optimizeBoundingBoxPoint];
                        GPKGBoundingBox *wgs84BoundingBox = [GPKGTileBoundingBoxUtils wgs84BoundingBoxWithTileGrid:optimizeTileGrid andZoom:zoom];
                        [self compareBoundingBox:optimizeBoundingBox withBoundingBox:wgs84BoundingBox andTileMatrix:tileMatrix];
                        optimizeBoundingBox = wgs84BoundingBox;
                        if(world){
                            GPKGTileGrid *worldTileGrid = [GPKGTileBoundingBoxUtils tileGridWithWgs84BoundingBox:boundingBox andZoom:zoom];
                            [GPKGTestUtils assertEqualIntWithValue:zoomTileGrid.minX andValue2:worldTileGrid.minX];
                            [GPKGTestUtils assertEqualIntWithValue:zoomTileGrid.maxX andValue2:worldTileGrid.maxX];
                            [GPKGTestUtils assertEqualIntWithValue:zoomTileGrid.minY andValue2:worldTileGrid.minY];
                            [GPKGTestUtils assertEqualIntWithValue:zoomTileGrid.maxY andValue2:worldTileGrid.maxY];
                            GPKGTileGrid *worldTilesTileGrid = [GPKGTileBoundingBoxUtils tileGridWithWgs84BoundingBox:tilesBoundingBox andZoom:zoom];
                            [GPKGTestUtils assertTrue:tileGrid.minX == worldTilesTileGrid.minX || tileGrid.minX - 1 == worldTilesTileGrid.minX];
                            [GPKGTestUtils assertTrue:tileGrid.maxX == worldTilesTileGrid.maxX || tileGrid.maxX + 1 == worldTilesTileGrid.maxX];
                            [GPKGTestUtils assertTrue:tileGrid.minY == worldTilesTileGrid.minY || tileGrid.minY - 1 == worldTilesTileGrid.minY];
                            [GPKGTestUtils assertTrue:tileGrid.maxY == worldTilesTileGrid.maxY || tileGrid.maxY + 1 == worldTilesTileGrid.maxY];
                        }
                        if(![transform isSameProjection]){
                            optimizeBoundingBox = [optimizeBoundingBox transform:transform];
                        }
                    }
                    break;
                default:
                    [GPKGTestUtils fail:@"Unexpected optimize type"];
                    break;
            }
            
            [GPKGTestUtils assertNotNil:optimizeTileGrid];
            [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[optimizeTileGrid width]];
            [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[optimizeTileGrid height]];
            [GPKGTestUtils assertNotNil:localTileGrid];
            [GPKGTestUtils assertEqualIntWithValue:tileColumn andValue2:localTileGrid.minX];
            [GPKGTestUtils assertEqualIntWithValue:tileRow andValue2:localTileGrid.minY];
            [self compareBoundingBox:tileBoundingBox withBoundingBox:optimizeBoundingBox andTileMatrix:tileMatrix];
        }
        
        [self compareBoundingBox:[geoPackage boundingBoxOfTable:table inProjection:reprojectProjection] withBoundingBox:[geoPackage contentsBoundingBoxOfTable:reprojectTable] andDelta:.0000001];
   }
    
}

+(void) compareBoundingBox: (GPKGBoundingBox *) boundingBox1 withBoundingBox: (GPKGBoundingBox *) boundingBox2 andTileMatrix: (GPKGTileMatrix *) tileMatrix{
    double longitudeDelta = [tileMatrix.pixelXSize doubleValue];
    double latitudeDelta = [tileMatrix.pixelYSize doubleValue];
    [self compareBoundingBox:boundingBox1 withBoundingBox:boundingBox2 andLongitudeDelta:longitudeDelta andLatitudeDelta:latitudeDelta];
    
}

+(void) compareBoundingBox: (GPKGBoundingBox *) boundingBox1 withBoundingBox: (GPKGBoundingBox *) boundingBox2 andDelta: (double) delta{
    [self compareBoundingBox:boundingBox1 withBoundingBox:boundingBox2 andLongitudeDelta:delta andLatitudeDelta:delta];
}

+(void) compareBoundingBox: (GPKGBoundingBox *) boundingBox1 withBoundingBox: (GPKGBoundingBox *) boundingBox2 andLongitudeDelta: (double) longitudeDelta andLatitudeDelta: (double) latitudeDelta{
    [GPKGTestUtils assertEqualDoubleWithValue:[boundingBox1.minLongitude doubleValue] andValue2:[boundingBox2.minLongitude doubleValue] andDelta:longitudeDelta];
    [GPKGTestUtils assertEqualDoubleWithValue:[boundingBox1.minLatitude doubleValue] andValue2:[boundingBox2.minLatitude doubleValue] andDelta:latitudeDelta];
    [GPKGTestUtils assertEqualDoubleWithValue:[boundingBox1.maxLongitude doubleValue] andValue2:[boundingBox2.maxLongitude doubleValue] andDelta:longitudeDelta];
    [GPKGTestUtils assertEqualDoubleWithValue:[boundingBox1.maxLatitude doubleValue] andValue2:[boundingBox2.maxLatitude doubleValue] andDelta:latitudeDelta];
}

+(NSArray<NSString *> *) randomTileTablesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    NSArray<NSString *> *tileTables = nil;
    NSArray<NSString *> *allTileTables = [geoPackage tileTables];
    int count = (int) allTileTables.count;
    if(count <= 2){
        tileTables = allTileTables;
    }else{
        int index1 = [GPKGTestUtils randomIntLessThan:count];
        int index2 = [GPKGTestUtils randomIntLessThan:count];
        if(index1 == index2){
            if(++index2 >= count){
                index2 = 0;
            }
        }
        tileTables = [NSArray arrayWithObjects:[allTileTables objectAtIndex:index1], [allTileTables objectAtIndex:index2], nil];
    }
    return tileTables;
}

+(SFPProjection *) alternateProjection: (SFPProjection *) projection{
    SFPProjection *alternate = nil;
    if([projection isEqualToAuthority:PROJ_AUTHORITY_EPSG andNumberCode:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]]){
        alternate = [SFPProjectionFactory projectionWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    }else{
        alternate = [SFPProjectionFactory projectionWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    }
    return alternate;
}

+(NSDictionary *) zoomCountsWithDao: (GPKGTileDao *) tileDao{
    NSMutableDictionary<NSNumber *, NSNumber *> *counts = [NSMutableDictionary dictionary];
    for(NSNumber *zoomLevel in tileDao.zoomLevels){
        int zoomCount = [tileDao countWithZoomLevel:[zoomLevel intValue]];
        [counts setObject:[NSNumber numberWithInt:zoomCount] forKey:zoomLevel];
    }
    return counts;
}

+(void) compareZoomCountsWithCount: (int) count andCounts: (NSDictionary<NSNumber *, NSNumber *> *) counts andDao: (GPKGTileDao *) tileDao{
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:[tileDao count]];
    NSDictionary<NSNumber *, NSNumber *> *countsAfter = [self zoomCountsWithDao:tileDao];
    [GPKGTestUtils assertEqualIntWithValue:(int)counts.count andValue2:(int)countsAfter.count];
    for(NSNumber *zoomLevel in tileDao.zoomLevels){
        [GPKGTestUtils assertEqualWithValue:[counts objectForKey:zoomLevel] andValue2:[countsAfter objectForKey:zoomLevel]];
    }
}

+(void) checkZoomCountsWithCount: (int) count andCounts: (NSDictionary<NSNumber *, NSNumber *> *) counts andDao: (GPKGTileDao *) tileDao andTiles: (int) tiles{
    [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:[tileDao count]];
    [GPKGTestUtils assertEqualIntWithValue:tiles andValue2:[tileDao count]];
    NSDictionary<NSNumber *, NSNumber *> *countsAfter = [self zoomCountsWithDao:tileDao];
    [GPKGTestUtils assertEqualIntWithValue:(int)counts.count andValue2:(int)countsAfter.count];
    for(NSNumber *zoomLevel in tileDao.zoomLevels){
        [GPKGTestUtils assertEqualBoolWithValue:[[counts objectForKey:zoomLevel] intValue] > 0 andValue2:[[countsAfter objectForKey:zoomLevel] intValue] > 0];
    }
}

@end
