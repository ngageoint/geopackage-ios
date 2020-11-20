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
    
    for(NSString *table in [geoPackage tileTables]){
        
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
    
    for(NSString *table in [geoPackage tileTables]){
        
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
    
    for(NSString *table in [geoPackage tileTables]){
        
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
    
    for(NSString *table in [geoPackage tileTables]){
        
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
    // TODO
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
