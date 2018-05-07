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
#import "SFPProjectionTransform.h"
#import "SFPProjectionConstants.h"
#import "GPKGTileGenerator.h"
#import "GPKGFeatureTileGenerator.h"
#import "SFPProjectionFactory.h"
#import "GPKGTestUtils.h"
#import "GPKGNumberFeaturesTile.h"

@implementation GPKGFeatureTileGeneratorTest

-(void) testTileGenerator{
    [self testTileGeneratorWithIndex:NO andUseIcon:NO andMaxFeatures:NO];
}

-(void) testTileGeneratorWithIndex{
    [self testTileGeneratorWithIndex:YES andUseIcon:NO andMaxFeatures:NO];
}

-(void) testTileGeneratorWithIcon{
    [self testTileGeneratorWithIndex:NO andUseIcon:YES andMaxFeatures:NO];
}

-(void) testTileGeneratorWithMaxFeatures{
    [self testTileGeneratorWithIndex:NO andUseIcon:NO andMaxFeatures:YES];
}

-(void) testTileGeneratorWithIndexAndIcon{
    [self testTileGeneratorWithIndex:YES andUseIcon:YES andMaxFeatures:NO];
}

-(void) testTileGeneratorWithIndexAndIconAndMaxFeatures{
    [self testTileGeneratorWithIndex:YES andUseIcon:YES andMaxFeatures:YES];
}

-(void) testTileGeneratorWithIndex: (BOOL) index andUseIcon: (BOOL) useIcon andMaxFeatures: (BOOL) maxFeatures{
 
    int minZoom = 0;
    int maxZoom = 4;
    
    GPKGFeatureDao * featureDao = [GPKGFeatureTileUtils createFeatureDaoWithGeoPackage:self.geoPackage];
    
    int num = [GPKGFeatureTileUtils insertFeaturesWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    
    GPKGFeatureTiles * featureTiles = [GPKGFeatureTileUtils createFeatureTilesWithGeoPackage:self.geoPackage andFeatureDao:featureDao andUseIcon:useIcon];
    
    @try{
    
        if(index){
            GPKGFeatureIndexManager *indexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
            [featureTiles setIndexManager:indexManager];
            [indexManager setIndexLocation:GPKG_FIT_GEOPACKAGE];
            int indexed = [indexManager index];
            [GPKGTestUtils assertEqualIntWithValue:num andValue2:indexed];
        }
        
        if(maxFeatures){
            [featureTiles setMaxFeaturesPerTile:[NSNumber numberWithInt:10]];
            GPKGNumberFeaturesTile *numberFeaturesTile = [[GPKGNumberFeaturesTile alloc] init];
            if(!index){
                [numberFeaturesTile setDrawUnindexedTiles:NO];
            }
            [featureTiles setMaxFeaturesTileDraw:numberFeaturesTile];
        }
        
        GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] init];
        boundingBox = [GPKGTileBoundingBoxUtils boundWgs84BoundingBoxWithWebMercatorLimits:boundingBox];
        boundingBox = [[[SFPProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR] transformWithBoundingBox:boundingBox];
        GPKGTileGenerator * tileGenerator = [[GPKGFeatureTileGenerator alloc] initWithGeoPackage:self.geoPackage andTableName:@"gen_feature_tiles" andFeatureTiles:featureTiles andMinZoom:minZoom andMaxZoom:maxZoom andBoundingBox:boundingBox andProjection:[SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR]];
        [tileGenerator setStandardWebMercatorFormat:false];
        
        int tiles = [tileGenerator generateTiles];
        
        int expectedTiles = 0;
        if(!maxFeatures || index){
            
            if(!index){
                GPKGFeatureIndexManager *indexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
                [featureTiles setIndexManager:indexManager];
                [indexManager setIndexLocation:GPKG_FIT_GEOPACKAGE];
                int indexed = [indexManager index];
                [GPKGTestUtils assertEqualIntWithValue:num andValue2:indexed];
            }
            
            for(int z = minZoom; z <= maxZoom; z++){
                int tilesPerSide = [GPKGTileBoundingBoxUtils tilesPerSideWithZoom:z];
                for (int x = 0; x < tilesPerSide; x++) {
                    for (int y = 0; y < tilesPerSide; y++) {
                        if ([featureTiles queryIndexedFeaturesCountWithX:x andY:y andZoom:z] > 0) {
                            expectedTiles++;
                        }
                    }
                }
            }
        }
        
        [GPKGTestUtils assertEqualIntWithValue:expectedTiles andValue2:tiles];
    
    }@finally{
        [featureTiles close];
    }
}

@end
