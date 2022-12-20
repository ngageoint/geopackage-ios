//
//  GPKGDateConverter.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/19/15.
//  Copyright © 2015 NGA. All rights reserved.
//

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
 *  Date converter between database date formats and date objects
 */
@interface GPKGDateConverter : NSObject

/**
 * Is parsing a date value from a string always expected
 */
@property (nonatomic) BOOL expected;

/**
 * Get a default date converter for all property configured date and date time formats
 *
 * @return date converter
 */
+(GPKGDateConverter *) converter;

/**
 * Get a date converter for the data type
 *
 * @param type
 *            data type
 * @return date converter
 */
+(GPKGDateConverter *) converter: (enum GPKGDataType) type;

/**
 * Get a date converter
 *
 * @return date converter
 */
+(GPKGDateConverter *) dateConverter;

/**
 * Get a date time converter
 *
 * @return date converter
 */
+(GPKGDateConverter *) dateTimeConverter;

/**
 * Get a date converter for the provided format
 *
 * @param format
 *            format
 * @return date converter
 */
+(GPKGDateConverter *) createWithFormat: (NSString *) format;

/**
 * Get a date converter for the provided formats
 *
 * @param formats
 *            formats
 * @return date converter
 */
+(GPKGDateConverter *) createWithFormats: (NSArray<NSString *> *) formats;

/**
 * Initialize
 *
 * @param format
 *            date format
 */
-(instancetype) initWithFormat: (NSString *) format;

/**
 * Initialize
 *
 * @param formats
 *            date formats
 */
-(instancetype) initWithFormats: (NSArray<NSString *> *) formats;

/**
 * Add date format
 *
 * @param format
 *            date format
 */
-(void) addFormat: (NSString *) format;

/**
 * Get the formatted string date value of the date
 *
 * @param date
 *            date
 * @return formatted string date
 */
-(NSString *) stringValue: (NSDate *) date;

/**
 * Get the date value of the formatted string date
 *
 * @param date
 *            formatted string date
 * @return date
 */
-(NSDate *) dateValue: (NSString *) date;

/**
 *  Convert a datetime string to a date
 *
 *  @param dateTimeString datetime string
 *
 *  @return date, or nil if the dateTimeString is nil or empty
 */
+(NSDate *) convertToDateWithString: (NSString *) dateTimeString;

/**
 *  Convert a datetime string to a date
 *
 *  @param dateTimeString datetime string
 *  @param expected if a parsed date is  expected
 *
 *  @return date, or nil if the dateTimeString is nil or empty
 */
+(NSDate *) convertToDateWithString: (NSString *) dateTimeString andExpected: (BOOL) expected;

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
