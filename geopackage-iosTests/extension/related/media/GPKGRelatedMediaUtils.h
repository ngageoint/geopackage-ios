//
//  GPKGRelatedMediaUtils.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGRelatedMediaUtils : NSObject

/**
 * Test related media tables
 *
 * @param geoPackage
 */
+(void) testMedia: (GPKGGeoPackage *) geoPackage;

@end
