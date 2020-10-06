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

@implementation GPKGProperties

static NSDictionary *properties;

+(void) initialize{
    if(properties == nil){
        NSString * propertiesPath = [GPKGIOUtils propertyListPathWithName:GPKG_RESOURCES_PROPERTIES];
        properties = [NSDictionary dictionaryWithContentsOfFile:propertiesPath];
    }
}

+(NSString *) combineBaseProperty: (NSString *) base withProperty: (NSString *) property{
    return [NSString stringWithFormat:@"%@%@%@", base, GPKG_PROP_DIVIDER, property];
}

+(NSString *) valueOfProperty: (NSString *) property{
    return [self valueOfProperty:property andRequired:YES];
}

+(NSString *) valueOfProperty: (NSString *) property andRequired: (BOOL) required{
    
    NSString * value = [properties valueForKey:property];
    
    if(value == nil && required){
        [NSException raise:@"Required Property" format:@"Required property not found: %@", property];
    }
    
    return value;
}

+(NSString *) valueOfBaseProperty: (NSString *) base andProperty: (NSString *) property{
    return [self valueOfBaseProperty:base andProperty:property andRequired:YES];
}

+(NSString *) valueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required{
    return [self valueOfProperty:[self combineBaseProperty:base withProperty:property] andRequired:required];
}

+(NSNumber *) numberValueOfProperty: (NSString *) property{
    return [self numberValueOfProperty:property andRequired:YES];
}

+(NSNumber *) numberValueOfProperty: (NSString *) property andRequired: (BOOL) required{
    NSNumber * value = nil;
    NSString * stringValue = [self valueOfProperty:property andRequired:required];
    if(stringValue != nil){
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        value = [formatter numberFromString:stringValue];
    }
    return value;
}

+(NSNumber *) numberValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property{
    return [self numberValueOfBaseProperty:base andProperty:property andRequired:YES];
}

+(NSNumber *) numberValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required{
    return [self numberValueOfProperty:[self combineBaseProperty:base withProperty:property] andRequired:required];
}

+(BOOL) boolValueOfProperty: (NSString *) property{
    return [self boolValueOfProperty:property andRequired:YES];
}

+(BOOL) boolValueOfProperty: (NSString *) property andRequired: (BOOL) required{
    BOOL value = NO;
    NSString * stringValue = [self valueOfProperty:property andRequired:required];
    if(stringValue != nil){
        value = [stringValue boolValue];
    }
    return value;
}

+(BOOL) boolValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property{
    return [self boolValueOfBaseProperty:base andProperty:property andRequired:YES];
}

+(BOOL) boolValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required{
    return [self boolValueOfProperty:[self combineBaseProperty:base withProperty:property] andRequired:required];
}

+(NSArray *) arrayValueOfProperty: (NSString *) property{
    return [self arrayValueOfProperty:property andRequired:YES];
}

+(NSArray *) arrayValueOfProperty: (NSString *) property andRequired: (BOOL) required{
    
    NSArray * value = [properties objectForKey:property];
    
    if(value == nil && required){
        [NSException raise:@"Required Property" format:@"Required property not found: %@", property];
    }
    
    return value;
}

+(NSArray *) arrayValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property{
    return [self arrayValueOfBaseProperty:base andProperty:property andRequired:YES];
}

+(NSArray *) arrayValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required{
    return [self arrayValueOfProperty:[self combineBaseProperty:base withProperty:property] andRequired:required];
}

+(NSDictionary *) dictionaryValueOfProperty: (NSString *) property{
    return [self dictionaryValueOfProperty:property andRequired:YES];
}

+(NSDictionary *) dictionaryValueOfProperty: (NSString *) property andRequired: (BOOL) required{
    
    NSDictionary * value = [properties objectForKey:property];
    
    if(value == nil && required){
        [NSException raise:@"Required Property" format:@"Required property not found: %@", property];
    }
    
    return value;
}

+(NSDictionary *) dictionaryValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property{
    return [self dictionaryValueOfBaseProperty:base andProperty:property andRequired:YES];
}

+(NSDictionary *) dictionaryValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required{
    return [self dictionaryValueOfProperty:[self combineBaseProperty:base withProperty:property] andRequired:required];
}

@end
