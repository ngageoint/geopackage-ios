//
//  GPKGGeoPackageManager.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageManager.h"

@implementation GPKGGeoPackageManager

-(GPKGGeoPackage *)open:(NSString *) name{
    GPKGConnection *database = [[GPKGConnection alloc] initWithDatabaseFilename:@"gdal_sample.gpkg"]; // TODO
    GPKGGeoPackage *geoPackage = [[GPKGGeoPackage alloc] initWithName: name andPath:@"TODO" andDatabase: database];
    return geoPackage;
}

@end
