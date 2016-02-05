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

@implementation GPKGOverlayFactory

+(MKTileOverlay *) getTileOverlayWithTileDao: (GPKGTileDao *) tileDao{
    return [self getBoundedOverlay:tileDao];
}

+(GPKGBoundedOverlay *) getBoundedOverlay: (GPKGTileDao *) tileDao{
    
    GPKGBoundedOverlay * overlay = nil;
    
    if([tileDao isStandardWebMercatorFormat]){
        overlay = [[GPKGStandardFormatOverlay alloc] initWithTileDao:tileDao];
    }else{
        overlay = [[GPKGGeoPackageOverlay alloc] initWithTileDao:tileDao];
    }
    
    return overlay;
}

@end
