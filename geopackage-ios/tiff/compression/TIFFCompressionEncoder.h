//
//  TIFFCompressionEncoder.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/9/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#ifndef TIFFCompressionEncoder_h
#define TIFFCompressionEncoder_h

#import <Foundation/Foundation.h>

/**
 *  Elevation image interface
 */
@protocol TIFFCompressionEncoder <NSObject>

/**
 * True to encode on a per row basis, false to encode on a per block / strip
 * basis
 *
 * @return true for row encoding
 */
-(BOOL) rowEncoding;

/**
 * Encode the data
 *
 * @param data
 *            data to encode
 * @param byteOrder
 *            data byte order
 * @return encoded data
 */
-(NSData *) encodeData: (NSData *) data withByteOrder: () byteOrder;

@end

#endif /* TIFFCompressionEncoder_h */
