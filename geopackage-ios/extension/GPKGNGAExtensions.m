//
//  GPKGNGAExtensions.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGNGAExtensions.h"
#import "GPKGFeatureTableIndex.h"

@implementation GPKGNGAExtensions

+(void) deleteTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    // Delete table index
    GPKGTableIndexDao * tableIndexDao = [geoPackage getTableIndexDao];
    [tableIndexDao deleteByIdCascade:table];
    NSString * extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
    [extensionsDao deleteByExtension:extension andTable:table];
    
    // Delete future extensions for the table here
}

+(void) deleteExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGExtensionsDao * extensionDao = [geoPackage getExtensionsDao];
    
    // Delete table index tables
    GPKGGeometryIndexDao * geometryIndexDao = [geoPackage getGeometryIndexDao];
    GPKGTableIndexDao * tableIndexDao = [geoPackage getTableIndexDao];
    [geometryIndexDao dropTable];
    [tableIndexDao dropTable];
    NSString * extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
    [extensionDao deleteByExtension:extension];
    
    // Delete future extension tables here
}

@end
