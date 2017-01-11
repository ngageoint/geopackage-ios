//
//  TIFFRawCompression.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/9/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFRawCompression.h"

@implementation TIFFRawCompression

-(NSData *) decodeData: (NSData *) data withByteOrder: (CFByteOrder) byteOrder{
    return data;
}

-(BOOL) rowEncoding{
    return false;
}

-(NSData *) encodeData: (NSData *) data withByteOrder: (CFByteOrder) byteOrder{
    return data;
}

@end
