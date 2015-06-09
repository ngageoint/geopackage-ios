//
//  GPKGGeoPackageValidate.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGGeoPackageValidate : NSObject

+(BOOL) hasGeoPackageExtension: (NSString *) file;

+(void) validateGeoPackageExtension: (NSString *) file;

+(BOOL) hasMinimumTables: (GPKGGeoPackage *) geoPackage;

+(void) validateMinimumTables: (GPKGGeoPackage *) geoPackage;

@end
