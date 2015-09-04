//
//  GPKGCompressFormats.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Enumeration of image compression formats
 */
enum GPKGCompressFormat{
    GPKG_CF_JPEG,
    GPKG_CF_PNG,
    GPKG_CF_NONE
};

/**
 *  Image compression format names
 */
extern NSString * const GPKG_CF_JPEG_NAME;
extern NSString * const GPKG_CF_PNG_NAME;
extern NSString * const GPKG_CF_NONE_NAME;

@interface GPKGCompressFormats : NSObject

/**
 *  Get the name of the compress format
 *
 *  @param compressFormat compress format
 *
 *  @return compress format name
 */
+(NSString *) name: (enum GPKGCompressFormat) compressFormat;

/**
 *  Get the compress format from the name
 *
 *  @param name compress format name
 *
 *  @return compress format
 */
+(enum GPKGCompressFormat) fromName: (NSString *) name;

@end
