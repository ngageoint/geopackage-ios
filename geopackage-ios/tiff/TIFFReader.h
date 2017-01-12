//
//  TIFFReader.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIFFImage.h"

/**
 * TIFF reader
 */
@interface TIFFReader : NSObject

/**
 * Read a TIFF from a file
 *
 * @param file
 *            TIFF file
 * @return TIFF image
 */
+(TIFFImage *) readTiffFromFile: (NSString *) file;

/**
 * Read a TIFF from a file
 *
 * @param file
 *            TIFF file
 * @param cache
 *            true to cache tiles and strips
 * @return TIFF image
 */
+(TIFFImage *) readTiffFromFile: (NSString *) file andCache: (BOOL) cache;

/**
 * Read a TIFF from an input stream
 *
 * @param stream
 *            TIFF input stream
 * @return TIFF image
 */
+(TIFFImage *) readTiffFromStream: (NSInputStream *) stream;

/**
 * Read a TIFF from an input stream
 *
 * @param stream
 *            TIFF input stream
 * @param cache
 *            true to cache tiles and strips
 * @return TIFF image
 */
+(TIFFImage *) readTiffFromStream: (NSInputStream *) stream andCache: (BOOL) cache;

/**
 * Read a TIFF from the bytes
 *
 * @param bytes
 *            TIFF bytes
 * @return TIFF image
 */
+(TIFFImage *) readTiffFromData: (NSData *) data;

/**
 * Read a TIFF from the bytes
 *
 * @param bytes
 *            TIFF bytes
 * @param cache
 *            true to cache tiles and strips
 * @return TIFF image
 */
+(TIFFImage *) readTiffFromData: (NSData *) data andCache: (BOOL) cache;

/**
 * Read a TIFF from the byte reader
 *
 * @param reader
 *            byte reader
 * @return TIFF image
 */
+(TIFFImage *) readTiffFromReader: (TIFFByteReader *) reader;

/**
 * Read a TIFF from the byte reader
 *
 * @param reader
 *            byte reader
 * @param cache
 *            true to cache tiles and strips
 * @return TIFF image
 */
+(TIFFImage *) readTiffFromReader: (TIFFByteReader *) reader andCache: (BOOL) cache;

@end
