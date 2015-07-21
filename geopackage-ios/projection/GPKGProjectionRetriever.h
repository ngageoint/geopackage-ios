//
//  GPKGProjectionRetriever.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGProjectionRetriever : NSObject

+(NSString *) getProjectionWithNumber: (NSNumber *) epsg;

@end
