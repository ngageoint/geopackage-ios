//
//  GPKGRelationTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Spec supported User-Defined Related Data Tables
 */
enum GPKGRelationType{
    
    /**
     * Link features with other features
     */
    GPKG_RT_FEATURES,
    
    /**
     * Relate sets of tabular text or numeric data
     */
    GPKG_RT_SIMPLE_ATTRIBUTES,
    
    /**
     * Relate features or attributes to multimedia files such as pictures and videos
     */
    GPKG_RT_MEDIA,
    
    /**
     * Relate features or attributes with attributes
     */
    GPKG_RT_ATTRIBUTES,
    
    /**
     * Relate features or attributes with tiles
     */
    GPKG_RT_TILES
    
};

/**
 *  Relation Type names
 */
extern NSString * const GPKG_RT_FEATURES_NAME;
extern NSString * const GPKG_RT_SIMPLE_ATTRIBUTES_NAME;
extern NSString * const GPKG_RT_MEDIA_NAME;
extern NSString * const GPKG_RT_ATTRIBUTES_NAME;
extern NSString * const GPKG_RT_TILES_NAME;

@interface GPKGRelationTypes : NSObject

/**
 *  Get the name of the relation type
 *
 *  @param relationType relation type
 *
 *  @return relation type name
 */
+(NSString *) name: (enum GPKGRelationType) relationType;

/**
 *  Get the relation type from the name
 *
 *  @param name relation type name
 *
 *  @return relation type
 */
+(enum GPKGRelationType) fromName: (NSString *) name;

/**
 * Get the contents data type
 *
 * @param relationType relation type
 */
+(NSString *) dataType: (enum GPKGRelationType) relationType;

@end
