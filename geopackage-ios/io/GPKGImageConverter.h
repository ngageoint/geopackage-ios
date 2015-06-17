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

@interface GPKGImageConverter : NSObject

+(UIImage* ) toImage: (NSData *) data;

+(UIImage *) toImage: (NSData *) data withScale: (CGFloat) scale;

+(NSData *) toData: (UIImage *) image andFormat: (enum GPKGCompressFormat) format;

+(NSData *) toData: (UIImage *) image andFormat: (enum GPKGCompressFormat) format andQuality: (CGFloat) quality;

@end
