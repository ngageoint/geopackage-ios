//
//  GPKGDgiwgDataTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGContentsDataTypes.h"

/**
 * DGIWG (Defence Geospatial Information Working Group) Data Types
 */
enum GPKGDgiwgDataType{
    GPKG_DGIWG_DT_FEATURES_2D,
    GPKG_DGIWG_DT_FEATURES_3D,
    GPKG_DGIWG_DT_TILES_2D,
    GPKG_DGIWG_DT_TILES_3D
};

@interface GPKGDgiwgDataTypes : NSObject

/**
 * Get the contents data type
 *
 * @return contents data type
 */
+(enum GPKGContentsDataType) dataType: (enum GPKGDgiwgDataType) dataType;

/**
 * Get the dimension
 *
 * @return dimension
 */
+(int) dimension: (enum GPKGDgiwgDataType) dataType;

/**
 * Is a features data type
 *
 * @return true if features
 */
+(BOOL) isFeatures: (enum GPKGDgiwgDataType) dataType;

/**
 * Is a tiles data type
 *
 * @return true if tiles
 */
+(BOOL) isTiles: (enum GPKGDgiwgDataType) dataType;

/**
 * Is a 2D data type
 *
 * @return true if 2D
 */
+(BOOL) is2D: (enum GPKGDgiwgDataType) dataType;

/**
 * Is a 3D data type
 *
 * @return true if 3D
 */
+(BOOL) is3D: (enum GPKGDgiwgDataType) dataType;

/**
 * Get a geometry columns z value, 0 for prohibited and 1 for mandatory
 *
 * @return z value
 */
+(int) z: (enum GPKGDgiwgDataType) dataType;

/**
 * Get the data types for the contents data type
 *
 * @param type
 *            contents data type
 * @return data types
 */
+(NSSet<NSNumber *> *) dataTypes: (enum GPKGContentsDataType) type;

@end
