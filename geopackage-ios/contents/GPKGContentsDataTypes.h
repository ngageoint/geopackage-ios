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
    GPKG_CDT_ATTRIBUTES
};

/**
 *  Contents data type names
 */
extern NSString * const GPKG_CDT_FEATURES_NAME;
extern NSString * const GPKG_CDT_TILES_NAME;
extern NSString * const GPKG_CDT_ATTRIBUTES_NAME;

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
 *  @param name contents data type name
 *
 *  @return contents data type
 */
+(enum GPKGContentsDataType) fromName: (NSString *) name;

/**
 * Determine if the type name is a registered data type
 *
 * @param name
 *            type name
 * @return true if a core contents data type
 */
+(BOOL) isType: (NSString *) name;

/**
 * Get the contents data type from a core type name
 *
 * @param name
 *            type name
 * @return contents data type if core, null if not
 */
+(enum GPKGContentsDataType) fromCoreName: (NSString *) name;

/**
 * Determine if the type name is a core contents data type
 *
 * @param name
 *            type name
 * @return true if a core contents data type
 */
+(BOOL) isCoreType: (NSString *) name;

/**
 * Set the type for the contents data type name
 *
 * @param name
 *            contents data type name
 * @param type
 *            contents data type
 */
+(void) setName: (NSString *) name asType: (enum GPKGContentsDataType) type;

/**
 * Determine if the contents data type name is the type
 *
 * @param name
 *            contents data type name
 * @param type
 *            comparison contents data type
 * @return true if matching core types
 */
+(BOOL) isName: (NSString *) name ofType: (enum GPKGContentsDataType) type;

/**
 * Determine if the contents data type name is the type
 *
 * @param name
 *            contents data type name
 * @param type
 *            comparison contents data type
 * @param matchUnknown
 *            true to match unknown data types
 * @return true if matching core types or matched unknown
 */
+(BOOL) isName: (NSString *) name ofType: (enum GPKGContentsDataType) type andMatchUnknown: (BOOL) matchUnknown;

/**
 * Determine if the contents data type name is a features type
 *
 * @param name
 *            contents data type name
 * @return true if a features type
 */
+(BOOL) isFeaturesType: (NSString *) name;

/**
 * Determine if the contents data type name is a features type
 *
 * @param name
 *            contents data type name
 * @param matchUnknown
 *            true to match unknown data types
 * @return true if a features type or matched unknown
 */
+(BOOL) isFeaturesType: (NSString *) name andMatchUnknown: (BOOL) matchUnknown;

/**
 * Determine if the contents data type name is a tiles type
 *
 * @param name
 *            contents data type name
 * @return true if a tiles type
 */
+(BOOL) isTilesType: (NSString *) name;

/**
 * Determine if the contents data type name is a tiles type
 *
 * @param name
 *            contents data type name
 * @param matchUnknown
 *            true to match unknown data types
 * @return true if a tiles type or matched unknown
 */
 +(BOOL) isTilesType: (NSString *) name andMatchUnknown: (BOOL) matchUnknown;

/**
 * Determine if the contents data type name is an attributes type
 *
 * @param name
 *            contents data type name
 * @return true if an attributes type
 */
+(BOOL) isAttributesType: (NSString *) name;

/**
 * Determine if the contents data type name is an attributes type
 *
 * @param name
 *            contents data type name
 * @param matchUnknown
 *            true to match unknown data types
 * @return true if an attributes type or matched unknown
 */
 +(BOOL) isAttributesType: (NSString *) name andMatchUnknown: (BOOL) matchUnknown;

@end
