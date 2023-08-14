//
//  GPKGGeoPackageOverlay.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageOverlay.h"
#import "PROJProjectionConstants.h"
#import "GPKGGeoPackageTileRetriever.h"
#import "GPKGTileUtils.h"

@interface GPKGGeoPackageOverlay ()

@property (nonatomic, strong) NSObject<GPKGTileRetriever> *retriever;
@property (nonatomic) MKMapRect mapRect;
@property (nonatomic) CLLocationCoordinate2D center;

@end

@implementation GPKGGeoPackageOverlay

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao{
    return [self initWithTileDao:tileDao andScaling:nil];
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (int) width andHeight: (int) height{
    return [self initWithTileDao:tileDao andWidth:width andHeight:height andScaling:nil];
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andScaling: (GPKGTileScaling *) scaling{
    float tileLength = [GPKGTileUtils tileLength];
    return [self initWithTileDao:tileDao andWidth:tileLength andHeight:tileLength andScaling:scaling];
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (int) width andHeight: (int) height andScaling: (GPKGTileScaling *) scaling{
    self = [super init];
    if(self != nil){
        self.tileSize = CGSizeMake(width, height);
        GPKGGeoPackageTileRetriever *retriever = [[GPKGGeoPackageTileRetriever alloc] initWithTileDao:tileDao andWidth:[NSNumber numberWithInt:width] andHeight:[NSNumber numberWithInt:height]];
        if(scaling != nil){
            [retriever setScaling:scaling];
        }
        [self initHelperWithRetriever:retriever];
    }
    return self;
}

-(void) initHelperWithRetriever: (GPKGGeoPackageTileRetriever *) retriever{
    self.retriever = retriever;
    SFPGeometryTransform *transform = [SFPGeometryTransform transformFromEpsg:PROJ_EPSG_WEB_MERCATOR andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    GPKGBoundingBox *boundingBox = [[retriever webMercatorBoundingBox] transform:transform];
    [transform destroy];
    self.mapRect = [boundingBox mapRect];
    self.center = [boundingBox center];
    
    //[self setMinimumZ:tileDao.minZoom];
    //[self setMaximumZ:tileDao.maxZoom];
}

-(BOOL) hasTileToRetrieveWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
   return [self.retriever hasTileWithX:x andY:y andZoom:zoom];
}

-(NSData *) retrieveTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    NSData *tileData = nil;
    
    GPKGGeoPackageTile *geoPackageTile = [self.retriever tileWithX:x andY:y andZoom:zoom];
    if(geoPackageTile != nil){
        tileData = geoPackageTile.data;
    }
        
    return tileData;
}

- (CLLocationCoordinate2D)coordinate
{
    return _center;
}

- (MKMapRect)boundingMapRect
{
    return _mapRect;
}

@end
