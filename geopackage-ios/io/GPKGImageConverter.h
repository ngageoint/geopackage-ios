//
//  GPKGImageConverter.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/16/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GPKGCompressFormats.h"

/**
 *  Conversions between images and image byte data
 */
@interface GPKGImageConverter : NSObject

/**
 *  Decode the byte data to an image
 *
 *  @param data byte data
 *
 *  @return image
 */
+(UIImage* ) toImage: (NSData *) data;

/**
 *  Decode the byte data to an image with scale
 *
 *  @param data  byte data
 *  @param scale scale factor, 0.0 to 1.0
 *
 *  @return image
 */
+(UIImage *) toImage: (NSData *) data withScale: (CGFloat) scale;

/**
 *  Compress the image to byte data
 *
 *  @param image  image
 *  @param format compress format
 *
 *  @return byte data
 */
+(NSData *) toData: (UIImage *) image andFormat: (enum GPKGCompressFormat) format;

/**
 *  Compress teh image to byte data with quality
 *
 *  @param image   image
 *  @param format  compress format
 *  @param quality quality, 0.0 to 1.0, only used for GPKG_CF_JPEG
 *
 *  @return byte data
 */
+(NSData *) toData: (UIImage *) image andFormat: (enum GPKGCompressFormat) format andQuality: (CGFloat) quality;

@end
