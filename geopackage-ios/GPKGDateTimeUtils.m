//
//  GPKGDateTimeUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/19/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGDateTimeUtils.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"

NSString * const GPKG_DTU_DATE_FORMAT = @"yyyy-MM-dd";
NSString * const GPKG_DTU_DATE_FORMAT2 = @"yyyy/MM/dd";
NSString * const GPKG_DTU_DATETIME_FORMAT = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
NSString * const GPKG_DTU_DATETIME_FORMAT2 = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
NSString * const GPKG_DTU_FUNCTION_DATE = @"date";
NSString * const GPKG_DTU_FUNCTION_TIME = @"time";
NSString * const GPKG_DTU_FUNCTION_DATETIME = @"datetime";
NSString * const GPKG_DTU_FUNCTION_JULIANDAY = @"julianday";
NSString * const GPKG_DTU_FUNCTION_STRFTIME = @"strftime";

@implementation GPKGDateTimeUtils

static NSArray * dateFormatters;

+(void) initialize{
    if(dateFormatters == nil){
        // Build a lite of date formatters for each confured datetime format
        NSMutableArray * formatters = [NSMutableArray array];
        NSArray * dateTimeFormats = [GPKGProperties arrayValueOfProperty:GPKG_PROP_DATETIME_FORMATS];
        for(NSString * dateTimeFormat in dateTimeFormats){
            NSDateFormatter *dateFormatter = [self createFormatterWithFormat:dateTimeFormat];
            [formatters addObject:dateFormatter];
        }
        dateFormatters = formatters;
    }
}

+(NSDate *) convertToDateWithString: (NSString *) dateTimeString{
    return [self convertToDateWithString:dateTimeString andExpected:YES];
}

+(NSDate *) convertToDateWithString: (NSString *) dateTimeString andExpected: (BOOL) expected{

    NSDate * date = nil;
    
    if(dateTimeString != nil && dateTimeString.length > 0){
    
        [self initialize];
        
        for(NSDateFormatter *dateFormatter in dateFormatters){
            date = [dateFormatter dateFromString:dateTimeString];
            if(date != nil){
                break;
            }
        }
        
        if(date == nil && expected){
            [NSException raise:@"No Date Formatter" format:@"No Date Formatter configured to convert date time string '%@' to a date", dateTimeString];
        }
    }
    
    return date;
}

+(NSString *) convertToStringWithDate: (NSDate *) date withFormat: (NSString *) format{
    NSDateFormatter *dateFormatter = [self createFormatterWithFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+(NSString *) convertToDateStringWithDate: (NSDate *) date{
    return [self convertToStringWithDate:date withFormat:GPKG_DTU_DATE_FORMAT];
}

+(NSString *) convertToDateTimeStringWithDate: (NSDate *) date{
    return [self convertToStringWithDate:date withFormat:GPKG_DTU_DATETIME_FORMAT];
}

+(NSString *) convertToStringWithDate: (NSDate *) date andType: (enum GPKGDataType) dataType{
    NSString *dateString = nil;
    switch(dataType){
        case GPKG_DT_DATE:
            dateString = [self convertToDateStringWithDate:date];
            break;
        case GPKG_DT_DATETIME:
            dateString = [self convertToDateTimeStringWithDate:date];
            break;
        default:
            [NSException raise:@"Illegal Data Type" format:@"Data type must be a date type: %@", [GPKGDataTypes name:dataType]];
    }
    return dateString;
}

+(NSDateFormatter *) createFormatterWithFormat: (NSString *) format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]]; // for fixed format dates
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return dateFormatter;
}

+(BOOL) isFunction: (NSString *) value{
    BOOL function = NO;
    if(value != nil){
        value = [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        function = [value hasPrefix:GPKG_DTU_FUNCTION_DATE]
            || [value hasPrefix:GPKG_DTU_FUNCTION_TIME]
            || [value hasPrefix:GPKG_DTU_FUNCTION_DATETIME]
            || [value hasPrefix:GPKG_DTU_FUNCTION_JULIANDAY]
            || [value hasPrefix:GPKG_DTU_FUNCTION_STRFTIME];
    }
    return function;
}

@end
