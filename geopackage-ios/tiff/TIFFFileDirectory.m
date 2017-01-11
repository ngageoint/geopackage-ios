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
    NSUInteger insertLocation = [_entries indexOfObject:entry inSortedRange:NSMakeRange(0, _entries.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(TIFFFileDirectoryEntry * obj1, TIFFFileDirectoryEntry * obj2){
        NSComparisonResult result = NSOrderedSame;
        int id = [TIFFFieldTagTypes tagId:[obj1 fieldTag]];
        int otherId = [TIFFFieldTagTypes tagId:[obj2 fieldTag]];
        if(id < otherId){
            result = NSOrderedAscending;
        } else if(id > otherId){
            result = NSOrderedDescending;
        }
        return result;
    }];
    NSNumber * fieldTagKey = [NSNumber numberWithInt:[TIFFFieldTagTypes tagId:[entry fieldTag]]];
    if([_fieldTagTypeMapping objectForKey:fieldTagKey] != nil){
        [_entries replaceObjectAtIndex:insertLocation withObject:entry];
    }else{
        [_entries insertObject:entry atIndex:insertLocation];
    }
    [_fieldTagTypeMapping setObject:entry forKey:fieldTagKey];
}

-(void) setCacheData: (BOOL) cacheData{
    if(cacheData){
        if(self.cache == nil){
            self.cache = [[NSMutableDictionary alloc] init];
        }
    }else{
        self.cache = nil;
    }
}

-(TIFFByteReader *) reader{
    return _reader;
}

-(BOOL) isTiled{
    return _tiled;
}

-(NSObject<TIFFCompressionDecoder> *) decoder{
    return _decoder;
}

-(int) numEntries{
    return (int)_entries.count;
}

-(TIFFFileDirectoryEntry *) getByFieldTagType: (enum TIFFFieldTagType) fieldTagType{
    return [_fieldTagTypeMapping objectForKey:[NSNumber numberWithInt:[TIFFFieldTagTypes tagId:fieldTagType]]];
}

-(NSOrderedSet<TIFFFileDirectoryEntry *> *) entries{
    return _entries;
}

-(NSDictionary<NSNumber *, TIFFFileDirectoryEntry *> *) fieldTagTypeMapping{
    return _fieldTagTypeMapping;
}

-(NSNumber *) imageWidth{
    return [self numberEntryValueWithFieldTag:TIFF_TAG_IMAGE_WIDTH];
}

-(void) setImageWidth: (unsigned short) width{
    [self setUnsignedShortEntryValue:width withFieldTag:TIFF_TAG_IMAGE_WIDTH];
}

-(void) setImageWidthAsLong: (unsigned long) width{
    [self setUnsignedLongEntryValue:width withFieldTag:TIFF_TAG_IMAGE_WIDTH];
}

-(NSNumber *) imageHeight{
    return [self numberEntryValueWithFieldTag:TIFF_TAG_IMAGE_LENGTH];
}

-(void) setImageHeight: (unsigned short) height{
    [self setUnsignedShortEntryValue:height withFieldTag:TIFF_TAG_IMAGE_LENGTH];
}

-(void) setImageHeightAsLong: (unsigned long) height{
    [self setUnsignedLongEntryValue:height withFieldTag:TIFF_TAG_IMAGE_LENGTH];
}

-(NSArray<NSNumber *> *) bitsPerSample{
    return [self shortListEntryValueWithFieldTag:TIFF_TAG_BITS_PER_SAMPLE];
}

-(void) setBitsPerSample: (NSArray<NSNumber *> *) bitsPerSample{
    [self setUnsignedShortListEntryValue:bitsPerSample withFieldTag:TIFF_TAG_BITS_PER_SAMPLE];
}

-(void) setBitsPerSampleAsSingleValue: (unsigned short) bitsPerSample{
    [self setBitsPerSample:[self createSingleShortListWithValue:bitsPerSample]];
}

-(NSNumber *) maxBitsPerSample{
    return [self maxShortEntryValueWithFieldTag:TIFF_TAG_BITS_PER_SAMPLE];
}

-(NSNumber *) compression{
    return [self shortEntryValueWithFieldTag:TIFF_TAG_COMPRESSION];
}

-(void) setCompression: (unsigned short) compression{
    [self setUnsignedShortEntryValue:compression withFieldTag:TIFF_TAG_COMPRESSION];
}

-(NSNumber *) photometricInterpretation{
    return [self shortEntryValueWithFieldTag:TIFF_TAG_PHOTOMETRIC_INTERPRETATION];
}

-(void) setPhotometricInterpretation: (unsigned short) photometricInterpretation{
    [self setUnsignedShortEntryValue:photometricInterpretation withFieldTag:TIFF_TAG_PHOTOMETRIC_INTERPRETATION];
}

-(NSArray<NSNumber *> *) stripOffsets{
    return [self numberListEntryValueWithFieldTag:TIFF_TAG_STRIP_OFFSETS];
}

-(void) setStripOffsets: (NSArray<NSNumber *> *) stripOffsets{
    [self setUnsignedShortListEntryValue:stripOffsets withFieldTag:TIFF_TAG_STRIP_OFFSETS];
}

-(void) setStripOffsetsAsLongs: (NSArray<NSNumber *> *) stripOffsets{
    [self setUnsignedLongListEntryValue:stripOffsets withFieldTag:TIFF_TAG_STRIP_OFFSETS];
}

-(void) setStripOffsetsAsSingleValue: (unsigned short) stripOffset{
    [self setStripOffsets:[self createSingleShortListWithValue:stripOffset]];
}

-(void) setStripOffsetsAsSingleLongValue: (unsigned long) stripOffset{
    [self setStripOffsetsAsLongs:[self createSingleLongListWithValue:stripOffset]];
}

-(NSNumber *) samplesPerPixel{
    return [self shortEntryValueWithFieldTag:TIFF_TAG_SAMPLES_PER_PIXEL];
}

-(void) setSamplesPerPixel: (unsigned short) samplesPerPixel{
    [self setUnsignedShortEntryValue:samplesPerPixel withFieldTag:TIFF_TAG_SAMPLES_PER_PIXEL];
}

-(NSNumber *) rowsPerStrip{
    return [self numberEntryValueWithFieldTag:TIFF_TAG_ROWS_PER_STRIP];
}

-(void) setRowsPerStrip: (unsigned short) rowsPerStrip{
    [self setUnsignedShortEntryValue:rowsPerStrip withFieldTag:TIFF_TAG_ROWS_PER_STRIP];
}

-(void) setRowsPerStripAsLong: (unsigned long) rowsPerStrip{
    [self setUnsignedLongEntryValue:rowsPerStrip withFieldTag:TIFF_TAG_ROWS_PER_STRIP];
}

-(NSArray<NSNumber *> *) stripByteCounts{
    return [self numberListEntryValueWithFieldTag:TIFF_TAG_STRIP_BYTE_COUNTS];
}

-(void) setStripByteCounts: (NSArray<NSNumber *> *) stripByteCounts{
    [self setUnsignedShortListEntryValue:stripByteCounts withFieldTag:TIFF_TAG_STRIP_BYTE_COUNTS];
}

-(void) setStripByteCountsAsLongs: (NSArray<NSNumber *> *) stripByteCounts{
    [self setUnsignedLongListEntryValue:stripByteCounts withFieldTag:TIFF_TAG_STRIP_BYTE_COUNTS];
}

-(void) setStripByteCountsAsSingleValue: (unsigned short) stripByteCount{
    [self setStripOffsets:[self createSingleShortListWithValue:stripByteCount]];
}

-(void) setStripByteCountsAsSingleLongValue: (unsigned long) stripByteCount{
    [self setStripOffsetsAsLongs:[self createSingleLongListWithValue:stripByteCount]];
}

-(NSArray<NSNumber *> *) xResolution{
    return [self longListEntryValueWithFieldTag:TIFF_TAG_X_RESOLUTION];
}

-(void) setXResolution: (NSArray<NSNumber *> *) xResolution{
    [self setUnsignedLongListEntryValue:xResolution withFieldTag:TIFF_TAG_X_RESOLUTION];
}

-(void) setXResolutionAsSingleValue: (unsigned long) xResolution{
    [self setXResolution:[self createSingleLongListWithValue:xResolution]];
}

-(NSArray<NSNumber *> *) yResolution{
    return [self longListEntryValueWithFieldTag:TIFF_TAG_Y_RESOLUTION];
}

-(void) setYResolution: (NSArray<NSNumber *> *) yResolution{
    [self setUnsignedLongListEntryValue:yResolution withFieldTag:TIFF_TAG_Y_RESOLUTION];
}

-(void) setYResolutionAsSingleValue: (unsigned long) yResolution{
    [self setYResolution:[self createSingleLongListWithValue:yResolution]];
}

-(NSNumber *) planarConfiguration{
    return [self shortEntryValueWithFieldTag:TIFF_TAG_PLANAR_CONFIGURATION];
}

-(void) setPlanarConfiguration: (unsigned short) planarConfiguration{
    [self setUnsignedShortEntryValue:planarConfiguration withFieldTag:TIFF_TAG_PLANAR_CONFIGURATION];
}

-(NSNumber *) resolutionUnit{
    return [self shortEntryValueWithFieldTag:TIFF_TAG_RESOLUTION_UNIT];
}

-(void) setResolutionUnit: (unsigned short) resolutionUnit{
    [self setUnsignedShortEntryValue:resolutionUnit withFieldTag:TIFF_TAG_RESOLUTION_UNIT];
}

-(NSArray<NSNumber *> *) colorMap{
    return [self shortListEntryValueWithFieldTag:TIFF_TAG_COLOR_MAP];
}

-(void) setColorMap: (NSArray<NSNumber *> *) colorMap{
    [self setUnsignedShortListEntryValue:colorMap withFieldTag:TIFF_TAG_COLOR_MAP];
}

-(void) setColorMapAsSingleValue: (unsigned short) colorMap{
    [self setColorMap:[self createSingleShortListWithValue:colorMap]];
}

-(NSNumber *) tileWidth{
    return self.tiled ? [self numberEntryValueWithFieldTag:TIFF_TAG_TILE_WIDTH] : [self imageWidth];
}

-(void) setTileWidth: (unsigned short) tileWidth{
    [self setUnsignedShortEntryValue:tileWidth withFieldTag:TIFF_TAG_TILE_WIDTH];
}

-(void) setTileWidthAsLong: (unsigned long) tileWidth{
    [self setUnsignedLongEntryValue:tileWidth withFieldTag:TIFF_TAG_TILE_WIDTH];
}

-(NSNumber *) tileHeight{
    return self.tiled ? [self numberEntryValueWithFieldTag:TIFF_TAG_TILE_LENGTH] : [self rowsPerStrip];
}

-(void) setTileHeight: (unsigned short) tileHeight{
    [self setUnsignedShortEntryValue:tileHeight withFieldTag:TIFF_TAG_TILE_LENGTH];
}

-(void) setTileHeightAsLong: (unsigned long) tileHeight{
    [self setUnsignedLongEntryValue:tileHeight withFieldTag:TIFF_TAG_TILE_LENGTH];
}

-(NSArray<NSNumber *> *) tileOffsets{
    return [self longListEntryValueWithFieldTag:TIFF_TAG_TILE_OFFSETS];
}

-(void) setTileOffsets: (NSArray<NSNumber *> *) tileOffsets{
    [self setUnsignedLongListEntryValue:tileOffsets withFieldTag:TIFF_TAG_TILE_OFFSETS];
}

-(void) setTileOffsetsAsSingleValue: (unsigned short) tileOffset{
    [self setTileOffsets:[self createSingleLongListWithValue:tileOffset]];
}

-(NSArray<NSNumber *> *) tileByteCounts{
    return [self numberListEntryValueWithFieldTag:TIFF_TAG_TILE_BYTE_COUNTS];
}

-(void) setTileByteCounts: (NSArray<NSNumber *> *) tileByteCounts{
    [self setUnsignedShortListEntryValue:tileByteCounts withFieldTag:TIFF_TAG_TILE_BYTE_COUNTS];
}

-(void) setTileByteCountsAsLongs: (NSArray<NSNumber *> *) tileByteCounts{
    [self setUnsignedLongListEntryValue:tileByteCounts withFieldTag:TIFF_TAG_TILE_BYTE_COUNTS];
}

-(void) setTileByteCountsAsSingleValue: (unsigned short) tileByteCount{
    [self setTileByteCounts:[self createSingleShortListWithValue:tileByteCount]];
}

-(void) setTileByteCountsAsSingleLongValue: (unsigned long) tileByteCount{
    [self setTileByteCountsAsLongs:[self createSingleLongListWithValue:tileByteCount]];
}

-(NSArray<NSNumber *> *) sampleFormat{
    return [self shortListEntryValueWithFieldTag:TIFF_TAG_SAMPLE_FORMAT];
}

-(void) setSampleFormat: (NSArray<NSNumber *> *) sampleFormat{
    [self setUnsignedShortListEntryValue:sampleFormat withFieldTag:TIFF_TAG_SAMPLE_FORMAT];
}

-(void) setSampleFormatAsSingleValue: (unsigned short) sampleFormat{
    [self setSampleFormat:[self createSingleShortListWithValue:sampleFormat]];
}

-(NSNumber *) maxSampleFormat{
    return [self maxShortEntryValueWithFieldTag:TIFF_TAG_SAMPLE_FORMAT];
}

-(TIFFRasters *) readRasters{
    TIFFImageWindow * window = [[TIFFImageWindow alloc] initWithFileDirectory:self];
    return [self readRastersWithWindow:window];
}

-(TIFFRasters *) readInterleavedRasters{
    TIFFImageWindow * window = [[TIFFImageWindow alloc] initWithFileDirectory:self];
    return [self readInterleavedRastersWithWindow:window];
}

-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window{
    return [self readRastersWithWindow:window andSamples:nil];
}

-(TIFFRasters *) readInterleavedRastersWithWindow: (TIFFImageWindow *) window{
    return [self readInterleavedRastersWithWindow:window andSamples:nil];
}

-(TIFFRasters *) readRastersWithSamples: (NSArray<NSNumber *> *) samples{
    TIFFImageWindow * window = [[TIFFImageWindow alloc] initWithFileDirectory:self];
    return [self readRastersWithWindow:window andSamples:samples];
}

-(TIFFRasters *) readInterleavedRastersWithSamples: (NSArray<NSNumber *> *) samples{
    TIFFImageWindow * window = [[TIFFImageWindow alloc] initWithFileDirectory:self];
    return [self readInterleavedRastersWithWindow:window andSamples:samples];
}

-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples{
    return [self readRastersWithWindow:window andSamples:samples andSampleValues:true andInterleaveValues:false];
}

-(TIFFRasters *) readInterleavedRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples{
    return [self readRastersWithWindow:window andSamples:samples andSampleValues:false andInterleaveValues:true];
}

-(TIFFRasters *) readRastersWithSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues{
    TIFFImageWindow * window = [[TIFFImageWindow alloc] initWithFileDirectory:self];
    return [self readRastersWithWindow:window andSampleValues:sampleValues andInterleaveValues:interleaveValues];
}

-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window andSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues{
    return [self readRastersWithWindow:window andSamples:nil andSampleValues:sampleValues andInterleaveValues:interleaveValues];
}

-(TIFFRasters *) readRastersWithSamples: (NSArray<NSNumber *> *) samples andSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues{
    TIFFImageWindow * window = [[TIFFImageWindow alloc] initWithFileDirectory:self];
    return [self readRastersWithWindow:window andSamples:samples andSampleValues:sampleValues andInterleaveValues:interleaveValues];
}

-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples andSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues{
    
    int width = [[self imageWidth] intValue];
    int height = [[self imageHeight] intValue];
    
    // Validate the image window
    if (window.minX < 0 || window.minY < 0 || window.maxX > width || window.maxY > height) {
        [NSException raise:@"Out of Bounds" format:@"Window is out of the image bounds. Width: %d, Height: %d, Windows: %@", width, height, window];
    } else if (window.minX > window.maxX || window.minY > window.maxY) {
        [NSException raise:@"Invalid Range" format:@"Invalid window range: %@", window];
    }
    
    int windowWidth = window.maxX - window.minX;
    int windowHeight = window.maxY - window.minY;
    int numPixels = windowWidth * windowHeight;
    
    // Set or validate the samples
    int samplesPerPixel = [[self samplesPerPixel] intValue];
    if (samples == nil) {
        NSMutableArray<NSNumber *> * allSamples = [[NSMutableArray alloc] initWithCapacity:samplesPerPixel];
        for (int i = 0; i < samplesPerPixel; i++) {
            [allSamples addObject:[NSNumber numberWithInt:i]];
        }
        samples = allSamples;
    } else {
        for (int i = 0; i < samples.count; i++) {
            if ([[samples objectAtIndex:i] intValue] >= samplesPerPixel) {
                [NSException raise:@"Invalid Index" format:@"Invalid sample index: %@", [samples objectAtIndex:i]];
            }
        }
    }
    
    // Create the interleaved result array
    NSMutableArray * interleave = nil;
    if (interleaveValues) {
        interleave = [TIFFRasters createEmptyInterleaveValuesWithSamplesPerPixel:(int)samples.count andPixels:numPixels];
    }
    
    // Create the sample indexed result double array
    NSMutableArray<NSMutableArray *> * sample = nil;
    if (sampleValues) {
        sample = [TIFFRasters createEmptySampleValuesWithSamplesPerPixel:(int)samples.count andPixels:numPixels];
    }
    
    // Create the rasters results
    TIFFRasters * rasters = [[TIFFRasters alloc] initWithWidth:windowWidth andHeight:windowHeight andSamplesPerPixel:samplesPerPixel andBitsPerSample:[self bitsPerSample] andSampleValues:sample andInterleaveValues:interleave];
    
    // Read the rasters
    [self readRastersWithWindow:window andSamples:samples andRasters:rasters];
    
    return rasters;
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
-(void) readRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples andRasters: (TIFFRasters *) rasters{

    int tileWidth = [[self tileWidth] intValue];
    int tileHeight = [[self tileHeight] intValue];

    int minXTile = floor(window.minX / ((double) tileWidth));
    int maxXTile = ceil(window.maxX / ((double) tileWidth));
    int minYTile = floor(window.minY / ((double) tileHeight));
    int maxYTile = ceil(window.maxY / ((double) tileHeight));
    
    int windowWidth = window.maxX - window.minX;
    
    int bytesPerPixel = [self bytesPerPixel];
    
    NSMutableArray<NSNumber *> * srcSampleOffsets = [[NSMutableArray alloc] initWithCapacity:samples.count];
    NSMutableArray<NSNumber *> * sampleFieldTypes = [[NSMutableArray alloc] initWithCapacity:samples.count];
    for (int i = 0; i < samples.count; i++) {
        int sampleOffset = 0;
        if (self.planarConfig == TIFF_PLANAR_CONFIGURATION_CHUNKY) {
            sampleOffset = [self sumOfValues:[self bitsPerSample] fromStart:0 andEnd:[[samples objectAtIndex:i] intValue]] / 8;
        }
        [srcSampleOffsets addObject:[NSNumber numberWithInt:sampleOffset]];
        [sampleFieldTypes addObject:[NSNumber numberWithInt:[self fieldTypeForSample:[[samples objectAtIndex:i] intValue]]]];
    }
    
    for (int yTile = minYTile; yTile < maxYTile; yTile++) {
        for (int xTile = minXTile; xTile < maxXTile; xTile++) {
            
            int firstLine = yTile * tileHeight;
            int firstCol = xTile * tileWidth;
            int lastLine = (yTile + 1) * tileHeight;
            int lastCol = (xTile + 1) * tileWidth;
            
            for (int sampleIndex = 0; sampleIndex < samples.count; sampleIndex++) {
                int sample = [[samples objectAtIndex:sampleIndex] intValue];
                if (self.planarConfig == TIFF_PLANAR_CONFIGURATION_PLANAR) {
                    bytesPerPixel = [self sampleByteSizeOfSampleIndex:sample];
                }
                
                NSData * block = [self tileOrStripWithX:xTile andY:yTile andSample:sample];
                TIFFByteReader * blockReader = [[TIFFByteReader alloc] initWithData:block andByteOrder:self.reader.byteOrder];
                
                for (int y = MAX(0, window.minY - firstLine); y < MIN(tileHeight, tileHeight - (lastLine - window.maxY)); y++) {
                         
                    for (int x = MAX(0, window.minX - firstCol); x < MIN(tileWidth, tileWidth - (lastCol - window.maxX)); x++) {
                                  
                        int pixelOffset = (y * tileWidth + x) * bytesPerPixel;
                        int valueOffset = pixelOffset + [[srcSampleOffsets objectAtIndex:sampleIndex] intValue];
                        [blockReader setNextByte:valueOffset];
                                  
                        // Read the value
                        NSNumber * value = [self readValueWithByteReader:blockReader andFieldType:[[sampleFieldTypes objectAtIndex: sampleIndex] intValue]];
                        
                        if([rasters hasInterleaveValues]){
                            int windowCoordinate = (y + firstLine - window.minY) * windowWidth * (int)samples.count + (x + firstCol - window.minX) * (int)samples.count + sampleIndex;
                            [rasters addInterleaveValue:value toCoordinate:windowCoordinate];
                        }
                                  
                        if ([rasters hasSampleValues]){
                            int windowCoordinate = (y + firstLine - window.minY) * windowWidth + x + firstCol - window.minX;
                            [rasters addSampleValue:value toIndex:sampleIndex andCoordinate:windowCoordinate];
                        }
                    }
                         
                }
            }
        }
    }
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
    
    NSNumber * value = nil;
    
    switch(fieldType){
        case TIFF_FIELD_BYTE:
            value = [reader readUnsignedByte];
            break;
        case TIFF_FIELD_SHORT:
            value = [reader readUnsignedShort];
            break;
        case TIFF_FIELD_LONG:
            value = [reader readUnsignedInt];
            break;
        case TIFF_FIELD_SBYTE:
            value = [reader readByte];
            break;
        case TIFF_FIELD_SSHORT:
            value = [reader readShort];
            break;
        case TIFF_FIELD_SLONG:
            value = [reader readInt];
            break;
        case TIFF_FIELD_FLOAT:
            value = [reader readFloat];
            break;
        case TIFF_FIELD_DOUBLE:
            value = [reader readDouble];
            break;
        default:
            [NSException raise:@"Unsupported Field Type" format:@"Unsupported raster field type %u", fieldType];
    }
    
    return value;
}

-(enum TIFFFieldType) fieldTypeForSample: (int) sampleIndex{

    enum TIFFFieldType fieldType;
    
    NSArray<NSNumber *> * sampleFormat = [self sampleFormat];
    int format = sampleFormat != nil ? [[sampleFormat objectAtIndex:sampleIndex] intValue] : (int)TIFF_SAMPLE_FORMAT_UNSIGNED_INT;
    int bitsPerSample = [[[self bitsPerSample] objectAtIndex:sampleIndex] intValue];
    
    if(format == TIFF_SAMPLE_FORMAT_UNSIGNED_INT){
        switch (bitsPerSample) {
            case 8:
                fieldType = TIFF_FIELD_BYTE;
                break;
            case 16:
                fieldType = TIFF_FIELD_SHORT;
                break;
            case 32:
                fieldType = TIFF_FIELD_LONG;
                break;
        }
    }else if(format == TIFF_SAMPLE_FORMAT_UNSIGNED_INT){
        switch (bitsPerSample) {
            case 8:
                fieldType = TIFF_FIELD_SBYTE;
                break;
            case 16:
                fieldType = TIFF_FIELD_SSHORT;
                break;
            case 32:
                fieldType = TIFF_FIELD_SLONG;
                break;
        }
    }else if(format == TIFF_SAMPLE_FORMAT_UNSIGNED_INT){
        switch (bitsPerSample) {
            case 32:
                fieldType = TIFF_FIELD_FLOAT;
                break;
            case 64:
                fieldType = TIFF_FIELD_DOUBLE;
                break;
        }
    }
    
    return fieldType;
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
    
    NSData * tileOrStrip = nil;
    
    int numTilesPerRow = ceil([[self imageWidth] doubleValue] / [[self tileWidth] doubleValue]);
    int numTilesPerCol = ceil([[self imageHeight] doubleValue] / [[self tileHeight] doubleValue]);
    
    int index = 0;
    if (self.planarConfig == TIFF_PLANAR_CONFIGURATION_CHUNKY) {
        index = y * numTilesPerRow + x;
    } else if (self.planarConfig == TIFF_PLANAR_CONFIGURATION_PLANAR) {
        index = sample * numTilesPerRow * numTilesPerCol + y * numTilesPerRow + x;
    }
    
    // Attempt to pull from the cache
    if (self.cache != nil && [self.cache objectForKey:[NSNumber numberWithInt:index]]  != nil) {
        tileOrStrip = [self.cache objectForKey:[NSNumber numberWithInt:index]];
    } else if (self.lastBlockIndex == index && self.lastBlock != nil) {
        tileOrStrip = self.lastBlock;
    } else {
        
        // Read and decode the block
        
        int offset = 0;
        int byteCount = 0;
        if (self.tiled) {
            offset = [[[self tileOffsets] objectAtIndex:index] intValue];
            byteCount = [[[self tileByteCounts] objectAtIndex:index] intValue];
        } else {
            offset = [[[self stripOffsets] objectAtIndex:index] intValue];
            byteCount = [[[self stripByteCounts] objectAtIndex:index] intValue];
        }
        
        [self.reader setNextByte:offset];
        NSData * bytes = [self.reader readBytesWithCount:byteCount];
        tileOrStrip = [self.decoder decodeData:bytes withByteOrder:self.reader.byteOrder];
        
        // Cache the data
        if (self.cache != nil) {
            [self.cache setObject:tileOrStrip forKey:[NSNumber numberWithInt:index]];
        } else {
            self.lastBlockIndex = index;
            self.lastBlock = tileOrStrip;
        }
    }
    
    return tileOrStrip;
}

/**
 * Get the sample byte size
 *
 * @param sampleIndex
 *            sample index
 * @return byte size
 */
-(int) sampleByteSizeOfSampleIndex: (int) sampleIndex{
    NSArray<NSNumber *> * bitsPerSample = [self bitsPerSample];
    if (sampleIndex >= bitsPerSample.count) {
        [NSException raise:@"Out of Range" format:@"Sample index %d is out of range", sampleIndex];
    }
    int bits = [[bitsPerSample objectAtIndex:sampleIndex] intValue];
    if ((bits % 8) != 0) {
        [NSException raise:@"Not Supported" format:@"Sample bit-width of %d is not supported", bits];
    }
    return (bits / 8);
}

/**
 * Calculates the number of bytes for each pixel across all samples. Only
 * full bytes are supported, an exception is thrown when this is not the
 * case.
 *
 * @return the bytes per pixel
 */
-(int) bytesPerPixel{
    int bitsPerSample = 0;
    NSArray<NSNumber *> * bitsPerSamples = [self bitsPerSample];
    for (int i = 0; i < bitsPerSamples.count; i++) {
        int bits = [[bitsPerSamples objectAtIndex:i] intValue];
        if ((bits % 8) != 0) {
            [NSException raise:@"Not Supported" format:@"Sample bit-width of %d is not supported", bits];
        } else if (bits != [[bitsPerSamples objectAtIndex:0] intValue]) {
            [NSException raise:@"Not Supported" format:@"Differing size of samples in a pixel are not supported. sample 0 = %@, sample %d = %d", [bitsPerSamples objectAtIndex: 0], i, bits];
        }
        bitsPerSample += bits;
    }
    return bitsPerSample / 8;
}

/**
 * Get a short entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return short  value
 */
-(NSNumber *) shortEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return (NSNumber *)[self entryValueWithFieldTag:fieldTagType];
}

/**
 * Set an unsigned short entry value for the field tag type
 *
 * @param value
 *            unsigned short value (16 bit)
 * @param fieldTagType
 *            field tag type
 */
-(void) setUnsignedShortEntryValue: (unsigned short) value withFieldTag: (enum TIFFFieldTagType) fieldTagType{
    [self setEntryValue:[NSNumber numberWithUnsignedShort:value] withFieldTag:fieldTagType andFieldType:TIFF_FIELD_SHORT andTypeCount:1];
}

/**
 * Get an number entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return number value
 */
-(NSNumber *) numberEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return (NSNumber *)[self entryValueWithFieldTag:fieldTagType];
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
    [self setEntryValue:[NSNumber numberWithUnsignedLong:value] withFieldTag:fieldTagType andFieldType:TIFF_FIELD_LONG andTypeCount:1];
}

/**
 * Get an short list entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return short list value
 */
-(NSArray<NSNumber *> *) shortListEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return (NSArray<NSNumber *> *)[self entryValueWithFieldTag:fieldTagType];
}

/**
 * Set an unsigned short list of values for the field tag type
 *
 * @param value
 * @param fieldTagType
 */
-(void) setUnsignedShortListEntryValue: (NSArray<NSNumber *> *) value withFieldTag: (enum TIFFFieldTagType) fieldTagType{
    [self setEntryValue:value withFieldTag:fieldTagType andFieldType:TIFF_FIELD_SHORT andTypeCount:(int)value.count];
}

/**
 * Get the max short from short list entry values
 *
 * @param fieldTagType
 *            field tag type
 * @return max short value
 */
-(NSNumber *) maxShortEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    NSNumber * maxValue = nil;
    NSArray<NSNumber *> * values = [self shortListEntryValueWithFieldTag:fieldTagType];
    if (values != nil) {
        maxValue = [[self sampleFormat] valueForKeyPath:@"@max.intValue"];
    }
    return maxValue;
}

/**
 * Get a number list entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return long list value
 */
-(NSArray<NSNumber *> *) numberListEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return (NSArray<NSNumber *> *)[self entryValueWithFieldTag:fieldTagType];
}

/**
 * Get a long list entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return long list value
 */
-(NSArray<NSNumber *> *) longListEntryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    return (NSArray<NSNumber *> *)[self entryValueWithFieldTag:fieldTagType];
}

/**
 * Set an unsigned long list of values for the field tag type
 *
 * @param value
 * @param fieldTagType
 */
-(void) setUnsignedLongListEntryValue: (NSArray<NSNumber *> *) value withFieldTag: (enum TIFFFieldTagType) fieldTagType{
    [self setEntryValue:value withFieldTag:fieldTagType andFieldType:TIFF_FIELD_LONG andTypeCount:(int)value.count];
}

/**
 * Get an entry value
 *
 * @param fieldTagType
 *            field tag type
 * @return value
 */
-(NSObject *) entryValueWithFieldTag: (enum TIFFFieldTagType) fieldTagType{
    NSObject * value = nil;
    TIFFFileDirectoryEntry * entry = [self.fieldTagTypeMapping objectForKey:[NSNumber numberWithInt:fieldTagType]];
    if(entry != nil){
        value = [entry values];
    }
    return value;
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
    TIFFFileDirectoryEntry * entry = [[TIFFFileDirectoryEntry alloc] initWithFieldTag:fieldTagType andFieldType:fieldType andTypeCount:typeCount andValues:values];
    [self addEntry:entry];
}

/**
 * Sum the list short values in the provided range
 *
 * @param values
 *            short values
 * @param start
 *            inclusive start index
 * @param end
 *            exclusive end index
 * @return sum
 */
-(int) sumOfValues: (NSArray<NSNumber *> *) values fromStart: (int) start andEnd: (int) end{
    int sum = 0;
    for (int i = start; i < end; i++) {
        sum += [[values objectAtIndex:i] intValue];
    }
    return sum;
}

/**
 * Create a single short list with the value
 *
 * @param value
 *            int value
 * @return single value list
 */
-(NSArray<NSNumber *> *) createSingleShortListWithValue: (unsigned short) value{
    return [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedShort:value], nil];
}

/**
 * Create a single long list with the value
 *
 * @param value
 *            long value
 * @return single value list
 */
-(NSArray<NSNumber *> *) createSingleLongListWithValue: (unsigned long) value{
    return [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedLong:value], nil];
}

-(int) size{
    return (int)(TIFF_IFD_HEADER_BYTES + (self.entries.count * TIFF_IFD_ENTRY_BYTES) + TIFF_IFD_OFFSET_BYTES);
}

-(int) sizeWithValues{
    int size = (int)(TIFF_IFD_HEADER_BYTES + TIFF_IFD_OFFSET_BYTES);
    for (TIFFFileDirectoryEntry * entry in self.entries) {
        size += [entry sizeWithValues];
    }
    return size;
}

@end
