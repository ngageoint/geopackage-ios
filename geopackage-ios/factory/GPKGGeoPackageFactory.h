//
//  GPKGGeoPackageFactory.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackageManager.h"

@interface GPKGGeoPackageFactory : NSObject

+(GPKGGeoPackageManager *) getManager;

@end
