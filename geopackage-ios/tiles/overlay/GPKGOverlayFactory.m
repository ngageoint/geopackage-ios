//
//  GPKGOverlayFactory.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGOverlayFactory.h"
#import "GPKGStandardFormatOverlay.h"
#import "GPKGGeoPackageOverlay.h"
#import "GPKGFeatureTileTableLinker.h"

@implementation GPKGOverlayFactory

+(MKTileOverlay *) tileOverlayWithTileDao: (GPKGTileDao *) tileDao{
    return [self boundedOverlay:tileDao];
}

+(MKTileOverlay *) tileOverlayWithTileDao: (GPKGTileDao *) tileDao andScaling: (GPKGTileScaling *) scaling{
    return [self boundedOverlay:tileDao andScaling:scaling];
}

+(GPKGBoundedOverlay *) boundedOverlay: (GPKGTileDao *) tileDao{
    
    GPKGBoundedOverlay * overlay = nil;
    
    if([tileDao isStandardWebMercatorFormat]){
        overlay = [[GPKGStandardFormatOverlay alloc] initWithTileDao:tileDao];
    }else{
        overlay = [[GPKGGeoPackageOverlay alloc] initWithTileDao:tileDao];
    }
    
    return overlay;
}

+(GPKGBoundedOverlay *) boundedOverlay: (GPKGTileDao *) tileDao andScaling: (GPKGTileScaling *) scaling{
    return [[GPKGGeoPackageOverlay alloc] initWithTileDao:tileDao andScaling:scaling];
}

+(GPKGCompositeOverlay *) compositeOverlayWithTileDao: (GPKGTileDao *) tileDao andOverlay: (GPKGBoundedOverlay *) overlay{
    NSArray *tileDaos = [[NSArray alloc] initWithObjects:tileDao, nil];
    return [self compositeOverlayWithTileDaos:tileDaos andOverlay:overlay];
}

+(GPKGCompositeOverlay *) compositeOverlayWithTileDaos: (NSArray<GPKGTileDao *> *) tileDaos andOverlay: (GPKGBoundedOverlay *) overlay{
    
    GPKGCompositeOverlay *compositeOverlay = [self compositeOverlayWithTileDaos:tileDaos];
    
    [compositeOverlay addOverlay:overlay];
    
    return compositeOverlay;
}

+(GPKGCompositeOverlay *) compositeOverlayWithTileDaos: (NSArray<GPKGTileDao *> *) tileDaos{
    
    GPKGCompositeOverlay *compositeOverlay = [[GPKGCompositeOverlay alloc] init];
    
    for(GPKGTileDao *tileDao in tileDaos){
        GPKGBoundedOverlay *boundedOverlay = [GPKGOverlayFactory boundedOverlay:tileDao];
        [compositeOverlay addOverlay:boundedOverlay];
    }
    
    return compositeOverlay;
}

+(GPKGBoundedOverlay *) linkedFeatureOverlayWithOverlay: (GPKGFeatureOverlay *) featureOverlay andGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGBoundedOverlay *overlay;
    
    // Get the linked tile daos
    GPKGFeatureTileTableLinker *linker = [[GPKGFeatureTileTableLinker alloc] initWithGeoPackage:geoPackage];
    NSArray<GPKGTileDao *> *tileDaos = [linker getTileDaosForFeatureTable:[featureOverlay.featureTiles getFeatureDao].tableName];
    
    if (tileDaos.count > 0) {
        // Create a composite overlay to search for existing tiles before drawing from features
        overlay = [self compositeOverlayWithTileDaos:tileDaos andOverlay:featureOverlay];
    } else {
        overlay = featureOverlay;
    }
    
    return overlay;
}

@end
