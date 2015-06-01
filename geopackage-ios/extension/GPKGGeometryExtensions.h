//
//  GPKGGeometryExtensions.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKBGeometryTypes.h"

@interface GPKGGeometryExtensions : NSObject

+(BOOL) isExtension: (enum WKBGeometryType) geometryType;
+(BOOL) isGeoPackageExtension: (enum WKBGeometryType) geometryType;
+(NSString *) getExtensionName: (enum WKBGeometryType) geometryType;
+(NSString *) getExtensionNameWithAuthor: (NSString *) author andType: (enum WKBGeometryType) geometryType;

@end
