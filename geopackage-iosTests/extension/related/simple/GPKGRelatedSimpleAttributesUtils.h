//
//  GPKGRelatedSimpleAttributesUtils.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGRelatedSimpleAttributesUtils : NSObject

/**
 * Test related simple attributes tables
 *
 * @param geoPackage
 */
+(void) testSimpleAttributes: (GPKGGeoPackage *) geoPackage;

@end
