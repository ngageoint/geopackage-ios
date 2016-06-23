//
//  GPKGFeatureTileGeneratorTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/16/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureTileGeneratorTest.h"
#import "GPKGFeatureTileUtils.h"
#import "GPKGBoundingBox.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGProjectionTransform.h"
#import "GPKGProjectionConstants.h"
#import "GPKGTileGenerator.h"
#import "GPKGFeatureTileGenerator.h"
#import "GPKGProjectionFactory.h"
#import "GPKGTestUtils.h"

@implementation GPKGFeatureTileGeneratorTest

-(void) testTileGenerator{
 
    int minZoom = 0;
    int maxZoom = 4;
    
    GPKGFeatureDao * featureDao = [GPKGFeatureTileUtils createFeatureDaoWithGeoPackage:self.geoPackage];
    
    [GPKGFeatureTileUtils insertFeaturesWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    
    GPKGFeatureTiles * featureTiles = [GPKGFeatureTileUtils createFeatureTilesWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] init];
    boundingBox = [GPKGTileBoundingBoxUtils boundWgs84BoundingBoxWithWebMercatorLimits:boundingBox];
    boundingBox = [[[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR] transformWithBoundingBox:boundingBox];
    GPKGTileGenerator * tileGenerator = [[GPKGFeatureTileGenerator alloc] initWithGeoPackage:self.geoPackage andTableName:@"gen_feature_tiles" andFeatureTiles:featureTiles andMinZoom:minZoom andMaxZoom:maxZoom andBoundingBox:boundingBox andProjection:[GPKGProjectionFactory getProjectionWithInt:PROJ_EPSG_WEB_MERCATOR]];
    [tileGenerator setStandardWebMercatorFormat:false];
    
    int tiles = [tileGenerator generateTiles];
    
    int expectedTiles = 0;
    for(int i = minZoom; i <= maxZoom; i++){
        int tilesPerSide = [GPKGTileBoundingBoxUtils tilesPerSideWithZoom:i];
        expectedTiles += (tilesPerSide * tilesPerSide);
    }
    
    [GPKGTestUtils assertEqualIntWithValue:expectedTiles andValue2:tiles];
    
}

@end
