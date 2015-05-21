//
//  GPKGDataTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGDataTypes.h"

NSString * const DT_BOOLEAN = @"BOOLEAN";
NSString * const DT_TINYINT = @"TINYINT";
NSString * const DT_SMALLINT = @"SMALLINT";
NSString * const DT_MEDIUMINT = @"MEDIUMINT";
NSString * const DT_INT = @"INT";
NSString * const DT_INTEGER = @"INTEGER";
NSString * const DT_FLOAT = @"FLOAT";
NSString * const DT_DOUBLE = @"DOUBLE";
NSString * const DT_REAL = @"REAL";
NSString * const DT_TEXT = @"TEXT";
NSString * const DT_BLOB = @"BLOB";
NSString * const DT_DATE = @"DATE";
NSString * const DT_DATETIME = @"DATETIME";

@implementation GPKGDataTypes

+(NSString *) name: (enum GPKGDataType) dataType{
    NSString * name = nil;
    
    switch(dataType){
        case BOOLEAN:
            name = DT_BOOLEAN;
            break;
        case TINYINT:
            name = DT_TINYINT;
            break;
        case SMALLINT:
            name = DT_SMALLINT;
            break;
        case MEDIUMINT:
            name = DT_MEDIUMINT;
            break;
        case INT:
            name = DT_INT;
            break;
        case INTEGER:
            name = DT_INTEGER;
            break;
        case FLOAT:
            name = DT_FLOAT;
            break;
        case DOUBLE:
            name = DT_DOUBLE;
            break;
        case REAL:
            name = DT_REAL;
            break;
        case TEXT:
            name = DT_TEXT;
            break;
        case BLOB:
            name = DT_BLOB;
            break;
        case DATE:
            name = DT_DATE;
            break;
        case DATETIME:
            name = DT_DATETIME;
            break;
    }
    
    return name;
}

+(Class) classType: (enum GPKGDataType) dataType{
    Class class = nil;
    
    switch(dataType){
        case BOOLEAN:
        case TINYINT:
        case SMALLINT:
        case MEDIUMINT:
        case INT:
        case INTEGER:
            class = [NSNumber class];
            break;
        case FLOAT:
        case DOUBLE:
        case REAL:
            class = [NSDecimalNumber class];
            break;
        case TEXT:
            class = [NSString class];
            break;
        case BLOB:
            class = [NSData class];
            break;
        case DATE:
        case DATETIME:
            class = [NSDate class];
            break;
    }
    
    return class;
}

@end
