//
//  GPKGGeoPackageManager.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageManager.h"
#import "GPKGGeoPackageConstants.h"

@implementation GPKGGeoPackageManager

-(BOOL) delete: (NSString *) database{
    // TODO
    return true;
}

-(BOOL) create: (NSString *) database{
    // TODO
    return true;
}

-(BOOL) importGeoPackage: (NSString *) file{
    // TODO
    return true;
}

-(GPKGGeoPackage *) open: (NSString *) database{
    // TODO
    NSString *filename = database;
    BOOL writable = true; // TODO
    
    GPKGConnection *db = [[GPKGConnection alloc] initWithDatabaseFilename:filename];
    GPKGGeoPackage *geoPackage = [[GPKGGeoPackage alloc] initWithConnection:db andWritable:writable];
    return geoPackage;
}

@end
