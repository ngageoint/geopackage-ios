//
//  GPKGExtensionManager.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGExtensionManager.h"
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

@interface GPKGExtensionManager()

@property (nonatomic, strong)  NSMutableArray<GPKGExtensionManagement *> *communityExtensions;

@end

@implementation GPKGExtensionManager

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        _communityExtensions = [NSMutableArray array];
        [_communityExtensions addObject:[[GPKGNGAExtensions alloc] initWithGeoPackage:geoPackage]];
    }
    return self;
}

-(NSString *) author{
    return GPKG_EXTENSION_AUTHOR;
}

-(void) deleteExtensionsForTable: (NSString *) table{
    
    // Handle deleting any extensions with extra tables here
    for(GPKGExtensionManagement *extensions in _communityExtensions){
        [extensions deleteExtensionsForTable:table];
    }
    
    [self deleteRTreeSpatialIndexForTable:table];
    [self deleteRelatedTablesForTable:table];
    [self deleteGriddedCoverageForTable:table];
    [self deleteSchemaForTable:table];
    [self deleteMetadataForTable:table];
    
    [self deleteForTable:table];
    
}

/**
 *  Delete the extensions for the table
 *
 *  @param table      table
 */
-(void) deleteForTable: (NSString *) table{
    
    GPKGExtensionsDao *extensionsDao = [_geoPackage extensionsDao];
    
    if([extensionsDao tableExists]){
        [extensionsDao deleteByTableName:table];
    }
    
}

-(void) deleteExtensions{
    
    // Handle deleting any extensions with extra tables here
    for(GPKGExtensionManagement *extensions in _communityExtensions){
        [extensions deleteExtensions];
    }
    
    [self deleteRTreeSpatialIndexExtension];
    [self deleteRelatedTablesExtension];
    [self deleteGriddedCoverageExtension];
    [self deleteSchemaExtension];
    [self deleteMetadataExtension];
    [self deleteCrsWktExtension];
    
    [self delete];
    
}

/**
 *  Delete the extensions
 */
-(void) delete{
    
    GPKGExtensionsDao *extensionsDao = [_geoPackage extensionsDao];
    
    if([extensionsDao tableExists]){
        [geoPackage dropTable:extensionsDao.tableName];
    }
}

-(void) copyExtensionsFromTable: (NSString *) table toTable: (NSString *) newTable{
    
    @try {
        
        [self copyRTreeSpatialIndexFromTable:table toTable:newTable];
        [self copyRelatedTablesFromTable:table toTable:newTable];
        [self copyGriddedCoverageFromTable:table toTable:newTable];
        [self copySchemaFromTable:table toTable:newTable];
        [self copyMetadataFromTable:table toTable:newTable];
        
        // Handle copying any extensions with extra tables here
        for(GPKGExtensionManagement *extensions in _communityExtensions){
            @try {
                [extensions copyExtensionsFromTable:table toTable:newTable];
            } @catch (NSException *exception) {
                NSLog(@"Failed to copy '%@' extensions for table: %@, copied from table: %@. error: %@", [extensions author], newTable, table, exception);
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to copy extensions for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

-(void) deleteRTreeSpatialIndexForTable: (NSString *) table{

    GPKGRTreeIndexExtension *rTreeIndexExtension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
    if([rTreeIndexExtension hasWithTableName:table]){
        [rTreeIndexExtension deleteWithTableName:table];
    }

}

-(void) deleteRTreeSpatialIndexExtension{
    
    GPKGRTreeIndexExtension *rTreeIndexExtension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
    if([rTreeIndexExtension has]){
        [rTreeIndexExtension deleteAll];
    }
    
}

-(void) copyRTreeSpatialIndexFromTable: (NSString *) table toTable: (NSString *) newTable{

    @try {
        
        GPKGRTreeIndexExtension *rTreeIndexExtension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
        
        if([rTreeIndexExtension hasWithTableName:table]){
            GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage geometryColumnsDao];
            
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

-(void) deleteRelatedTablesForTable: (NSString *) table{

    GPKGRelatedTablesExtension *relatedTablesExtension = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    if ([relatedTablesExtension has]) {
        [relatedTablesExtension removeRelationshipsWithTable:table];
    }
    
}

-(void) deleteRelatedTablesExtension{

    GPKGRelatedTablesExtension *relatedTablesExtension = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    if ([relatedTablesExtension has]) {
        [relatedTablesExtension removeExtension];
    }
    
}

-(void) copyRelatedTablesFromTable: (NSString *) table toTable: (NSString *) newTable{

    @try {
        
        GPKGRelatedTablesExtension *relatedTablesExtension = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
        if([relatedTablesExtension has]){
            
            GPKGExtendedRelationsDao *extendedRelationsDao = [relatedTablesExtension extendedRelationsDao];
            GPKGExtensionsDao *extensionsDao = [geoPackage extensionsDao];
            
            NSMutableArray<GPKGExtendedRelation *> *extendedRelations = [NSMutableArray array];
            GPKGResultSet *extendedRelationsResults = [extendedRelationsDao relationsToBaseTable:table];
            @try {
                while([extendedRelationsResults moveToNext]){
                    GPKGExtendedRelation *extendedRelation = [extendedRelationsDao relation:extendedRelationsResults];
                    [extendedRelations addObject:extendedRelation];
                }
            } @finally {
                [extendedRelationsResults close];
            }
            
            for(GPKGExtendedRelation *extendedRelation in extendedRelations){
            
                NSString *mappingTableName = extendedRelation.mappingTableName;
                
                GPKGExtensions *extension = nil;
                GPKGResultSet *extensionsResults = [extensionsDao queryByExtension:[relatedTablesExtension extensionName] andTable:mappingTableName];
                @try {
                    if([extensionsResults moveToNext]){
                        extension = (GPKGExtensions *)[extensionsDao object:extensionsResults];
                    }
                } @finally {
                    [extensionsResults close];
                }
                
                if(extension != nil){
                        
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
            }

        }
        
    } @catch (NSException *exception) {
        NSLog(@"Failed to create Related Tables for table: %@, copied from table: %@. error: %@", newTable, table, exception);
    }
    
}

-(void) deleteGriddedCoverageForTable: (NSString *) table{

    if([geoPackage isTable:table ofTypeName:GPKG_CD_GRIDDED_COVERAGE]){
        
        GPKGGriddedTileDao *griddedTileDao = [GPKGCoverageData griddedTileDaoWithGeoPackage:geoPackage];
        GPKGGriddedCoverageDao *griddedCoverageDao = [GPKGCoverageData griddedCoverageDaoWithGeoPackage:geoPackage];
        GPKGExtensionsDao *extensionsDao = [geoPackage extensionsDao];
        
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

-(void) deleteGriddedCoverageExtension{

    NSArray *coverageTables = [geoPackage tablesByTypeName:GPKG_CD_GRIDDED_COVERAGE];
    for(NSString *table in coverageTables){
        [geoPackage deleteTable:table];
    }
    
    GPKGGriddedTileDao *griddedTileDao = [GPKGCoverageData griddedTileDaoWithGeoPackage:geoPackage];
    GPKGGriddedCoverageDao *griddedCoverageDao = [GPKGCoverageData griddedCoverageDaoWithGeoPackage:geoPackage];
    GPKGExtensionsDao *extensionsDao = [geoPackage extensionsDao];
    
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

-(void) copyGriddedCoverageFromTable: (NSString *) table toTable: (NSString *) newTable{

    @try {
        
        if([geoPackage isTable:table ofTypeName:GPKG_CD_GRIDDED_COVERAGE]){
            
            GPKGExtensionsDao *extensionsDao = [geoPackage extensionsDao];
            
            if ([extensionsDao tableExists]) {
                
                GPKGResultSet *extensions = [extensionsDao queryByExtension:[GPKGExtensions buildDefaultAuthorExtensionName:GPKG_GRIDDED_COVERAGE_EXTENSION_NAME] andTable:table];
                @try {
                    if([extensions moveToNext]){
                        GPKGExtensions *extension = (GPKGExtensions *)[extensionsDao object:extensions];
                        
                        [extension setTableName:newTable];
                        [extensionsDao create:extension];
                        
                        GPKGGriddedCoverageDao *griddedCoverageDao = [GPKGCoverageData griddedCoverageDaoWithGeoPackage:geoPackage];
                        if([griddedCoverageDao tableExists]){
                            
                            [GPKGSqlUtils transferContentInTable:GPKG_CDGC_TABLE_NAME inColumn:GPKG_CDGC_COLUMN_TILE_MATRIX_SET_NAME withNewValue:newTable andCurrentValue:table andIdColumn:GPKG_CDGC_COLUMN_ID withConnection:geoPackage.database];
                            
                        }
                        
                        GPKGGriddedTileDao *griddedTileDao = [GPKGCoverageData griddedTileDaoWithGeoPackage:geoPackage];
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

-(void) deleteSchemaForTable: (NSString *) table{

    GPKGDataColumnsDao *dataColumnsDao = [GPKGSchemaExtension dataColumnsDaoWithGeoPackage:geoPackage];
    if([dataColumnsDao tableExists]){
        [dataColumnsDao deleteByTableName:table];
    }

}

-(void) deleteSchemaExtension{

    GPKGSchemaExtension *schemaExtension = [[GPKGSchemaExtension alloc] initWithGeoPackage:geoPackage];
    if ([schemaExtension has]) {
        [schemaExtension removeExtension];
    }
    
}

-(void) copySchemaFromTable: (NSString *) table toTable: (NSString *) newTable{

    @try {
        
        if([geoPackage isTableOrView:GPKG_DC_TABLE_NAME]){
            
            GPKGUserCustomTable *dataColumnsTable = [GPKGUserCustomTableReader readTableWithConnection:geoPackage.database andTableName:GPKG_DC_TABLE_NAME];
            GPKGUserColumn *nameColumn = [dataColumnsTable columnWithColumnName:GPKG_DC_COLUMN_NAME];
            if([nameColumn hasConstraints]){
                [nameColumn clearConstraints];
                if([dataColumnsTable hasConstraints]){
                    [dataColumnsTable clearConstraints];
                    NSString *constraintSql = [[GPKGTableCreator readProperty:GPKG_DC_TABLE_NAME fromProperties:GPKG_EXTENSION_AUTHOR] objectAtIndex:0];
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

-(void) deleteMetadataForTable: (NSString *) table{

    GPKGMetadataReferenceDao *metadataReferenceDao = [MetadataExtension metadataReferenceDaoWithGeoPackage:geoPackage];
    if([metadataReferenceDao tableExists]){
        [metadataReferenceDao deleteByTableName:table];
    }
    
}

-(void) deleteMetadataExtension{

    GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
    if ([metadataExtension has]) {
        [metadataExtension removeExtension];
    }
    
}

-(void) copyMetadataFromTable: (NSString *) table toTable: (NSString *) newTable{

        @try {
    
            if([geoPackage isTableOrView:GPKG_MR_TABLE_NAME]){
                
                [GPKGSqlUtils transferContentInTable:GPKG_MR_TABLE_NAME inColumn:GPKG_MR_COLUMN_TABLE_NAME withNewValue:newTable andCurrentValue:table withConnection:geoPackage.database];
                
            }
            
        } @catch (NSException *exception) {
            NSLog(@"Failed to create Metadata for table: %@, copied from table: %@. error: %@", newTable, table, exception);
        }
            
}

-(void) deleteCrsWktExtension{

    GPKGCrsWktExtension *crsWktExtension = [[GPKGCrsWktExtension alloc] initWithGeoPackage:geoPackage];
    if ([crsWktExtension has]) {
        [crsWktExtension removeExtension];
    }
    
}

@end
