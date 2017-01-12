//
//  TIFFRasters.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Raster image values
 */
@interface TIFFRasters : NSObject

/**
 * Initialize
 *
 * @param width
 *            width of pixels
 * @param height
 *            height of pixels
 * @param samplesPerPixel
 *            samples per pixel
 * @param bitsPerSample
 *            bits per sample
 * @param sampleValues
 *            empty sample values double array
 */
-(instancetype) initWithWidth: (int) width andHeight: (int) height andSamplesPerPixel: (int) samplesPerPixel andBitsPerSample: (NSArray<NSNumber *> *) bitsPerSample andSampleValues: (NSMutableArray<NSMutableArray *> *) sampleValues;

/**
 * Initialize
 *
 * @param width
 *            width of pixels
 * @param height
 *            height of pixels
 * @param samplesPerPixel
 *            samples per pixel
 * @param bitsPerSample
 *            bits per sample
 * @param interleaveValues
 *            empty interleaved values array
 */
-(instancetype) initWithWidth: (int) width andHeight: (int) height andSamplesPerPixel: (int) samplesPerPixel andBitsPerSample: (NSArray<NSNumber *> *) bitsPerSample andInterleaveValues: (NSMutableArray *) interleaveValues;

/**
 * Initialize
 *
 * @param width
 *            width of pixels
 * @param height
 *            height of pixels
 * @param samplesPerPixel
 *            samples per pixel
 * @param bitsPerSample
 *            bits per sample
 * @param sampleValues
 *            empty sample values double array
 * @param interleaveValues
 *            empty interleaved values array
 */
-(instancetype) initWithWidth: (int) width andHeight: (int) height andSamplesPerPixel: (int) samplesPerPixel andBitsPerSample: (NSArray<NSNumber *> *) bitsPerSample andSampleValues: (NSMutableArray<NSMutableArray *> *) sampleValues andInterleaveValues: (NSMutableArray *) interleaveValues;

/**
 * Initialize
 *
 * @param width
 *            width of pixels
 * @param height
 *            height of pixels
 * @param samplesPerPixel
 *            samples per pixel
 * @param bitsPerSample
 *            bits per sample
 */
-(instancetype) initWithWidth: (int) width andHeight: (int) height andSamplesPerPixel: (int) samplesPerPixel andBitsPerSample: (NSArray<NSNumber *> *) bitsPerSample;

/**
 * Initialize
 *
 * @param width
 *            width of pixels
 * @param height
 *            height of pixels
 * @param samplesPerPixel
 *            samples per pixel
 * @param bitsPerSample
 *            bits per sample
 */
-(instancetype) initWithWidth: (int) width andHeight: (int) height andSamplesPerPixel: (int) samplesPerPixel andSingleBitsPerSample: (int) bitsPerSample;

/**
 * True if the results are stored by samples
 *
 * @return true if results exist
 */
-(BOOL) hasSampleValues;

/**
 * True if the results are stored interleaved
 *
 * @return true if results exist
 */
-(BOOL) hasInterleaveValues;

/**
 * Add a value to the sample results
 *
 * @param sampleIndex
 *            sample index
 * @param coordinate
 *            coordinate location
 * @param value
 *            value
 */
-(void) addSampleValue: (NSObject *) value toIndex: (int) sampleIndex andCoordinate: (int) coordinate;

/**
 * Add a value to the interleaved results
 *
 * @param coordinate
 *            coordinate location
 * @param value
 *            value
 */
-(void) addInterleaveValue: (NSObject *) value toCoordinate: (int) coordinate;

/**
 * Get the width of pixels
 *
 * @return width
 */
-(int) width;

/**
 * Get the height of pixels
 *
 * @return height
 */
-(int) height;

/**
 * Return the number of pixels
 *
 * @return number of pixels
 */
-(int) numPixels;

/**
 * Get the number of samples per pixel
 *
 * @return samples per pixel
 */
-(int) samplesPerPixel;

/**
 * Get the bits per sample
 *
 * @return bits per sample
 */
-(NSArray<NSNumber *> *) bitsPerSample;

/**
 * Get the results stored by samples
 *
 * @return sample values
 */
-(NSArray<NSArray *> *) sampleValues;

/**
 * Set the results stored by samples
 *
 * @param sampleValues
 *            sample values
 */
-(void) setSampleValuesAndValidate: (NSMutableArray<NSMutableArray *> *) sampleValues;

/**
 * Get the results stored as interleaved pixel samples
 *
 * @return interleaved values
 */
-(NSArray *) interleaveValues;

/**
 * Set the results stored as interleaved pixel samples
 *
 * @param interleaveValues
 *            interleaved values
 */
-(void) setInterleaveValuesAndValidate: (NSMutableArray *) interleaveValues;

/**
 * Get the pixel sample values
 *
 * @param x
 *            x coordinate (>= 0 && < width)
 * @param y
 *            y coordinate (>= 0 && < height)
 * @return pixel sample values
 */
-(NSArray *) pixelAtX: (int) x andY: (int) y;

/**
 * Set the pixel sample values
 *
 * @param x
 *            x coordinate (>= 0 && < width)
 * @param y
 *            y coordinate (>= 0 && < height)
 * @param values
 *            pixel values
 */
-(void) setPixelAtX: (int) x andY: (int) y withValues: (NSArray *) values;

/**
 * Get a pixel sample value
 *
 * @param sample
 *            sample index (>= 0 && < samplesPerPixel)
 * @param x
 *            x coordinate (>= 0 && < width)
 * @param y
 *            y coordinate (>= 0 && < height)
 * @return pixel sample
 */
-(NSObject *) pixelSampleAtSample: (int) sample andX: (int) x andY: (int) y;

/**
 * Set a pixel vample value
 *
 * @param sample
 *            sample index (>= 0 && < samplesPerPixel)
 * @param x
 *            x coordinate (>= 0 && < width)
 * @param y
 *            y coordinate (>= 0 && < height)
 * @param value
 *            pixel value
 */
-(void) setPixelSampleAtSample: (int) sample andX: (int) x andY: (int) y withValue: (NSObject *) value;

/**
 * Get the first pixel sample value, useful for single sample pixels
 * (grayscale)
 *
 * @param x
 *            x coordinate (>= 0 && < width)
 * @param y
 *            y coordinate (>= 0 && < height)
 * @return first pixel sample
 */
-(NSObject *) firstPixelSampleAtX: (int) x andY: (int) y;

/**
 * Set the first pixel sample value, useful for single sample pixels
 * (grayscale)
 *
 * @param x
 *            x coordinate (>= 0 && < width)
 * @param y
 *            y coordinate (>= 0 && < height)
 * @param value
 *            pixel value
 */
-(void) setFirstPixelSampleAtX: (int) x andY: (int) y withValue: (NSObject *) value;

/**
 * Get the sample index location
 *
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return sample index
 */
-(int) sampleIndexAtX: (int) x andY: (int) y;

/**
 * Get the interleave index location
 *
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return interleave index
 */
-(int) interleaveIndexAtX: (int) x andY: (int) y;

/**
 * Size in bytes of the image
 *
 * @return bytes
 */
-(int) size;

/**
 * Size in bytes of a pixel
 *
 * @return bytes
 */
-(int) sizePixel;

/**
 * Size in bytes of a sample
 *
 * @param sample
 *            sample index
 * @return bytes
 */
-(int) sizeSample: (int) sample;

/**
 * Calculate the rows per strip to write
 *
 * @param planarConfiguration
 *            chunky or planar
 * @return rows per strip
 */
-(int) calculateRowsPerStripWithPlanarConfiguration: (int) planarConfiguration;

/**
 * Calculate the rows per strip to write
 *
 * @param planarConfiguration
 *            chunky or planar
 * @param maxBytesPerStrip
 *            attempted max bytes per strip
 * @return rows per strip
 */
-(int) calculateRowsPerStripWithPlanarConfiguration: (int) planarConfiguration andMaxBytesPerStrip: (int) maxBytesPerStrip;

/**
 * Create an empty sample values array
 *
 * @param samplesPerPixel
 *            samples per pixel
 * @param width
 *            width of pixels
 * @param height
 *            height of pixels
 */
+(NSMutableArray<NSMutableArray *> *) createEmptySampleValuesWithSamplesPerPixel: (int) samplesPerPixel andWidth: (int) width andHeight: (int) height;

/**
 * Create an empty sample values array
 *
 * @param samplesPerPixel
 *            samples per pixel
 * @param pixels
 *            number of pixels
 */
+(NSMutableArray<NSMutableArray *> *) createEmptySampleValuesWithSamplesPerPixel: (int) samplesPerPixel andPixels: (int) pixels;

/**
 * Create an empty interleave values array
 *
 * @param samplesPerPixel
 *            samples per pixel
 * @param width
 *            width of pixels
 * @param height
 *            height of pixels
 */
+(NSMutableArray *) createEmptyInterleaveValuesWithSamplesPerPixel: (int) samplesPerPixel andWidth: (int) width andHeight: (int) height;

/**
 * Create an empty interleave values array
 *
 * @param samplesPerPixel
 *            samples per pixel
 * @param pixels
 *            number of pixels
 */
+(NSMutableArray *) createEmptyInterleaveValuesWithSamplesPerPixel: (int) samplesPerPixel andPixels: (int) pixels;

@end
