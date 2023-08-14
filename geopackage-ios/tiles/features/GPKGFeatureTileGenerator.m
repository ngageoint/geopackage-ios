//
//  GPKGFeatureTileGenerator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTileGenerator.h"
#import "GPKGFeatureTileTableLinker.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "PROJProjectionConstants.h"

@interface GPKGFeatureTileGenerator ()

@property (nonatomic, strong) GPKGFeatureTiles *featureTiles;

@end

@implementation GPKGFeatureTileGenerator

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andFeatureTiles: (GPKGFeatureTiles *) featureTiles andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (PROJProjection *) projection{
    self = [self initWithGeoPackage:geoPackage andTableName:tableName andFeatureTiles:featureTiles andFeatureGeoPackage:geoPackage andMinZoom:minZoom andMaxZoom:maxZoom andBoundingBox:boundingBox andProjection:projection];
    return self;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andFeatureTiles: (GPKGFeatureTiles *) featureTiles andFeatureGeoPackage: (GPKGGeoPackage *) featureGeoPackage andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (PROJProjection *) projection{
    self = [super initWithGeoPackage:geoPackage andTableName:tableName andMinZoom:minZoom andMaxZoom:maxZoom andBoundingBox:[self boundingBoxWithGeoPackage:featureGeoPackage andFeatureTiles:featureTiles andBoundingBox:boundingBox andProjection:projection] andProjection:projection];
    if(self != nil){
        self.featureTiles = featureTiles;
        self.linkTables = YES;
    }
    return self;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andFeatureTiles: (GPKGFeatureTiles *) featureTiles andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andProjection: (PROJProjection *) projection{
    self = [self initWithGeoPackage:geoPackage andTableName:tableName andFeatureTiles:featureTiles andMinZoom:minZoom andMaxZoom:maxZoom andBoundingBox:nil andProjection:projection];
    return self;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andFeatureTiles: (GPKGFeatureTiles *) featureTiles andFeatureGeoPackage: (GPKGGeoPackage *) featureGeoPackage andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andProjection: (PROJProjection *) projection{
    self = [self initWithGeoPackage:geoPackage andTableName:tableName andFeatureTiles:featureTiles andFeatureGeoPackage:featureGeoPackage andMinZoom:minZoom andMaxZoom:maxZoom andBoundingBox:nil andProjection:projection];
    return self;
}

-(GPKGBoundingBox *) boundingBoxWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureTiles: (GPKGFeatureTiles *) featureTiles andBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (PROJProjection *) projection{
    
    NSString *tableName = [featureTiles featureDao].tableName;
    BOOL manualQuery = boundingBox == nil;
    GPKGBoundingBox *featureBoundingBox = [geoPackage boundingBoxOfTable:tableName inProjection:projection andManual:manualQuery];
    if(featureBoundingBox != nil){
        if(boundingBox == nil){
            boundingBox = featureBoundingBox;
        }else{
            boundingBox = [boundingBox overlap:featureBoundingBox];
        }
    }
    
    if(boundingBox != nil){
        boundingBox = [featureTiles expandBoundingBox:boundingBox inProjection:projection];
    }
    
    return boundingBox;
}

-(GPKGBoundingBox *) boundingBoxAtZoom: (int) zoom{
    
    SFPGeometryTransform *projectionToWebMercator = [SFPGeometryTransform transformFromProjection:self.projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    GPKGBoundingBox *webMercatorBoundingBox = [self.boundingBox transform:projectionToWebMercator];

    GPKGTileGrid *tileGrid = [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:webMercatorBoundingBox andZoom:zoom];
    GPKGBoundingBox *tileBoundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithX:tileGrid.minX andY:tileGrid.minY andZoom:zoom];
    
    GPKGBoundingBox *expandedBoundingBox = [self.featureTiles expandBoundingBox:webMercatorBoundingBox withTileBoundingBox:tileBoundingBox];
    
    SFPGeometryTransform *inverse = [projectionToWebMercator inverseTransformation];
    GPKGBoundingBox *zoomBoundingBox = [expandedBoundingBox transform:inverse];
    
    [projectionToWebMercator destroy];
    [inverse destroy];
    
    return zoomBoundingBox;
}

-(void) close{
    [self.featureTiles close];
    [super close];
}

-(void) preTileGeneration{
    
    // Link the feature and tile table if they are in the same GeoPackage
    NSString *featureTable = [self.featureTiles featureDao].tableName;
    NSString *tileTable = self.tableName;
    if (self.linkTables && [self.geoPackage isFeatureTable:featureTable] && [self.geoPackage isTileTable:tileTable]) {
        GPKGFeatureTileTableLinker *linker = [[GPKGFeatureTileTableLinker alloc] initWithGeoPackage:self.geoPackage];
        [linker linkWithFeatureTable:featureTable andTileTable:tileTable];
    }
    
}

-(NSData *) createTileWithZ: (int) z andX: (int) x andY: (int) y{
    
    NSData *tileData = [self.featureTiles drawTileDataWithX:x andY:y andZoom:z];
    
    return tileData;
}

@end
