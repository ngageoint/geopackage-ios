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
 *  Combine the base property with the property to create a single combined property
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return string value
 */
+(NSString *) combineBaseProperty: (NSString *) base withProperty: (NSString *) property;

/**
 *  Get the string value of the property
 *
 *  @param property property
 *
 *  @return string value
 */
+(NSString *) valueOfProperty: (NSString *) property;

/**
 *  Get the string value of the property with required option
 *
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return string value
 */
+(NSString *) valueOfProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the string value of the property combined with the base
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return string value
 */
+(NSString *) valueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

/**
 *  Get the string value of the property combined with the base with required option
 *
 *  @param base     base property
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return string value
 */
+(NSString *) valueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the number value of the property
 *
 *  @param property property
 *
 *  @return number value
 */
+(NSNumber *) numberValueOfProperty: (NSString *) property;

/**
 *  Get the number value of the property with required option
 *
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return number value
 */
+(NSNumber *) numberValueOfProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the number value of the property combined with the base
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return number value
 */
+(NSNumber *) numberValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

/**
 *  Get the number value of the property combined with the base with required option
 *
 *  @param base     base property
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return number value
 */
+(NSNumber *) numberValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the boolean value of the property
 *
 *  @param property property
 *
 *  @return bool value
 */
+(BOOL) boolValueOfProperty: (NSString *) property;

/**
 *  Get the boolean value of the property with required option
 *
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return bool value
 */
+(BOOL) boolValueOfProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the boolean value of the property combined with the base
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return bool value
 */
+(BOOL) boolValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

/**
 *  Get the boolean value of the property combined with the base with required option
 *
 *  @param base     base property
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return bool value
 */
+(BOOL) boolValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the array value of the property
 *
 *  @param property property
 *
 *  @return array value
 */
+(NSArray *) arrayValueOfProperty: (NSString *) property;

/**
 *  Get the array value of the property with required option
 *
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return array value
 */
+(NSArray *) arrayValueOfProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the array value of the property combined with the base
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return array value
 */
+(NSArray *) arrayValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

/**
 *  Get the array value of the property combined with the base with required option
 *
 *  @param base     base property
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return array value
 */
+(NSArray *) arrayValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the dictionary value of the property
 *
 *  @param property property
 *
 *  @return dictionary value
 */
+(NSDictionary *) dictionaryValueOfProperty: (NSString *) property;

/**
 *  Get the dictionary value of the property with required option
 *
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return dictionary value
 */
+(NSDictionary *) dictionaryValueOfProperty: (NSString *) property andRequired: (BOOL) required;

/**
 *  Get the dictionary value of the property combined with the base
 *
 *  @param base     base property
 *  @param property property
 *
 *  @return dictionary value
 */
+(NSDictionary *) dictionaryValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

/**
 *  Get the dictionary value of the property combined with the base with required option
 *
 *  @param base     base property
 *  @param property property
 *  @param required true if required to exist
 *
 *  @return dictionary value
 */
+(NSDictionary *) dictionaryValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

@end
