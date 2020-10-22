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

NSString * const GPKG_NGA_EXTENSION_AUTHOR = @"nga";

@implementation GPKGNGAExtensions

+(GPKGNGAExtensions *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [[GPKGNGAExtensions alloc] initWithGeoPackage:geoPackage];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    return self;
}

-(NSString *) author{
    return GPKG_NGA_EXTENSION_AUTHOR;
}

-(void) deleteExtensionsForTable: (NSString *) table{
    
    [self deleteGeometryIndexForTable:table];
    [self deleteFeatureTileLinkForTable:table];
    [self deleteTileScalingForTable:table];
    [self deletePropertiesForTable:table];
    [self deleteFeatureStyleForTable:table];
    [self deleteContentsIdForTable:table];
    
    // Delete future extensions for the table here
}

-(void) deleteExtensions{
    
    [self deleteGeometryIndexExtension];
    [self deleteFeatureTileLinkExtension];
    [self deleteTileScalingExtension];
    [self deletePropertiesExtension];
    [self deleteFeatureStyleExtension];
    [self deleteContentsIdExtension];
    
    // Delete future extension tables here
}

-(void) copyExtensionsFromTable: (NSString *) table toTable: (NSString *) newTable{
    
    [self copyContentsIdFromTable:table toTable:newTable];
    [self copyFeatureStyleFromTable:table toTable:newTable];
    [self copyTileScalingFromTable:table toTable:newTable];
    [self copyFeatureTileLinkFromTable:table toTable:newTable];
    [self copyGeometryIndexFromTable:table toTable:newTable];
    
    // Copy future extensions for the table here
}

-(void) deleteGeometryIndexForTable: (NSString *) table{
    
    GPKGTableIndexDao *tableIndexDao = [GPKGFeatureTableIndex tableIndexDaoWithGeoPackage:self.geoPackage];
    GPKGExtensionsDao *extensionsDao = [self.geoPackage extensionsDao];
    
    if([tableIndexDao tableExists]){
        [tableIndexDao deleteByIdCascade:table];
    }
    if([extensionsDao tableExists]){
        NSString *extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_NGA_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension andTable:table];
    }
    
}

-(void) deleteGeometryIndexExtension{
    
    GPKGGeometryIndexDao *geometryIndexDao = [GPKGFeatureTableIndex geometryIndexDaoWithGeoPackage:self.geoPackage];
    GPKGTableIndexDao *tableIndexDao = [GPKGFeatureTableIndex tableIndexDaoWithGeoPackage:self.geoPackage];
    GPKGExtensionsDao *extensionsDao = [self.geoPackage extensionsDao];
    
    if([geometryIndexDao tableExists]){
        [geometryIndexDao dropTable];
    }
    if([tableIndexDao tableExists]){
        [tableIndexDao dropTable];
    }
    if([extensionsDao tableExists]){
        NSString *extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_NGA_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension];
    }
    
}

-(void) copyGeometryIndexFromTable: (NSString *) table toTable: (NSString *) newTable{

    @try {
        
        GPKGExtensionsDao *extensionsDao = [self.geoPackage extensionsDao];
        
        if ([extensionsDao tableExists]) {
            
            GPKGResultSet *extensions = [extensionsDao queryByExtension:[GPKGExtensions buildExtensionNameWithAuthor:GPKG_NGA_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR] andTable:table];
            @try {
                if([extensions moveToNext]){
                    GPKGExtensions *extension = (GPKGExtensions *)[extensionsDao object:extensions];
                    
                    [extension setTableName:newTable];
                    [extensionsDao create:extension];
                    
                    GPKGTableIndexDao *tableIndexDao = [GPKGFeatureTableIndex tableIndexDaoWithGeoPackage:self.geoPackage];
                    if([tableIndexDao tableExists]){
                        
                        GPKGTableIndex *tableIndex = (GPKGTableIndex *)[tableIndexDao queryForIdObject:table];
                        if(tableIndex != nil){
                            
                            [tableIndex setTableName:newTable];
                            [tableIndexDao create:tableIndex];
                            
                            if([self.geoPackage isTableOrView:GPKG_GI_TABLE_NAME]){
                                
                                [GPKGSqlUtils transferContentInTable:GPKG_GI_TABLE_NAME inColumn:GPKG_GI_COLUMN_TABLE_NAME withNewValue:newTable andCurrentValue:table withConnection:self.geoPackage.database];
                                
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

-(void) deleteFeatureTileLinkForTable: (NSString *) table{
    
    GPKGFeatureTileLinkDao *featureTileLinkDao = [GPKGFeatureTileTableLinker featureTileLinkDaoWithGeoPackage:self.geoPackage];
    
    if([featureTileLinkDao tableExists]){
        [featureTileLinkDao deleteByTableName:table];
    }
}

-(void) deleteFeatureTileLinkExtension{
    
    GPKGFeatureTileLinkDao *featureTileLinkDao = [GPKGFeatureTileTableLinker featureTileLinkDaoWithGeoPackage:self.geoPackage];
    GPKGExtensionsDao *extensionsDao = [self.geoPackage extensionsDao];
    
    if([featureTileLinkDao tableExists]){
        [featureTileLinkDao dropTable];
    }
    if([extensionsDao tableExists]){
        NSString *extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_NGA_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension];
    }
}

-(void) copyFeatureTileLinkFromTable: (NSString *) table toTable: (NSString *) newTable{

    @try {
        
        GPKGExtensionsDao *extensionsDao = [self.geoPackage extensionsDao];
        
        if ([extensionsDao tableExists]) {
            
            GPKGResultSet *extensions = [extensionsDao queryByExtension:[GPKGExtensions buildExtensionNameWithAuthor:GPKG_NGA_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR]];
            @try {
                if(extensions.count > 0){

                    GPKGFeatureTileLinkDao *featureTileLinkDao = [GPKGFeatureTileTableLinker featureTileLinkDaoWithGeoPackage:self.geoPackage];
                    if([featureTileLinkDao tableExists]){
                        
                        NSMutableArray<GPKGFeatureTileLink *> *newLinks = [NSMutableArray array];
                        
                        GPKGResultSet *featureTileLinks = [featureTileLinkDao queryForFeatureTableName:table];
                        @try {
                            while([featureTileLinks moveToNext]){
                                GPKGFeatureTileLink *featureTileLink = (GPKGFeatureTileLink *)[featureTileLinkDao object:featureTileLinks];
                                [featureTileLink setFeatureTableName:newTable];
                                [newLinks addObject:featureTileLink];
                            }
                        } @finally {
                            [featureTileLinks close];
                        }
                        
                        featureTileLinks = [featureTileLinkDao queryForTileTableName:table];
                        @try {
                            while([featureTileLinks moveToNext]){
                                GPKGFeatureTileLink *featureTileLink = (GPKGFeatureTileLink *)[featureTileLinkDao object:featureTileLinks];
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

-(void) deleteTileScalingForTable: (NSString *) table{
    
    GPKGTileScalingDao *tileScalingDao = [GPKGTileTableScaling tileScalingDaoWithGeoPackage:self.geoPackage];
    GPKGExtensionsDao *extensionsDao = [self.geoPackage extensionsDao];
    
    if([tileScalingDao tableExists]){
        [tileScalingDao deleteById:table];
    }
    if([extensionsDao tableExists]){
        NSString *extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_NGA_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension andTable:table];
    }
    
}

-(void) deleteTileScalingExtension{
    
    GPKGTileScalingDao *tileScalingDao = [GPKGTileTableScaling tileScalingDaoWithGeoPackage:self.geoPackage];
    GPKGExtensionsDao *extensionsDao = [self.geoPackage extensionsDao];
    
    if([tileScalingDao tableExists]){
        [tileScalingDao dropTable];
    }
    if([extensionsDao tableExists]){
        NSString *extension = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_NGA_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR];
        [extensionsDao deleteByExtension:extension];
    }
    
}

-(void) copyTileScalingFromTable: (NSString *) table toTable: (NSString *) newTable{

    @try {
        
        GPKGTileTableScaling *tileTableScaling = [[GPKGTileTableScaling alloc] initWithGeoPackage:self.geoPackage andTableName:table];
        
        if ([tileTableScaling has]) {
            
            GPKGExtensions *extension = [tileTableScaling extension];
            
            if(extension != nil){
                [extension setTableName:newTable];
                [tileTableScaling.extensionsDao create:extension];
                
                if([self.geoPackage isTableOrView:GPKG_TS_TABLE_NAME]){
                    
                    [GPKGSqlUtils transferContentInTable:GPKG_TS_TABLE_NAME inColumn:GPKG_TS_COLUMN_TABLE_NAME withNewValue:newTable andCurrentValue:table withConnection:self.geoPackage.database];
                    
                }
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Tile Scaling for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

-(void) deletePropertiesForTable: (NSString *) table{
    
    if([table caseInsensitiveCompare:GPKG_EXTENSION_PROPERTIES_TABLE_NAME] == NSOrderedSame){
        [self deletePropertiesExtension];
    }
    
}

-(void) deletePropertiesExtension{
    GPKGPropertiesExtension *extension = [[GPKGPropertiesExtension alloc] initWithGeoPackage:self.geoPackage];
    [extension removeExtension];
}

-(void) deleteFeatureStyleForTable: (NSString *) table{
    
    GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:self.geoPackage];
    if([featureStyleExtension hasWithTable:table]){
        [featureStyleExtension deleteRelationshipsWithTable:table];
    }
    
}

-(void) deleteFeatureStyleExtension{
    
    GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:self.geoPackage];
    if ([featureStyleExtension has]) {
        [featureStyleExtension removeExtension];
    }
    
}

-(void) copyFeatureStyleFromTable: (NSString *) table toTable: (NSString *) newTable{

    @try {
        
        GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:self.geoPackage];
        if([featureStyleExtension hasRelationshipWithTable:table]){
            
            GPKGExtensions *extension = [featureStyleExtension forTable:table];
            
            if (extension != nil) {
                [extension setTableName:newTable];
                [featureStyleExtension.extensionsDao create:extension];
                
                GPKGContentsIdExtension *contentsIdExtension = [featureStyleExtension contentsId];
                NSNumber *contentsId = [contentsIdExtension idForTableName:table];
                NSNumber *newContentsId = [contentsIdExtension idForTableName:newTable];
                
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
-(void) copyFeatureTableStyleWithExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andMappingTablePrefix: (NSString *) mappingTablePrefix andTable: (NSString *) table andNewTable: (NSString *) newTable andContentsId: (NSNumber *) contentsId andNewContentsId: (NSNumber *) newContentsId{
    
    GPKGGeoPackage *geoPackage = featureStyleExtension.geoPackage;
    
    NSString *mappingTableName = [featureStyleExtension mappingTableNameWithPrefix:mappingTablePrefix andTable:table];
    
    GPKGExtensionsDao *extensionsDao = featureStyleExtension.extensionsDao;
    GPKGResultSet *extensions = [extensionsDao queryByExtension:[[featureStyleExtension relatedTables] extensionName] andTable:mappingTableName];
    
    @try {
        if([extensions moveToNext]){
            GPKGExtensions *extension = (GPKGExtensions *)[extensionsDao object:extensions];
            
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

-(void) deleteContentsIdForTable: (NSString *) table{
    
    GPKGContentsIdExtension *contentsIdExtension = [[GPKGContentsIdExtension alloc] initWithGeoPackage:self.geoPackage];
    if ([contentsIdExtension has]) {
        [contentsIdExtension deleteForTableName:table];
    }
    
}

-(void) deleteContentsIdExtension{
    
    GPKGContentsIdExtension *contentsIdExtension = [[GPKGContentsIdExtension alloc] initWithGeoPackage:self.geoPackage];
    if ([contentsIdExtension has]) {
        [contentsIdExtension removeExtension];
    }
    
}

-(void) copyContentsIdFromTable: (NSString *) table toTable: (NSString *) newTable{
    
    @try {
        
        GPKGContentsIdExtension *contentsIdExtension = [[GPKGContentsIdExtension alloc] initWithGeoPackage:self.geoPackage];
        
        if ([contentsIdExtension has]) {
            if([contentsIdExtension forTableName:table] != nil){
                [contentsIdExtension createForTableName:newTable];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Contents Id for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

@end
