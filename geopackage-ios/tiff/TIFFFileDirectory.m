//
//  TIFFFileDirectory.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFFileDirectory.h"
#import "TIFFCompressionDecoder.h"
#import "TIFFRasters.h"
#import "TIFFConstants.h"
#import "TIFFRawCompression.h"
#import "TIFFLZWCompression.h"
#import "TIFFDeflateCompression.h"
#import "TIFFPackbitsCompression.h"

@interface TIFFFileDirectory()

@property (nonatomic, strong) NSMutableOrderedSet<TIFFFileDirectoryEntry *> * entries;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, TIFFFileDirectoryEntry *> * fieldTagTypeMapping;
@property (nonatomic, strong) TIFFByteReader * reader;
@property (nonatomic) BOOL tiled;
@property (nonatomic) int planarConfig;
@property (nonatomic, strong) NSObject<TIFFCompressionDecoder> * decoder;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSData *> * cache;
@property (nonatomic, strong) TIFFRasters * writeRasters;
@property (nonatomic) int lastBlockIndex;
@property (nonatomic, strong) NSData * lastBlock;

@end

@implementation TIFFFileDirectory

-(instancetype)initWithEntries: (NSMutableOrderedSet<TIFFFileDirectoryEntry *> *) entries andReader: (TIFFByteReader *) reader{
    return [self initWithEntries:entries andReader:reader andCacheData:false];
}

-(instancetype)initWithEntries: (NSMutableOrderedSet<TIFFFileDirectoryEntry *> *) entries andReader: (TIFFByteReader *) reader andCacheData: (BOOL) cacheData{
    self = [super init];
    if(self){
        // Set the entries and the field tag type mapping
        self.entries = entries;
        _fieldTagTypeMapping = [[NSMutableDictionary alloc] init];
        for(TIFFFileDirectoryEntry * entry in entries){
            NSNumber * fieldTagKey = [NSNumber numberWithInt:[TIFFFieldTagTypes tagId:[entry fieldTag]]];
            [_fieldTagTypeMapping setObject:entry forKey:fieldTagKey];
        }
        
        self.reader = reader;
        
        // Set the cache
        [self setCacheData:cacheData];
        
        // Determine if tiled
        self.tiled = [self rowsPerStrip] == nil;
        
        // Determine and validate the planar configuration
        NSNumber * pc = [self planarConfiguration];
        self.planarConfig = pc != nil ? [pc intValue] : (int)TIFF_PLANAR_CONFIGURATION_CHUNKY;
        if (self.planarConfig != TIFF_PLANAR_CONFIGURATION_CHUNKY
            && self.planarConfig != (int)TIFF_PLANAR_CONFIGURATION_PLANAR) {
            [NSException raise:@"Invalid" format:@"Invalid planar configuration: %d", self.planarConfig];
        }
        
        // Determine the decoder based upon the compression
        NSNumber * compression = [self compression];
        if (compression == nil) {
            compression = [NSNumber numberWithInteger:TIFF_COMPRESSION_NO];
        }
        
        NSInteger compressionInteger = [compression integerValue];
        if(compressionInteger == TIFF_COMPRESSION_NO){
            self.decoder = [[TIFFRawCompression alloc] init];
        }else if(compressionInteger == TIFF_COMPRESSION_CCITT_HUFFMAN){
            [NSException raise:@"Not Supported" format:@"CCITT Huffman compression not supported: %@", compression];
        }else if(compressionInteger == TIFF_COMPRESSION_T4){
            [NSException raise:@"Not Supported" format:@"T4-encoding compression not supported: %@", compression];
        }else if(compressionInteger == TIFF_COMPRESSION_T6){
            [NSException raise:@"Not Supported" format:@"T6-encoding compression not supported: %@", compression];
        }else if(compressionInteger == TIFF_COMPRESSION_LZW){
            self.decoder = [[TIFFLZWCompression alloc] init];
        }else if(compressionInteger == TIFF_COMPRESSION_JPEG_OLD || compressionInteger == TIFF_COMPRESSION_JPEG_NEW){
            [NSException raise:@"Not Supported" format:@"JPEG compression not supported: %@", compression];
        }else if(compressionInteger == TIFF_COMPRESSION_DEFLATE){
            self.decoder = [[TIFFDeflateCompression alloc] init];
        }else if(compressionInteger == TIFF_COMPRESSION_PACKBITS){
            self.decoder = [[TIFFPackbitsCompression alloc] init];
        }else{
            [NSException raise:@"Not Supported" format:@"Unknown compression method identifier: %@", compression];
        }
    }
    return self;
}

-(instancetype)init{
    return [self initWithRasters:nil];
}

-(instancetype)initWithRasters: (TIFFRasters *) rasters{
    return [self initWithEntries:[[NSMutableOrderedSet alloc] init] andRasters:rasters];
}

-(instancetype)initWithEntries: (NSMutableOrderedSet<TIFFFileDirectoryEntry *> *) entries andRasters: (TIFFRasters *) rasters{
    self = [super init];
    if(self){
        self.entries = entries;
        _fieldTagTypeMapping = [[NSMutableDictionary alloc] init];
        for(TIFFFileDirectoryEntry * entry in entries){
            NSNumber * fieldTagKey = [NSNumber numberWithInt:[TIFFFieldTagTypes tagId:[entry fieldTag]]];
            [_fieldTagTypeMapping setObject:entry forKey:fieldTagKey];
        }
        self.writeRasters = rasters;
    }
    return self;
}

-(void) addEntry: (TIFFFileDirectoryEntry *) entry{
    // TODO
}

-(void) setCacheData: (BOOL) cacheData{
    // TODO
}

-(TIFFByteReader *) reader{
    return nil; // TODO
}

-(BOOL) isTiled{
    return false; // TODO
}

-(NSObject<TIFFCompressionDecoder> *) decoder{
    return nil; // TODO
}

-(int) numEntries{
    return -1; // TODO
}

-(TIFFFileDirectoryEntry *) getByFieldTagType: (enum TIFFFieldTagType) fieldTagType{
    return nil; // TODO
}

-(NSOrderedSet<TIFFFileDirectoryEntry *> *) entries{
    return nil; // TODO
}

-(NSDictionary<NSNumber *, TIFFFileDirectoryEntry *> *) fieldTagTypeMapping{
    return nil; // TODO
}

-(NSNumber *) imageWidth{
    return nil; // TODO
}

-(void) setImageWidth: (unsigned short) width{
    // TODO
}

-(void) setImageWidthAsLong: (unsigned long) width{
    // TODO
}

-(NSNumber *) imageHeight{
    return nil; // TODO
}

-(void) setImageHeight: (unsigned short) height{
    // TODO
}

-(void) setImageHeightAsLong: (unsigned long) height{
    // TODO
}

-(NSArray<NSNumber *> *) bitsPerSample{
    return nil; // TODO
}

-(void) setBitsPerSample: (NSArray<NSNumber *> *) bitsPerSample{
    // TODO
}

-(void) setBitsPerSampleAsSingleValue: (unsigned short) bitsPerSample{
    // TODO
}

-(NSNumber *) maxBitsPerSample{
    return nil; // TODO
}

-(NSNumber *) compression{
    return nil; // TODO
}

-(void) setCompression: (unsigned short) compression{
    // TODO
}

-(NSNumber *) photometricInterpretation{
    return nil; // TODO
}

-(void) setPhotometricInterpretation: (unsigned short) photometricInterpretation{
    // TODO
}

-(NSArray<NSNumber *> *) stripOffsets{
    return nil; // TODO
}

-(void) setStripOffsets: (NSArray<NSNumber *> *) stripOffsets{
    // TODO
}

-(void) setStripOffsetsAsLongs: (NSArray<NSNumber *> *) stripOffsets{
    // TODO
}

-(void) setStripOffsetsAsSingleValue: (unsigned short) stripOffset{
    // TODO
}

-(void) setStripOffsetsAsSingleLongValue: (unsigned long) stripOffset{
    // TODO
}

-(NSNumber *) samplesPerPixel{
    return nil; // TODO
}

-(void) setSamplesPerPixel: (unsigned short) samplesPerPixel{
    // TODO
}

-(NSNumber *) rowsPerStrip{
    return nil; // TODO
}

-(void) setRowsPerStrip: (unsigned short) rowsPerStrip{
    // TODO
}

-(void) setRowsPerStripAsLong: (unsigned long) rowsPerStrip{
    // TODO
}

-(NSArray<NSNumber *> *) stripByteCounts{
    return nil; // TODO
}

-(void) setStripByteCounts: (NSArray<NSNumber *> *) stripByteCounts{
    // TODO
}

-(void) setStripByteCountsAsLongs: (NSArray<NSNumber *> *) stripByteCounts{
    // TODO
}

-(void) setStripByteCountsAsSingleValue: (unsigned short) stripOffset{
    // TODO
}

-(void) setStripByteCountsAsSingleLongValue: (unsigned long) stripOffset{
    // TODO
}

-(NSArray<NSNumber *> *) xResolution{
    return nil; // TODO
}

-(void) setXResolution: (NSArray<NSNumber *> *) xResolution{
    // TODO
}

-(void) setXResolutionAsSingleValue: (unsigned long) xResolution{
    // TODO
}

-(NSArray<NSNumber *> *) yResolution{
    return nil; // TODO
}

-(void) setYResolution: (NSArray<NSNumber *> *) yResolution{
    // TODO
}

-(void) setYResolutionAsSingleValue: (unsigned long) yResolution{
    // TODO
}

-(NSNumber *) planarConfiguration{
    return nil; // TODO
}

-(void) setPlanarConfiguration: (unsigned short) planarConfiguration{
    // TODO
}

-(NSNumber *) resolutionUnit{
    return nil; // TODO
}

-(void) setResolutionUnit: (unsigned short) resolutionUnit{
    // TODO
}

-(NSArray<NSNumber *> *) colorMap{
    return nil; // TODO
}

-(void) setColorMap: (NSArray<NSNumber *> *) colorMap{
    // TODO
}

-(void) setColorMapAsSingleValue: (unsigned short) colorMap{
    // TODO
}

-(NSNumber *) tileWidth{
    return nil; // TODO
}

-(void) setTileWidth: (unsigned short) tileWidth{
    // TODO
}

-(void) setTileWidthAsLong: (unsigned long) tileWidth{
    // TODO
}

-(NSNumber *) tileHeight{
    return nil; // TODO
}

-(void) setTileHeight: (unsigned short) tileHeight{
    // TODO
}

-(void) setTileHeightAsLong: (unsigned long) tileHeight{
    // TODO
}

-(NSArray<NSNumber *> *) tileOffsets{
    return nil; // TODO
}

-(void) setTileOffsets: (NSArray<NSNumber *> *) tileOffsets{
    // TODO
}

-(void) setTileOffsetsAsSingleValue: (unsigned short) tileOffset{
    // TODO
}

-(NSArray<NSNumber *> *) tileByteCounts{
    return nil; // TODO
}

-(void) setTileByteCounts: (NSArray<NSNumber *> *) tileByteCounts{
    // TODO
}

-(void) setTileByteCountsAsLongs: (NSArray<NSNumber *> *) tileByteCounts{
    // TODO
}

-(void) setTileByteCountsAsSingleValue: (unsigned short) tileByteCount{
    // TODO
}

-(void) setTileByteCountsAsSingleLongValue: (unsigned long) tileByteCount{
    // TODO
}

-(NSArray<NSNumber *> *) sampleFormat{
    return nil; // TODO
}

-(void) setSampleFormat: (NSArray<NSNumber *> *) sampleFormat{
    // TODO
}

-(void) setSampleFormatAsSingleValue: (unsigned short) sampleFormat{
    // TODO
}

-(NSNumber *) maxSampleFormat{
    return nil; // TODO
}

-(TIFFRasters *) writeRasters{
    return nil; // TODO
}

-(void) setWriteRasters: (TIFFRasters *) rasters{
    // TODO
}

-(TIFFRasters *) readRasters{
    return nil; // TODO
}

-(TIFFRasters *) readInterleavedRasters{
    return nil; // TODO
}

-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window{
    return nil; // TODO
}

-(TIFFRasters *) readInterleavedRastersWithWindow: (TIFFImageWindow *) window{
    return nil; // TODO
}

-(TIFFRasters *) readRastersWithSamples: (NSArray<NSNumber *> *) samples{
    return nil; // TODO
}

-(TIFFRasters *) readInterleavedRastersWithSamples: (NSArray<NSNumber *> *) samples{
    return nil; // TODO
}

-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples{
    return nil; // TODO
}

-(TIFFRasters *) readInterleavedRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples{
    return nil; // TODO
}

-(TIFFRasters *) readRastersWithSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues{
    return nil; // TODO
}

-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window andSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues{
    return nil; // TODO
}

-(TIFFRasters *) readRastersWithSamples: (NSArray<NSNumber *> *) samples andSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues{
    return nil; // TODO
}

-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples andSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues{
    return nil; // TODO
}

/**
 * Read and populate the rasters
 *
 * @param window
 *            image window
 * @param samples
 *            pixel samples to read
 * @param rasters
 *            rasters to populate
 */
-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples andRasters: (TIFFRasters *) rasters{
    return nil; // TODO
}

/**
 * Read the value from the reader according to the field type
 *
 * @param reader
 *            byte reader
 * @param fieldType
 *            field type
 * @return value
 */
-(NSNumber *) readValueWithByteReader: (TIFFByteReader *) reader andFieldType: (enum TIFFFieldType) fieldType{
    return nil; // TODO
}

-(enum TIFFFieldType) fieldTypeForSample: (int) sampleIndex{
    return 0; // TODO
}

/**
 * Get the tile or strip for the sample coordinate
 *
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @param sample
 *            sample index
 * @return bytes
 */
-(NSData *) tileOrStripWithX: (int) x andY: (int) y andSample: (int) sample{
    return nil; // TODO
}

/**
 * Get the sample byte size
 *
 * @param sampleIndex
 *            sample index
 * @return byte size
 */
-(int) sampleByteSizeOfSampleIndex: (int) sampleIndex{
    return 0; // TODO
}

/**
 * Calculates the number of bytes for each pixel across all samples. Only
 * full bytes are supported, an exception is thrown when this is not the
 * case.
 *
 * @return the bytes per pixel
 */
-(int) bytesPerPixel{
    return 0; // TODO
}

/**
 * Get an integer entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return integer value
 */
-(NSNumber *) integerEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return nil; // TODO
}

/**
 * Set an unsigned integer entry value for the field tag type
 *
 * @param value
 *            unsigned integer value (16 bit)
 * @param fieldTagType
 *            field tag type
 */
-(void) setUnsignedIntegerEntryValue: (unsigned short) value withFieldTag: (enum TIFFFieldTagType) fieldTagType{
    // TODO
}

/**
 * Get an number entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return number value
 */
-(NSNumber *) numberEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return nil; // TODO
}

/**
 * Set an unsigned long entry value for the field tag type
 *
 * @param value
 *            unsigned long value (32 bit)
 * @param fieldTagType
 *            field tag type
 */
-(void) setUnsignedLongEntryValue: (unsigned long) value withFieldTag: (enum TIFFFieldTagType) fieldTagType{
    // TODO
}

/**
 * Get an integer list entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return integer list value
 */
-(NSArray<NSNumber *> *) integerListEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return nil; // TODO
}

/**
 * Set an unsigned integer list of values for the field tag type
 *
 * @param value
 * @param fieldTagType
 */
-(void) setUnsignedIntegerListEntryValue: (NSArray<NSNumber *> *) value withFieldTag: (enum TIFFFieldTagType) fieldTagType{
    // TODO
}

/**
 * Get the max integer from integer list entry values
 *
 * @param fieldTagType
 *            field tag type
 * @return max integer value
 */
-(NSNumber *) maxIntegerEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return nil; // TODO
}

/**
 * Get a number list entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return long list value
 */
-(NSArray<NSNumber *> *) numberListEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return nil; // TODO
}

/**
 * Get a long list entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return long list value
 */
-(NSArray<NSNumber *> *) longListEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return nil; // TODO
}

/**
 * Set an unsigned long list of values for the field tag type
 *
 * @param value
 * @param fieldTagType
 */
-(void) setUnsignedLongListEntryValue: (NSArray<NSNumber *> *) value withFieldTag: (enum TIFFFieldTagType) fieldTagType{
    // TODO
}

/**
 * Get an entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return value
 */
-(NSObject *) entryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return nil; // TODO
}

/**
 * Create and set the entry value
 *
 * @param values
 *            entry values
 * @param fieldTagType
 *            field tag type
 * @param fieldType
 *            field type
 * @param typeCount
 *            type count
 */
-(void) setEntryValue: (NSObject *) values withFieldTag: (enum TIFFFieldTagType) fieldTagType andFieldType: (enum TIFFFieldType) fieldType andTypeCount: (int) typeCount{
    // TODO
}

/**
 * Sum the list integer values in the provided range
 *
 * @param values
 *            integer values
 * @param start
 *            inclusive start index
 * @param end
 *            exclusive end index
 * @return sum
 */
-(int) sumOfValues: (NSArray<NSNumber *> *) values fromStart: (int) start andEnd: (int) end{
    return 0; //TODO
}

/**
 * Create a single integer list with the value
 *
 * @param value
 *            int value
 * @return single value list
 */
-(NSArray<NSNumber *> *) createSingleIntegerListWithValue: (unsigned short) value{
    return nil; // TODO
}

/**
 * Create a single long list with the value
 *
 * @param value
 *            long value
 * @return single value list
 */
-(NSArray<NSNumber *> *) createSingleLongListWithValue: (unsigned long) value{
    return nil; // TODO
}

-(int) size{
    return 0; // TODO
}

-(int) sizeWithValues{
    return 0; // TODO
}

@end
