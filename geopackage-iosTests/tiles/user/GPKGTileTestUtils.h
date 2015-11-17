//
//  GPKGTileTestUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGTileTestUtils : NSObject

+(void)testTileMatrixBoundingBox: (GPKGGeoPackage *) geoPackage;

@end
