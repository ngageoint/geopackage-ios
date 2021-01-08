//
//  GPKGNetworkUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/8/21.
//  Copyright © 2021 NGA. All rights reserved.
//

#import "GPKGNetworkUtils.h"

@implementation GPKGNetworkUtils

+(NSData *) sendSynchronousRequest: (NSURLRequest *) request returningResponse: (NSURLResponse **) response error: (NSError **) error{
    
    __block NSData *data = nil;
    __block NSURLResponse *blockResponse = nil;
    __block NSError *blockError = nil;

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable taskData, NSURLResponse * _Nullable taskResponse, NSError * _Nullable taskError) {

        data = taskData;
        blockError = taskError;
        blockResponse = taskResponse;

        dispatch_group_leave(group);
    }] resume];

    dispatch_group_wait(group,  DISPATCH_TIME_FOREVER);

    *error = blockError;
    *response = blockResponse;

    return data;
}

@end
