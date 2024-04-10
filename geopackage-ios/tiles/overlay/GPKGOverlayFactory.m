//
//  GPKGOverlayFactory.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGOverlayFactory.h"
#import "GPKGXYZOverlay.h"
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
    
    GPKGBoundedOverlay *overlay = nil;
    
    if([tileDao isXYZTiles]){
        overlay = [[GPKGXYZOverlay alloc] initWithTileDao:tileDao];
    }else{
        overlay = [[GPKGGeoPackageOverlay alloc] initWithTileDao:tileDao];
    }
    
    return overlay;
}

+(GPKGBoundedOverlay *) boundedOverlay: (GPKGTileDao *) tileDao andScaling: (GPKGTileScaling *) scaling{
    return [[GPKGGeoPackageOverlay alloc] initWithTileDao:tileDao andScaling:scaling];
}

+(GPKGCompositeOverlay *) compositeOverlayWithTileDao: (GPKGTileDao *) tileDao andOverlay: (GPKGBoundedOverlay *) overlay{
    NSArray *tileDaos = [NSArray arrayWithObjects:tileDao, nil];
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
    NSArray<GPKGTileDao *> *tileDaos = [linker tileDaosForFeatureTable:[featureOverlay.featureTiles featureDao].tableName];
    
    if (tileDaos.count > 0) {
        // Create a composite overlay to search for existing tiles before drawing from features
        overlay = [self compositeOverlayWithTileDaos:tileDaos andOverlay:featureOverlay];
    } else {
        overlay = featureOverlay;
    }
    
    return overlay;
}

+(MKTileOverlay *) tileOverlayWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) table{
    return [self boundedOverlayWithGeoPackage:geoPackage andTableName:table];
}

+(GPKGBoundedOverlay *) boundedOverlayWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) table{
    
    GPKGBoundedOverlay *overlay = nil;
    
    if([geoPackage isTileTable:table]){
        GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:table];
        overlay = [self boundedOverlay:tileDao];
    }else if([geoPackage isFeatureTable:table]){
        GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:table];
        GPKGFeatureTiles *featureTiles = [[GPKGFeatureTiles alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        overlay = [[GPKGFeatureOverlay alloc] initWithFeatureTiles:featureTiles];
    }else{
        [NSException raise:@"Table Type" format:@"Table is not a tile or feature type: %@", table];
    }
    
    return overlay;
}

+(MKTileOverlay *) tileOverlayWithGeoPackage: (GPKGGeoPackage *) geoPackage andUserDao: (GPKGUserDao *) userDao{
    return [self boundedOverlayWithGeoPackage:geoPackage andUserDao:userDao];
}

+(GPKGBoundedOverlay *) boundedOverlayWithGeoPackage: (GPKGGeoPackage *) geoPackage andUserDao: (GPKGUserDao *) userDao{
    
    GPKGBoundedOverlay *overlay = nil;
    
    if([userDao isKindOfClass:[GPKGTileDao class]]){
        overlay = [self boundedOverlay:(GPKGTileDao *) userDao];
    }else if([userDao isKindOfClass:[GPKGFeatureDao class]]){
        GPKGFeatureTiles *featureTiles = [[GPKGFeatureTiles alloc] initWithGeoPackage:geoPackage andFeatureDao:(GPKGFeatureDao *) userDao];
        overlay = [[GPKGFeatureOverlay alloc] initWithFeatureTiles:featureTiles];
    }else{
        [NSException raise:@"DAO Type" format:@"User DAO is not a tile or feature type: %@", userDao.tableName];
    }
    
    return overlay;
}

@end
