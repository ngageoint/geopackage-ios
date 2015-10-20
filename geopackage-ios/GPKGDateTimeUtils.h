//
//  GPKGDateTimeUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/19/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Provides DateTime utility methods
 */
@interface GPKGDateTimeUtils : NSObject

/**
 *  Convert a datetime string to a date
 *
 *  @param dateTimeString datetime string
 *
 *  @return date, or nil if the dateTimeString is nil or empty
 */
+(NSDate *) convertToDateWithString: (NSString *) dateTimeString;

@end
