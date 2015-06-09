//
//  GPKGTestSetupTeardown.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGTestSetupTeardown : NSObject

+(GPKGGeoPackage *) setUpCreateWithFeatures: (BOOL) features andTiles: (BOOL) tiles;

+(void) tearDownCreateWithGeoPackage: (GPKGGeoPackage *) geoPackage;

+(GPKGGeoPackage *) setUpImport;

+(void) tearDownImportWithGeoPackage: (GPKGGeoPackage *) geoPackage;

@end
