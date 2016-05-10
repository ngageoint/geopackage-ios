//
//  GPKGFeatureTileTableLinkerUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGFeatureTileTableLinkerUtils : NSObject

/**
 *  Test link
 *
 *  @param geoPackage GeoPackage
 */
+(void) testLinkWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
