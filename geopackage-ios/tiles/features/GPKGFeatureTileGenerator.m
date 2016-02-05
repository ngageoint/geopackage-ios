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

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andFeatureTiles: (GPKGFeatureTiles *) featureTiles andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom{
    self = [super initWithGeoPackage:geoPackage andTableName:tableName andMinZoom:minZoom andMaxZoom:maxZoom];
    if(self != nil){
        self.featureTiles = featureTiles;
        self.linkTables = true;
    }
    return self;
}

-(void) preTileGeneration{
    
    // Link the feature and tile table
    if (self.linkTables) {
        GPKGFeatureTileTableLinker * linker = [[GPKGFeatureTileTableLinker alloc] initWithGeoPackage:self.geoPackage];
        [linker linkWithFeatureTable:[self.featureTiles getFeatureDao].tableName andTileTable:self.tableName];
    }
    
}

-(NSData *) createTileWithZ: (int) z andX: (int) x andY: (int) y{
    
    NSData * tileData = [self.featureTiles drawTileDataWithX:x andY:y andZoom:z];
    
    return tileData;
}

@end
