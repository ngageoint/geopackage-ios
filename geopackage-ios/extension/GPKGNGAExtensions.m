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
#import "GPKGSqlUtils.h"
#import "GPKGUserCustomTableReader.h"
#import "GPKGAlterTable.h"

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

+(void) copyTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

    @try {
        
        [self copyContentsIdWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copyFeatureStyleWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copyTileScalingWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copyFeatureTileLinkWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copyGeometryIndexWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        
        // Copy future extensions for the table here
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to copy extensions for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
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

+(void) copyGeometryIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

    @try {
        
        GPKGExtensionsDao *extensionsDao = [geoPackage getExtensionsDao];
        
        if ([extensionsDao tableExists]) {
            
            GPKGResultSet *extensions = [extensionsDao queryByExtension:[GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR] andTable:table];
            @try {
                if([extensions moveToNext]){
                    GPKGExtensions *extension = (GPKGExtensions *)[extensionsDao getObject:extensions];
                    
                    [extension setTableName:newTable];
                    [extensionsDao create:extension];
                    
                    GPKGTableIndexDao *tableIndexDao = [geoPackage getTableIndexDao];
                    if([tableIndexDao tableExists]){
                        
                        GPKGTableIndex *tableIndex = (GPKGTableIndex *)[tableIndexDao queryForIdObject:table];
                        if(tableIndex != nil){
                            
                            [tableIndex setTableName:newTable];
                            [tableIndexDao create:tableIndex];
                            
                            if([geoPackage isTable:GPKG_GI_TABLE_NAME]){
                                
                                [GPKGSqlUtils transferContentInTable:GPKG_GI_TABLE_NAME inColumn:GPKG_GI_COLUMN_TABLE_NAME withNewValue:newTable andCurrentValue:table withConnection:geoPackage.database];
                                
                            }
                        }
                    }
                }
            } @finally {
                [extensions close];
            }

        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Geometry Index for table: %@, copied from table: %@. error: %@", newTable, table, exception);
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

+(void) copyFeatureTileLinkWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

    @try {
        
        GPKGExtensionsDao *extensionsDao = [geoPackage getExtensionsDao];
        
        if ([extensionsDao tableExists]) {
            
            GPKGResultSet *extensions = [extensionsDao queryByExtension:[GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_FEATURE_TILE_LINK_AUTHOR andExtensionName:GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR]];
            @try {
                if(extensions.count > 0){

                    GPKGFeatureTileLinkDao *featureTileLinkDao = [geoPackage getFeatureTileLinkDao];
                    if([featureTileLinkDao tableExists]){
                        
                        NSMutableArray<GPKGFeatureTileLink *> *newLinks = [NSMutableArray array];
                        
                        GPKGResultSet *featureTileLinks = [featureTileLinkDao queryForFeatureTableName:table];
                        @try {
                            while([featureTileLinks moveToNext]){
                                GPKGFeatureTileLink *featureTileLink = (GPKGFeatureTileLink *)[featureTileLinkDao getObject:featureTileLinks];
                                [featureTileLink setFeatureTableName:newTable];
                                [newLinks addObject:featureTileLink];
                            }
                        } @finally {
                            [featureTileLinks close];
                        }
                        
                        featureTileLinks = [featureTileLinkDao queryForTileTableName:table];
                        @try {
                            while([featureTileLinks moveToNext]){
                                GPKGFeatureTileLink *featureTileLink = (GPKGFeatureTileLink *)[featureTileLinkDao getObject:featureTileLinks];
                                [featureTileLink setTileTableName:newTable];
                                [newLinks addObject:featureTileLink];
                            }
                        } @finally {
                            [featureTileLinks close];
                        }
                        
                        for(GPKGFeatureTileLink *featureTileLink in newLinks){
                            [featureTileLinkDao create:featureTileLink];
                        }
                        
                    }
                    
                }
            } @finally {
                [extensions close];
            }
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Feature Tile Link for table: %@, copied from table: %@. error: %@", newTable, table, exception);
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

+(void) copyTileScalingWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

    @try {
        
        GPKGTileTableScaling *tileTableScaling = [[GPKGTileTableScaling alloc] initWithGeoPackage:geoPackage andTableName:table];
        
        if ([tileTableScaling has]) {
            
            GPKGExtensions *extension = [tileTableScaling getExtension];
            
            if(extension != nil){
                [extension setTableName:newTable];
                [tileTableScaling.extensionsDao create:extension];
                
                if([geoPackage isTable:GPKG_TS_TABLE_NAME]){
                    
                    [GPKGSqlUtils transferContentInTable:GPKG_TS_TABLE_NAME inColumn:GPKG_TS_COLUMN_TABLE_NAME withNewValue:newTable andCurrentValue:table withConnection:geoPackage.database];
                    
                }
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Tile Scaling for table: %@, copied from table: %@. error: %@", newTable, table, exception);
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

+(void) copyFeatureStyleWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

    @try {
        
        GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage];
        if([featureStyleExtension hasRelationshipWithTable:table]){
            
            GPKGExtensions *extension = [featureStyleExtension getWithExtensionName:[featureStyleExtension getExtensionName] andTableName:table andColumnName:nil];
            
            if (extension != nil) {
                [extension setTableName:newTable];
                [featureStyleExtension.extensionsDao create:extension];
                
                GPKGContentsIdExtension *contentsIdExtension = [featureStyleExtension contentsId];
                NSNumber *contentsId = [contentsIdExtension getIdForTableName:table];
                NSNumber *newContentsId = [contentsIdExtension getIdForTableName:newTable];
                
                if (contentsId != nil && newContentsId != nil) {
                    
                    if([featureStyleExtension hasTableStyleRelationshipWithTable:table]){
                        
                        [self copyFeatureTableStyleWithExtension:featureStyleExtension andMappingTablePrefix:GPKG_FSE_TABLE_MAPPING_TABLE_STYLE andTable:table andNewTable:newTable andContentsId:contentsId andNewContentsId:newContentsId];
                        
                    }
                    
                    if ([featureStyleExtension hasTableIconRelationshipWithTable:table]) {
                        
                        [self copyFeatureTableStyleWithExtension:featureStyleExtension andMappingTablePrefix:GPKG_FSE_TABLE_MAPPING_TABLE_ICON andTable:table andNewTable:newTable andContentsId:contentsId andNewContentsId:newContentsId];
                        
                    }
                    
                }
                
            }
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Feature Style for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

/**
 * Copy the feature table style
 *
 * @param featureStyleExtension
 *            feature style extension
 * @param mappingTablePrefix
 *            mapping table prefix
 * @param table
 *            table name
 * @param newTable
 *            new table name
 * @param contentsId
 *            contents id
 * @param newContentsId
 *            new contents id
 */
+(void) copyFeatureTableStyleWithExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andMappingTablePrefix: (NSString *) mappingTablePrefix andTable: (NSString *) table andNewTable: (NSString *) newTable andContentsId: (NSNumber *) contentsId andNewContentsId: (NSNumber *) newContentsId{
    
    GPKGGeoPackage *geoPackage = featureStyleExtension.geoPackage;
    
    NSString *mappingTableName = [featureStyleExtension mappingTableNameWithPrefix:mappingTablePrefix andTable:table];
    
    GPKGExtensionsDao *extensionsDao = featureStyleExtension.extensionsDao;
    GPKGResultSet *extensions = [extensionsDao queryByExtension:[[featureStyleExtension relatedTables] getExtensionName] andTable:mappingTableName];
    
    @try {
        if([extensions moveToNext]){
            GPKGExtensions *extension = (GPKGExtensions *)[extensionsDao getObject:extensions];
            
            NSString *newMappingTableName = [featureStyleExtension mappingTableNameWithPrefix:mappingTablePrefix andTable:newTable];
            
            GPKGUserCustomTable *userTable = [GPKGUserCustomTableReader readTableWithConnection:geoPackage.database andTableName:mappingTableName];
            [GPKGAlterTable copyTable:userTable toTable:newMappingTableName andTransfer:NO withConnection:geoPackage.database];
            
            GPKGTableMapping *mappingTableTableMapping = [[GPKGTableMapping alloc] initWithTable:userTable andNewTable:newMappingTableName];
            GPKGMappedColumn *baseIdColumn = [mappingTableTableMapping columnForName:GPKG_UMT_COLUMN_BASE_ID];
            [baseIdColumn setConstantValue:newContentsId];
            [baseIdColumn setWhereValue:contentsId];
            [GPKGSqlUtils transferTableContent:mappingTableTableMapping withConnection:geoPackage.database];
            
            [extension setTableName:newMappingTableName];
            [extensionsDao create:extension];

            GPKGTableMapping *extendedRelationTableMapping = [[GPKGTableMapping alloc] initWithTableName:GPKG_ER_TABLE_NAME andConnection:geoPackage.database];
            [extendedRelationTableMapping removeColumn:GPKG_ER_COLUMN_ID];
            GPKGMappedColumn *baseTableNameColumn = [extendedRelationTableMapping columnForName:GPKG_ER_COLUMN_BASE_TABLE_NAME];
            [baseTableNameColumn setWhereValue:GPKG_CI_TABLE_NAME];
            GPKGMappedColumn *mappingTableNameColumn = [extendedRelationTableMapping columnForName:GPKG_ER_COLUMN_MAPPING_TABLE_NAME];
            [mappingTableNameColumn setConstantValue:newMappingTableName];
            [mappingTableNameColumn setWhereValue:mappingTableName];
            [GPKGSqlUtils transferTableContent:extendedRelationTableMapping withConnection:geoPackage.database];

        }
    } @finally {
        [extensions close];
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

+(void) copyContentsIdWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

    @try {
        
        GPKGContentsIdExtension *contentsIdExtension = [[GPKGContentsIdExtension alloc] initWithGeoPackage:geoPackage];
        
        if ([contentsIdExtension has]) {
            if([contentsIdExtension getForTableName:table] != nil){
                [contentsIdExtension createForTableName:newTable];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Contents Id for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

@end
