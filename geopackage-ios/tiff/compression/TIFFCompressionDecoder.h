//
//  TIFFCompressionDecoder.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/9/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#ifndef TIFFCompressionDecoder_h
#define TIFFCompressionDecoder_h

#import <Foundation/Foundation.h>

/**
 *  Elevation image interface
 */
@protocol TIFFCompressionDecoder <NSObject>

/**
 * Decode the data
 *
 * @param data
 *            data to decode
 * @param byteOrder
 *            data byte order
 * @return decoded data
 */
-(NSData *) decodeData: (NSData *) data withByteOrder: () byteOrder;

@end

#endif /* TIFFCompressionDecoder_h */
