//
//  TIFFImage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIFFFileDirectory.h"

/**
 * TIFF Image containing the File Directories
 */
@interface TIFFImage : NSObject

/**
 * Initialize
 */
-(instancetype) init;

/**
 * Initialize, single file directory
 *
 * @param fileDirectory
 *            file directory
 */
-(instancetype) initWithFileDirectory: (TIFFFileDirectory *) fileDirectory;

/**
 * Initialize, multiple file directories
 *
 * @param fileDirectories
 *            file directories
 */
-(instancetype) initWithFileDirectories: (NSArray<TIFFFileDirectory *> *) fileDirectories;

/**
 * Add a file directory
 *
 * @param fileDirectory
 *            file directory
 */
-(void) addFileDirectory: (TIFFFileDirectory *) fileDirectory;

/**
 * Get the file directories
 *
 * @return file directories
 */
-(void) addFileDirectories: (NSArray<TIFFFileDirectory *> *) fileDirectories;

/**
 * Get the default, first, or only file directory
 *
 * @return file directory
 */
-(TIFFFileDirectory *) fileDirectory;

/**
 * Get the file directory at the index
 *
 * @param index
 *            index
 * @return file directory
 */
-(TIFFFileDirectory *) fileDirectoryAtIndex: (int) index;

/**
 * Size in bytes of the TIFF header and file directories with their entries
 *
 * @return size in bytes
 */
-(int) sizeHeaderAndDirectories;

/**
 * Size in bytes of the TIFF header and file directories with their entries
 * and entry values
 *
 * @return size in bytes
 */
-(int) sizeHeaderAndDirectoriesWithValues;

@end
