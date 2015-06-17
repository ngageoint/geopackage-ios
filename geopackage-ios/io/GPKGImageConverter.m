//
//  GPKGImageConverter.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/16/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGImageConverter.h"

@implementation GPKGImageConverter

+(UIImage *) toImage: (NSData *) data{
    return [UIImage imageWithData:data];
}

+(UIImage *) toImage: (NSData *) data withScale: (CGFloat) scale{
    return [UIImage imageWithData:data scale:scale];
}

+(NSData *) toData: (UIImage *) image andFormat: (enum GPKGCompressFormat) format{
    return [self toData:image andFormat:format andQuality:1];
}

+(NSData *) toData: (UIImage *) image andFormat: (enum GPKGCompressFormat) format andQuality: (CGFloat) quality{
    NSData * data = nil;
    
    switch(format){
        case GPKG_CF_JPEG:
            data = UIImageJPEGRepresentation(image, quality);
            break;
            
        case GPKG_CF_PNG:
            data = UIImagePNGRepresentation(image);
            break;
        default:
            [NSException raise:@"Format Not Supported" format:@"Compress Format '%u' not supported", format];
    }

    return data;
}

@end
