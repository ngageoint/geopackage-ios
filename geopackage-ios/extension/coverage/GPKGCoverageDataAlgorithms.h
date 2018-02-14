//
//  GPKGCoverageDataAlgorithms.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Tile Gridded Coverage Data Algorithm interpolation enumeration types
 */
enum GPKGCoverageDataAlgorithm{
    
    /**
     * Selects the value of the nearest point and does not consider the values
     * of neighboring points at all
     */
    GPKG_CDA_NEAREST_NEIGHBOR,
    
    /**
     * Performs linear interpolation first in one direction, and then again in
     * the other direction
     */
    GPKG_CDA_BILINEAR,
    
    /**
     * Considers 16 pixels to interpolate each value
     */
    GPKG_CDA_BICUBIC
    
};

/**
 *  Tile Gridded Coverage Data Algorithm names
 */
extern NSString * const GPKG_CDA_NEAREST_NEIGHBOR_NAME;
extern NSString * const GPKG_CDA_BILINEAR_NAME;
extern NSString * const GPKG_CDA_BICUBIC_NAME;


@interface GPKGCoverageDataAlgorithms : NSObject

/**
 *  Get the name of the coverage data algorithm
 *
 *  @param algorithm algorithm type
 *
 *  @return algorithm name
 */
+(NSString *) name: (enum GPKGCoverageDataAlgorithm) algorithm;

/**
 *  Get the coverage data algorithm type from the algorithm name
 *
 *  @param name algorithm name
 *
 *  @return algorithm type
 */
+(enum GPKGCoverageDataAlgorithm) fromName: (NSString *) name;

@end
