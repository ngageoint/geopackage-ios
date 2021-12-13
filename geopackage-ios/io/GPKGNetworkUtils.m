//
//  GPKGNetworkUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/8/21.
//  Copyright © 2021 NGA. All rights reserved.
//

#import "GPKGNetworkUtils.h"

@implementation GPKGNetworkUtils

static int HTTP_OK = 200;
static int HTTP_MOVED_PERM = 301;
static int HTTP_MOVED_TEMP = 302;
static int HTTP_SEE_OTHER = 303;

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

+(NSData *) sendSynchronousWithRedirectsRequest: (NSMutableURLRequest *) request withUrl: (NSString *) url{
    
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *data = [self sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if(error){
        [NSException raise:@"Failed Request" format:@"Failed request. URL: %@, error: %@", url, error];
    }
    
    int responseCode = (int) urlResponse.statusCode;
    
    if(responseCode == HTTP_MOVED_PERM
       || responseCode == HTTP_MOVED_TEMP
       || responseCode == HTTP_SEE_OTHER){
        
        NSString *redirect = [urlResponse.allHeaderFields objectForKey:@"Location"];
        request.URL = [NSURL URLWithString:redirect];
        
        urlResponse = nil;
        error = nil;
        data = [GPKGNetworkUtils sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
        if(error){
            [NSException raise:@"Failed Request" format:@"Failed request. Redirect URL: %@, Original URL: %@, error: %@", redirect, url, error];
        }
        
        responseCode = (int) urlResponse.statusCode;
    }
    
    if(responseCode != HTTP_OK){
        [NSException raise:@"Failed Request" format:@"Failed request. URL: %@, Response Code: %d, Response Message: %@, error: %@", url, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode], error];
    }
    
    return data;
}

@end
