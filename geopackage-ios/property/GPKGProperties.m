//
//  GPKGProperties.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGProperties.h"
#import "GPKGIOUtils.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGPropertyConstants.h"

static NSDictionary * properties;

@implementation GPKGProperties

+(NSString *) getValueOfProperty: (NSString *) property{
    return [self getValueOfProperty:property andRequired:true];
}

+(NSString *) getValueOfProperty: (NSString *) property andRequired: (BOOL) required{
    
    if(properties == nil){
        NSString * propertiesPath = [GPKGIOUtils getPropertyListPathWithName:GPKG_GEO_PACKAGE_RESOURCES_PROPERTIES];
        properties = [NSDictionary dictionaryWithContentsOfFile:propertiesPath];
    }
    
    NSString * value = [properties valueForKey:property];
    
    if(value == nil && required){
        [NSException raise:@"Required Property" format:@"Required property not found: %@", property];
    }
    
    return value;
}

+(NSString *) getValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property{
    return [self getValueOfBaseProperty:base andProperty:property andRequired:true];
}

+(NSString *) getValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required{
    return [self getValueOfProperty:[NSString stringWithFormat:@"%@%@%@", base, GPKG_PROP_DIVIDER, property] andRequired:required];
}

+(NSNumber *) getNumberValueOfProperty: (NSString *) property{
    return [self getNumberValueOfProperty:property andRequired:true];
}

+(NSNumber *) getNumberValueOfProperty: (NSString *) property andRequired: (BOOL) required{
    NSNumber * value = nil;
    NSString * stringValue = [self getValueOfProperty:property andRequired:required];
    if(stringValue != nil){
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        value = [formatter numberFromString:stringValue];
    }
    return value;
}

+(NSNumber *) getNumberValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property{
    return [self getNumberValueOfBaseProperty:base andProperty:property andRequired:true];
}

+(NSNumber *) getNumberValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required{
    return [self getNumberValueOfProperty:[NSString stringWithFormat:@"%@%@%@", base, GPKG_PROP_DIVIDER, property] andRequired:required];
}

+(BOOL) getBoolValueOfProperty: (NSString *) property{
    return [self getBoolValueOfProperty:property andRequired:true];
}

+(BOOL) getBoolValueOfProperty: (NSString *) property andRequired: (BOOL) required{
    BOOL value = false;
    NSString * stringValue = [self getValueOfProperty:property andRequired:required];
    if(stringValue != nil){
        value = [stringValue boolValue];
    }
    return value;
}

+(BOOL) getBoolValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property{
    return [self getBoolValueOfBaseProperty:base andProperty:property andRequired:true];
}

+(BOOL) getBoolValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required{
    return [self getBoolValueOfProperty:[NSString stringWithFormat:@"%@%@%@", base, GPKG_PROP_DIVIDER, property] andRequired:required];
}

@end
