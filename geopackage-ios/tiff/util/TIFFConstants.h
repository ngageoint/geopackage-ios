//
//  TIFFConstants.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Little Endian byte order string
 */
extern NSString * const TIFF_BYTE_ORDER_LITTLE_ENDIAN;

/**
 * Big Endian byte order string
 */
extern NSString * const TIFF_BYTE_ORDER_BIG_ENDIAN;

/**
 * TIFF File Identifier
 */
extern NSInteger const TIFF_FILE_IDENTIFIER;

/**
 * TIFF header bytes
 */
extern NSInteger const TIFF_HEADER_BYTES;

/**
 * Image File Directory header / number of entries bytes
 */
extern NSInteger const TIFF_IFD_HEADER_BYTES;

/**
 * Image File Directory offset to the next IFD bytes
 */
extern NSInteger const TIFF_IFD_OFFSET_BYTES;

/**
 * Image File Directory entry bytes
 */
extern NSInteger const TIFF_IFD_ENTRY_BYTES;

/**
 * Default max bytes per strip when writing strips
 */
extern NSInteger const TIFF_DEFAULT_MAX_BYTES_PER_STRIP;

// Compression constants
extern NSInteger const TIFF_COMPRESSION_NO;
extern NSInteger const TIFF_COMPRESSION_CCITT_HUFFMAN;
extern NSInteger const TIFF_COMPRESSION_T4;
extern NSInteger const TIFF_COMPRESSION_T6;
extern NSInteger const TIFF_COMPRESSION_LZW;
extern NSInteger const TIFF_COMPRESSION_JPEG_OLD;
extern NSInteger const TIFF_COMPRESSION_JPEG_NEW;
extern NSInteger const TIFF_COMPRESSION_DEFLATE;
extern NSInteger const TIFF_COMPRESSION_PACKBITS;

// Extra Samples constants
extern NSInteger const TIFF_EXTRA_SAMPLES_UNSPECIFIED;
extern NSInteger const TIFF_EXTRA_SAMPLES_ASSOCIATED_ALPHA;
extern NSInteger const TIFF_EXTRA_SAMPLES_UNASSOCIATED_ALPHA;

// Fill Order constants
extern NSInteger const TIFF_FILL_ORDER_LOWER_COLUMN_HIGHER_ORDER;
extern NSInteger const TIFF_FILL_ORDER_LOWER_COLUMN_LOWER_ORDER;

// Gray Response constants
extern NSInteger const TIFF_GRAY_RESPONSE_TENTHS;
extern NSInteger const TIFF_GRAY_RESPONSE_HUNDREDTHS;
extern NSInteger const TIFF_GRAY_RESPONSE_THOUSANDTHS;
extern NSInteger const TIFF_GRAY_RESPONSE_TEN_THOUSANDTHS;
extern NSInteger const TIFF_GRAY_RESPONSE_HUNDRED_THOUSANDTHS;

// Orientation constants
extern NSInteger const TIFF_ORIENTATION_TOP_ROW_LEFT_COLUMN;
extern NSInteger const TIFF_ORIENTATION_TOP_ROW_RIGHT_COLUMN;
extern NSInteger const TIFF_ORIENTATION_BOTTOM_ROW_RIGHT_COLUMN;
extern NSInteger const TIFF_ORIENTATION_BOTTOM_ROW_LEFT_COLUMN;
extern NSInteger const TIFF_ORIENTATION_LEFT_ROW_TOP_COLUMN;
extern NSInteger const TIFF_ORIENTATION_RIGHT_ROW_TOP_COLUMN;
extern NSInteger const TIFF_ORIENTATION_RIGHT_ROW_BOTTOM_COLUMN;
extern NSInteger const TIFF_ORIENTATION_LEFT_ROW_BOTTOM_COLUMN;

// Photometric Interpretation constants
extern NSInteger const TIFF_PHOTOMETRIC_INTERPRETATION_WHITE_IS_ZERO;
extern NSInteger const TIFF_PHOTOMETRIC_INTERPRETATION_BLACK_IS_ZERO;
extern NSInteger const TIFF_PHOTOMETRIC_INTERPRETATION_RGB;
extern NSInteger const TIFF_PHOTOMETRIC_INTERPRETATION_PALETTE;
extern NSInteger const TIFF_PHOTOMETRIC_INTERPRETATION_TRANSPARENCY;

// Planar Configuration constants
extern NSInteger const TIFF_PLANAR_CONFIGURATION_CHUNKY;
extern NSInteger const TIFF_PLANAR_CONFIGURATION_PLANAR;

// Resolution Unit constants
extern NSInteger const TIFF_RESOLUTION_UNIT_NO;
extern NSInteger const TIFF_RESOLUTION_UNIT_INCH;
extern NSInteger const TIFF_RESOLUTION_UNIT_CENTIMETER;

// Sample Format constants
extern NSInteger const TIFF_SAMPLE_FORMAT_UNSIGNED_INT;
extern NSInteger const TIFF_SAMPLE_FORMAT_SIGNED_INT;
extern NSInteger const TIFF_SAMPLE_FORMAT_FLOAT;
extern NSInteger const TIFF_SAMPLE_FORMAT_UNDEFINED;

// Subfile Type constants
extern NSInteger const TIFF_SUBFILE_TYPE_FULL;
extern NSInteger const TIFF_SUBFILE_TYPE_REDUCED;
extern NSInteger const TIFF_SAMPLE_FORMAT_SINGLE_PAGE_MULTI_PAGE;

// Threshholding constants
extern NSInteger const TIFF_THRESHHOLDING_NO;
extern NSInteger const TIFF_THRESHHOLDING_ORDERED;
extern NSInteger const TIFF_THRESHHOLDING_RANDOM;

@interface TIFFConstants : NSObject

@end
