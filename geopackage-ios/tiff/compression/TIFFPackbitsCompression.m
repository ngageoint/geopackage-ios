//
//  TIFFPackbitsCompression.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/9/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFPackbitsCompression.h"

@implementation TIFFPackbitsCompression

-(NSData *) decodeData: (NSData *) data withByteOrder: () byteOrder{
    // TODO
    [NSException raise:@"Not Implemented" format:@"Packbits decoder is not yet implemented"];
    return data;
}

-(BOOL) rowEncoding{
    return true;
}

-(NSData *) encodeData: (NSData *) data withByteOrder: () byteOrder{
    [NSException raise:@"Not Implemented" format:@"Packbits encoder is not yet implemented"];
    return data;
}

@end
