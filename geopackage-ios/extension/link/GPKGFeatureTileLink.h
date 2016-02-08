//
//  GPKGFeatureTileLink.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Feature Tile Link table constants
 */
extern NSString * const GPKG_FTL_TABLE_NAME;
extern NSString * const GPKG_FTL_COLUMN_PK1;
extern NSString * const GPKG_FTL_COLUMN_PK2;
extern NSString * const GPKG_FTL_COLUMN_FEATURE_TABLE_NAME;
extern NSString * const GPKG_FTL_COLUMN_TILE_TABLE_NAME;

@interface GPKGFeatureTileLink : NSObject

/**
 *  Name of the feature table
 */
@property (nonatomic, strong) NSString *featureTableName;

/**
 * Name of the tile table
 */
@property (nonatomic, strong) NSString *tileTableName;

@end
