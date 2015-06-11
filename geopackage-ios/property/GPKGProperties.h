//
//  GPKGProperties.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGProperties : NSObject

+(NSString *) getValueOfProperty: (NSString *) property;

+(NSString *) getValueOfProperty: (NSString *) property andRequired: (BOOL) required;

+(NSString *) getValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

+(NSString *) getValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

+(NSNumber *) getNumberValueOfProperty: (NSString *) property;

+(NSNumber *) getNumberValueOfProperty: (NSString *) property andRequired: (BOOL) required;

+(NSNumber *) getNumberValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property;

+(NSNumber *) getNumberValueOfBaseProperty: (NSString *) base andProperty: (NSString *) property andRequired: (BOOL) required;

@end
