//
//  TIFFTestUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIFFImage.h"

@interface TIFFTestUtils : NSObject

+(void)assertNil:(id) value;

+(void)assertNotNil:(id) value;

+(void)assertTrue: (BOOL) value;

+(void)assertFalse: (BOOL) value;

+(void)assertEqualWithValue:(NSObject *) value andValue2: (NSObject *) value2;

+(void)assertEqualBoolWithValue:(BOOL) value andValue2: (BOOL) value2;

+(void)assertEqualIntWithValue:(int) value andValue2: (int) value2;

+(void)assertEqualDoubleWithValue:(double) value andValue2: (double) value2;

+(NSDecimalNumber *) roundDouble: (double) value;

+(NSDecimalNumber *) roundDouble: (double) value withScale: (int) scale;

+(int) randomIntLessThan: (int) max;

+(double) randomDouble;

+(double) randomDoubleLessThan: (double) max;

+(BOOL) coinFlip;

/**
 * Compare two TIFF Images
 *
 * @param tiffImage1
 *            tiff image 1
 * @param tiffImage2
 *            tiff image 2
 */
+(void) compareTIFFImagesWithImage1: (TIFFImage *) tiffImage1 andImage2: (TIFFImage *) tiffImage2;

/**
 * Compare two TIFF Images
 *
 * @param tiffImage1
 *            tiff image 1
 * @param tiffImage2
 *            tiff image 2
 * @param exactType
 *            true if matching the exact data type
 * @param sameBitsPerSample
 *            true if should have the same bits per sample
 */
+(void) compareTIFFImagesWithImage1: (TIFFImage *) tiffImage1 andImage2: (TIFFImage *) tiffImage2 andExactType: (BOOL) exactType andSameBitsPerSample: (BOOL) sameBitsPerSample;

/**
 * Compare rasters sample values
 *
 * @param rasters1
 *            rasters 1
 * @param rasters2
 *            rasters 2
 */
+(void) compareRastersSampleValuesWithRasters1: (TIFFRasters *) rasters1 andRasters2: (TIFFRasters *) rasters2;

/**
 * Compare rasters sample values
 *
 * @param rasters1
 *            rasters 1
 * @param rasters2
 *            rasters 2
 * @param exactType
 *            true if matching the exact data type
 * @param sameBitsPerSample
 *            true if should have the same bits per sample
 */
+(void) compareRastersSampleValuesWithRasters1: (TIFFRasters *) rasters1 andRasters2: (TIFFRasters *) rasters2 andExactType: (BOOL) exactType andSameBitsPerSample: (BOOL) sameBitsPerSample;

/**
 * Compare rasters interleave values
 *
 * @param rasters1
 *            rasters 1
 * @param rasters2
 *            rasters 2
 */
+(void) compareRastersInterleaveValuesWithRasters1: (TIFFRasters *) rasters1 andRasters2: (TIFFRasters *) rasters2;

/**
 * Compare rasters interleave values
 *
 * @param rasters1
 *            rasters 1
 * @param rasters2
 *            rasters 2
 * @param exactType
 *            true if matching the exact data type
 * @param sameBitsPerSample
 *            true if should have the same bits per sample
 */
+(void) compareRastersInterleaveValuesWithRasters1: (TIFFRasters *) rasters1 andRasters2: (TIFFRasters *) rasters2 andExactType: (BOOL) exactType andSameBitsPerSample: (BOOL) sameBitsPerSample;

/**
 * Compare rasters pixel values
 *
 * @param fileDirectory1
 *            file directory 1
 * @param rasters1
 *            rasters 1
 * @param fileDirectory2
 *            file directory 2
 * @param rasters2
 *            rasters 2
 * @param exactType
 *            true if matching the exact data type
 * @param sameBitsPerSample
 *            true if should have the same bits per sample
 */
+(void) compareRastersWithFileDirectory1: (TIFFFileDirectory *) fileDirectory1 andRasters1: (TIFFRasters *) rasters1 andFileDirectory2: (TIFFFileDirectory *) fileDirectory2 andRasters2: (TIFFRasters *) rasters2 andExactType: (BOOL) exactType andSameBitsPerSample: (BOOL) sameBitsPerSample;

/**
 * Get the file
 *
 * @param fileName
 *            file name
 * @return file
 */
+(NSString *) getTestFileWithName: (NSString *) fileName;

@end
