//
//  GPKGFeatureTileGenerator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileGenerator.h"
#import "GPKGFeatureTiles.h"

/**
 *  Creates a set of tiles within a GeoPackage by generating tiles from features
 */
@interface GPKGFeatureTileGenerator : GPKGTileGenerator

/**
 *  Flag indicating whether the feature and tile tables should be linked
 */
@property (nonatomic) BOOL linkTables;

/**
 *  Initialize
 *
 *  @param geoPackage   GeoPackage
 *  @param tableName    table name
 *  @param featureTiles feature tiles
 *  @param minZoom      min zoom
 *  @param maxZoom      max zoom
 *
 *  @return new feature tile generator
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andFeatureTiles: (GPKGFeatureTiles *) featureTiles andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom;

@end
