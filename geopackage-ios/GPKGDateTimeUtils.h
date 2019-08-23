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
 * Date format
 */
extern NSString * const GPKG_DTU_DATE_FORMAT;

/**
 * Non standard Date format
 */
extern NSString * const GPKG_DTU_DATE_FORMAT2;

/**
 * Date Time format
 */
extern NSString * const GPKG_DTU_DATETIME_FORMAT;

/**
 * Secondary Date Time format w/o milliseconds for parsing string dates
 */
extern NSString * const GPKG_DTU_DATETIME_FORMAT2;

/**
 * SQLite date function
 */
extern NSString * const GPKG_DTU_FUNCTION_DATE;

/**
 * SQLite time function
 */
extern NSString * const GPKG_DTU_FUNCTION_TIME;

/**
 * SQLite datetime function
 */
extern NSString * const GPKG_DTU_FUNCTION_DATETIME;

/**
 * SQLite julianday function
 */
extern NSString * const GPKG_DTU_FUNCTION_JULIANDAY;

/**
 * SQLite strftime function
 */
extern NSString * const GPKG_DTU_FUNCTION_STRFTIME;

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

/**
 * Determine if the date/time string value is a SQLite function
 *
 * @param value
 *            date/time string value
 * @return true if a function, false if the value should be parsed
 */
+(BOOL) isFunction: (NSString *) value;

@end
