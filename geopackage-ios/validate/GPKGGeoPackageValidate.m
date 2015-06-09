//
//  GPKGGeoPackageValidate.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageValidate.h"
#import "GPKGGeoPackageConstants.h"

@implementation GPKGGeoPackageValidate

+(BOOL) hasGeoPackageExtension: (NSString *) file{
    NSString * extension = [file pathExtension];
    BOOL isGeoPackage = extension != nil
        && ([extension caseInsensitiveCompare:GPKG_GEOPACKAGE_EXTENSION]
            || [extension caseInsensitiveCompare:GPKG_GEOPACKAGE_EXTENDED_EXTENSION]);
    return isGeoPackage;
}

+(void) validateGeoPackageExtension: (NSString *) file{
    if(![self hasGeoPackageExtension:file]){
        [NSException raise:@"Invalid Extension" format:@"GeoPackage database file '%@' does not have a valid extension of '%@' or '%@'", file, GPKG_GEOPACKAGE_EXTENSION, GPKG_GEOPACKAGE_EXTENDED_EXTENSION];
    }
}

+(BOOL) hasMinimumTables: (GPKGGeoPackage *) geoPackage{
    BOOL hasMinimum = [[geoPackage getSpatialReferenceSystemDao] tableExists] && [[geoPackage getContentsDao] tableExists];
    return hasMinimum;
}

+(void) validateMinimumTables: (GPKGGeoPackage *) geoPackage{
    if(![self hasMinimumTables:geoPackage]){
        [NSException raise:@"Minimum Tables" format:@"Invalid GeoPackage. Does not contain required tables: %@ & %@, GeoPackage Name: %@", GPKG_SRS_TABLE_NAME, GPKG_CON_TABLE_NAME, geoPackage.name];
    }
}

@end
