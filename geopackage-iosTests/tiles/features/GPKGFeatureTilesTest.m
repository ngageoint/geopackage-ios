//
//  GPKGFeatureTilesTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/16/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureTilesTest.h"
#import "GPKGFeatureTileUtils.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGTestUtils.h"

@implementation GPKGFeatureTilesTest

-(void) testFeatureTiles{
    [self testFeatureTilesWithUseIcon:NO];
}
    
-(void) testFeatureTilesWithIcon{
    [self testFeatureTilesWithUseIcon:YES];
}

-(void) testFeatureTilesWithUseIcon: (BOOL) useIcon{
    
    GPKGFeatureDao *featureDao = [GPKGFeatureTileUtils createFeatureDaoWithGeoPackage:self.geoPackage];
    
    int num = [GPKGFeatureTileUtils insertFeaturesWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    
    GPKGFeatureTiles *featureTiles = [GPKGFeatureTileUtils createFeatureTilesWithGeoPackage:self.geoPackage andFeatureDao:featureDao andUseIcon:useIcon];
    
    @try{
        GPKGFeatureIndexer *indexer = [[GPKGFeatureIndexer alloc] initWithFeatureDao:featureDao];
        @try{
            [indexer index];
        }@finally{
            [indexer close];
        }
        
        GPKGFeatureIndexManager *indexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
        [featureTiles setIndexManager:indexManager];
        
        [indexManager setIndexLocation:GPKG_FIT_GEOPACKAGE];
        int indexed = [indexManager index];
        [GPKGTestUtils assertEqualIntWithValue:num andValue2:indexed];
        
        [self createTilesWithFeatureTiles:featureTiles andMinZoom:0 andMaxZoom:3];
    }@finally{
        [featureTiles close];
    }
    
}

-(void) createTilesWithFeatureTiles: (GPKGFeatureTiles *) featureTiles andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom{
    for(int i = minZoom; i <= maxZoom; i++){
        [self createTilesWithFeatureTiles:featureTiles andZoom:i];
    }
}

-(void) createTilesWithFeatureTiles: (GPKGFeatureTiles *) featureTiles andZoom: (int) zoom{
    int tilesPerSide = [GPKGTileBoundingBoxUtils tilesPerSideWithZoom:zoom];
    for(int i = 0; i < tilesPerSide; i++){
        for(int j = 0; j < tilesPerSide; j++){
            UIImage *image = [featureTiles drawTileWithX:i andY:j andZoom:zoom];
            if(image != nil){
                int count = [featureTiles queryIndexedFeaturesCountWithX:i andY:j andZoom:zoom];
                [GPKGTestUtils assertTrue:count > 0];
                [GPKGTestUtils assertEqualIntWithValue:featureTiles.tileWidth andValue2:image.size.width];
                [GPKGTestUtils assertEqualIntWithValue:featureTiles.tileHeight andValue2:image.size.height];
            }
        }
    }
}

@end
