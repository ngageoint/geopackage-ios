//
//  TIFFFieldTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Field tag type enumeration
 */
enum TIFFFieldType{
    TIFF_FIELD_BYTE = 1,
    TIFF_FIELD_ASCII,
    TIFF_FIELD_SHORT,
    TIFF_FIELD_LONG,
    TIFF_FIELD_RATIONAL,
    TIFF_FIELD_SBYTE,
    TIFF_FIELD_UNDEFINED,
    TIFF_FIELD_SSHORT,
    TIFF_FIELD_SLONG,
    TIFF_FIELD_SRATIONAL,
    TIFF_FIELD_FLOAT,
    TIFF_FIELD_DOUBLE
};

/**
 * Field Types
 */
@interface TIFFFieldTypes : NSObject

/**
 * Get the field type value
 *
 * @param fieldType field type
 *
 * @return field type value
 */
+(int) value: (enum TIFFFieldType) fieldType;

/**
 * Get the number of bytes per value
 *
 * @param fieldType field type
 *
 * @return number of bytes
 */
+(int) bytes: (enum TIFFFieldType) fieldType;

/**
 * Get the field type
 *
 * @param value
 *            field type value
 *
 * @return field type
 */
+(enum TIFFFieldType) typeByValue: (int) value;

@end
