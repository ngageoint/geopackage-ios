//
//  GPKGDataTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGDataTypes.h"
#import "GPKGUtils.h"

NSString * const GPKG_DT_BOOLEAN_NAME = @"BOOLEAN";
NSString * const GPKG_DT_TINYINT_NAME = @"TINYINT";
NSString * const GPKG_DT_SMALLINT_NAME = @"SMALLINT";
NSString * const GPKG_DT_MEDIUMINT_NAME = @"MEDIUMINT";
NSString * const GPKG_DT_INT_NAME = @"INT";
NSString * const GPKG_DT_INTEGER_NAME = @"INTEGER";
NSString * const GPKG_DT_FLOAT_NAME = @"FLOAT";
NSString * const GPKG_DT_DOUBLE_NAME = @"DOUBLE";
NSString * const GPKG_DT_REAL_NAME = @"REAL";
NSString * const GPKG_DT_TEXT_NAME = @"TEXT";
NSString * const GPKG_DT_BLOB_NAME = @"BLOB";
NSString * const GPKG_DT_DATE_NAME = @"DATE";
NSString * const GPKG_DT_DATETIME_NAME = @"DATETIME";
NSString * const GPKG_DT_GEOMETRY_NAME = @"GEOMETRY";

@implementation GPKGDataTypes

+(NSString *) name: (enum GPKGDataType) dataType{
    NSString * name = nil;
    
    switch(dataType){
        case GPKG_DT_BOOLEAN:
            name = GPKG_DT_BOOLEAN_NAME;
            break;
        case GPKG_DT_TINYINT:
            name = GPKG_DT_TINYINT_NAME;
            break;
        case GPKG_DT_SMALLINT:
            name = GPKG_DT_SMALLINT_NAME;
            break;
        case GPKG_DT_MEDIUMINT:
            name = GPKG_DT_MEDIUMINT_NAME;
            break;
        case GPKG_DT_INT:
            name = GPKG_DT_INT_NAME;
            break;
        case GPKG_DT_INTEGER:
            name = GPKG_DT_INTEGER_NAME;
            break;
        case GPKG_DT_FLOAT:
            name = GPKG_DT_FLOAT_NAME;
            break;
        case GPKG_DT_DOUBLE:
            name = GPKG_DT_DOUBLE_NAME;
            break;
        case GPKG_DT_REAL:
            name = GPKG_DT_REAL_NAME;
            break;
        case GPKG_DT_TEXT:
            name = GPKG_DT_TEXT_NAME;
            break;
        case GPKG_DT_BLOB:
            name = GPKG_DT_BLOB_NAME;
            break;
        case GPKG_DT_DATE:
            name = GPKG_DT_DATE_NAME;
            break;
        case GPKG_DT_DATETIME:
            name = GPKG_DT_DATETIME_NAME;
            break;
        case GPKG_DT_GEOMETRY:
            name = GPKG_DT_GEOMETRY_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGDataType) fromName: (NSString *) name{
    enum GPKGDataType value = -1;
    
    if(name != nil){
        name = [name uppercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_DT_BOOLEAN], GPKG_DT_BOOLEAN_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_TINYINT], GPKG_DT_TINYINT_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_SMALLINT], GPKG_DT_SMALLINT_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_MEDIUMINT], GPKG_DT_MEDIUMINT_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_INT], GPKG_DT_INT_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_INTEGER], GPKG_DT_INTEGER_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_FLOAT], GPKG_DT_FLOAT_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_DOUBLE], GPKG_DT_DOUBLE_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_REAL], GPKG_DT_REAL_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_TEXT], GPKG_DT_TEXT_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_BLOB], GPKG_DT_BLOB_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_DATE], GPKG_DT_DATE_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_DATETIME], GPKG_DT_DATETIME_NAME,
                               [NSNumber numberWithInteger:GPKG_DT_GEOMETRY], GPKG_DT_GEOMETRY_NAME,
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        value = (enum GPKGDataType)[enumValue intValue];
    }
    
    return value;
}

+(Class) classType: (enum GPKGDataType) dataType{
    Class class = nil;
    
    switch(dataType){
        case GPKG_DT_BOOLEAN:
        case GPKG_DT_TINYINT:
        case GPKG_DT_SMALLINT:
        case GPKG_DT_MEDIUMINT:
        case GPKG_DT_INT:
        case GPKG_DT_INTEGER:
            class = [NSNumber class];
            break;
        case GPKG_DT_FLOAT:
        case GPKG_DT_DOUBLE:
        case GPKG_DT_REAL:
            class = [NSDecimalNumber class];
            break;
        case GPKG_DT_TEXT:
            class = [NSString class];
            break;
        case GPKG_DT_BLOB:
            class = [NSData class];
            break;
        case GPKG_DT_DATE:
        case GPKG_DT_DATETIME:
            class = [NSDate class];
            break;
        case GPKG_DT_GEOMETRY:
            break;
    }
    
    return class;
}

@end
