//
//  GPKGDateTimeUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/19/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGDataTypes.h"

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

/**
 *  Convert a date to the provided string format
 *
 *  @param date date
 *  @param format date format
 *
 *  @return string formatted date
 */
+(NSString *) convertToStringWithDate: (NSDate *) date withFormat: (NSString *) format;

/**
 *  Convert a date to the string format: yyyy-MM-dd
 *
 *  @param date date
 *
 *  @return string formatted date
 */
+(NSString *) convertToDateStringWithDate: (NSDate *) date;

/**
 *  Convert a date to the string format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
 *
 *  @param date date
 *
 *  @return string formatted date
 */
+(NSString *) convertToDateTimeStringWithDate: (NSDate *) date;

/**
 *  Convert a date to the corresponding data type string format
 *
 *  @param date date
 *  @param dataType date data type
 *
 *  @return string formatted date
 */
+(NSString *) convertToStringWithDate: (NSDate *) date andType: (enum GPKGDataType) dataType;

/**
 *  Create a date formatter with the provided format
 *
 *  @param format date format
 *
 *  @return date formatter
 */
+(NSDateFormatter *) createFormatterWithFormat: (NSString *) format;

@end
