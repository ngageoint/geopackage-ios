//
//  GPKGGriddedCoverageEncodingTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/18/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Gridded Coverage encoding type enumeration
 */
enum GPKGGriddedCoverageEncodingType{
    
    /**
     * Assume the value is center of grid cell (default)
     */
    GPKG_GCET_CENTER,
    
    /**
     * Assume the entire grid cell has the same value
     */
    GPKG_GCET_AREA,
    
    /**
     * A typical use case is for a mesh of elevation values as specified in the
     * OGC CDB standard Clause 5.6.1 (lower left corner)
     */
    GPKG_GCET_CORNER
    
};

/**
 *  Gridded Coverage encoding type names
 */
extern NSString * const GPKG_GCET_CENTER_NAME;
extern NSString * const GPKG_GCET_AREA_NAME;
extern NSString * const GPKG_GCET_CORNER_NAME;

@interface GPKGGriddedCoverageEncodingTypes : NSObject

/**
 *  Get the name of the gridded coverage encoding type
 *
 *  @param griddedCoverageEncodingType gridded coverage encoding type
 *
 *  @return gridded coverage encoding type name
 */
+(NSString *) name: (enum GPKGGriddedCoverageEncodingType) griddedCoverageEncodingType;

/**
 *  Get the gridded coverage encoding type from the name
 *
 *  @param name gridded coverage encoding type name
 *
 *  @return gridded coverage encoding type
 */
+(enum GPKGGriddedCoverageEncodingType) fromName: (NSString *) name;

@end
