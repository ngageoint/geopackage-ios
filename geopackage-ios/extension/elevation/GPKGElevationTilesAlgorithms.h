//
//  GPKGElevationTilesAlgorithms.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Elevation Tiles Algorithm interpolation enumeration types
 */
enum GPKGElevationTilesAlgorithm{
    
    /**
     * Selects the value of the nearest point and does not consider the values
     * of neighboring points at all
     */
    GPKG_ETA_NEAREST_NEIGHBOR,
    
    /**
     * Performs linear interpolation first in one direction, and then again in
     * the other direction
     */
    GPKG_ETA_BILINEAR,
    
    /**
     * Considers 16 pixels to interpolate each value
     */
    GPKG_ETA_BICUBIC
    
};

@interface GPKGElevationTilesAlgorithms : NSObject

@end
