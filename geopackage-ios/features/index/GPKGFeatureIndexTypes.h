//
//  GPKGFeatureIndexTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Enumeration of feature index types
 */
enum GPKGFeatureIndexType{
    GPKG_FIT_METADATA,
    GPKG_FIT_GEOPACKAGE,
    GPKG_FIT_NONE
};

/**
 *  Feature index type names
 */
extern NSString * const GPKG_FIT_METADATA_NAME;
extern NSString * const GPKG_FIT_GEOPACKAGE_NAME;
extern NSString * const GPKG_FIT_NONE_NAME;

@interface GPKGFeatureIndexTypes : NSObject

/**
 *  Get the name of the feature index type
 *
 *  @param featureIndexType feature index type
 *
 *  @return feature index type name
 */
+(NSString *) name: (enum GPKGFeatureIndexType) featureIndexType;

/**
 *  Get the feature index type from the feature index type name
 *
 *  @param name feature index type name
 *
 *  @return feature index type
 */
+(enum GPKGFeatureIndexType) fromName: (NSString *) name;

@end
