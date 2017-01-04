//
//  TIFFByteReader.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Read through byte data
 */
@interface TIFFByteReader : NSObject

/**
 *  Next byte index to read
 */
@property int nextByte;

/**
 *  Bytes to read
 */
@property (nonatomic, strong) NSData *bytes;

/**
 *  Byte order used to read, little or big endian
 */
@property (nonatomic) CFByteOrder byteOrder;

/**
 *  Initialize
 *
 *  @param bytes byte data
 *
 *  @return new byte reader
 */
-(instancetype) initWithData: (NSData *) bytes;

/**
 *  Initialize
 *
 *  @param bytes byte data
 *  @param byteOrder byte order
 *
 *  @return new byte reader
 */
-(instancetype) initWithData: (NSData *) bytes andByteOrder: (CFByteOrder) byteOrder;

/**
 * Check if there is at least one more byte left to read
 *
 * @return true more bytes left to read
 */
-(BOOL) hasByte;

/**
 * Check if there is at least one more byte left to read
 *
 * @param offset
 *            byte offset
 * @return true more bytes left to read
 */
-(BOOL) hasByteWithOffset: (int) offset;

/**
 * Check if there are the provided number of bytes left to read
 *
 * @param num
 *            number of bytes
 * @return true if has at least the number of bytes left
 */
-(BOOL) hasBytesWithCount: (int) num;

/**
 * Check if there are the provided number of bytes left to read
 *
 * @param num
 *            number of bytes
 * @param offset
 *            byte offset
 * @return true if has at least the number of bytes left
 */
-(BOOL) hasBytesWithCount: (int) num andOffset: (int) offset;

/**
 * Read a String from the provided number of bytes
 *
 * @param num
 *            number of bytes
 * @return String
 * @throws UnsupportedEncodingException
 */
-(NSString *) readStringWithCount: (int) num;

/**
 * Read a String from the provided number of bytes
 *
 * @param offset
 *            byte offset
 * @param num
 *            number of bytes
 * @return String
 * @throws UnsupportedEncodingException
 */
-(NSString *) readStringWithCount: (int) num andOffset: (int) offset;

/**
 *  Read a single byte
 *
 *  @return byte
 */
-(NSNumber *) readByte;

/**
 * Read a byte
 *
 * @param offset
 *            byte offset
 * @return byte
 */
-(NSNumber *) readByteWithOffset: (int) offset;

/**
 * Read an unsigned byte
 *
 * @return unsigned byte as short
 */
-(NSNumber *) readUnsignedByte;

/**
 * Read an unsigned byte
 *
 * @param offset
 *            byte offset
 * @return unsigned byte as short
 */
-(NSNumber *) readUnsignedByteWithOffset: (int) offset;

/**
 * Read a number of bytes
 *
 * @param num
 *            number of bytes
 * @return bytes
 */
-(NSData *) readBytesWithCount: (int) num;

/**
 * Read a number of bytes
 *
 * @param num
 *            number of bytes
 * @param offset
 *            byte offset
 *
 * @return bytes
 */
-(NSData *) readBytesWithCount: (int) num andOffset: (int) offset;

/**
 * Read a short
 *
 * @return short
 */
-(NSNumber *) readShort;

/**
 * Read a short
 *
 * @param offset
 *            byte offset
 * @return short
 */
-(NSNumber *) readShortWithOffset: (int) offset;

/**
 * Read an unsigned short
 *
 * @return unsigned short as int
 */
-(NSNumber *) readUnsignedShort;

/**
 * Read an unsigned short
 *
 * @param offset
 *            byte offset
 * @return unsigned short as int
 */
-(NSNumber *) readUnsignedShortWithOffset: (int) offset;

/**
 *  Read an integer (4 bytes)
 *
 *  @return integer
 */
-(NSNumber *) readInt;

/**
 * Read an integer
 *
 * @param offset
 *            byte offset
 * @return integer
 */
-(NSNumber *) readIntWithOffset: (int) offset;

/**
 * Read an unsigned int
 *
 * @return unsigned int as long
 */
-(NSNumber *) readUnsignedInt;

/**
 * Read an unsigned int
 *
 * @param offset
 *            byte offset
 * @return unsigned int as long
 */
-(NSNumber *) readUnsignedIntWithOffset: (int) offset;

/**
 * Read a float
 *
 * @return float
 */
-(NSDecimalNumber *) readFloat;

/**
 * Read a float
 *
 * @param offset
 *            byte offset
 * @return float
 */
-(NSDecimalNumber *) readFloatWithOffset: (int) offset;

/**
 *  Read a double (8 bytes)
 *
 *  @return double
 */
-(NSDecimalNumber *) readDouble;

/**
 * Read a double
 *
 * @param offset
 *            byte offset
 * @return double
 */
-(NSDecimalNumber *) readDoubleWithOffset: (int) offset;

/**
 * Get the byte length
 *
 * @return byte length
 */
-(int) byteLength;

@end
