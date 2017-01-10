//
//  TIFFDeflateCompression.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/9/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFDeflateCompression.h"

@implementation TIFFDeflateCompression

-(NSData *) decodeData: (NSData *) data withByteOrder: () byteOrder{
    [NSException raise:@"Not Implemented" format:@"Deflate decoder is not yet implemented"];
    return data;
}

-(BOOL) rowEncoding{
    return false;
}

-(NSData *) encodeData: (NSData *) data withByteOrder: () byteOrder{
    [NSException raise:@"Not Implemented" format:@"Deflate encoder is not yet implemented"];
    return data;
}

@end
