//
//  GPKGGeoPackageOverlay.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageOverlay.h"
#import "GPKGProjectionTransform.h"
#import "GPKGProjectionConstants.h"
#import "GPKGGeoPackageTileRetriever.h"

@interface GPKGGeoPackageOverlay ()

@property (nonatomic, strong) NSObject<GPKGTileRetriever> *retriever;
@property (nonatomic) MKMapRect mapRect;
@property (nonatomic) CLLocationCoordinate2D center;

@end

@implementation GPKGGeoPackageOverlay

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao{
    self = [self initWithTileDao:tileDao andWidth:512 andHeight:512];
    return self;
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (int) width andHeight: (int) height{
    self = [super init];
    if(self != nil){
        self.tileSize = CGSizeMake(width, height);
        GPKGGeoPackageTileRetriever * retriever = [[GPKGGeoPackageTileRetriever alloc] initWithTileDao:tileDao andWidth:[NSNumber numberWithInt:width] andHeight:[NSNumber numberWithInt:height]];
        [self initHelperWithRetriever:retriever];
    }
    return self;
}

-(void) initHelperWithRetriever: (GPKGGeoPackageTileRetriever *) retriever{
    self.retriever = retriever;
    GPKGProjectionTransform * transform = [[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WEB_MERCATOR andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    GPKGBoundingBox * boundingBox = [transform transformWithBoundingBox:[retriever getWebMercatorBoundingBox]];
    self.mapRect = [boundingBox getMapRect];
    self.center = [boundingBox getCenter];
    
    //[self setMinimumZ:tileDao.minZoom];
    //[self setMaximumZ:tileDao.maxZoom];
}

-(BOOL) hasTileToRetrieveWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
   return [self.retriever hasTileWithX:x andY:y andZoom:zoom];
}

-(NSData *) retrieveTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    NSData * tileData = nil;
    
    GPKGGeoPackageTile * geoPackageTile = [self.retriever getTileWithX:x andY:y andZoom:zoom];
    if(geoPackageTile != nil){
        tileData = geoPackageTile.data;
    }
        
    return tileData;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.center;
}

- (MKMapRect)boundingMapRect
{
    return self.mapRect;
}

@end
