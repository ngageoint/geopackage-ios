//
//  GPKGTileScalingTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"

/**
 * Tile Scaling Type enumeration for defining scaled tile searching of nearby
 * zoom levels in place of missing tiles
 */
enum GPKGTileScalingType{
    
    /**
     * Search for tiles by zooming in
     */
    GPKG_TSC_IN,
    
    /**
     * Search for tiles by zooming out
     */
    GPKG_TSC_OUT,
    
    /**
     * Search for tiles by zooming in first, and then zooming out
     */
    GPKG_TSC_IN_OUT,
    
    /**
     * Search for tiles by zooming out first, and then zooming in
     */
    GPKG_TSC_OUT_IN,
    
    /**
     * Search for tiles in closest zoom level order, zoom in levels before zoom
     * out
     */
    GPKG_TSC_CLOSEST_IN_OUT,
    
    /**
     * Search for tiles in closest zoom level order, zoom out levels before zoom
     * in
     */
    GPKG_TSC_CLOSEST_OUT_IN
    
};

/**
 *  Tile Scaling Type names
 */
extern NSString * const GPKG_TSC_IN_NAME;
extern NSString * const GPKG_TSC_OUT_NAME;
extern NSString * const GPKG_TSC_IN_OUT_NAME;
extern NSString * const GPKG_TSC_OUT_IN_NAME;
extern NSString * const GPKG_TSC_CLOSEST_IN_OUT_NAME;
extern NSString * const GPKG_TSC_CLOSEST_OUT_IN_NAME;

@interface GPKGTileScalingTypes : GPKGBaseDao

/**
 *  Get the name of the tile scaling type
 *
 *  @param griddedCoverageEncodingType tile scaling type
 *
 *  @return tile scaling type name
 */
+(NSString *) name: (enum GPKGTileScalingType) tileScalingType;

/**
 *  Get the tile scaling type from the name
 *
 *  @param name tile scaling type name
 *
 *  @return tile scaling type
 */
+(enum GPKGTileScalingType) fromName: (NSString *) name;

@end
