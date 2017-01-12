//
//  TIFFFileDirectory.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIFFFileDirectoryEntry.h"
#import "TIFFFieldTagTypes.h"
#import "TIFFByteReader.h"
#import "TIFFRasters.h"
#import "TIFFCompressionDecoder.h"
#import "TIFFRasters.h"
#import "TIFFImageWindow.h"

@class TIFFImageWindow;

/**
 * File Directory, represents all directory entries and can be used to read the
 * image raster
 */
@interface TIFFFileDirectory : NSObject

/**
 * Rasters to write to the TIFF file
 */
@property (nonatomic, strong) TIFFRasters * writeRasters;

/**
 * Initialize, for reading TIFF files
 *
 * @param entries
 *            file directory entries
 * @param reader
 *            TIFF file byte reader
 */
-(instancetype)initWithEntries: (NSMutableOrderedSet<TIFFFileDirectoryEntry *> *) entries andReader: (TIFFByteReader *) reader;

/**
 * Initialize, for reading TIFF files
 *
 * @param entries
 *            file directory entries
 * @param reader
 *            TIFF file byte reader
 * @param cacheData
 *            true to cache tiles and strips
 */
-(instancetype)initWithEntries: (NSMutableOrderedSet<TIFFFileDirectoryEntry *> *) entries andReader: (TIFFByteReader *) reader andCacheData: (BOOL) cacheData;

/**
 * Constructor, for writing TIFF files
 */
-(instancetype)init;

/**
 * Constructor, for writing TIFF files
 *
 * @param rasters
 *            image rasters to write
 */
-(instancetype)initWithRasters: (TIFFRasters *) rasters;

/**
 * Constructor, for writing TIFF files
 *
 * @param entries
 *            file directory entries
 * @param rasters
 *            image rasters to write
 */
-(instancetype)initWithEntries: (NSMutableOrderedSet<TIFFFileDirectoryEntry *> *) entries andRasters: (TIFFRasters *) rasters;

/**
 * Add an entry
 *
 * @param entry
 *            file directory entry
 */
-(void) addEntry: (TIFFFileDirectoryEntry *) entry;

/**
 * Set whether to cache tiles. Does nothing is already caching tiles, clears
 * the existing cache if set to false.
 *
 * @param cacheData
 *            true to cache tiles and strips
 */
-(void) setCacheData: (BOOL) cacheData;

/**
 * Get the byte reader
 *
 * @return byte reader
 */
-(TIFFByteReader *) reader;

/**
 * Is this a tiled image
 *
 * @return true if tiled
 */
-(BOOL) isTiled;

/**
 * Get the compression decoder
 *
 * @return compression decoder
 */
-(NSObject<TIFFCompressionDecoder> *) decoder;

/**
 * Get the number of entries
 *
 * @return entry count
 */
-(int) numEntries;

/**
 * Get a file directory entry from the field tag type
 *
 * @param fieldTagType
 *            field tag type
 * @return file directory entry
 */
-(TIFFFileDirectoryEntry *) getByFieldTagType: (enum TIFFFieldTagType) fieldTagType;

/**
 * Get the file directory entries
 *
 * @return file directory entries
 */
-(NSOrderedSet<TIFFFileDirectoryEntry *> *) entries;

/**
 * Get the field tag type to file directory entry mapping
 *
 * @return field tag type mapping
 */
-(NSDictionary<NSNumber *, TIFFFileDirectoryEntry *> *) fieldTagTypeMapping;

/**
 * Get the image width
 *
 * @return image width
 */
-(NSNumber *) imageWidth;

/**
 * Set the image width
 *
 * @param width
 *            image width
 */
-(void) setImageWidth: (unsigned short) width;

/**
 * Set the image width
 *
 * @param width
 *            image width
 */
-(void) setImageWidthAsLong: (unsigned long) width;

/**
 * Get the image height
 *
 * @return image height
 */
-(NSNumber *) imageHeight;

/**
 * Set the image height
 *
 * @param width
 *            image height
 */
-(void) setImageHeight: (unsigned short) height;

/**
 * Set the image height
 *
 * @param width
 *            image height
 */
-(void) setImageHeightAsLong: (unsigned long) height;

/**
 * Get the bits per sample
 *
 * @return bits per sample
 */
-(NSArray<NSNumber *> *) bitsPerSample;

/**
 * Set the bits per sample
 *
 * @param bitsPerSample
 *            bits per sample
 */
-(void) setBitsPerSample: (NSArray<NSNumber *> *) bitsPerSample;

/**
 * Set a single value bits per sample
 *
 * @param bitsPerSample
 *            bits per sample
 */
-(void) setBitsPerSampleAsSingleValue: (unsigned short) bitsPerSample;

/**
 * Get the max bits per sample
 *
 * @return max bits per sample
 */
-(NSNumber *) maxBitsPerSample;

/**
 * Get the compression
 *
 * @return compression
 */
-(NSNumber *) compression;

/**
 * Set the compression
 *
 * @param compression
 *            compression
 */
-(void) setCompression: (unsigned short) compression;

/**
 * Get the photometric interpretation
 *
 * @return photometric interpretation
 */
-(NSNumber *) photometricInterpretation;

/**
 * Set the photometric interpretation
 *
 * @param photometricInterpretation
 *            photometric interpretation
 */
-(void) setPhotometricInterpretation: (unsigned short) photometricInterpretation;

/**
 * Get the strip offsets
 *
 * @return strip offsets
 */
-(NSArray<NSNumber *> *) stripOffsets;

/**
 * Set the strip offsets
 *
 * @param stripOffsets
 *            strip offsets
 */
-(void) setStripOffsets: (NSArray<NSNumber *> *) stripOffsets;

/**
 * Set the strip offsets
 *
 * @param stripOffsets
 *            strip offsets
 */
-(void) setStripOffsetsAsLongs: (NSArray<NSNumber *> *) stripOffsets;

/**
 * Set a single value strip offset
 *
 * @param stripOffset
 *            strip offset
 */
-(void) setStripOffsetsAsSingleValue: (unsigned short) stripOffset;

/**
 * Set a single value strip offset
 *
 * @param stripOffset
 *            strip offset
 */
-(void) setStripOffsetsAsSingleLongValue: (unsigned long) stripOffset;

/**
 * Get the samples per pixel
 *
 * @return samples per pixel
 */
-(NSNumber *) samplesPerPixel;

/**
 * Set the samples per pixel
 *
 * @param samplesPerPixel
 *            samples per pixel
 */
-(void) setSamplesPerPixel: (unsigned short) samplesPerPixel;

/**
 * Get the rows per strip
 *
 * @return rows per strip
 */
-(NSNumber *) rowsPerStrip;

/**
 * Set the rows per strip
 *
 * @param rowsPerStrip
 *            rows per strip
 */
-(void) setRowsPerStrip: (unsigned short) rowsPerStrip;

/**
 * Set the rows per strip
 *
 * @param rowsPerStrip
 *            rows per strip
 */
-(void) setRowsPerStripAsLong: (unsigned long) rowsPerStrip;

/**
 * Get the strip byte counts
 *
 * @return strip byte counts
 */
-(NSArray<NSNumber *> *) stripByteCounts;

/**
 * Set the strip byte counts
 *
 * @param stripByteCounts
 *            strip byte counts
 */
-(void) setStripByteCounts: (NSArray<NSNumber *> *) stripByteCounts;

/**
 * Set the strip byte counts
 *
 * @param stripByteCounts
 *            strip byte counts
 */
-(void) setStripByteCountsAsLongs: (NSArray<NSNumber *> *) stripByteCounts;

/**
 * Set a single value strip byte count
 *
 * @param stripByteCount
 *            strip byte count
 */
-(void) setStripByteCountsAsSingleValue: (unsigned short) stripByteCount;

/**
 * Set a single value strip byte count
 *
 * @param stripByteCount
 *            strip byte count
 */
-(void) setStripByteCountsAsSingleLongValue: (unsigned long) stripByteCount;

/**
 * Get the x resolution
 *
 * @return x resolution
 */
-(NSArray<NSNumber *> *) xResolution;

/**
 * Set the x resolution
 *
 * @param xResolution
 *            x resolution
 */
-(void) setXResolution: (NSArray<NSNumber *> *) xResolution;

/**
 * Set a single value x resolution
 *
 * @param xResolution
 *            x resolution
 */
-(void) setXResolutionAsSingleValue: (unsigned long) xResolution;

/**
 * Get the y resolution
 *
 * @return y resolution
 */
-(NSArray<NSNumber *> *) yResolution;

/**
 * Set the y resolution
 *
 * @param yResolution
 *            y resolution
 */
-(void) setYResolution: (NSArray<NSNumber *> *) yResolution;

/**
 * Set a single value y resolution
 *
 * @param yResolution
 *            y resolution
 */
-(void) setYResolutionAsSingleValue: (unsigned long) yResolution;

/**
 * Get the planar configuration
 *
 * @return planar configuration
 */
-(NSNumber *) planarConfiguration;

/**
 * Set the planar configuration
 *
 * @param planarConfiguration
 *            planar configuration
 */
-(void) setPlanarConfiguration: (unsigned short) planarConfiguration;

/**
 * Get the resolution unit
 *
 * @return resolution unit
 */
-(NSNumber *) resolutionUnit;

/**
 * Set the resolution unit
 *
 * @param resolutionUnit
 *            resolution unit
 */
-(void) setResolutionUnit: (unsigned short) resolutionUnit;

/**
 * Get the color map
 *
 * @return color map
 */
-(NSArray<NSNumber *> *) colorMap;

/**
 * Set the color map
 *
 * @param colorMap
 *            color map
 */
-(void) setColorMap: (NSArray<NSNumber *> *) colorMap;

/**
 * Set a single value color map
 *
 * @param colorMap
 *            color map
 */
-(void) setColorMapAsSingleValue: (unsigned short) colorMap;

/**
 * Get the tile width
 *
 * @return tile width
 */
-(NSNumber *) tileWidth;

/**
 * Set the tile width
 *
 * @param tileWidth
 *            tile width
 */
-(void) setTileWidth: (unsigned short) tileWidth;

/**
 * Set the tile width
 *
 * @param tileWidth
 *            tile width
 */
-(void) setTileWidthAsLong: (unsigned long) tileWidth;

/**
 * Get the tile height
 *
 * @return tile height
 */
-(NSNumber *) tileHeight;

/**
 * Set the tile height
 *
 * @param tileHeight
 *            tile width
 */
-(void) setTileHeight: (unsigned short) tileHeight;

/**
 * Set the tile height
 *
 * @param tileHeight
 *            tile height
 */
-(void) setTileHeightAsLong: (unsigned long) tileHeight;

/**
 * Get the tile offsets
 *
 * @return tile offsets
 */
-(NSArray<NSNumber *> *) tileOffsets;

/**
 * Set the tile offsets
 *
 * @param tileOffsets
 *            tile offsets
 */
-(void) setTileOffsets: (NSArray<NSNumber *> *) tileOffsets;

/**
 * Set a single value tile offset
 *
 * @param tileOffset
 *            tile offset
 */
-(void) setTileOffsetsAsSingleValue: (unsigned short) tileOffset;

/**
 * Get the tile byte counts
 *
 * @return tile byte counts
 */
-(NSArray<NSNumber *> *) tileByteCounts;

/**
 * Set the tile byte counts
 *
 * @param tileByteCounts
 *            tile byte counts
 */
-(void) setTileByteCounts: (NSArray<NSNumber *> *) tileByteCounts;

/**
 * Set the tile byte counts
 *
 * @param tileByteCounts
 *            tile byte counts
 */
-(void) setTileByteCountsAsLongs: (NSArray<NSNumber *> *) tileByteCounts;

/**
 * Set a single value tile byte count
 *
 * @param tileByteCount
 *            tile byte count
 */
-(void) setTileByteCountsAsSingleValue: (unsigned short) tileByteCount;

/**
 * Set a single value tile byte count
 *
 * @param tileByteCount
 *            tile byte count
 */
-(void) setTileByteCountsAsSingleLongValue: (unsigned long) tileByteCount;

/**
 * Get the sample format
 *
 * @return sample format
 */
-(NSArray<NSNumber *> *) sampleFormat;

/**
 * Set the sample format
 *
 * @param sampleFormat
 *            sample format
 */
-(void) setSampleFormat: (NSArray<NSNumber *> *) sampleFormat;

/**
 * Set a single value sample format
 *
 * @param sampleFormat
 *            sample format
 */
-(void) setSampleFormatAsSingleValue: (unsigned short) sampleFormat;

/**
 * Get the max sample format
 *
 * @return max sample format
 */
-(NSNumber *) maxSampleFormat;

/**
 * Get the rasters for writing a TIFF file
 *
 * @return rasters image rasters
 */
-(TIFFRasters *) writeRasters;

/**
 * Set the rasters for writing a TIFF file
 *
 * @param rasters
 *            image rasters
 */
-(void) setWriteRasters: (TIFFRasters *) rasters;

/**
 * Read the rasters
 *
 * @return rasters
 */
-(TIFFRasters *) readRasters;

/**
 * Read the rasters as interleaved
 *
 * @return rasters
 */
-(TIFFRasters *) readInterleavedRasters;

/**
 * Read the rasters
 *
 * @param window
 *            image window
 * @return rasters
 */
-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window;

/**
 * Read the rasters as interleaved
 *
 * @param window
 *            image window
 * @return rasters
 */
-(TIFFRasters *) readInterleavedRastersWithWindow: (TIFFImageWindow *) window;

/**
 * Read the rasters
 *
 * @param samples
 *            pixel samples to read
 * @return rasters
 */
-(TIFFRasters *) readRastersWithSamples: (NSArray<NSNumber *> *) samples;

/**
 * Read the rasters as interleaved
 *
 * @param samples
 *            pixel samples to read
 * @return rasters
 */
-(TIFFRasters *) readInterleavedRastersWithSamples: (NSArray<NSNumber *> *) samples;

/**
 * Read the rasters
 *
 * @param window
 *            image window
 * @param samples
 *            pixel samples to read
 * @return rasters
 */
-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples;

/**
 * Read the rasters as interleaved
 *
 * @param window
 *            image window
 * @param samples
 *            pixel samples to read
 * @return rasters
 */
-(TIFFRasters *) readInterleavedRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples;

/**
 * Read the rasters
 *
 * @param sampleValues
 *            true to read results per sample
 * @param interleaveValues
 *            true to read results as interleaved
 * @return rasters
 */
-(TIFFRasters *) readRastersWithSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues;

/**
 * Read the rasters
 *
 * @param window
 *            image window
 * @param sampleValues
 *            true to read results per sample
 * @param interleaveValues
 *            true to read results as interleaved
 * @return rasters
 */
-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window andSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues;

/**
 * Read the rasters
 *
 * @param samples
 *            pixel samples to read
 * @param sampleValues
 *            true to read results per sample
 * @param interleaveValues
 *            true to read results as interleaved
 * @return rasters
 */
-(TIFFRasters *) readRastersWithSamples: (NSArray<NSNumber *> *) samples andSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues;

/**
 * Read the rasters
 *
 * @param window
 *            image window
 * @param samples
 *            pixel samples to read
 * @param sampleValues
 *            true to read results per sample
 * @param interleaveValues
 *            true to read results as interleaved
 * @return rasters
 */
-(TIFFRasters *) readRastersWithWindow: (TIFFImageWindow *) window andSamples: (NSArray<NSNumber *> *) samples andSampleValues: (BOOL) sampleValues andInterleaveValues: (BOOL) interleaveValues;

/**
 * Get the field type for the sample
 *
 * @param sampleIndex
 *            sample index
 * @return field type
 */
-(enum TIFFFieldType) fieldTypeForSample: (int) sampleIndex;

/**
 * Size in bytes of the Image File Directory (all contiguous)
 *
 * @return size in bytes
 */
-(int) size;

/**
 * Size in bytes of the image file directory including entry values (not
 * contiguous bytes)
 *
 * @return size in bytes
 */
-(int) sizeWithValues;

@end
