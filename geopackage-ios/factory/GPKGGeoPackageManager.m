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
    NSString *filename = @"gdal_sample.gpkg"; // TODO
    
    GPKGConnection *database = [[GPKGConnection alloc] initWithDatabaseFilename:filename];
    GPKGGeoPackage *geoPackage = [[GPKGGeoPackage alloc] initWithConnection:database];
    return geoPackage;
}

@end
