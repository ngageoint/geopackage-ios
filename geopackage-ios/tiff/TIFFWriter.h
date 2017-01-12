//
//  TIFFWriter.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIFFImage.h"
#import "TIFFByteWriter.h"

/**
 * TIFF Writer.
 *
 * For a striped TIFF, the FileDirectory setStripOffsets(NSArray) and setStripByteCounts(NSArray) methods are automatically set or adjusted based upon attributes including:
 *    rowsPerStrip
 *    imageHeight
 *    planarConfiguration
 *    samplesPerPixel
 *
 * The Rasters calculateRowsPerStrip(int) and Rasters calculateRowsPerStrip(int, int) methods provide a mechanism
 * for determining a FileDirectory rowsPerStrip setting.
 */
@interface TIFFWriter : NSObject

/**
 * Write a TIFF to a file
 *
 * @param file
 *            file to create
 * @param tiffImage
 *            TIFF image
 */
+(void) writeTiffWithFile: (NSString *) file andImage: (TIFFImage *) tiffImage;

/**
 * Write a TIFF to a file
 *
 * @param file
 *            file to create
 * @param writer
 *            byte writer
 * @param tiffImage
 *            TIFF Image
 */
+(void) writeTiffWithFile: (NSString *) file andWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage;

/**
 * Write a TIFF to bytes
 *
 * @param tiffImage
 *            TIFF image
 * @return tiff bytes
 */
+(NSData *) writeTiffToDataWithImage: (TIFFImage *) tiffImage;

/**
 * Write a TIFF to bytes
 *
 * @param writer
 *            byte writer
 * @param tiffImage
 *            TIFF image
 * @return tiff bytes
 */
+(NSData *) writeTiffToDataWithWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage;

/**
 * Write a TIFF to a byte writer
 *
 * @param writer
 *            byte writer
 * @param tiffImage
 *            TIFF image
 */
+(void) writeTiffWithWriter: (TIFFByteWriter *) writer andImage: (TIFFImage *) tiffImage;

@end
