//
//  GPKGNGAExtensions.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGNGAExtensions.h"
#import "GPKGFeatureTableIndex.h"
#import "GPKGFeatureTileLinkDao.h"
#import "GPKGFeatureTileTableLinker.h"

@implementation GPKGNGAExtensions

+(void) deleteTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    [self deleteGeometryIndexWithGeoPackage:geoPackage andTable:table];
    [self deleteFeatureTileLinkWithGeoPackage:geoPackage andTable:table];
    
    // Delete future extensions for the table here
}

+(void) deleteExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [self deleteGeometryIndexExtensionWithGeoPackage:geoPackage];
    [self deleteFeatureTileLinkExtensionWithGeoPackage:geoPackage];
    
    // Delete future extension tables here
}

+(void) deleteGeometryIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    GPKGTableIndexDao * tableIndexDao = [geoPackage getTableIndexDao];
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    if([tableIndexDao tableExists]){
        [tableIndexDao deleteByIdCascade:table];
    }
    if([extensionsDao tableExists]){
        NSString * extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension andTable:table];
    }
    
}

+(void) deleteGeometryIndexExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryIndexDao * geometryIndexDao = [geoPackage getGeometryIndexDao];
    GPKGTableIndexDao * tableIndexDao = [geoPackage getTableIndexDao];
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    if([geometryIndexDao tableExists]){
        [geometryIndexDao dropTable];
    }
    if([tableIndexDao tableExists]){
        [tableIndexDao dropTable];
    }
    if([extensionsDao tableExists]){
        NSString * extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension];
    }
    
}

+(void) deleteFeatureTileLinkWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    GPKGFeatureTileLinkDao * featureTileLinkDao = [geoPackage getFeatureTileLinkDao];
    
    if([featureTileLinkDao tableExists]){
        [featureTileLinkDao deleteByTableName:table];
    }
}

+(void) deleteFeatureTileLinkExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGFeatureTileLinkDao * featureTileLinkDao = [geoPackage getFeatureTileLinkDao];
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    if([featureTileLinkDao tableExists]){
        [featureTileLinkDao dropTable];
    }
    if([extensionsDao tableExists]){
        NSString * extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_FEATURE_TILE_LINK_AUTHOR andExtensionName:GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension];
    }
}

@end
