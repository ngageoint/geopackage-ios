//
//  GPKGGeoPackageExtensions.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackageExtensions.h"
#import "GPKGNGAExtensions.h"

@implementation GPKGGeoPackageExtensions

+(void) deleteTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    // Handle deleting any extensions with extra tables here
    [GPKGNGAExtensions deleteTableExtensionsWithGeoPackage:geoPackage andTable:table];
    
    [self deleteWithGeoPackage:geoPackage andTable:table];
    
}

+(void) deleteExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Handle deleting any extensions with extra tables here
    [GPKGNGAExtensions deleteExtensionsWithGeoPackage:geoPackage];
    
    [self deleteWithGeoPackage:geoPackage];
}

/**
 *  Delete the extensions for the table
 *
 *  @param geoPackage GeoPackage
 *  @param table      table
 */
+(void) deleteWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    if([extensionsDao tableExists]){
        [extensionsDao deleteByTableName:table];
    }
    
}

/**
 *  Delete the extensions
 *
 *  @param geoPackage GeoPackage
 */
+(void) deleteWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    if([extensionsDao tableExists]){
        [extensionsDao deleteAll];
    }
}

@end
