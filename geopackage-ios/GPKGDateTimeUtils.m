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

@implementation GPKGDateTimeUtils

static NSArray * dateFormatters;

+(void) initialize{
    if(dateFormatters == nil){
        // Build a lite of date formatters for each confured datetime format
        NSMutableArray * formatters = [[NSMutableArray alloc] init];
        NSArray * dateTimeFormats = [GPKGProperties getArrayValueOfProperty:GPKG_PROP_DATETIME_FORMATS];
        for(NSString * dateTimeFormat in dateTimeFormats){
            NSDateFormatter *dateFormatter = [self createFormatterWithFormat:dateTimeFormat];
            [formatters addObject:dateFormatter];
        }
        dateFormatters = formatters;
    }
}

+(NSDate *) convertToDateWithString: (NSString *) dateTimeString{

    NSDate * date = nil;
    
    if(dateTimeString != nil && dateTimeString.length > 0){
    
        [self initialize];
        
        for(NSDateFormatter *dateFormatter in dateFormatters){
            date = [dateFormatter dateFromString:dateTimeString];
            if(date != nil){
                break;
            }
        }
        
        if(date == nil){
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
    return [self convertToStringWithDate:date withFormat:@"yyyy-MM-dd"];
}

+(NSString *) convertToDateTimeStringWithDate: (NSDate *) date{
    return [self convertToStringWithDate:date withFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
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
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return dateFormatter;
}

@end
