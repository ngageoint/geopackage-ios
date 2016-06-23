//
//  GPKGFeatureTileGenerator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTileGenerator.h"
#import "GPKGFeatureTileTableLinker.h"

@interface GPKGFeatureTileGenerator ()

@property (nonatomic, strong) GPKGFeatureTiles *featureTiles;

@end

@implementation GPKGFeatureTileGenerator

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andFeatureTiles: (GPKGFeatureTiles *) featureTiles andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    self = [super initWithGeoPackage:geoPackage andTableName:tableName andMinZoom:minZoom andMaxZoom:maxZoom andBoundingBox:boundingBox andProjection:projection];
    if(self != nil){
        self.featureTiles = featureTiles;
        self.linkTables = true;
    }
    return self;
}

-(void) preTileGeneration{
    
    // Link the feature and tile table if they are in the same GeoPackage
    NSString * featureTable = [self.featureTiles getFeatureDao].tableName;
    NSString * tileTable = self.tableName;
    if (self.linkTables && [self.geoPackage isFeatureTable:featureTable] && [self.geoPackage isTileTable:tileTable]) {
        GPKGFeatureTileTableLinker * linker = [[GPKGFeatureTileTableLinker alloc] initWithGeoPackage:self.geoPackage];
        [linker linkWithFeatureTable:featureTable andTileTable:tileTable];
    }
    
}

-(NSData *) createTileWithZ: (int) z andX: (int) x andY: (int) y{
    
    NSData * tileData = [self.featureTiles drawTileDataWithX:x andY:y andZoom:z];
    
    return tileData;
}

@end
