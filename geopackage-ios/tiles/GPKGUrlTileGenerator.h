//
//  GPKGUrlTileGenerator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileGenerator.h"

extern NSString * const GPKG_TG_URL_EPSG_PATTERN;

@interface GPKGUrlTileGenerator : GPKGTileGenerator

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andTileUrl: (NSString *) tileUrl andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom;

@end
