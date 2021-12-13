//
//  GPKGNetworkUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/8/21.
//  Copyright © 2021 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Network Utilities
 */
@interface GPKGNetworkUtils : NSObject

/**
 *  Send a synchronous network request
 *
 *  @param request url request
 *  @param response url response
 *  @param error network error
 *
 *  @return response data
 */
+(NSData *) sendSynchronousRequest: (NSURLRequest *) request returningResponse: (NSURLResponse **) response error: (NSError **) error;

/**
 *  Send a synchronous network request with attempted redirect response updated request
 *
 *  @param request url request
 *  @param url url value
 *
 *  @return response data
 */
+(NSData *) sendSynchronousWithRedirectsRequest: (NSMutableURLRequest *) request withUrl: (NSString *) url;

@end
