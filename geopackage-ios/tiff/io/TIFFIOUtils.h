//
//  TIFFIOUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIFFIOUtils : NSObject

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

@end
