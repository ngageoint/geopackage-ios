//
//  GPKGGeoPackageExtensions.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackageExtensions.h"
#import "GPKGNGAExtensions.h"
#import "GPKGRTreeIndexExtension.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGCoverageData.h"
#import "GPKGSchemaExtension.h"
#import "GPKGMetadataExtension.h"
#import "GPKGCrsWktExtension.h"
#import "GPKGTableInfo.h"
#import "GPKGSqlUtils.h"
#import "GPKGUserCustomTableReader.h"
#import "GPKGAlterTable.h"
#import "GPKGTableCreator.h"
#import "GPKGConstraintParser.h"

@implementation GPKGGeoPackageExtensions

+(void) deleteTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{
    
    // Handle deleting any extensions with extra tables here
    [GPKGNGAExtensions deleteTableExtensionsWithGeoPackage:geoPackage andTable:table];
    
    [self deleteRTreeSpatialIndexWithGeoPackage:geoPackage andTable:table];
    [self deleteRelatedTablesWithGeoPackage:geoPackage andTable:table];
    [self deleteGriddedCoverageWithGeoPackage:geoPackage andTable:table];
    [self deleteSchemaWithGeoPackage:geoPackage andTable:table];
    [self deleteMetadataWithGeoPackage:geoPackage andTable:table];
    
    [self deleteWithGeoPackage:geoPackage andTable:table];
}

+(void) deleteExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Handle deleting any extensions with extra tables here
    [GPKGNGAExtensions deleteExtensionsWithGeoPackage:geoPackage];
    
    [self deleteRTreeSpatialIndexExtensionWithGeoPackage:geoPackage];
    [self deleteRelatedTablesExtensionWithGeoPackage:geoPackage];
    [self deleteGriddedCoverageExtensionWithGeoPackage:geoPackage];
    [self deleteSchemaExtensionWithGeoPackage:geoPackage];
    [self deleteMetadataExtensionWithGeoPackage:geoPackage];
    [self deleteCrsWktExtensionWithGeoPackage:geoPackage];
    
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
        [geoPackage dropTable:extensionsDao.tableName];
    }
}

+(void) copyTableExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{
    
    @try {
        
        [self copyRTreeSpatialIndexWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copyRelatedTablesWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copyGriddedCoverageWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copySchemaWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        [self copyMetadataWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        
        // Handle copying any extensions with extra tables here
        [GPKGNGAExtensions copyTableExtensionsWithGeoPackage:geoPackage andTable:table andNewTable:newTable];
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to copy extensions for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

+(void) deleteRTreeSpatialIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{

    GPKGRTreeIndexExtension *rTreeIndexExtension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
    if([rTreeIndexExtension hasWithTableName:table]){
        [rTreeIndexExtension deleteWithTableName:table];
    }

}

+(void) deleteRTreeSpatialIndexExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGRTreeIndexExtension *rTreeIndexExtension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
    if([rTreeIndexExtension has]){
        [rTreeIndexExtension deleteAll];
    }
    
}

+(void) copyRTreeSpatialIndexWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

    @try {
        
        GPKGRTreeIndexExtension *rTreeIndexExtension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
        
        if([rTreeIndexExtension hasWithTableName:table]){
            GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage getGeometryColumnsDao];
            
            GPKGGeometryColumns *geometryColumns = [geometryColumnsDao queryForTableName:newTable];
            if(geometryColumns != nil){
                GPKGTableInfo *tableInfo = [GPKGTableInfo infoWithConnection:geoPackage.database andTable:newTable];
                if(tableInfo != nil){
                    NSString *pk = [[tableInfo primaryKey] name];
                    [rTreeIndexExtension createWithTableName:newTable andGeometryColumnName:geometryColumns.columnName andIdColumnName:pk];
                }
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create RTree for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
}

+(void) deleteRelatedTablesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{

    GPKGRelatedTablesExtension *relatedTablesExtension = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    if ([relatedTablesExtension has]) {
        [relatedTablesExtension removeRelationshipsWithTable:table];
    }
    
}

+(void) deleteRelatedTablesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGRelatedTablesExtension *relatedTablesExtension = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    if ([relatedTablesExtension has]) {
        [relatedTablesExtension removeExtension];
    }
    
}

+(void) copyRelatedTablesWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

    @try {
        
        GPKGRelatedTablesExtension *relatedTablesExtension = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
        if([relatedTablesExtension has]){
            
            GPKGExtendedRelationsDao *extendedRelationsDao = [relatedTablesExtension getExtendedRelationsDao];
            GPKGExtensionsDao *extensionsDao = [geoPackage getExtensionsDao];
            
            GPKGResultSet *extendRelations = [extendedRelationsDao relationsToBaseTable:table];
            @try {
                while([extendRelations moveToNext]){
                    GPKGExtendedRelation *extendedRelation = [extendedRelationsDao relation:extendRelations];
                    
                    NSString *mappingTableName = extendedRelation.mappingTableName;
                    
                    GPKGResultSet *extensions = [extensionsDao queryByExtension:[relatedTablesExtension getExtensionName] andTable:mappingTableName];
                    @try {
                        if([extensions moveToNext]){
                            GPKGExtensions *extension = (GPKGExtensions *)[extensionsDao getObject:extensions];
                            
                            NSString *newMappingTableName = [GPKGSqlUtils createName:mappingTableName andReplace:table withReplacement:newTable withConnection:geoPackage.database];
                            
                            GPKGUserCustomTable *userTable = [GPKGUserCustomTableReader readTableWithConnection:geoPackage.database andTableName:mappingTableName];
                            [GPKGAlterTable copyTable:userTable toTable:newMappingTableName withConnection:geoPackage.database];
                            
                            [extension setTableName:newMappingTableName];
                            [extensionsDao create:extension];
                            
                            GPKGTableMapping *extendedRelationTableMapping = [[GPKGTableMapping alloc] initWithTableName:GPKG_ER_TABLE_NAME andConnection:geoPackage.database];
                            [extendedRelationTableMapping removeColumn:GPKG_ER_COLUMN_ID];
                            GPKGMappedColumn *baseTableNameColumn = [extendedRelationTableMapping columnForName:GPKG_ER_COLUMN_BASE_TABLE_NAME];
                            [baseTableNameColumn setConstantValue:newTable];
                            [baseTableNameColumn setWhereValue:table];
                            GPKGMappedColumn *mappingTableNameColumn = [extendedRelationTableMapping columnForName:GPKG_ER_COLUMN_MAPPING_TABLE_NAME];
                            [mappingTableNameColumn setConstantValue:newMappingTableName];
                            [mappingTableNameColumn setWhereValue:mappingTableName];
                            [GPKGSqlUtils transferTableContent:extendedRelationTableMapping withConnection:geoPackage.database];
                            
                        }
                    } @finally {
                        [extensions close];
                    }
                    
                }
            } @finally {
                [extendRelations close];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Related Tables for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

+(void) deleteGriddedCoverageWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{

    if([geoPackage isTable:table ofType:GPKG_CDT_GRIDDED_COVERAGE]){
        
        GPKGGriddedTileDao *griddedTileDao = [geoPackage getGriddedTileDao];
        GPKGGriddedCoverageDao *griddedCoverageDao = [geoPackage getGriddedCoverageDao];
        GPKGExtensionsDao *extensionsDao = [geoPackage getExtensionsDao];
        
        if ([griddedTileDao tableExists]) {
            [griddedTileDao deleteByTableName:table];
        }
        if ([griddedCoverageDao tableExists]) {
            [griddedCoverageDao deleteByTableName:table];
        }
        if ([extensionsDao tableExists]) {
            [extensionsDao deleteByExtension:[GPKGExtensions buildDefaultAuthorExtensionName:GPKG_GRIDDED_COVERAGE_EXTENSION_NAME] andTable:table];
        }
        
    }
    
}

+(void) deleteGriddedCoverageExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    NSArray *coverageTables = [geoPackage getTablesByType:GPKG_CDT_GRIDDED_COVERAGE];
    for(NSString *table in coverageTables){
        [geoPackage deleteTable:table];
    }
    
    GPKGGriddedTileDao *griddedTileDao = [geoPackage getGriddedTileDao];
    GPKGGriddedCoverageDao *griddedCoverageDao = [geoPackage getGriddedCoverageDao];
    GPKGExtensionsDao *extensionsDao = [geoPackage getExtensionsDao];
    
    if ([griddedTileDao tableExists]) {
        [geoPackage dropTable:griddedTileDao.tableName];
    }
    if ([griddedCoverageDao tableExists]) {
        [geoPackage dropTable:griddedCoverageDao.tableName];
    }
    if ([extensionsDao tableExists]) {
        [extensionsDao deleteByExtension:[GPKGExtensions buildDefaultAuthorExtensionName:GPKG_GRIDDED_COVERAGE_EXTENSION_NAME]];
    }
    
}

+(void) copyGriddedCoverageWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

    @try {
        
        if([geoPackage isTable:table ofType:GPKG_CDT_GRIDDED_COVERAGE]){
            
            GPKGExtensionsDao *extensionsDao = [geoPackage getExtensionsDao];
            
            if ([extensionsDao tableExists]) {
                
                GPKGResultSet *extensions = [extensionsDao queryByExtension:[GPKGExtensions buildDefaultAuthorExtensionName:GPKG_GRIDDED_COVERAGE_EXTENSION_NAME] andTable:table];
                @try {
                    if([extensions moveToNext]){
                        GPKGExtensions *extension = (GPKGExtensions *)[extensionsDao getObject:extensions];
                        
                        [extension setTableName:newTable];
                        [extensionsDao create:extension];
                        
                        GPKGGriddedCoverageDao *griddedCoverageDao = [geoPackage getGriddedCoverageDao];
                        if([griddedCoverageDao tableExists]){
                            
                            [GPKGSqlUtils transferContentInTable:GPKG_CDGC_TABLE_NAME inColumn:GPKG_CDGC_COLUMN_TILE_MATRIX_SET_NAME withNewValue:newTable andCurrentValue:table andIdColumn:GPKG_CDGC_COLUMN_ID withConnection:geoPackage.database];
                            
                        }
                        
                        GPKGGriddedTileDao *griddedTileDao = [geoPackage getGriddedTileDao];
                        if([griddedTileDao tableExists]){
                            
                            [GPKGSqlUtils transferContentInTable:GPKG_CDGT_TABLE_NAME inColumn:GPKG_CDGT_COLUMN_TABLE_NAME withNewValue:newTable andCurrentValue:table andIdColumn:GPKG_CDGT_COLUMN_ID withConnection:geoPackage.database];
                            
                        }
                        
                    }
                } @finally {
                    [extensions close];
                }
                
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Gridded Coverage for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

+(void) deleteSchemaWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{

    GPKGDataColumnsDao *dataColumnsDao = [geoPackage getDataColumnsDao];
    if([dataColumnsDao tableExists]){
        [dataColumnsDao deleteByTableName:table];
    }

}

+(void) deleteSchemaExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGSchemaExtension *schemaExtension = [[GPKGSchemaExtension alloc] initWithGeoPackage:geoPackage];
    if ([schemaExtension has]) {
        [schemaExtension removeExtension];
    }
    
}

+(void) copySchemaWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

    @try {
        
        if([geoPackage isTable:GPKG_DC_TABLE_NAME]){
            
            GPKGUserCustomTable *dataColumnsTable = [GPKGUserCustomTableReader readTableWithConnection:geoPackage.database andTableName:GPKG_DC_TABLE_NAME];
            GPKGUserColumn *nameColumn = [dataColumnsTable getColumnWithColumnName:GPKG_DC_COLUMN_NAME];
            if([nameColumn hasConstraints]){
                [nameColumn clearConstraints];
                if([dataColumnsTable hasConstraints]){
                    [dataColumnsTable clearConstraints];
                    NSString *constraintSql = [[GPKGTableCreator readSQLScript:GPKG_DC_TABLE_NAME] objectAtIndex:0];
                    GPKGTableConstraints *constraints = [GPKGConstraintParser tableConstraintsForSQL:constraintSql];
                    [dataColumnsTable addConstraints:[constraints tableConstraints]];
                }
                [GPKGAlterTable alterColumn:nameColumn inTable:dataColumnsTable withConnection:geoPackage.database];
            }
            
            [GPKGSqlUtils transferContentInTable:GPKG_DC_TABLE_NAME inColumn:GPKG_DC_COLUMN_TABLE_NAME withNewValue:newTable andCurrentValue:table withConnection:geoPackage.database];
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Schema for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

+(void) deleteMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table{

    GPKGMetadataReferenceDao *metadataReferenceDao = [geoPackage getMetadataReferenceDao];
    if([metadataReferenceDao tableExists]){
        [metadataReferenceDao deleteByTableName:table];
    }
    
}

+(void) deleteMetadataExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
    if ([metadataExtension has]) {
        [metadataExtension removeExtension];
    }
    
}

+(void) copyMetadataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) table andNewTable: (NSString *) newTable{

        @try {
    
            if([geoPackage isTable:GPKG_MR_TABLE_NAME]){
                
                [GPKGSqlUtils transferContentInTable:GPKG_MR_TABLE_NAME inColumn:GPKG_MR_COLUMN_TABLE_NAME withNewValue:newTable andCurrentValue:table withConnection:geoPackage.database];
                
            }
            
        } @catch (NSException *exception) {
            NSLog(@"Failed to create Metadata for table: %@, copied from table: %@. error: %@", newTable, table, exception);
        }
            
}

+(void) deleteCrsWktExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGCrsWktExtension *crsWktExtension = [[GPKGCrsWktExtension alloc] initWithGeoPackage:geoPackage];
    if ([crsWktExtension has]) {
        [crsWktExtension removeExtension];
    }
    
}

@end
