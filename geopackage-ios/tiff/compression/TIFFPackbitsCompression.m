//
//  TIFFPackbitsCompression.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/9/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFPackbitsCompression.h"
#import "TIFFByteReader.h"

@implementation TIFFPackbitsCompression

-(NSData *) decodeData: (NSData *) data withByteOrder: (CFByteOrder) byteOrder{
    
    TIFFByteReader * reader = [[TIFFByteReader alloc] initWithData:data andByteOrder:byteOrder];
    
    NSOutputStream * decodedStream = [NSOutputStream outputStreamToMemory];
    [decodedStream open];
    
    while ([reader hasByte]) {
        int header = [[reader readByte] intValue];
        if (header != -128) {
            if (header < 0) {
                unsigned char next = [[reader readUnsignedByte] unsignedCharValue];
                header = -header;
                for (int i = 0; i <= header; i++) {
                    [decodedStream write:&next maxLength:1];
                }
            } else {
                for (int i = 0; i <= header; i++) {
                    unsigned char next = [[reader readUnsignedByte] unsignedCharValue];
                    [decodedStream write:&next maxLength:1];
                }
            }
        }
    }
    
    NSData *decoded = [decodedStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    [decodedStream close];
    
    return decoded;
}

-(BOOL) rowEncoding{
    return true;
}

-(NSData *) encodeData: (NSData *) data withByteOrder: (CFByteOrder) byteOrder{
    [NSException raise:@"Not Implemented" format:@"Packbits encoder is not yet implemented"];
    return data;
}

@end
