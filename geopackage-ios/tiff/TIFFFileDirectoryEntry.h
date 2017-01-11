//
//  TIFFFileDirectoryEntry.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIFFFieldTagTypes.h"
#import "TIFFFieldTypes.h"

/**
 * TIFF File Directory Entry
 */
@interface TIFFFileDirectoryEntry : NSObject

/**
 * Initialize
 *
 * @param fieldTag
 *            field tag type
 * @param fieldType
 *            field type
 * @param typeCount
 *            type count
 * @param values
 *            values
 */
-(instancetype)initWithFieldTag: (enum TIFFFieldTagType) fieldTag andFieldType: (enum TIFFFieldType) fieldType andTypeCount: (int) typeCount andValues: (NSObject *) values;

/**
 * Get the field tag type
 *
 * @return field tag type
 */
-(enum TIFFFieldTagType) fieldTag;

/**
 * Get the field type
 *
 * @return field type
 */
-(enum TIFFFieldType) fieldType;

/**
 * Get the type count
 *
 * @return type count
 */
-(int) typeCount;

/**
 * Get the values
 *
 * @return values
 */
-(NSObject *) values;

/**
 * Size in bytes of the image file directory entry and its values (not
 * contiguous bytes)
 *
 * @return size in bytes
 */
-(int) sizeWithValues;

/**
 * Size of the values not included in the directory entry bytes
 *
 * @return size in bytes
 */
-(int) sizeOfValues;

@end
