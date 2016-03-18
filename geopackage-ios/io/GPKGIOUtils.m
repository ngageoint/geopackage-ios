//
//  GPKGIOUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGIOUtils.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"

@implementation GPKGIOUtils

+(NSString *) getPropertyListPathWithName: (NSString *) name{
    return [self getResourcePathWithName:name andType:GPKG_GEO_PACKAGE_PROPERTY_LIST_TYPE];
}

+(NSString *) getResourcePathWithName: (NSString *) name andType: (NSString *) type{
    
    NSString * resource = [NSString stringWithFormat:@"%@/%@", GPKG_GEO_PACKAGE_BUNDLE_NAME, name];
    NSString * resourcePath = [[NSBundle mainBundle] pathForResource:resource ofType:type];
    if(resourcePath == nil){
        resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:resource ofType:type];
        if(resourcePath == nil){
            resourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:type];
            if(resourcePath == nil){
                resourcePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
            }
        }
    }
    if(resourcePath == nil){
        [NSException raise:@"Resource Not Found" format:@"Failed to find resource '%@' of type '%@'", name, type];
    }
    
    return resourcePath;
}

+(NSString *) documentsDirectory{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documents = [paths objectAtIndex:0];
    return documents;
}

+(NSString *) documentsDirectoryWithSubDirectory: (NSString *) subDirectory{
    NSString * documents = [self documentsDirectory];
    NSString * directory = [documents stringByAppendingPathComponent:subDirectory];
    return directory;
}

+(NSString *) geoPackageDirectory{
    NSString * geopackage = [GPKGProperties getValueOfProperty:GPKG_PROP_DIR_GEOPACKAGE];
    [self createDirectoryIfNotExists:geopackage];
    return geopackage;
}

+(NSString *) databaseDirectory{
    NSString * geopackage = [self geoPackageDirectory];
    NSString * database = [geopackage stringByAppendingPathComponent:[GPKGProperties getValueOfProperty:GPKG_PROP_DIR_DATABASE]];
    [self createDirectoryIfNotExists:database];
    return database;
}

+(NSString *) metadataDirectory{
    NSString * geopackage = [self geoPackageDirectory];
    NSString * metadata = [geopackage stringByAppendingPathComponent:[GPKGProperties getValueOfProperty:GPKG_PROP_DIR_METADATA]];
    [self createDirectoryIfNotExists:metadata];
    return metadata;
}

+(NSString *) metadataDatabaseFile{
    NSString * metadataDirectory = [self metadataDirectory];
    NSString * metadataFile = [metadataDirectory stringByAppendingPathComponent:[GPKGProperties getValueOfProperty:GPKG_PROP_DIR_METADATA_FILE_DB]];
    return metadataFile;
}

+(void) createDirectoryIfNotExists: (NSString *) directory{
    NSString * documentsDirectory = [self documentsDirectoryWithSubDirectory:directory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
        NSError *error = nil;
        BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if(error || !created){
            NSLog(@"Failed to create directory at path '%@' with error: %@", documentsDirectory, error);
        }
    }
}

+(NSString *) localDocumentsDirectoryPath: (NSString *) directory{
    NSString * documents = [NSString stringWithFormat:@"%@/", [self documentsDirectory]];
    NSString * path = directory;
    if([directory hasPrefix:documents]){
        path = [directory substringFromIndex:[documents length]];
    } else{
        documents = [NSString stringWithFormat:@"/private%@", documents];
        if([directory hasPrefix:documents]){
            path = [directory substringFromIndex:[documents length]];
        }
    }
    return path;
}

+(void) copyFile: (NSString *) copyFrom toFile: (NSString *) copyTo{
    
    NSInputStream * from = [NSInputStream inputStreamWithFileAtPath:copyFrom];
    NSOutputStream * to = [NSOutputStream outputStreamToFileAtPath:copyTo append:false];
    [to open];
    
    [self copyInputStream:from toOutputStream:to];
    
    [to close];
}

+(void) copyInputStream: (NSInputStream *) copyFrom toFile: (NSString *) copyTo{
    [self copyInputStream:copyFrom toFile:copyTo withProgress:nil];
}

+(void) copyInputStream: (NSInputStream *) copyFrom toFile: (NSString *) copyTo withProgress: (NSObject<GPKGProgress> *) progress{
    
    NSOutputStream * outputStream = [NSOutputStream outputStreamToFileAtPath:copyTo append:false];
    [outputStream open];
    
    [self copyInputStream:copyFrom toOutputStream:outputStream withProgress:progress];
    
    [outputStream close];
    
    // Try to delete the file if progress was cancelled
    if(progress != nil && ![progress isActive] && [progress cleanupOnCancel]){
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        BOOL fileDeleted = [fileManager removeItemAtPath:copyTo error:&error];
        if(error || !fileDeleted){
            NSLog(@"Failed to delete file copied from stream at path '%@' with error: %@", copyTo, error);
        }
    }
}

+(NSData *) fileData: (NSString *) file{
    
    NSInputStream * inputStream = [NSInputStream inputStreamWithFileAtPath:file];
    
    return [self streamData:inputStream];
}

+(NSData *) streamData: (NSInputStream *) stream{
    
    NSOutputStream * outputStream = [NSOutputStream outputStreamToMemory];
    [outputStream open];
    
    [self copyInputStream:stream toOutputStream:outputStream];
    
    NSData *data = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    [outputStream close];
    
    return data;
}

+(void) copyInputStream: (NSInputStream *) copyFrom toOutputStream: (NSOutputStream *) copyTo{
    [self copyInputStream:copyFrom toOutputStream:copyTo withProgress:nil];
}

+(void) copyInputStream: (NSInputStream *) copyFrom toOutputStream: (NSOutputStream *) copyTo withProgress: (NSObject<GPKGProgress> *) progress{
    NSInteger bufferSize = 1024;
    NSInteger length;
    uint8_t buffer[bufferSize];
    while((progress == nil || [progress isActive])
          && (length = [copyFrom read:buffer maxLength:bufferSize]) != 0) {
        if(length > 0) {
            [copyTo write:buffer maxLength:length];
            if(progress != nil){
                [progress addProgress:(int)length];
            }
        } else {
            [NSException raise:@"Copy Stream Error" format:@"%@", [[copyFrom streamError] localizedDescription]];
        }
    }
    
    [copyFrom close];
}

+(BOOL) deleteFile: (NSString *) file{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL fileDeleted = [fileManager removeItemAtPath:file error:&error];
    if(error || !fileDeleted){
        NSLog(@"Failed to delete GeoPackage file at '%@' with error: %@", file, error);
    }
    return fileDeleted;
}

+(NSString *) formatBytes: (int) bytes{
    
    double value = bytes;
    NSString * unit = @"B";
    
    if (bytes >= 1024) {
        int exponent = (int) (log(bytes) / log(1024));
        exponent = MIN(exponent, 4);
        switch (exponent) {
            case 1:
                unit = @"KB";
                break;
            case 2:
                unit = @"MB";
                break;
            case 3:
                unit = @"GB";
                break;
            case 4:
                unit = @"TB";
                break;
        }
        value = bytes / pow(1024, exponent);
    }
    
    return [NSString stringWithFormat:@"%.02f %@", value, unit];
}

+(NSString *) decodeUrl: (NSString *) url{
    NSString *result = [url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

@end
