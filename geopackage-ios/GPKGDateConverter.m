//
//  GPKGDateConverter.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/19/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGDateConverter.h"
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

@interface GPKGDateConverter ()

/**
 *  Date formatters
 */
@property (nonatomic, strong) NSMutableArray<NSDateFormatter *> *formatters;

@end

@implementation GPKGDateConverter

+(GPKGDateConverter *) converter{
    NSArray<NSString *> *dateTimeFormats = [GPKGProperties arrayValueOfProperty:GPKG_PROP_DATETIME_FORMATS];
    return [self createWithFormats:dateTimeFormats];
}

+(GPKGDateConverter *) converter: (enum GPKGDataType) type{
    
    GPKGDateConverter *converter = nil;
    
    switch(type){
        case GPKG_DT_DATE:
            converter = [self dateConverter];
            break;
        case GPKG_DT_DATETIME:
            converter = [self dateTimeConverter];
            break;
        default:
            [NSException raise:@"Illegal Data Type" format:@"Not a date data type: %@", [GPKGDataTypes name:type]];
    }
    
    return converter;
}

+(GPKGDateConverter *) dateConverter{
    return [self createWithFormats:[NSArray arrayWithObjects:GPKG_DTU_DATE_FORMAT, GPKG_DTU_DATE_FORMAT2, nil]];
}

+(GPKGDateConverter *) dateTimeConverter{
    return [self createWithFormats:[NSArray arrayWithObjects:GPKG_DTU_DATETIME_FORMAT, GPKG_DTU_DATETIME_FORMAT2, nil]];
}

+(GPKGDateConverter *) createWithFormat: (NSString *) format{
    return [[GPKGDateConverter alloc] initWithFormat:format];
}

+(GPKGDateConverter *) createWithFormats: (NSArray<NSString *> *) formats{
    return [[GPKGDateConverter alloc] initWithFormats:formats];
}

-(instancetype) initWithFormat: (NSString *) format{
    return [self initWithFormats:[NSArray arrayWithObject:format]];
}

-(instancetype) initWithFormats: (NSArray<NSString *> *) formats{
    self = [super init];
    if(self != nil){
        _expected = YES;
        _formatters = [NSMutableArray array];
        for(NSString *format in formats){
            [self addFormat:format];
        }
    }
    return self;
}

-(void) addFormat: (NSString *) format{
    NSDateFormatter *dateFormatter = [GPKGDateConverter createFormatterWithFormat:format];
    [_formatters addObject:dateFormatter];
}

-(NSString *) stringValue: (NSDate *) date{
    NSString *value = nil;
    if(date != nil){
        NSDateFormatter* dateFormatter = [_formatters firstObject];
        value = [dateFormatter stringFromDate:date];
    }
    return value;
}

-(NSDate *) dateValue: (NSString *) date{
    
    NSDate *value = nil;
    
    if(date != nil && date.length > 0){
        
        // Try each date formatter in order
        for(NSDateFormatter *dateFormatter in _formatters){
            value = [dateFormatter dateFromString:date];
            if(value != nil){
                break;
            }
        }
        
        // If no value could be parsed when expected
        if(value == nil && _expected){
            [NSException raise:@"No Date Formatter" format:@"Failed to parse date string: %@", date];
        }
    }
    
    return value;
}

static GPKGDateConverter *converter;

+(void) initialize{
    if(converter == nil){
        converter = [self converter];
    }
}

+(NSDate *) convertToDateWithString: (NSString *) dateTimeString{
    return [converter dateValue:dateTimeString];
}

+(NSDate *) convertToDateWithString: (NSString *) dateTimeString andExpected: (BOOL) expected{
    NSDate *date = nil;
    if(expected){
        date = [self convertToDateWithString:dateTimeString];
    }else{
        GPKGDateConverter *convert = [self converter];
        convert.expected = NO;
        date = [convert dateValue:dateTimeString];
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
