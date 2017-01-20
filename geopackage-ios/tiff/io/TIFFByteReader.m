//
//  TIFFByteReader.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFByteReader.h"

@implementation TIFFByteReader

-(instancetype) initWithData: (NSData *) bytes{
    return [self initWithData:bytes andByteOrder:CFByteOrderBigEndian];
}

-(instancetype) initWithData: (NSData *) bytes andByteOrder: (CFByteOrder) byteOrder{
    self = [super init];
    if(self != nil){
        self.bytes = bytes;
        self.nextByte = 0;
        self.byteOrder = byteOrder;
    }
    return self;
}

-(BOOL) hasByte{
    return [self hasBytesWithCount:1];
}

-(BOOL) hasByteWithOffset: (int) offset{
    return [self hasBytesWithCount:1 andOffset:offset];
}

-(BOOL) hasBytesWithCount: (int) num{
    return [self hasBytesWithCount:num andOffset:self.nextByte];
}

-(BOOL) hasBytesWithCount: (int) num andOffset: (int) offset{
    return offset + num <= self.bytes.length;
}

-(NSString *) readStringWithCount: (int) num{
    NSString * value = [self readStringWithCount:num andOffset:self.nextByte];
    self.nextByte += num;
    return value;
}

-(NSString *) readStringWithCount: (int) num andOffset: (int) offset{
    [self verifyRemainingBytesWithOffset:offset andBytesToRead:num];
    
    char *buffer = (char *)malloc(sizeof(char) * (num +1));
    [self.bytes getBytes:buffer range:NSMakeRange(offset, num)];
    buffer[num] = '\0';
    NSString * value = [NSString stringWithUTF8String:buffer];

    free(buffer);
    
    return value;
}

-(NSNumber *) readByte{
    NSNumber * value = [self readByteWithOffset:self.nextByte];
    self.nextByte++;
    return value;
}

-(NSNumber *) readByteWithOffset: (int) offset{
    uint8_t result = [self read8BitIntWithOffset:offset];
    return [NSNumber numberWithChar:result];
}

-(NSNumber *) readUnsignedByte{
    NSNumber * value = [self readUnsignedByteWithOffset:self.nextByte];
    self.nextByte++;
    return value;
}

-(NSNumber *) readUnsignedByteWithOffset: (int) offset{
    uint8_t result = [self read8BitIntWithOffset:offset];
    return [NSNumber numberWithUnsignedChar:result];
}

-(uint8_t) read8BitIntWithOffset: (int) offset{
    [self verifyRemainingBytesWithOffset:offset andBytesToRead:1];
    
    uint8_t value;
    [self.bytes getBytes:&value range:NSMakeRange(offset, 1)];
    
    return value;
}

-(NSData *) readBytesWithCount: (int) num{
    NSData * readBytes = [self readBytesWithCount:num andOffset:self.nextByte];
    self.nextByte += num;
    return readBytes;
}

-(NSData *) readBytesWithCount: (int) num andOffset: (int) offset{
    [self verifyRemainingBytesWithOffset:offset andBytesToRead:num];
    NSData * readBytes = [self.bytes subdataWithRange:NSMakeRange(offset, num)];
    return readBytes;
}

-(NSNumber *) readShort{
    NSNumber * value = [self readShortWithOffset:self.nextByte];
    self.nextByte += 2;
    return value;
}

-(NSNumber *) readShortWithOffset: (int) offset{
    uint16_t result = [self read16BitIntWithOffset:offset];
    return [NSNumber numberWithShort:result];
}

-(NSNumber *) readUnsignedShort{
    NSNumber * value = [self readUnsignedShortWithOffset:self.nextByte];
    self.nextByte += 2;
    return value;
}

-(NSNumber *) readUnsignedShortWithOffset: (int) offset{
    uint16_t result = [self read16BitIntWithOffset:offset];
    return [NSNumber numberWithUnsignedShort:result];
}

-(uint16_t) read16BitIntWithOffset: (int) offset{
    [self verifyRemainingBytesWithOffset:offset andBytesToRead:2];
    
    uint16_t value;
    [self.bytes getBytes:&value range:NSMakeRange(offset, 2)];
    
    if(self.byteOrder == CFByteOrderBigEndian){
        value = CFSwapInt16BigToHost(value);
    }else{
        value = CFSwapInt16LittleToHost(value);
    }
    
    return value;
}

-(NSNumber *) readInt{
    NSNumber * value = [self readIntWithOffset:self.nextByte];
    self.nextByte += 4;
    return value;
}

-(NSNumber *) readIntWithOffset: (int) offset{
    uint32_t result = [self read32BitIntWithOffset:offset];
    return [NSNumber numberWithInt:result];
}

-(NSNumber *) readUnsignedInt{
    NSNumber * value = [self readUnsignedIntWithOffset:self.nextByte];
    self.nextByte += 4;
    return value;
}

-(NSNumber *) readUnsignedIntWithOffset: (int) offset{
    uint32_t result = [self read32BitIntWithOffset:offset];
    return [NSNumber numberWithUnsignedInt:result];
}

-(uint32_t) read32BitIntWithOffset: (int) offset{
    [self verifyRemainingBytesWithOffset:offset andBytesToRead:4];
    
    uint32_t value;
    [self.bytes getBytes:&value range:NSMakeRange(offset, 4)];
    
    if(self.byteOrder == CFByteOrderBigEndian){
        value = CFSwapInt32BigToHost(value);
    }else{
        value = CFSwapInt32LittleToHost(value);
    }
    
    return value;
}

-(NSDecimalNumber *) readFloat{
    NSDecimalNumber * value = [self readFloatWithOffset:self.nextByte];
    self.nextByte += 4;
    return value;
}

-(NSDecimalNumber *) readFloatWithOffset: (int) offset{
    [self verifyRemainingBytesWithOffset:offset andBytesToRead:4];
    
    uint32_t value;
    [self.bytes getBytes:&value range:NSMakeRange(offset, 4)];
    
    union FloatSwap {
        float v;
        uint32_t sv;
    } result;
    result.sv = value;
    
    if(self.byteOrder == CFByteOrderBigEndian){
        result.sv = CFSwapInt32BigToHost(result.sv);
    }else{
        result.sv = CFSwapInt32LittleToHost(result.sv);
    }
    
    return [[NSDecimalNumber alloc] initWithFloat:result.v];
}

-(NSDecimalNumber *) readDouble{
    NSDecimalNumber * value = [self readDoubleWithOffset:self.nextByte];
    self.nextByte += 8;
    return value;
}

-(NSDecimalNumber *) readDoubleWithOffset: (int) offset{
    [self verifyRemainingBytesWithOffset:offset andBytesToRead:8];
    
    uint64_t value;
    [self.bytes getBytes:&value range:NSMakeRange(offset, 8)];
    
    union DoubleSwap {
        double v;
        uint64_t sv;
    } result;
    result.sv = value;
    
    if(self.byteOrder == CFByteOrderBigEndian){
        result.sv = CFSwapInt64BigToHost(result.sv);
    }else{
        result.sv = CFSwapInt64LittleToHost(result.sv);
    }
    
    return [[NSDecimalNumber alloc] initWithDouble:result.v];
}

-(int) byteLength{
    return (int)self.bytes.length;
}

/**
 * Verify with the remaining bytes that there are enough remaining to read
 * the provided amount
 *
 * @param offset
 *            byte offset
 * @param bytesToRead
 *            number of bytes to read
 */
-(void) verifyRemainingBytesWithOffset: (int) offset andBytesToRead: (int) bytesToRead{
    if (offset + bytesToRead > self.bytes.length) {
        [NSException raise:@"No More Bytes" format:@"No more remaining bytes to read. Total Bytes: %d, Byte offset: %d, Attempted to read: %d", (int)self.bytes.length, offset, bytesToRead];
    }
}

@end
