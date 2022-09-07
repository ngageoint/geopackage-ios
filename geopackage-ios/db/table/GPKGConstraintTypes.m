//
//  GPKGConstraintTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGConstraintTypes.h"
#import "GPKGUtils.h"

NSString * const GPKG_CT_PRIMARY_KEY_NAME = @"PRIMARY_KEY";
NSString * const GPKG_CT_UNIQUE_NAME = @"UNIQUE";
NSString * const GPKG_CT_CHECK_NAME = @"CHECK";
NSString * const GPKG_CT_FOREIGN_KEY_NAME = @"FOREIGN_KEY";
NSString * const GPKG_CT_NOT_NULL_NAME = @"NOT_NULL";
NSString * const GPKG_CT_DEFAULT_NAME = @"DEFAULT";
NSString * const GPKG_CT_COLLATE_NAME = @"COLLATE";
NSString * const GPKG_CT_AUTOINCREMENT_NAME = @"AUTOINCREMENT";

@implementation GPKGConstraintTypes

static NSSet<NSNumber *> *TABLE_CONSTRAINTS = nil;
static NSSet<NSNumber *> *COLUMN_CONSTRAINTS = nil;
static NSMutableDictionary<NSString *, NSNumber *> *tableLookup = nil;
static NSMutableDictionary<NSString *, NSNumber *> *columnLookup = nil;

+(void) initialize{
    if(TABLE_CONSTRAINTS == nil){
        TABLE_CONSTRAINTS = [NSSet setWithObjects:
                              [NSNumber numberWithInteger:GPKG_CT_PRIMARY_KEY],
                              [NSNumber numberWithInteger:GPKG_CT_UNIQUE],
                              [NSNumber numberWithInteger:GPKG_CT_CHECK],
                              [NSNumber numberWithInteger:GPKG_CT_FOREIGN_KEY],
                              nil];
        tableLookup = [NSMutableDictionary dictionary];
        for(NSNumber *type in TABLE_CONSTRAINTS){
            [self addConstraint:type toLookup:tableLookup];
        }
    }
    if(COLUMN_CONSTRAINTS == nil){
        COLUMN_CONSTRAINTS = [NSSet setWithObjects:
                              [NSNumber numberWithInteger:GPKG_CT_PRIMARY_KEY],
                              [NSNumber numberWithInteger:GPKG_CT_NOT_NULL],
                              [NSNumber numberWithInteger:GPKG_CT_UNIQUE],
                              [NSNumber numberWithInteger:GPKG_CT_CHECK],
                              [NSNumber numberWithInteger:GPKG_CT_DEFAULT],
                              [NSNumber numberWithInteger:GPKG_CT_COLLATE],
                              [NSNumber numberWithInteger:GPKG_CT_FOREIGN_KEY],
                              [NSNumber numberWithInteger:GPKG_CT_AUTOINCREMENT],
                              nil];
        columnLookup = [NSMutableDictionary dictionary];
        for(NSNumber *type in COLUMN_CONSTRAINTS){
            [self addConstraint:type toLookup:columnLookup];
        }
    }

}

+(void) addConstraint: (NSNumber *) typeNumber toLookup: (NSMutableDictionary<NSString *, NSNumber *> *) lookup{
    enum GPKGConstraintType type = [typeNumber intValue];
    NSString *name = [GPKGConstraintTypes name:type];
    NSArray<NSString *> *parts = [name componentsSeparatedByString:@"_"];
    [lookup setObject:typeNumber forKey:[parts objectAtIndex:0]];
    if(parts.count > 0){
        [lookup setObject:typeNumber forKey:[name stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
    }
}

+(NSString *) name: (enum GPKGConstraintType) type{
    NSString *name = nil;
    
    switch(type){
        case GPKG_CT_PRIMARY_KEY:
            name = GPKG_CT_PRIMARY_KEY_NAME;
            break;
        case GPKG_CT_UNIQUE:
            name = GPKG_CT_UNIQUE_NAME;
            break;
        case GPKG_CT_CHECK:
            name = GPKG_CT_CHECK_NAME;
            break;
        case GPKG_CT_FOREIGN_KEY:
            name = GPKG_CT_FOREIGN_KEY_NAME;
            break;
        case GPKG_CT_NOT_NULL:
            name = GPKG_CT_NOT_NULL_NAME;
            break;
        case GPKG_CT_DEFAULT:
            name = GPKG_CT_DEFAULT_NAME;
            break;
        case GPKG_CT_COLLATE:
            name = GPKG_CT_COLLATE_NAME;
            break;
        case GPKG_CT_AUTOINCREMENT:
            name = GPKG_CT_AUTOINCREMENT_NAME;
            break;
    }
    
    return name;
}

+(enum GPKGConstraintType) fromName: (NSString *) name{
    enum GPKGConstraintType value = -1;
    
    if(name != nil){
        name = [name uppercaseString];
        NSDictionary *types = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:GPKG_CT_PRIMARY_KEY], GPKG_CT_PRIMARY_KEY_NAME,
                               [NSNumber numberWithInteger:GPKG_CT_UNIQUE], GPKG_CT_UNIQUE_NAME,
                               [NSNumber numberWithInteger:GPKG_CT_CHECK], GPKG_CT_CHECK_NAME,
                               [NSNumber numberWithInteger:GPKG_CT_FOREIGN_KEY], GPKG_CT_FOREIGN_KEY_NAME,
                               [NSNumber numberWithInteger:GPKG_CT_NOT_NULL], GPKG_CT_NOT_NULL_NAME,
                               [NSNumber numberWithInteger:GPKG_CT_DEFAULT], GPKG_CT_DEFAULT_NAME,
                               [NSNumber numberWithInteger:GPKG_CT_COLLATE], GPKG_CT_COLLATE_NAME,
                               [NSNumber numberWithInteger:GPKG_CT_AUTOINCREMENT], GPKG_CT_AUTOINCREMENT_NAME,
                               nil
                               ];
        NSNumber *enumValue = [GPKGUtils objectForKey:name inDictionary:types];
        if(enumValue != nil){
            value = (enum GPKGConstraintType)[enumValue intValue];
        }
    }
    
    return value;
}

+(enum GPKGConstraintType) tableTypeOfValue: (NSString *) value{
    return [self typeOfValue:value fromLookup:tableLookup];
}

+(enum GPKGConstraintType) columnTypeOfValue: (NSString *) value{
    return [self typeOfValue:value fromLookup:columnLookup];
}

+(enum GPKGConstraintType) typeOfValue: (NSString *) value fromLookup: (NSMutableDictionary<NSString *, NSNumber *> *) lookup{
    enum GPKGConstraintType type = -1;
    NSNumber *typeNumber = [lookup objectForKey:[value uppercaseString]];
    if(typeNumber != nil){
        type = [typeNumber intValue];
    }
    return type;
}

+(enum GPKGConstraintType) typeOfValue: (NSString *) value{
    enum GPKGConstraintType type = [self tableTypeOfValue:value];
    if ((int)type < 0) {
        type = [self columnTypeOfValue:value];
    }
    return type;
}

@end
