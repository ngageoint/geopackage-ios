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
 *  @return bytes written
 */
-(int) writeString: (NSString *) value;

/**
 *  Write a byte
 *
 *  @param value byte
 */
-(void) writeNumberAsByte: (NSNumber *) value;

/**
 *  Write a byte
 *
 *  @param value byte
 */
-(void) writeByte: (char) value;

/**
 * Write an unsigned byte
 *
 * @param value
 *            unsigned byte as a short
 */
-(void) writeNumberAsUnsignedByte: (NSNumber *) value;

/**
 * Write an unsigned byte
 *
 * @param value
 *            unsigned byte as a short
 */
-(void) writeUnsignedByte: (unsigned char) value;

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
-(void) writeNumberAsShort: (NSNumber *) value;

/**
 * Write a short
 *
 * @param value
 *            short
 */
-(void) writeShort: (short) value;

/**
 * Write an unsigned short
 *
 * @param value
 *            unsigned short as an int
 */
-(void) writeNumberAsUnsignedShort: (NSNumber *) value;

/**
 * Write an unsigned short
 *
 * @param value
 *            unsigned short as an int
 */
-(void) writeUnsignedShort: (unsigned short) value;

/**
 *  Write an integer
 *
 *  @param value integer
 */
-(void) writeNumberAsInt: (NSNumber *) value;

/**
 *  Write an integer
 *
 *  @param value integer
 */
-(void) writeInt: (int) value;

/**
 * Write an unsigned int
 *
 * @param value
 *            unsigned int as long
 */
-(void) writeNumberAsUnsignedInt: (NSNumber *) value;

/**
 * Write an unsigned int
 *
 * @param value
 *            unsigned int as long
 */
-(void) writeUnsignedInt: (unsigned int) value;

/**
 * Write a float
 *
 * @param value
 *            float
 */
-(void) writeNumberAsFloat: (NSDecimalNumber *) value;

/**
 * Write a float
 *
 * @param value
 *            float
 */
-(void) writeFloat: (float) value;

/**
 *  Write a double
 *
 *  @param value double
 */
-(void) writeNumberAsDouble: (NSDecimalNumber *) value;

/**
 *  Write a double
 *
 *  @param value double
 */
-(void) writeDouble: (double) value;

@end
