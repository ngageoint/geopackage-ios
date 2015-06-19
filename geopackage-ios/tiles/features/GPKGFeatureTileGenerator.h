//
//  GPKGFeatureTileGenerator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileGenerator.h"
#import "GPKGFeatureTiles.h"

@interface GPKGFeatureTileGenerator : GPKGTileGenerator

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andFeatureTiles: (GPKGFeatureTiles *) featureTiles andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom;

@end
