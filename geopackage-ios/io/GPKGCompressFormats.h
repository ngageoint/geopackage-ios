//
//  GPKGCompressFormats.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

enum GPKGCompressFormat{
    GPKG_CF_JPEG,
    GPKG_CF_PNG
};

extern NSString * const GPKG_CF_JPEG_NAME;
extern NSString * const GPKG_CF_PNG_NAME;

@interface GPKGCompressFormats : NSObject

+(NSString *) name: (enum GPKGCompressFormat) compressFormat;

+(enum GPKGCompressFormat) fromName: (NSString *) name;

@end
