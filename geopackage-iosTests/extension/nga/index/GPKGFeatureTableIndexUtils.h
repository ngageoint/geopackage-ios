//
//  GPKGFeatureTableIndexUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/19/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackage.h"

@interface GPKGFeatureTableIndexUtils : NSObject

+(void) testIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andGeodesic: (BOOL) geodesic;

+(void) testDeleteAllWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
