//
//  GPKGGeometryData.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryData.h"
#import "SFByteReader.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGGeometryExtensions.h"
#import "SFWBGeometryReader.h"
#import "SFByteWriter.h"
#import "SFWBGeometryWriter.h"
#import "SFGeometryEnvelopeBuilder.h"
#import "SFPointFiniteFilter.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "SFWTGeometryWriter.h"

@implementation GPKGGeometryData

/**
 * Point filter
 */
static NSObject<SFGeometryFilter> *geometryFilter;

/**
 * Default SRS Id, Undefined Cartesian (-1)
 */
static NSNumber *defaultSrsId;

/**
 * Default byte order
 */
static int defaultByteOrder;

+(void) initialize{
    geometryFilter = [[SFPointFiniteFilter alloc] init];
    defaultSrsId = [GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_SRS_ID];
    defaultByteOrder = CFByteOrderBigEndian;
}

+(NSObject<SFGeometryFilter> *) geometryFilter{
    return geometryFilter;
}

+(void) setGeometryFilter: (NSObject<SFGeometryFilter> *) filter{
    geometryFilter = filter;
}

+(NSNumber *) defaultSrsId{
    return defaultSrsId;
}

+(void) setDefaultSrsId: (NSNumber *) srsId{
    defaultSrsId = srsId;
}

+(int) defaultByteOrder{
    return defaultByteOrder;
}

+(void) setDefaultByteOrder: (int) byteOrder{
    defaultByteOrder = byteOrder;
}

+(GPKGGeometryData *) create{
    return [[GPKGGeometryData alloc] init];
}

+(GPKGGeometryData *) createWithGeometry: (SFGeometry *) geometry{
    return [[GPKGGeometryData alloc] initWithGeometry:geometry];
}

+(GPKGGeometryData *) createAndBuildEnvelopeWithGeometry: (SFGeometry *) geometry{
    return [[GPKGGeometryData alloc] initWithGeometry:geometry andBuildEnvelope:YES];
}

+(GPKGGeometryData *) createWithSrsId: (NSNumber *) srsId{
    return [[GPKGGeometryData alloc] initWithSrsId:srsId];
}

+(GPKGGeometryData *) createWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry{
    return [[GPKGGeometryData alloc] initWithSrsId:srsId andGeometry:geometry];
}

+(GPKGGeometryData *) createAndBuildEnvelopeWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry{
    return [[GPKGGeometryData alloc] initWithSrsId:srsId andGeometry:geometry andBuildEnvelope:YES];
}

+(GPKGGeometryData *) createAndWriteWithGeometry: (SFGeometry *) geometry{
    return [self writeData:[self createWithGeometry:geometry]];
}

+(GPKGGeometryData *) createBuildEnvelopeAndWriteWithGeometry: (SFGeometry *) geometry{
    return [self writeData:[self createAndBuildEnvelopeWithGeometry:geometry]];
}

+(GPKGGeometryData *) createAndWriteWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry{
    return [self writeData:[self createWithSrsId:srsId andGeometry:geometry]];
}

+(GPKGGeometryData *) createBuildEnvelopeAndWriteWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry{
    return [self writeData:[self createAndBuildEnvelopeWithSrsId:srsId andGeometry:geometry]];
}

+(GPKGGeometryData *) createWithData: (NSData *) bytes{
    return [[GPKGGeometryData alloc] initWithData:bytes];
}

+(GPKGGeometryData *) createWithGeometry: (SFGeometry *) geometry andEnvelope: (SFGeometryEnvelope *) envelope{
    return [[GPKGGeometryData alloc] initWithGeometry:geometry andEnvelope:envelope];
}

+(GPKGGeometryData *) createWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry andEnvelope: (SFGeometryEnvelope *) envelope{
    // TODO
}

+(GPKGGeometryData *) createWithGeometryData: (GPKGGeometryData *) geometryData{
    
}

+(GPKGGeometryData *) createFromWkb: (NSData *) bytes{
    
}

+(GPKGGeometryData *) createAndBuildEnvelopeFromWkb: (NSData *) bytes{
    
}

+(GPKGGeometryData *) createFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId{
    
}

+(GPKGGeometryData *) createAndBuildEnvelopeFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId{
    
}

+(GPKGGeometryData *) createAndWriteFromWkb: (NSData *) bytes{
    
}

+(GPKGGeometryData *) createBuildEnvelopeAndWriteFromWkb: (NSData *) bytes{
    
}

+(GPKGGeometryData *) createAndWriteFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId{
    
}

+(GPKGGeometryData *) createBuildEnvelopeAndWriteFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId{
    
}

+(SFGeometry *) createGeometryFromWkb: (NSData *) bytes{
    
}

+(GPKGGeometryData *) createFromWkt: (NSString *) text{
    
}

+(GPKGGeometryData *) createAndBuildEnvelopeFromWkt: (NSString *) text{
    
}

+(GPKGGeometryData *) createFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId{
    
}

+(GPKGGeometryData *) createAndBuildEnvelopeFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId{
    
}

+(GPKGGeometryData *) createAndWriteFromWkt: (NSString *) text{
    
}

+(GPKGGeometryData *) createBuildEnvelopeAndWriteFromWkt: (NSString *) text{
    
}

+(GPKGGeometryData *) createAndWriteFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId{
    
}

+(GPKGGeometryData *) createBuildEnvelopeAndWriteFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId{
    
}

+(SFGeometry *) createGeometryFromWkt: (NSString *) text{
    
}

+(NSData *) dataFromGeometry: (SFGeometry *) geometry{
    
}

+(NSData *) dataAndBuildEnvelopeFromGeometry: (SFGeometry *) geometry{
    
}

+(NSData *) dataFromGeometry: (SFGeometry *) geometry withSrsId: (NSNumber *) srsId{
    
}

+(NSData *) dataAndBuildEnvelopeFromGeometry: (SFGeometry *) geometry withSrsId: (NSNumber *) srsId{
    
}

+(NSData *) dataFromWkb: (NSData *) bytes{
    
}

+(NSData *) dataAndBuildEnvelopeFromWkb: (NSData *) bytes{
    
}

+(NSData *) dataFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId{
    
}

+(NSData *) dataAndBuildEnvelopeFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId{
    
}

+(NSData *) dataFromWkt: (NSString *) text{
    
}

+(NSData *) dataAndBuildEnvelopeFromWkt: (NSString *) text{
    
}

+(NSData *) dataFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId{
    
}

+(NSData *) dataAndBuildEnvelopeFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId{
    
}

+(NSData *) wkbFromGeometryData: (GPKGGeometryData *) geometryData{
    
}

+(NSData *) wkbFromGeometry: (SFGeometry *) geometry{
    
}

+(NSData *) wkbFromData: (NSData *) bytes{
    
}

+(NSData *) wkbFromWkt: (NSString *) text{
    
}

+(NSString *) wktFromGeometryData: (GPKGGeometryData *) geometryData{
    
}

+(NSString *) wktFromGeometry: (SFGeometry *) geometry{
    
}

+(NSString *) wktFromData: (NSData *) bytes{
    
}

+(NSString *) wktFromWkb: (NSData *) bytes{
    
}

-(instancetype) init{
    return [self initWithSrsId:defaultSrsId];
}

-(instancetype) initWithGeometry: (SFGeometry *) geometry{
    return [self initWithGeometry:geometry andBuildEnvelope:NO];
}

-(instancetype) initWithGeometry: (SFGeometry *) geometry andBuildEnvelope: (BOOL) buildEnvelope{
    self = [self init];
    if(self != nil){
        [self setGeometry:geometry];
        if(buildEnvelope){
            [self buildEnvelope];
        }
    }
    return self;
}

-(instancetype) initWithSrsId: (NSNumber *) srsId{
    self = [super init];
    if(self != nil){
        self.srsId = srsId;
        self.empty = YES;
        self.byteOrder = defaultByteOrder;
    }
    return self;
}

-(instancetype) initWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry{
    return [self initWithSrsId:srsId andGeometry:geometry andBuildEnvelope:NO];
}

-(instancetype) initWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry andBuildEnvelope: (BOOL) buildEnvelope{
    self = [self initWithSrsId:srsId];
    if(self != nil){
        [self setGeometry:geometry];
        if(buildEnvelope){
            [self buildEnvelope];
        }
    }
    return self;
}

-(instancetype) initWithGeometry: (SFGeometry *) geometry andEnvelope: (SFGeometryEnvelope *) envelope{
    self = [self init];
    if(self != nil){
        [self setGeometry:geometry];
        [self setEnvelope:envelope];
    }
    return self;
}

-(instancetype) initWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry andEnvelope: (SFGeometryEnvelope *) envelope{
    self = [self initWithSrsId:srsId];
    if(self != nil){
        [self setGeometry:geometry];
        [self setEnvelope:envelope];
    }
    return self;
}

-(instancetype) initWithGeometryData: (GPKGGeometryData *) geometryData{
    self = [self init];
    if(self != nil){
        [self setSrsId:geometryData.srsId];
        SFGeometry *geometry = geometryData.geometry;
        if(geometry != nil){
            geometry = [geometry mutableCopy];
        }
        [self setGeometry:geometry];
        SFGeometryEnvelope *envelope = geometryData.envelope;
        if(envelope != nil){
            envelope = [envelope mutableCopy];
        }
        [self setEnvelope:envelope];
        NSData *bytes = geometryData.bytes;
        if(bytes != nil){
            bytes = [NSData dataWithData:bytes];
        }
        self.bytes = bytes;
        self.wkbGeometryIndex = geometryData.wkbGeometryIndex;
        [self setByteOrder:geometryData.byteOrder];
    }
    return self;
}

-(instancetype) initWithData: (NSData *) bytes{
    self = [super init];
    if(self != nil){
        self.empty = YES;
        self.byteOrder = defaultByteOrder;
        [self fromData:bytes];
    }
    return self;
}

-(void) fromData: (NSData *) bytes{
    self.bytes = bytes;
    
    SFByteReader *reader = [[SFByteReader alloc] initWithData:bytes];
    
    // Get 2 bytes as the magic number and validate
    NSString *magic = [reader readString:2];
    if(![magic isEqualToString:GPKG_GEOMETRY_MAGIC_NUMBER]){
        [NSException raise:@"Invalid Magic Number" format:@"Unexpected GeoPackage Geometry magic number: %@, Expected: %@", magic, GPKG_GEOMETRY_MAGIC_NUMBER];
    }
    
    // Get a byte as the version and validate, value of 0 = version 1
    NSNumber *version = [reader readByte];
    if([version intValue] != GPKG_GEOMETRY_VERSION_1){
        [NSException raise:@"Invalid Version" format:@"Unexpected GeoPackage Geometry version: %@, Expected: %ld", version, (long)GPKG_GEOMETRY_VERSION_1];
    }
    
    // Get a flags byte and then read the flag values
    NSNumber *flags = [reader readByte];
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
        self.geometry = [SFWBGeometryReader readGeometryWithReader:reader andFilter:geometryFilter];
    }
    
}

-(NSData *) toData{
    SFByteWriter * writer = [[SFByteWriter alloc] init];
    
    // Write GP as the 2 byte magic number
    [writer writeString:GPKG_GEOMETRY_MAGIC_NUMBER];
    
    // Write a byte as the version, value of 0 = version 1
    [writer writeByte:[NSNumber numberWithInteger:GPKG_GEOMETRY_VERSION_1]];
    
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
        [SFWBGeometryWriter writeGeometry:self.geometry withWriter:writer];
    }
    
    // Get the bytes
    self.bytes = [writer data];
    
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
    int envelopeIndicator = self.envelope == nil ? 0 : [GPKGGeometryData indicatorWithEnvelope:self.envelope];
    flag += (envelopeIndicator << 1);
    
    // Add the byte order to bit 0, 0 for Big Endian and 1 for Little
    // Endian
    int byteOrderValue = (self.byteOrder == CFByteOrderBigEndian) ? 0 : 1;
    flag += byteOrderValue;
    
    return [NSNumber numberWithInt:flag];
}

-(SFGeometryEnvelope *) readEnvelopeWithIndicator: (int) envelopeIndicator andByteReader: (SFByteReader *) reader{
    
    SFGeometryEnvelope * envelope = nil;
    
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
        
        envelope = [[SFGeometryEnvelope alloc] initWithHasZ:hasZ andHasM:hasM];
        
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

-(void) writeEnvelopeWithByteWriter: (SFByteWriter *) writer{
    
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

-(void) setGeometry:(SFGeometry *) geometry{
    _geometry = geometry;
    self.empty = geometry == nil;
    if(geometry != nil){
        self.extended = [GPKGGeometryExtensions isNonStandard:geometry.geometryType];
    }
}

-(NSData *) setDataWithGeometry:(SFGeometry *) geometry{
    return [self setDataWithGeometry:geometry andBuildEnvelope:NO];
}

-(NSData *) setDataAndBuildEnvelopeWithGeometry: (SFGeometry *) geometry{
    return [self setDataWithGeometry:geometry andBuildEnvelope:YES];
}

/**
 * Set the geometry, optionally build the envelope, and write to bytes
 *
 * @param geometry
 *            geometry
 * @param buildEnvelope
 *            true to build and set the envelope
 * @return geometry bytes
 */
-(NSData *) setDataWithGeometry: (SFGeometry *) geometry andBuildEnvelope: (BOOL) buildEnvelope{
    [self setGeometry:geometry];
    if(buildEnvelope){
        [self buildEnvelope]
    }
    return [self toData];
}

-(void) setGeometryFromWkb: (NSData *) bytes{
    [self setGeometry:[GPKGGeometryData createGeometryFromWkb:data]];
}

-(void) setGeometryFromWkt: (NSString *) text{
    [self setGeometry:[GPKGGeometryData createGeometryFromWkt:text]];
}

-(NSData *) headerData{
    NSData *headerData = nil;
    if(self.bytes != nil){
        headerData = [self.bytes subdataWithRange:NSMakeRange(0, self.wkbGeometryIndex)];
    }
    return headerData;
}

-(NSData *) wkb{
    NSData *wkbData = nil;
    if(self.bytes != nil){
        int wkbByteCount = (int)[self.bytes length] - self.wkbGeometryIndex;
        wkbData = [self.bytes subdataWithRange:NSMakeRange(self.wkbGeometryIndex, wkbByteCount)];
    }
    return wkbData;
}

-(NSString *) wkt{
    NSString *wkt = nil;
    if(self.geometry != nil){
        wkt = [SFWTGeometryWriter writeGeometry:self.geometry];
    }
    return wkt;
}

-(SFGeometryEnvelope *) envelope{
    SFGeometryEnvelope *envelope = self.envelope;
    if(envelope == nil){
        envelope = [self buildEnvelope];
    }
    return envelope;
}

-(SFGeometryEnvelope *) buildEnvelope{
    SFGeometryEnvelope *envelope = nil;
    if(self.geometry != nil){
        envelope = [SFGeometryEnvelopeBuilder buildEnvelopeWithGeometry:self.geometry];
    }
    [self setEnvelope:envelope];
    return envelope;
}

+(int) indicatorWithEnvelope: (SFGeometryEnvelope *) envelope{
    int indicator = 1;
    if(envelope.hasZ){
        indicator++;
    }
    if(envelope.hasM){
        indicator += 2;
    }
    return indicator;
}

-(GPKGGeometryData *) transform: (SFPProjectionTransform *) transform{
    GPKGGeometryData *transformed = self;
    if([transform isSameProjection]){
        transformed = [[GPKGGeometryData alloc] initWithGeometryData:transformed];
    }else{
        SFGeometry *geometry = self.geometry;
        if(geometry != nil){
            geometry = [transform transformWithGeometry:geometry];
        }
        SFGeometryEnvelope *envelope = self.envelope;
        if(envelope != nil){
            envelope = [transform transformWithGeometryEnvelope:envelope];
        }
        transformed = [[GPKGGeometryData alloc] initWithSrsId:self.srsId andGeometry:geometry andEnvelope:envelope];
    }
    return transformed;
}

+(GPKGGeometryData *) writeData: (GPKGGeometryData *) geometryData{
    [geometryData toData];
    return geometryData;
}

@end
