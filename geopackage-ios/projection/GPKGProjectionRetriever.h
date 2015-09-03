//
//  GPKGProjectionRetriever.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Retrieves the proj4 projection parameter string for an EPSG code
 */
@interface GPKGProjectionRetriever : NSObject

/**
 *  Get the proj4 projection string for the EPSG code
 *
 *  @param epsg EPSG code
 *
 *  @return projection string
 */
+(NSString *) getProjectionWithNumber: (NSNumber *) epsg;

@end
