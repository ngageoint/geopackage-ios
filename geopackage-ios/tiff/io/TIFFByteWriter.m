//
//  TIFFByteWriter.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFByteWriter.h"

@implementation TIFFByteWriter

-(instancetype) init{
    return [self initWithByteOrder:CFByteOrderBigEndian];
}

-(instancetype) initWithByteOrder: (CFByteOrder) byteOrder{
    self = [super init];
    if(self != nil){
        self.nextByte = 0;
        self.os = [[NSOutputStream alloc] initToMemory];
        [self.os open];
        self.byteOrder = byteOrder;
    }
    return self;
}

-(void) close{
    [self.os close];
}

-(NSData *) getData{
    return [self.os propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
}

-(int) size{
    return self.nextByte;
}

-(void) writeString: (NSString *) value{
    NSData *data = [[NSData alloc] initWithData:[value dataUsingEncoding:NSUTF8StringEncoding]];
    [self.os write:[data bytes] maxLength:[value length]];
    self.nextByte += (int)[value length];
}

-(void) writeByte: (NSNumber *) value{
    uint8_t byteValue = [value charValue];
    [self write8BitInt:byteValue];
}

-(void) writeUnsignedByte: (NSNumber *) value{
    uint8_t byteValue = [value unsignedCharValue];
    [self write8BitInt:byteValue];
}

-(void) write8BitInt: (uint8_t) value{
    NSData *data = [NSData dataWithBytes:&value length:1];
    [self.os write:[data bytes]  maxLength:1];
    self.nextByte++;
}

-(void) writeBytesWithData: (NSData *) data{
    [self.os write:[data bytes]  maxLength:data.length];
}

-(void) writeShort: (NSNumber *) value{
    uint16_t shortValue = [value shortValue];
    [self write16BitInt:shortValue];
}

-(void) writeUnsignedShort: (NSNumber *) value{
    uint16_t shortValue = [value unsignedShortValue];
    [self write16BitInt:shortValue];
}

-(void) write16BitInt: (uint16_t) value{
    
    if(self.byteOrder == CFByteOrderBigEndian){
        value = CFSwapInt32HostToBig(value);
    }else{
        value = CFSwapInt32HostToLittle(value);
    }
    
    NSData *data = [NSData dataWithBytes:&value length:2];
    [self.os write:[data bytes]  maxLength:2];
    self.nextByte += 2;
}

-(void) writeInt: (NSNumber *) value{
    uint32_t intValue = [value intValue];
    [self write32BitInt:intValue];
}

-(void) writeUnsignedInt: (NSNumber *) value{
    uint32_t intValue = [value unsignedIntValue];
    [self write32BitInt:intValue];
}

-(void) write32BitInt: (uint32_t) value{
    
    if(self.byteOrder == CFByteOrderBigEndian){
        value = CFSwapInt32HostToBig(value);
    }else{
        value = CFSwapInt32HostToLittle(value);
    }
    
    NSData *data = [NSData dataWithBytes:&value length:4];
    [self.os write:[data bytes]  maxLength:4];
    self.nextByte += 4;
}

-(void) writeFloat: (NSDecimalNumber *) value{
    
    union FloatSwap {
        float v;
        uint32_t sv;
    } result;
    result.v = [value floatValue];
    
    if(self.byteOrder == CFByteOrderBigEndian){
        result.sv = CFSwapInt32HostToBig(result.sv);
    }else{
        result.sv = CFSwapInt32HostToLittle(result.sv);
    }
    
    NSData *data = [NSData dataWithBytes:&result.sv length:4];
    [self.os write:[data bytes]  maxLength:4];
    self.nextByte += 4;
}

-(void) writeDouble: (NSDecimalNumber *) value{
    
    union DoubleSwap {
        double v;
        uint64_t sv;
    } result;
    result.v = [value doubleValue];
    
    if(self.byteOrder == CFByteOrderBigEndian){
        result.sv = CFSwapInt64HostToBig(result.sv);
    }else{
        result.sv = CFSwapInt64HostToLittle(result.sv);
    }
    
    NSData *data = [NSData dataWithBytes:&result.sv length:8];
    [self.os write:[data bytes]  maxLength:8];
    self.nextByte += 8;
}

@end
