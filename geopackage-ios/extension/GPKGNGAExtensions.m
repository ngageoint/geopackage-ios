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
#import "GPKGTileTableScaling.h"
#import "GPKGPropertiesExtension.h"
#import "GPKGFeatureStyleExtension.h"
#import "GPKGContentsIdExtension.h"

@implementation GPKGNGAExtensions

+(void) deleteTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    [self deleteGeometryIndexWithGeoPackage:geoPackage andTable:table];
    [self deleteFeatureTileLinkWithGeoPackage:geoPackage andTable:table];
    [self deleteTileScalingWithGeoPackage:geoPackage andTable:table];
    [self deletePropertiesWithGeoPackage:geoPackage andTable:table];
    [self deleteFeatureStyleWithGeoPackage:geoPackage andTable:table];
    [self deleteContentsIdWithGeoPackage:geoPackage andTable:table];
    
    // Delete future extensions for the table here
}

+(void) deleteExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [self deleteGeometryIndexExtensionWithGeoPackage:geoPackage];
    [self deleteFeatureTileLinkExtensionWithGeoPackage:geoPackage];
    [self deleteTileScalingExtensionWithGeoPackage:geoPackage];
    [self deletePropertiesExtensionWithGeoPackage:geoPackage];
    [self deleteFeatureStyleExtensionWithGeoPackage:geoPackage];
    [self deleteContentsIdExtensionWithGeoPackage:geoPackage];
    
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

+(void) deleteTileScalingWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    GPKGTileScalingDao *tileScalingDao = [geoPackage getTileScalingDao];
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    if([tileScalingDao tableExists]){
        [tileScalingDao deleteById:table];
    }
    if([extensionsDao tableExists]){
        NSString * extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_TILE_SCALING_AUTHOR andExtensionName:GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension andTable:table];
    }
    
}

+(void) deleteTileScalingExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGTileScalingDao *tileScalingDao = [geoPackage getTileScalingDao];
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    if([tileScalingDao tableExists]){
        [tileScalingDao dropTable];
    }
    if([extensionsDao tableExists]){
        NSString * extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_TILE_SCALING_AUTHOR andExtensionName:GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension];
    }
    
}

+(void) deletePropertiesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    if([table caseInsensitiveCompare:GPKG_EXTENSION_PROPERTIES_TABLE_NAME] == NSOrderedSame){
        [self deletePropertiesExtensionWithGeoPackage:geoPackage];
    }
    
}

+(void) deletePropertiesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];
    
    if([geoPackage isTable:GPKG_EXTENSION_PROPERTIES_TABLE_NAME]){
        GPKGContentsDao *contentsDao = [geoPackage getContentsDao];
        [contentsDao deleteTable:GPKG_EXTENSION_PROPERTIES_TABLE_NAME];
    }
    
    if([extensionsDao tableExists]){
        NSString * extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_PROPERTIES_AUTHOR andExtensionName:GPKG_EXTENSION_PROPERTIES_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension andTable:GPKG_EXTENSION_PROPERTIES_TABLE_NAME];
    }
}

+(void) deleteFeatureStyleWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage];
    if([featureStyleExtension hasWithTable:table]){
        [featureStyleExtension deleteRelationshipsWithTable:table];
    }
}

+(void) deleteFeatureStyleExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage];
    if ([featureStyleExtension has]) {
        [featureStyleExtension removeExtension];
    }
}

+(void) deleteContentsIdWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    GPKGContentsIdExtension *contentsIdExtension = [[GPKGContentsIdExtension alloc] initWithGeoPackage:geoPackage];
    if ([contentsIdExtension has]) {
        [contentsIdExtension deleteForTableName:table];
    }
    
}

+(void) deleteContentsIdExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGContentsIdExtension *contentsIdExtension = [[GPKGContentsIdExtension alloc] initWithGeoPackage:geoPackage];
    if ([contentsIdExtension has]) {
        [contentsIdExtension removeExtension];
    }
    
}

@end
