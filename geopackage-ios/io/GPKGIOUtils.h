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

+(NSString *) getPropertyListPathWithName: (NSString *) name;

+(NSString *) getResourcePathWithName: (NSString *) name andType: (NSString *) type;

+(NSString *) documentsDirectory;

+(NSString *) documentsDirectoryWithSubDirectory: (NSString *) subDirectory;

+(NSString *) geoPackageDirectory;

+(NSString *) databaseDirectory;

+(NSString *) metadataDirectory;

+(NSString *) metadataDatabaseFile;

+(void) createDirectoryIfNotExists: (NSString *) directory;

+(void) copyFile: (NSString *) copyFrom toFile: (NSString *) copyTo;

+(void) copyInputStream: (NSInputStream *) copyFrom toFile: (NSString *) copyTo;

+(void) copyInputStream: (NSInputStream *) copyFrom toFile: (NSString *) copyTo withProgress: (NSObject<GPKGProgress> *) progress;

+(NSData *) fileData: (NSString *) file;

+(NSData *) streamData: (NSInputStream *) stream;

+(void) copyInputStream: (NSInputStream *) copyFrom toOutputStream: (NSOutputStream *) copyTo;

+(void) copyInputStream: (NSInputStream *) copyFrom toOutputStream: (NSOutputStream *) copyTo withProgress: (NSObject<GPKGProgress> *) progress;

+(BOOL) deleteFile: (NSString *) file;

+(NSString *) formatBytes: (int) bytes;

+(NSString *) decodeUrl: (NSString *) url;

@end
