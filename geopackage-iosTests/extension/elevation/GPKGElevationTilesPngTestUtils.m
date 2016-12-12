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

@implementation GPKGElevationTilesPngTestUtils

+(void) testElevationsWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGElevationTileValues *) elevationTileValues andAlgorithm: (enum GPKGElevationTilesAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    // TODO
}

+(void) testRandomBoundingBoxWithGeoPackage: (GPKGGeoPackage *) geoPackage andValues: (GPKGElevationTileValues *) elevationTileValues andAlgorithm: (enum GPKGElevationTilesAlgorithm) algorithm andAllowNils: (BOOL) allowNils{
    // TODO
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
    return nil; // TODO
}

@end
