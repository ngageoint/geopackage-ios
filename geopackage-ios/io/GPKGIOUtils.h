//
//  GPKGIOUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGIOUtils : NSObject

+(NSString *) getPropertyListPathWithName: (NSString *) name;

+(NSString *) getResourcePathWithName: (NSString *) name andType: (NSString *) type;

+(NSString *) documentsDirectory;

+(NSString *) geoPackageDirectory;

+(NSString *) databaseDirectory;

+(void) createDirectoryIfNotExists: (NSString *) directory;

+(NSString *) formatBytes: (int) bytes;

+(NSString *) decodeUrl: (NSString *) url;

@end
