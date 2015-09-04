//
//  GPKGIOUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGProgress.h"

@interface GPKGIOUtils : NSObject

/**
 *  Get the path of the property list file with name
 *
 *  @param name plist base file name
 *
 *  @return property list file path
 */
+(NSString *) getPropertyListPathWithName: (NSString *) name;

/**
 *  Get the path of the resource file with name and file type
 *
 *  @param name file name
 *  @param type extension type
 *
 *  @return file resource path
 */
+(NSString *) getResourcePathWithName: (NSString *) name andType: (NSString *) type;

/**
 *  Get the documents directory path
 *
 *  @return documents directory
 */
+(NSString *) documentsDirectory;

/**
 *  Get a sub directory path within the document directory
 *
 *  @param subDirectory sub directory path
 *
 *  @return documents sub directory path
 */
+(NSString *) documentsDirectoryWithSubDirectory: (NSString *) subDirectory;

/**
 *  Get the GeoPackage directory path for saving GeoPackage related files
 *
 *  @return GeoPackage directory
 */
+(NSString *) geoPackageDirectory;

/**
 *  Get the GeoPackage database directory path for saving GeoPackages
 *
 *  @return GeoPackage database directory
 */
+(NSString *) databaseDirectory;

/**
 *  Get the GeoPackage metadata directory path for saving metadata
 *
 *  @return GeoPackage metadata directory
 */
+(NSString *) metadataDirectory;

/**
 *  Get the GeoPackage metadata database file path
 *
 *  @return GeoPackage metadata database file path
 */
+(NSString *) metadataDatabaseFile;

/**
 *  Create a directory if it does not exist
 *
 *  @param directory directory to create
 */
+(void) createDirectoryIfNotExists: (NSString *) directory;

/**
 *  Copy a file
 *
 *  @param copyFrom file to copy
 *  @param copyTo   file location to copy to
 */
+(void) copyFile: (NSString *) copyFrom toFile: (NSString *) copyTo;

/**
 *  Copy an input stream to a file
 *
 *  @param copyFrom input stream to copy
 *  @param copyTo   file location to copy to
 */
+(void) copyInputStream: (NSInputStream *) copyFrom toFile: (NSString *) copyTo;

/**
 *  Copy an input stream to a file with progress callbacks
 *
 *  @param copyFrom input stream to copy
 *  @param copyTo   file location to copy to
 *  @param progress progress callbacks
 */
+(void) copyInputStream: (NSInputStream *) copyFrom toFile: (NSString *) copyTo withProgress: (NSObject<GPKGProgress> *) progress;

/**
 *  Get the file byte data
 *
 *  @param file file path
 *
 *  @return byte data
 */
+(NSData *) fileData: (NSString *) file;

/**
 *  Get the input stream byte data
 *
 *  @param stream input stream
 *
 *  @return input stream byte data
 */
+(NSData *) streamData: (NSInputStream *) stream;

/**
 *  Copy the input stream to an output stream
 *
 *  @param copyFrom input stream
 *  @param copyTo   output stream
 */
+(void) copyInputStream: (NSInputStream *) copyFrom toOutputStream: (NSOutputStream *) copyTo;

/**
 *  Copy the input stream to an output stream with progress callbacks
 *
 *  @param copyFrom input stream
 *  @param copyTo   output stream
 *  @param progress progress callbacks
 */
+(void) copyInputStream: (NSInputStream *) copyFrom toOutputStream: (NSOutputStream *) copyTo withProgress: (NSObject<GPKGProgress> *) progress;

/**
 *  Delete the file
 *
 *  @param file file path
 *
 *  @return true if deleted
 */
+(BOOL) deleteFile: (NSString *) file;

/**
 *  Format the bytes into readable text
 *
 *  @param bytes bytes
 *
 *  @return byte text
 */
+(NSString *) formatBytes: (int) bytes;

/**
 *  Decode a URL
 *
 *  @param url url
 *
 *  @return decoded url
 */
+(NSString *) decodeUrl: (NSString *) url;

@end
