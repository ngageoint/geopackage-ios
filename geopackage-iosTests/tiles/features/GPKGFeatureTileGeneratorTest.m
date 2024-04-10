//
//  GPKGFeatureTileGeneratorTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/16/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureTileGeneratorTest.h"
#import "GPKGFeatureTileUtils.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "PROJProjectionConstants.h"
#import "GPKGFeatureTileGenerator.h"
#import "PROJProjectionFactory.h"
#import "GPKGTestUtils.h"
#import "GPKGNumberFeaturesTile.h"

@implementation GPKGFeatureTileGeneratorTest

-(void) testTileGenerator{
    [self testTileGeneratorWithIndex:NO andUseIcon:NO andMaxFeatures:NO andGeodesic:NO];
}

-(void) testTileGeneratorWithIndex{
    [self testTileGeneratorWithIndex:YES andUseIcon:NO andMaxFeatures:NO andGeodesic:NO];
}

-(void) testTileGeneratorWithIcon{
    [self testTileGeneratorWithIndex:NO andUseIcon:YES andMaxFeatures:NO andGeodesic:NO];
}

-(void) testTileGeneratorWithMaxFeatures{
    [self testTileGeneratorWithIndex:NO andUseIcon:NO andMaxFeatures:YES andGeodesic:NO];
}

-(void) testTileGeneratorWithGeodesic{
    [self testTileGeneratorWithIndex:NO andUseIcon:NO andMaxFeatures:NO andGeodesic:YES];
}

-(void) testTileGeneratorWithIndexAndIcon{
    [self testTileGeneratorWithIndex:YES andUseIcon:YES andMaxFeatures:NO andGeodesic:NO];
}

-(void) testTileGeneratorWithIndexAndIconAndGeodesic{
    [self testTileGeneratorWithIndex:YES andUseIcon:YES andMaxFeatures:NO andGeodesic:YES];
}

-(void) testTileGeneratorWithIndexAndIconAndMaxFeatures{
    [self testTileGeneratorWithIndex:YES andUseIcon:YES andMaxFeatures:YES andGeodesic:NO];
}

-(void) testTileGeneratorWithIndexAndIconAndMaxFeaturesAndGeodesic{
    [self testTileGeneratorWithIndex:YES andUseIcon:YES andMaxFeatures:YES andGeodesic:YES];
}

-(void) testTileGeneratorWithIndex: (BOOL) index andUseIcon: (BOOL) useIcon andMaxFeatures: (BOOL) maxFeatures andGeodesic: (BOOL) geodesic{
 
    int minZoom = 0;
    int maxZoom = 4;
    
    GPKGFeatureDao *featureDao = [GPKGFeatureTileUtils createFeatureDaoWithGeoPackage:self.geoPackage];
    
    int num = [GPKGFeatureTileUtils insertFeaturesWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    
    GPKGFeatureTiles *featureTiles = [GPKGFeatureTileUtils createFeatureTilesWithGeoPackage:self.geoPackage andFeatureDao:featureDao andUseIcon:useIcon andGeodesic:geodesic];
    
    @try{
    
        if(index){
            GPKGFeatureIndexManager *indexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:self.geoPackage andFeatureDao:featureDao andGeodesic:geodesic];
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
        
        GPKGTileGenerator *tileGenerator = [[GPKGFeatureTileGenerator alloc] initWithGeoPackage:self.geoPackage andTableName:@"gen_feature_tiles" andFeatureTiles:featureTiles andMinZoom:minZoom andMaxZoom:maxZoom andProjection:[PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR]];
        [tileGenerator setXyzTiles:NO];
        
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
                
                GPKGTileGrid *tileGrid = [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:[tileGenerator boundingBoxAtZoom:z] andZoom:z];
                
                for (int x = tileGrid.minX; x <= tileGrid.maxX; x++) {
                    for (int y = tileGrid.minY; y <= tileGrid.maxY; y++) {
                        if([featureTiles queryIndexedFeaturesCountWithX:x andY:y andZoom:z] > 0){
                            
                            GPKGBoundingBox *webMercatorBoundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithX:x andY:y andZoom:z];
                            GPKGFeatureIndexResults *results = [featureTiles queryIndexedFeaturesWithX:x andY:y andZoom:z];
                            UIImage *image = [featureTiles drawTileWithZoom:z andBoundingBox:webMercatorBoundingBox andIndexResults:results];
                            if(image != nil){
                                expectedTiles++;
                            }
                            
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
