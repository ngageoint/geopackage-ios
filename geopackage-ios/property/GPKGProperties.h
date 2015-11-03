//
//  GPKGProperties.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  GeoPackage property loader
 */
@interface GPKGProperties : NSObject

/**
 *  Get the string value of the property
 *
 *  @param property property
 *
 *  @return string value
 */
+(NSString *) getValueOfProperty: (NSString *) property;

/**
 *  Get the string value of the property with required option
 *
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return string value
 */
+(NSString *) getValueOfProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the string value of the property combined with the base
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return string value
 */
+(NSString *) getValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

/**
 *  Get the string value of the property combined with the base with required option
 *
 *  @param base     base property
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return string value
 */
+(NSString *) getValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the number value of the property
 *
 *  @param property property
 *
 *  @return number value
 */
+(NSNumber *) getNumberValueOfProperty: (NSString *) property;

/**
 *  Get the number value of the property with required option
 *
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return number value
 */
+(NSNumber *) getNumberValueOfProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the number value of the property combined with the base
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return number value
 */
+(NSNumber *) getNumberValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

/**
 *  Get the number value of the property combined with the base with required option
 *
 *  @param base     base property
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return number value
 */
+(NSNumber *) getNumberValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the boolean value of the property
 *
 *  @param property property
 *
 *  @return bool value
 */
+(BOOL) getBoolValueOfProperty: (NSString *) property;

/**
 *  Get the boolean value of the property with required option
 *
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return bool value
 */
+(BOOL) getBoolValueOfProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the boolean value of the property combined with the base
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return bool value
 */
+(BOOL) getBoolValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

/**
 *  Get the boolean value of the property combined with the base with required option
 *
 *  @param base     base property
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return bool value
 */
+(BOOL) getBoolValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the array value of the property
 *
 *  @param property property
 *
 *  @return array value
 */
+(NSArray *) getArrayValueOfProperty: (NSString *) property;

/**
 *  Get the array value of the property with required option
 *
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return array value
 */
+(NSArray *) getArrayValueOfProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the array value of the property combined with the base
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return array value
 */
+(NSArray *) getArrayValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

/**
 *  Get the array value of the property combined with the base with required option
 *
 *  @param base     base property
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return array value
 */
+(NSArray *) getArrayValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the dictionary value of the property
 *
 *  @param property property
 *
 *  @return dictionary value
 */
+(NSDictionary *) getDictionaryValueOfProperty: (NSString *) property;

/**
 *  Get the dictionary value of the property with required option
 *
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return dictionary value
 */
+(NSDictionary *) getDictionaryValueOfProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the dictionary value of the property combined with the base
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return dictionary value
 */
+(NSDictionary *) getDictionaryValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

/**
 *  Get the dictionary value of the property combined with the base with required option
 *
 *  @param base     base property
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return dictionary value
 */
+(NSDictionary *) getDictionaryValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

@end
