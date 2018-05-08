//
//  GPKGGeoPackageTileRetriever.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackageTileRetriever.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "SFPProjectionFactory.h"
#import "GPKGTileCreator.h"
#import "SFPProjectionTransform.h"
#import "SFPProjectionConstants.h"

@interface GPKGGeoPackageTileRetriever ()

@property (nonatomic, strong) GPKGTileCreator *tileCreator;
@property (nonatomic, strong) GPKGBoundingBox * setWebMercatorBoundingBox;

@end

@implementation GPKGGeoPackageTileRetriever

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao{
    self = [self initWithTileDao:tileDao andWidth:nil andHeight:nil];
    return self;
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height{
    self = [super init];
    if(self != nil){
        
        [tileDao adjustTileMatrixLengths];
        
        SFPProjection * webMercator = [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
        
        self.tileCreator = [[GPKGTileCreator alloc] initWithTileDao:tileDao andWidth:width andHeight:height andProjection:webMercator];
        
        SFPProjectionTransform * projectionToWebMercator = [[SFPProjectionTransform alloc] initWithFromProjection:[self.tileCreator tilesProjection] andToProjection:webMercator];
        GPKGBoundingBox * tileSetBoundingBox = [self.tileCreator tileSetBoundingBox];
        if([[self.tileCreator tilesProjection] getUnit] == SFP_UNIT_DEGREES){
            tileSetBoundingBox = [GPKGTileBoundingBoxUtils boundDegreesBoundingBoxWithWebMercatorLimits:tileSetBoundingBox];
        }
        self.setWebMercatorBoundingBox = [tileSetBoundingBox transform:projectionToWebMercator];
    }
    return self;
}

-(BOOL) hasTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    // Get the bounding box of the requested tile
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:(int)x andY:(int)y andZoom:(int)zoom];
    
    BOOL hasTile = [self.tileCreator hasTileWithBoundingBox:webMercatorBoundingBox];
    
    return hasTile;
}

-(GPKGGeoPackageTile *) getTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    // Get the bounding box of the requested tile
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:(int)x andY:(int)y andZoom:(int)zoom];
    
    GPKGGeoPackageTile * tile = [self.tileCreator getTileWithBoundingBox:webMercatorBoundingBox];
    
    return tile;
}

-(GPKGBoundingBox *) getWebMercatorBoundingBox{
    return self.setWebMercatorBoundingBox;
}

-(GPKGTileScaling *) getScaling{
    return self.tileCreator.scaling;
}

-(void) setScaling: (GPKGTileScaling *) scaling{
    [self.tileCreator setScaling:scaling];
}

@end
