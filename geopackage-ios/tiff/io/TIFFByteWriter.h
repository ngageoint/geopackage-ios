//
//  TIFFByteWriter.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Write byte data
 */
@interface TIFFByteWriter : NSObject

/**
 *  Next byte index to write
 */
@property int nextByte;

/**
 *  Output stream to write bytes to
 */
@property (nonatomic, strong) NSOutputStream * os;

/**
 *  Byte order used to write, little or big endian
 */
@property (nonatomic) CFByteOrder byteOrder;

/**
 *  Initialize
 *
 *  @return new byte writer
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param byteOrder byte order
 *
 *  @return new byte writer
 */
-(instancetype) initWithByteOrder: (CFByteOrder) byteOrder;

/**
 *  Close the byte writer
 */
-(void) close;

/**
 *  Get the written byte data
 *
 *  @return byte data
 */
-(NSData *) getData;

/**
 *  Get the current size in bytes written
 *
 *  @return bytes written
 */
-(int) size;

/**
 *  Write a string
 *
 *  @param value string
 */
-(void) writeString: (NSString *) value;

/**
 *  Write a byte
 *
 *  @param value byte
 */
-(void) writeByte: (NSNumber *) value;

/**
 * Write an unsigned byte
 *
 * @param value
 *            unsigned byte as a short
 */
-(void) writeUnsignedByte: (NSNumber *) value;

/**
 * Write the bytes
 *
 * @param value
 *            bytes
 */
-(void) writeBytesWithData: (NSData *) data;

/**
 * Write a short
 *
 * @param value
 *            short
 */
-(void) writeShort: (NSNumber *) value;

/**
 * Write an unsigned short
 *
 * @param value
 *            unsigned short as an int
 */
-(void) writeUnsignedShort: (NSNumber *) value;

/**
 *  Write an integer
 *
 *  @param value integer
 */
-(void) writeInt: (NSNumber *) value;

/**
 * Write an unsigned int
 *
 * @param value
 *            unsigned int as long
 */
-(void) writeUnsignedInt: (NSNumber *) value;

/**
 * Write a float
 *
 * @param value
 *            float
 */
-(void) writeFloat: (NSDecimalNumber *) value;

/**
 *  Write a double
 *
 *  @param value double
 */
-(void) writeDouble: (NSDecimalNumber *) value;

@end
