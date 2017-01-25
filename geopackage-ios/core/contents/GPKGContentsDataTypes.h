//
//  GPKGContentsDataTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/31/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Enumeration of column data types
 */
enum GPKGContentsDataType{
    GPKG_CDT_FEATURES,
    GPKG_CDT_TILES,
    GPKG_CDT_ATTRIBUTES,
    GPKG_CDT_ELEVATION_TILES
};

/**
 *  Contents data type names
 */
extern NSString * const GPKG_CDT_FEATURES_NAME;
extern NSString * const GPKG_CDT_TILES_NAME;
extern NSString * const GPKG_CDT_ATTRIBUTES_NAME;
extern NSString * const GPKG_CDT_ELEVATION_TILES_NAME;

@interface GPKGContentsDataTypes : NSObject

/**
 *  Get the name of the contents data type
 *
 *  @param contentsDataType contents data type
 *
 *  @return contents data type name
 */
+(NSString *) name: (enum GPKGContentsDataType) contentsDataType;

/**
 *  Get the contents data type from the contents data type name
 *
 *  @param contents name data type name
 *
 *  @return contents data type
 */
+(enum GPKGContentsDataType) fromName: (NSString *) name;


@end
