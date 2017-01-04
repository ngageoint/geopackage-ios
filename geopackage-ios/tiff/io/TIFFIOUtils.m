//
//  TIFFIOUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFIOUtils.h"

@implementation TIFFIOUtils

+(void) copyFile: (NSString *) copyFrom toFile: (NSString *) copyTo{
    
    NSInputStream * from = [NSInputStream inputStreamWithFileAtPath:copyFrom];
    NSOutputStream * to = [NSOutputStream outputStreamToFileAtPath:copyTo append:false];
    [to open];
    
    [self copyInputStream:from toOutputStream:to];
    
    [to close];
}

+(void) copyInputStream: (NSInputStream *) copyFrom toFile: (NSString *) copyTo{
    
    NSOutputStream * outputStream = [NSOutputStream outputStreamToFileAtPath:copyTo append:false];
    [outputStream open];
    
    [self copyInputStream:copyFrom toOutputStream:outputStream];
    
    [outputStream close];
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

    NSInteger bufferSize = 1024;
    NSInteger length;
    uint8_t buffer[bufferSize];
    while((length = [copyFrom read:buffer maxLength:bufferSize]) != 0) {
        if(length > 0) {
            [copyTo write:buffer maxLength:length];
        } else {
            [NSException raise:@"Copy Stream Error" format:@"%@", [[copyFrom streamError] localizedDescription]];
        }
    }
    
    [copyFrom close];
}

@end
