//
//  GPKGFeatureTilesTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/16/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureTilesTest.h"
#import "GPKGFeatureTileUtils.h"
#import "GPKGFeatureIndexer.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGImageConverter.h"

@implementation GPKGFeatureTilesTest

-(void) testFeatureTiles{
    
    GPKGFeatureDao * featureDao = [GPKGFeatureTileUtils createFeatureDaoWithGeoPackage:self.geoPackage];
    
    [GPKGFeatureTileUtils insertFeaturesWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    
    GPKGFeatureTiles * featureTiles = [GPKGFeatureTileUtils createFeatureTilesWithGeoPackage:self.geoPackage andFeatureDao:featureDao];
    
    GPKGFeatureIndexer * indexer = [[GPKGFeatureIndexer alloc] initWithFeatureDao:featureDao];
    [indexer index];
    
    [self createTilesWithFeatureTiles:featureTiles andMinZoom:0 andMaxZoom:1];
    
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
            UIImage * image = [featureTiles drawTileWithX:i andY:j andZoom:zoom];
            NSData * data = [GPKGImageConverter toData:image andFormat:GPKG_CF_PNG];
            [GPKGTestUtils assertTrue:data.length > 0];
            [GPKGTestUtils assertEqualIntWithValue:featureTiles.tileWidth andValue2:image.size.width];
            [GPKGTestUtils assertEqualIntWithValue:featureTiles.tileHeight andValue2:image.size.height];
        }
    }
}

@end
