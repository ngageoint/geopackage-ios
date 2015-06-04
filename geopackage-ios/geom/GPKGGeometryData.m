//
//  GPKGGeometryData.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryData.h"
#import "WKBByteReader.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGGeometryExtensions.h"
#import "WKBGeometryReader.h"
#import "WKBByteWriter.h"
#import "WKBGeometryWriter.h"

@implementation GPKGGeometryData

-(instancetype) initWithSrsId: (NSNumber *) srsId
{
    self = [super init];
    if(self != nil){
        self.srsId = srsId;
        self.empty = true;
        self.byteOrder = CFByteOrderBigEndian;
    }
    return self;
}

-(instancetype) initWithData: (NSData *) bytes
{
    self = [super init];
    if(self != nil){
        self.empty = true;
        self.byteOrder = CFByteOrderBigEndian;
        [self fromData:bytes];
    }
    return self;
}

-(void) fromData: (NSData *) bytes
{
    self.bytes = bytes;
    
    WKBByteReader * reader = [[WKBByteReader alloc] initWithData:bytes];
    
    // Get 2 bytes as the magic number and validate
    NSString * magic = [reader readString:2];
    if(![magic isEqualToString:GPKG_GEO_PACKAGE_GEOMETRY_MAGIC_NUMBER]){
        [NSException raise:@"Invalid Magic Number" format:@"Unexpected GeoPackage Geometry magic number: %@, Expected: %@", magic, GPKG_GEO_PACKAGE_GEOMETRY_MAGIC_NUMBER];
    }
    
    NSNumber * version = [reader readByte];
    if([version intValue] != GPKG_GEO_PACKAGE_GEOMETRY_VERSION_1){
        [NSException raise:@"Invalid Version" format:@"Unexpected GeoPackage Geometry version: %@, Expected: %ld", version, (long)GPKG_GEO_PACKAGE_GEOMETRY_VERSION_1];
    }
    
    // Get a flags byte and then read the flag values
    NSNumber * flags = [reader readByte];
    int envelopeIndicator = [self readFlags: flags];
    [reader setByteOrder:self.byteOrder];
    
    // Read the 5th - 8th bytes as the srs id
    self.srsId = [reader readInt];
    
    // Read the envelope
    self.envelope = [self readEnvelopeWithIndicator:envelopeIndicator andByteReader:reader];
    
    // Save off where the WKB bytes start
    self.wkbGeometryIndex = reader.nextByte;
    
    // Read the Well-Known Binary Geometry if not marked as empty
    if(!self.empty){
        self.geometry = [WKBGeometryReader readGeometryWithReader:reader];
    }
    
}

-(NSData *) toData
{
    WKBByteWriter * writer = [[WKBByteWriter alloc] init];
    
    // Write GP as the 2 byte magic number
    [writer writeString:GPKG_GEO_PACKAGE_GEOMETRY_MAGIC_NUMBER];
    
    // Write a byte as the version, value of 0 = version 1
    [writer writeByte:[NSNumber numberWithInteger:GPKG_GEO_PACKAGE_GEOMETRY_VERSION_1]];
    
    // Build and write a flags byte
    NSNumber * flags = [self buildFlagsByte];
    [writer writeByte:flags];
    [writer setByteOrder:self.byteOrder];
    
    // Write the 4 byte srs id int
    [writer writeInt:self.srsId];
    
    // Write the envelope
    [self writeEnvelopeWithByteWriter:writer];
    
    // Save off where the WKB bytes start
    self.wkbGeometryIndex = [writer size];
    
    // Write the Well-Known Binary Geometry if not marked as empty
    if (!self.empty) {
        [WKBGeometryWriter writeGeometry:self.geometry withWriter:writer];
    }
    
    // Get the bytes
    self.bytes = [writer getData];
    
    // Close the writer
    [writer close];
    
    return self.bytes;
}

-(int) readFlags: (NSNumber *) flags {
    
    int flagsInt = [flags intValue];
    
    // Verify the reserved bits at 7 and 6 are 0
    int reserved7 = (flagsInt >> 7) & 1;
    int reserved6 = (flagsInt >> 6) & 1;
    if (reserved7 != 0 || reserved6 != 0) {
        [NSException raise:@"Geometry Flags" format:@"Unexpected GeoPackage Geometry flags. Flag bit 7 and 6 should both be 0, 7=%d, 6=%d", reserved7, reserved6];
    }
    
    // Get the binary type from bit 5, 0 for standard and 1 for extended
    int binaryType = (flagsInt >> 5) & 1;
    self.extended = binaryType == 1;
    
    // Get the empty geometry flag from bit 4, 0 for non-empty and 1 for
    // empty
    int emptyValue = (flagsInt >> 4) & 1;
    self.empty = emptyValue == 1;
    
    // Get the envelope contents indicator code (3-bit unsigned integer from
    // bits 3, 2, and 1)
    int envelopeIndicator = (flagsInt >> 1) & 7;
    if (envelopeIndicator > 4) {
        [NSException raise:@"Geometry Flags" format:@"Unexpected GeoPackage Geometry flags. Envelope contents indicator must be between 0 and 4. Actual: %d", envelopeIndicator];
    }
    
    // Get the byte order from bit 0, 0 for Big Endian and 1 for Little
    // Endian
    int byteOrderValue = flagsInt & 1;
    self.byteOrder = byteOrderValue == 0 ? CFByteOrderBigEndian
				: CFByteOrderLittleEndian;
    
    return envelopeIndicator;
}

-(NSNumber *) buildFlagsByte{
    
    int flag = 0;
    
    // Add the binary type to bit 5, 0 for standard and 1 for extended
    int binaryType = self.extended ? 1 : 0;
    flag += (binaryType << 5);
    
    // Add the empty geometry flag to bit 4, 0 for non-empty and 1 for
    // empty
    int emptyValue = self.empty ? 1 : 0;
    flag += (emptyValue << 4);
    
    // Add the envelope contents indicator code (3-bit unsigned integer to
    // bits 3, 2, and 1)
    int envelopeIndicator = self.envelope == nil ? 0 : [GPKGGeometryData getIndicatorWithEnvelope:self.envelope];
    flag += (envelopeIndicator << 1);
    
    // Add the byte order to bit 0, 0 for Big Endian and 1 for Little
    // Endian
    int byteOrderValue = (self.byteOrder == CFByteOrderBigEndian) ? 0 : 1;
    flag += byteOrderValue;
    
    return [NSNumber numberWithInt:flag];
}

-(WKBGeometryEnvelope *) readEnvelopeWithIndicator: (int) envelopeIndicator andByteReader: (WKBByteReader *) reader{
    
    WKBGeometryEnvelope * envelope = nil;
    
    if(envelopeIndicator > 0){
        
        // Read x and y values and create envelope
        NSDecimalNumber * minX = [reader readDouble];
        NSDecimalNumber * maxX = [reader readDouble];
        NSDecimalNumber * minY = [reader readDouble];
        NSDecimalNumber * maxY = [reader readDouble];
        
        BOOL hasZ = false;
        NSDecimalNumber *  minZ = nil;
        NSDecimalNumber *  maxZ = nil;
        
        BOOL hasM = false;
        NSDecimalNumber *  minM = nil;
        NSDecimalNumber *  maxM = nil;
        
        // Read z values
        if (envelopeIndicator == 2 || envelopeIndicator == 4) {
            hasZ = true;
            minZ = [reader readDouble];
            maxZ = [reader readDouble];
        }
        
        // Read m values
        if (envelopeIndicator == 3 || envelopeIndicator == 4) {
            hasM = true;
            minM = [reader readDouble];
            maxM = [reader readDouble];
        }
        
        envelope = [[WKBGeometryEnvelope alloc] initWithHasZ:hasZ andHasM:hasM];
        
        [envelope setMinX:minX];
        [envelope setMaxX:maxX];
        [envelope setMinY:minY];
        [envelope setMaxY:maxY];
        
        if (hasZ) {
            [envelope setMinZ:minZ];
            [envelope setMaxZ:maxZ];
        }
        
        if (hasM) {
            [envelope setMinM:minM];
            [envelope setMaxM:maxM];
        }
        
    }
    
    return envelope;
}

-(void) writeEnvelopeWithByteWriter: (WKBByteWriter *) writer{
    
    if (self.envelope != nil) {
        
        // Write x and y values
        [writer writeDouble:self.envelope.minX];
        [writer writeDouble:self.envelope.maxX];
        [writer writeDouble:self.envelope.minY];
        [writer writeDouble:self.envelope.maxY];
        
        // Write z values
        if (self.envelope.hasZ) {
            [writer writeDouble:self.envelope.minZ];
            [writer writeDouble:self.envelope.maxZ];
        }
        
        // Write m values
        if (self.envelope.hasM) {
            [writer writeDouble:self.envelope.minM];
            [writer writeDouble:self.envelope.maxM];
        }
    }
}

-(void) setGeometry:(WKBGeometry *) geometry{
    _geometry = geometry;
    self.empty = geometry == nil;
    if(geometry != nil){
        self.extended = [GPKGGeometryExtensions isExtension:geometry.geometryType];
    }
}

-(NSData *) getHeaderData
{
    return [self.bytes subdataWithRange:NSMakeRange(0, self.wkbGeometryIndex)];
}

-(NSData *) getWkbData
{
    int wkbByteCount = (int)[self.bytes length] - self.wkbGeometryIndex;
    return [self.bytes subdataWithRange:NSMakeRange(self.wkbGeometryIndex, wkbByteCount)];
}

+(int) getIndicatorWithEnvelope: (WKBGeometryEnvelope *) envelope{
    int indicator = 1;
    if(envelope.hasZ){
        indicator++;
    }
    if(envelope.hasM){
        indicator += 2;
    }
    return indicator;
}

@end
