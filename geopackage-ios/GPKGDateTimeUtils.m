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
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:dateTimeFormat];
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

@end
