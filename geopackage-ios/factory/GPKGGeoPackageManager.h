//
//  GPKGGeoPackageManager.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGGeoPackageManager : NSObject

-(BOOL) delete: (NSString *) database;

-(BOOL) create: (NSString *) database;

-(BOOL) importGeoPackage: (NSString *) file;

-(GPKGGeoPackage *) open: (NSString *) database;

@end
