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

@implementation GPKGTileReprojectionTestUtils

+(void) testReprojectWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    for(NSString *table in [self randomTileTablesWithGeoPackage:geoPackage]){
        
        NSString *reprojectTable = [NSString stringWithFormat:@"%@_reproject", table];
        SFPProjection *projection = [geoPackage projectionOfTable:table];
        SFPProjection *reprojectProjection = [self alternateProjection:projection];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        int count = [tileDao count];
        NSDictionary<NSNumber *, NSNumber *> *counts = [self zoomCountsWithDao:tileDao];
        
        GPKGTileReprojection *tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        int tiles = [tileReprojection reproject];
        
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:tiles > 0];
        
        [GPKGTestUtils assertTrue:[projection isEqualToProjection:[geoPackage projectionOfTable:table]]];
        [GPKGTestUtils assertTrue:[reprojectProjection isEqualToProjection:[geoPackage projectionOfTable:reprojectTable]]];
        
        tileDao = [geoPackage tileDaoWithTableName:table];
        [self compareZoomCountsWithCount:count andCounts:counts andDao:tileDao];
        
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:reprojectTable];
        [self checkZoomCountsWithCount:count andCounts:counts andDao:reprojectTileDao andTiles:tiles];
        
    }
    
}

+(void) testReprojectReplaceWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    for(NSString *table in [self randomTileTablesWithGeoPackage:geoPackage]){
        
        SFPProjection *projection = [geoPackage projectionOfTable:table];
        SFPProjection *reprojectProjection = [self alternateProjection:projection];
        
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        int count = [tileDao count];
        NSDictionary<NSNumber *, NSNumber *> *counts = [self zoomCountsWithDao:tileDao];
        
        GPKGTileReprojection *tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table inProjection:reprojectProjection];
        
        int tiles = [tileReprojection reproject];
        
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:tiles > 0];
        
        [GPKGTestUtils assertTrue:[reprojectProjection isEqualToProjection:[geoPackage projectionOfTable:table]]];
        
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:table];
        [self checkZoomCountsWithCount:count andCounts:counts andDao:reprojectTileDao andTiles:tiles];
        
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
        
        GPKGTileReprojection *tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        int tiles = [tileReprojection reproject];
        
        [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:tiles > 0];
        
        [GPKGTestUtils assertTrue:[projection isEqualToProjection:[geoPackage projectionOfTable:table]]];
        [GPKGTestUtils assertTrue:[reprojectProjection isEqualToProjection:[geoPackage projectionOfTable:reprojectTable]]];
        
        tileDao = [geoPackage tileDaoWithTableName:table];
        [self compareZoomCountsWithCount:count andCounts:counts andDao:tileDao];
        
        GPKGTileDao *reprojectTileDao = [geoPackage tileDaoWithTableName:reprojectTable];
        [self checkZoomCountsWithCount:count andCounts:counts andDao:reprojectTileDao andTiles:tiles];
        
        tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        int tiles2 = [tileReprojection reproject];
        [GPKGTestUtils assertEqualIntWithValue:tiles andValue2:tiles2];
        
        GPKGTileMatrixSet *tileMatrixSet = reprojectTileDao.tileMatrixSet;
        NSDecimalNumber *multiplier = [[NSDecimalNumber alloc] initWithDouble:0.5];
        [tileMatrixSet setMinX:[tileMatrixSet.minX decimalNumberByMultiplyingBy:multiplier]];
        [tileMatrixSet setMinY:[tileMatrixSet.minY decimalNumberByMultiplyingBy:multiplier]];
        [tileMatrixSet setMaxX:[tileMatrixSet.maxX decimalNumberByMultiplyingBy:multiplier]];
        [tileMatrixSet setMaxY:[tileMatrixSet.maxY decimalNumberByMultiplyingBy:multiplier]];
        [[reprojectTileDao tileMatrixSetDao] update:tileMatrixSet];
        
        tileReprojection = [GPKGTileReprojection createWithGeoPackage:geoPackage andTable:table toTable:reprojectTable inProjection:reprojectProjection];
        
        @try {
            [tileReprojection reproject];
            [GPKGTestUtils fail:@"Reprojection of existing table with new geographic properties did not fail"];
        } @catch (NSException *exception) {
            // expected
        }
        
        [tileReprojection setOverwrite:YES];
        [tileReprojection reproject];
        
        [tileReprojection setOverwrite:NO];
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
    }
    
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
    for(NSNumber *zoomLevel in [tileDao zoomLevels]){
        int zoomCount = [tileDao countWithZoomLevel:[zoomLevel intValue]];
        [counts setObject:[NSNumber numberWithInt:zoomCount] forKey:zoomLevel];
    }
    return counts;
}

+(void) compareZoomCountsWithCount: (int) count andCounts: (NSDictionary<NSNumber *, NSNumber *> *) counts andDao: (GPKGTileDao *) tileDao{
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:[tileDao count]];
    NSDictionary<NSNumber *, NSNumber *> *countsAfter = [self zoomCountsWithDao:tileDao];
    [GPKGTestUtils assertEqualIntWithValue:(int)counts.count andValue2:(int)countsAfter.count];
    for(NSNumber *zoomLevel in [tileDao zoomLevels]){
        [GPKGTestUtils assertEqualWithValue:[counts objectForKey:zoomLevel] andValue2:[countsAfter objectForKey:zoomLevel]];
    }
}

+(void) checkZoomCountsWithCount: (int) count andCounts: (NSDictionary<NSNumber *, NSNumber *> *) counts andDao: (GPKGTileDao *) tileDao andTiles: (int) tiles{
    [GPKGTestUtils assertEqualBoolWithValue:count > 0 andValue2:[tileDao count]];
    [GPKGTestUtils assertEqualIntWithValue:tiles andValue2:[tileDao count]];
    NSDictionary<NSNumber *, NSNumber *> *countsAfter = [self zoomCountsWithDao:tileDao];
    [GPKGTestUtils assertEqualIntWithValue:(int)counts.count andValue2:(int)countsAfter.count];
    for(NSNumber *zoomLevel in [tileDao zoomLevels]){
        [GPKGTestUtils assertEqualBoolWithValue:[[counts objectForKey:zoomLevel] intValue] > 0 andValue2:[[countsAfter objectForKey:zoomLevel] intValue] > 0];
    }
}

@end
