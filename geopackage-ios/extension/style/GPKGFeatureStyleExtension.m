//
//  GPKGFeatureStyleExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureStyleExtension.h"
#import "GPKGExtensions.h"
#import "GPKGProperties.h"
#import "GPKGStyleTable.h"
#import "GPKGIconTable.h"
#import "GPKGStyleMappingTable.h"

NSString * const GPKG_EXTENSION_FEATURE_STYLE_AUTHOR = @"nga";
NSString * const GPKG_EXTENSION_FEATURE_STYLE_NAME_NO_AUTHOR = @"feature_style";
NSString * const GPKG_PROP_EXTENSION_FEATURE_STYLE_DEFINITION = @"geopackage.extensions.feature_style";

NSString * const GPKG_FSE_TABLE_MAPPING_STYLE = @"nga_style_";
NSString * const GPKG_FSE_TABLE_MAPPING_TABLE_STYLE = @"nga_style_default_";
NSString * const GPKG_FSE_TABLE_MAPPING_ICON = @"nga_icon_";
NSString * const GPKG_FSE_TABLE_MAPPING_TABLE_ICON = @"nga_icon_default_";

@interface GPKGFeatureStyleExtension ()

@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionDefinition;
@property (nonatomic, strong) GPKGRelatedTablesExtension *relatedTables;
@property (nonatomic, strong) GPKGContentsIdExtension *contentsId;

@end

@implementation GPKGFeatureStyleExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andRelatedTables: (GPKGRelatedTablesExtension *) relatedTables{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_FEATURE_STYLE_AUTHOR andExtensionName:GPKG_EXTENSION_FEATURE_STYLE_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties getValueOfProperty:GPKG_PROP_EXTENSION_FEATURE_STYLE_DEFINITION];
        self.relatedTables = relatedTables;
        self.contentsId = [[GPKGContentsIdExtension alloc] initWithGeoPackage:geoPackage];
    }
    return self;
}

/**
 * Get or create the extension
 *
 * @param featureTable
 *            feature table
 * @return extension
 */
-(GPKGExtensions *) getOrCreateWithTable: (NSString *) featureTable{
    
    GPKGExtensions *extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:featureTable andColumnName:nil andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(NSArray<NSString *> *) tables{
    NSMutableArray<NSString *> *tables = [[NSMutableArray alloc] init];
    GPKGResultSet *extensions = [self getWithExtensionName:self.extensionName];
    if(extensions != nil){
        @try {
            while([extensions moveToNext]){
                GPKGExtensions *extension = (GPKGExtensions *)[self.extensionsDao getObject:extensions];
                [tables addObject:extension.tableName];
            }
        } @finally {
            [extensions close];
        }
    }
    return tables;
}

-(BOOL) has{
    return [self hasWithExtensionName:self.extensionName];
}

-(BOOL) hasWithTable: (NSString *) featureTable{
    return [self hasWithExtensionName:self.extensionName andTableName:featureTable andColumnName:nil];
}

-(GPKGRelatedTablesExtension *) relatedTables{
    return _relatedTables;
}

-(GPKGContentsIdExtension *) contentsId{
    return _contentsId;
}

-(void) createRelationshipsWithTable: (NSString *) featureTable{
    [self createStyleRelationshipWithTable:featureTable];
    [self createTableStyleRelationshipWithTable:featureTable];
    [self createIconRelationshipWithTable:featureTable];
    [self createTableIconRelationshipWithTable:featureTable];
}

-(BOOL) hasRelationshipWithTable: (NSString *) featureTable{
    return [self hasStyleRelationshipWithTable:featureTable]
        || [self hasTableStyleRelationshipWithTable:featureTable]
        || [self hasIconRelationshipWithTable:featureTable]
        || [self hasTableIconRelationshipWithTable:featureTable];
}

-(void) createStyleRelationshipWithTable: (NSString *) featureTable{
    [self createStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_STYLE andTable:featureTable] andFeatureTable:featureTable andBaseTable:featureTable andRelatedTable:GPKG_ST_TABLE_NAME];
}

-(BOOL) hasStyleRelationshipWithTable: (NSString *) featureTable{
    return [self hasStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_STYLE andTable:featureTable] andBaseTable:featureTable andRelatedTable:GPKG_ST_TABLE_NAME];
}

-(void) createTableStyleRelationshipWithTable: (NSString *) featureTable{
    [self createStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_STYLE andTable:featureTable] andFeatureTable:featureTable andBaseTable:GPKG_CI_TABLE_NAME andRelatedTable:GPKG_ST_TABLE_NAME];
}

-(BOOL) hasTableStyleRelationshipWithTable: (NSString *) featureTable{
    return [self hasStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_STYLE andTable:featureTable] andBaseTable:GPKG_CI_TABLE_NAME andRelatedTable:GPKG_ST_TABLE_NAME];
}

-(void) createIconRelationshipWithTable: (NSString *) featureTable{
    [self createStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_ICON andTable:featureTable] andFeatureTable:featureTable andBaseTable:featureTable andRelatedTable:GPKG_IT_TABLE_NAME];
}

-(BOOL) hasIconRelationshipWithTable: (NSString *) featureTable{
    return [self hasStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_ICON andTable:featureTable] andBaseTable:featureTable andRelatedTable:GPKG_IT_TABLE_NAME];
}

-(void) createTableIconRelationshipWithTable: (NSString *) featureTable{
    [self createStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_ICON andTable:featureTable] andFeatureTable:featureTable andBaseTable:GPKG_CI_TABLE_NAME andRelatedTable:GPKG_IT_TABLE_NAME];
}

-(BOOL) hasTableIconRelationshipWithTable: (NSString *) featureTable{
    return [self hasStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_ICON andTable:featureTable] andBaseTable:GPKG_CI_TABLE_NAME andRelatedTable:GPKG_IT_TABLE_NAME];
}

-(NSString *) mappingTableNameWithPrefix: (NSString *) tablePrefix andTable: (NSString *) featureTable{
    return [NSString stringWithFormat:@"%@%@", tablePrefix, featureTable];
}

/**
 * Check if the style extension relationship between a feature table and
 * style extension table exists
 *
 * @param mappingTableName
 *            mapping table name
 * @param featureTable
 *            feature table name
 * @param baseTable
 *            base table name
 * @param relatedTable
 *            related table name
 * @return true if relationship exists
 */
-(BOOL) hasStyleRelationshipWithMappingTable: (NSString *) mappingTableName andBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable{
    return [self.relatedTables hasRelationsWithBaseTable:baseTable andRelatedTable:relatedTable andMappingTable:mappingTableName];
}

/**
 * Create a style extension relationship between a feature table and style
 * extension table
 *
 * @param mappingTableName
 *            mapping table name
 * @param featureTable
 *            feature table name
 * @param baseTable
 *            base table name
 * @param relatedTable
 *            related table name
 */
-(void) createStyleRelationshipWithMappingTable: (NSString *) mappingTableName andFeatureTable: (NSString *) featureTable andBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable{
    
    if(![self hasStyleRelationshipWithMappingTable:mappingTableName andBaseTable:baseTable andRelatedTable:relatedTable]){
        
        // Create the extension
        [self getOrCreateWithTable:featureTable];
        
        if([baseTable isEqualToString:GPKG_CI_TABLE_NAME]){
            if(![self.contentsId has]){
                [self.contentsId getOrCreateExtension];
            }
        }
        
        GPKGStyleMappingTable *mappingTable = [[GPKGStyleMappingTable alloc] initWithTableName:mappingTableName];
        
        if([relatedTable isEqualToString:GPKG_ST_TABLE_NAME]){
            [self.relatedTables addAttributesRelationshipWithBaseTable:baseTable andAttributesTable:[[GPKGStyleTable alloc] init] andUserMappingTable:mappingTable];
        }else{
            [self.relatedTables addMediaRelationshipWithBaseTable:baseTable andMediaTable:[[GPKGIconTable alloc] init] andUserMappingTable:mappingTable];
        }
        
    }
    
}

-(void) deleteRelationships{
    NSArray<NSString *> *tables = [self tables];
    for(NSString *table in tables){
        [self deleteRelationshipsWithTable:table];
    }
}

-(void) deleteRelationshipsWithTable: (NSString *) featureTable{
    [self deleteStyleRelationshipWithTable:featureTable];
    [self deleteTableStyleRelationshipWithTable:featureTable];
    [self deleteIconRelationshipWithTable:featureTable];
    [self deleteTableIconRelationshipWithTable:featureTable];
}

-(void) deleteStyleRelationshipWithTable: (NSString *) featureTable{
    [self deleteStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_STYLE andTable:featureTable] andFeatureTable:featureTable];
}

-(void) deleteTableStyleRelationshipWithTable: (NSString *) featureTable{
    [self deleteStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_STYLE andTable:featureTable] andFeatureTable:featureTable];
}

-(void) deleteIconRelationshipWithTable: (NSString *) featureTable{
    [self deleteStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_ICON andTable:featureTable] andFeatureTable:featureTable];
}

-(void) deleteTableIconRelationshipWithTable: (NSString *) featureTable{
    [self deleteStyleRelationshipWithMappingTable:[self mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_ICON andTable:featureTable] andFeatureTable:featureTable];
}

/**
 * Delete a style extension feature table relationship and the mapping table
 *
 * @param mappingTableName
 *            mapping table name
 * @param featureTable
 *            feature table name
 */
-(void) deleteStyleRelationshipWithMappingTable: (NSString *) mappingTableName andFeatureTable: (NSString *) featureTable {
    
    [self.relatedTables removeRelationshipsWithMappingTable:mappingTableName];
    
    if(![self hasRelationshipWithTable:featureTable] && [self.extensionsDao tableExists]){
        [self.extensionsDao deleteByExtension:self.extensionName andTable:featureTable];
    }
    
}

-(void) removeExtension{

    [self deleteRelationships];
    
    [self.geoPackage deleteUserTable:GPKG_ST_TABLE_NAME];
    
    [self.geoPackage deleteUserTable:GPKG_IT_TABLE_NAME];
    
    if([self.extensionsDao tableExists]){
        [self.extensionsDao deleteByExtension:self.extensionName];
    }
    
}

-(GPKGStyleMappingDao *) styleMappingDaoWithTable: (NSString *) featureTable{
    return [self mappingDaoWithPrefix:GPKG_FSE_TABLE_MAPPING_STYLE andTable:featureTable];
}

-(GPKGStyleMappingDao *) tableStyleMappingDaoWithTable: (NSString *) featureTable{
    return [self mappingDaoWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_STYLE andTable:featureTable];
}

-(GPKGStyleMappingDao *) iconMappingDaoWithTable: (NSString *) featureTable{
    return [self mappingDaoWithPrefix:GPKG_FSE_TABLE_MAPPING_ICON andTable:featureTable];
}

-(GPKGStyleMappingDao *) tableIconMappingDaoWithTable: (NSString *) featureTable{
    return [self mappingDaoWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_ICON andTable:featureTable];
}

/**
 * Get a Style Mapping DAO from a table name
 *
 * @param tablePrefix  table name prefix
 * @param featureTable feature table
 * @return style mapping dao
 */
-(GPKGStyleMappingDao *) mappingDaoWithPrefix: (NSString *) tablePrefix andTable: (NSString *) featureTable{
    
    NSString *tableName = [NSString stringWithFormat:@"%@%@", tablePrefix, featureTable];
    GPKGStyleMappingDao *dao = nil;
    if([self.geoPackage isTable:tableName]){
        dao = [[GPKGStyleMappingDao alloc] initWithDao:[self.relatedTables userDaoForTableName:tableName]];
    }
    return dao;
}

-(GPKGStyleDao *) styleDao{
    GPKGStyleDao *styleDao = nil;
    if([self.geoPackage isTable:GPKG_ST_TABLE_NAME]){
        GPKGAttributesDao *attributesDao = [self.geoPackage getAttributesDaoWithTableName:GPKG_ST_TABLE_NAME];
        styleDao = [[GPKGStyleDao alloc] initWithDao:attributesDao];
        [self.relatedTables setContentsInTable:[styleDao table]];
    }
    return styleDao;
}

-(GPKGIconDao *) iconDao{
    GPKGIconDao *iconDao = nil;
    if([self.geoPackage isTable:GPKG_IT_TABLE_NAME]){
        iconDao = [[GPKGIconDao alloc] initWithDao:[self.relatedTables userDaoForTableName:GPKG_IT_TABLE_NAME]];
        [self.relatedTables setContentsInTable:[iconDao table]];
    }
    return iconDao;
}

-(GPKGFeatureStyles *) tableFeatureStylesWithTable: (GPKGFeatureTable *) featureTable{
    return [self tableFeatureStylesWithTableName:featureTable.tableName];
}

-(GPKGFeatureStyles *) tableFeatureStylesWithTableName: (NSString *) featureTable{
    
    GPKGFeatureStyles *featureStyles = nil;
    
    NSNumber *id = [self.contentsId getIdForTableName:featureTable];
    if(id != nil){
        
        int idValue = [id intValue];
        GPKGStyles *styles = [self tableStylesWithTableName:featureTable andContentsId:idValue];
        GPKGIcons *icons = [self tableIconsWithTableName:featureTable andContentsId:idValue];
        
        if(styles != nil || icons != nil){
            featureStyles = [[GPKGFeatureStyles alloc] initWithStyles:styles andIcons:icons];
        }
        
    }
    
    return featureStyles;
}

-(GPKGStyles *) tableStylesWithTable: (GPKGFeatureTable *) featureTable{
    return [self tableStylesWithTableName:featureTable.tableName];
}

-(GPKGStyles *) tableStylesWithTableName: (NSString *) featureTable{
    GPKGStyles *styles = nil;
    NSNumber *id = [self.contentsId getIdForTableName:featureTable];
    if (id != nil) {
        styles = [self tableStylesWithTableName:featureTable andContentsId:[id intValue]];
    }
    return styles;
}

/**
 * Get the feature table default styles
 *
 * @param featureTable feature table
 * @param contentsId   contents id
 * @return table styles or null
 */
-(GPKGStyles *) tableStylesWithTableName: (NSString *) featureTable andContentsId: (int) contentsId{
    return [self stylesWithId:contentsId andDao:[self tableStyleMappingDaoWithTable:featureTable]];
}

-(GPKGStyleRow *) tableStyleWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType{
    GPKGStyleRow *styleRow = nil;
    GPKGStyles *tableStyles = [self tableStylesWithTableName:featureTable];
    if(tableStyles != nil){
        styleRow = [tableStyles styleForGeometryType:geometryType];
    }
    return styleRow;
}

-(GPKGStyleRow *) tableStyleDefaultWithTableName: (NSString *) featureTable{
    return [self tableStyleWithTableName:featureTable andGeometryType:SF_NONE];
}

-(GPKGIcons *) tableIconsWithTable: (GPKGFeatureTable *) featureTable{
    return [self tableIconsWithTableName:featureTable.tableName];
}

-(GPKGIcons *) tableIconsWithTableName: (NSString *) featureTable{
    GPKGIcons *icons = nil;
    NSNumber *id = [self.contentsId getIdForTableName:featureTable];
    if (id != nil) {
        icons = [self tableIconsWithTableName:featureTable andContentsId:[id intValue]];
    }
    return icons;
}

/**
 * Get the feature table default icons
 *
 * @param featureTable feature table
 * @param contentsId   contents id
 * @return table icons or null
 */
-(GPKGIcons *) tableIconsWithTableName: (NSString *) featureTable andContentsId: (int) contentsId{
    return [self iconsWithId:contentsId andDao:[self tableIconMappingDaoWithTable:featureTable]];
}

-(GPKGIconRow *) tableIconDefaultWithTableName: (NSString *) featureTable{
    return [self tableIconWithTableName:featureTable andGeometryType:SF_NONE];
}

-(GPKGIconRow *) tableIconWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType{
    GPKGIconRow *iconRow = nil;
    GPKGIcons *tableIcons = [self tableIconsWithTableName:featureTable];
    if(tableIcons != nil){
        iconRow = [tableIcons iconForGeometryType:geometryType];
    }
    return iconRow;
}

-(GPKGFeatureStyles *) featureStylesWithFeature: (GPKGFeatureRow *) featureRow{
    return [self featureStylesWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue]];
}

-(GPKGFeatureStyles *) featureStylesWithTableName: (NSString *) featureTable andId: (int) featureId{

    GPKGStyles *styles = [self stylesWithTableName:featureTable andId:featureId];
    GPKGIcons *icons = [self iconsWithTableName:featureTable andId:featureId];
    
    GPKGFeatureStyles *featureStyles = nil;
    if(styles != nil || icons != nil){
        featureStyles = [[GPKGFeatureStyles alloc] initWithStyles:styles andIcons:icons];
    }
    
    return featureStyles;
}

-(GPKGFeatureStyle *) featureStyleWithFeature: (GPKGFeatureRow *) featureRow{
    return [self featureStyleWithFeature:featureRow andGeometryType:[featureRow getGeometryType]];
}

-(GPKGFeatureStyle *) featureStyleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    return [self featureStyleWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:geometryType];
}

-(GPKGFeatureStyle *) featureStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow{
    return [self featureStyleWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:SF_NONE];
}

-(GPKGFeatureStyle *) featureStyleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{

    GPKGFeatureStyle *featureStyle = nil;
    
    GPKGStyleRow *style = [self styleWithTableName:featureTable andId:featureId andGeometryType:geometryType];
    GPKGIconRow *icon = [self iconWithTableName:featureTable andId:featureId andGeometryType:geometryType];
    
    if(style != nil || icon != nil){
        featureStyle = [[GPKGFeatureStyle alloc] initWithStyle:style andIcon:icon];
    }
    
    return featureStyle;
}

-(GPKGFeatureStyle *) featureStyleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId{
    return [self featureStyleWithTableName:featureTable andId:featureId andGeometryType:SF_NONE];
}

-(GPKGStyles *) stylesWithFeature: (GPKGFeatureRow *) featureRow{
    return [self stylesWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue]];
}

-(GPKGStyles *) stylesWithTableName: (NSString *) featureTable andId: (int) featureId{
    return [self stylesWithId:featureId andDao:[self styleMappingDaoWithTable:featureTable]];
}

-(GPKGStyleRow *) styleWithFeature: (GPKGFeatureRow *) featureRow{
    return [self styleWithFeature:featureRow andGeometryType:[featureRow getGeometryType]];
}

-(GPKGStyleRow *) styleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    return [self styleWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:geometryType];
}

-(GPKGStyleRow *) styleDefaultWithFeature: (GPKGFeatureRow *) featureRow{
    return [self styleWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:SF_NONE];
}

-(GPKGStyleRow *) styleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    return [self styleWithTableName:featureTable andId:featureId andGeometryType:geometryType andTableStyle:YES];
}

-(GPKGStyleRow *) styleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId{
    return [self styleWithTableName:featureTable andId:featureId andGeometryType:SF_NONE andTableStyle:YES];
}

-(GPKGStyleRow *) styleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType andTableStyle: (BOOL) tableStyle{
    
    GPKGStyleRow *styleRow = nil;
    
    // Feature Style
    GPKGStyles *styles = [self stylesWithTableName:featureTable andId:featureId];
    if (styles != nil) {
        styleRow = [styles styleForGeometryType:geometryType];
    }
    
    if (styleRow == nil && tableStyle) {
        
        // Table Style
        styleRow = [self tableStyleWithTableName:featureTable andGeometryType:geometryType];
        
    }
    
    return styleRow;
}

-(GPKGStyleRow *) styleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId andTableStyle: (BOOL) tableStyle{
    return [self styleWithTableName:featureTable andId:featureId andGeometryType:SF_NONE andTableStyle:tableStyle];
}

-(GPKGIcons *) iconsWithFeature: (GPKGFeatureRow *) featureRow{
    return [self iconsWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue]];
}

-(GPKGIcons *) iconsWithTableName: (NSString *) featureTable andId: (int) featureId{
    return [self iconsWithId:featureId andDao:[self iconMappingDaoWithTable:featureTable]];
}

-(GPKGIconRow *) iconWithFeature: (GPKGFeatureRow *) featureRow{
    return [self iconWithFeature:featureRow andGeometryType:[featureRow getGeometryType]];
}

-(GPKGIconRow *) iconWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    return [self iconWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:geometryType];
}

-(GPKGIconRow *) iconDefaultWithFeature: (GPKGFeatureRow *) featureRow{
    return [self iconWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:SF_NONE];
}

-(GPKGIconRow *) iconWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    return [self iconWithTableName:featureTable andId:featureId andGeometryType:geometryType andTableIcon:YES];
}

-(GPKGIconRow *) iconDefaultWithTableName: (NSString *) featureTable andId: (int) featureId{
    return [self iconWithTableName:featureTable andId:featureId andGeometryType:SF_NONE andTableIcon:YES];
}

-(GPKGIconRow *) iconWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType andTableIcon: (BOOL) tableIcon{
    
    GPKGIconRow *iconRow = nil;
    
    // Feature Icon
    GPKGIcons *icons = [self iconsWithTableName:featureTable andId:featureId];
    if (icons != nil) {
        iconRow = [icons iconForGeometryType:geometryType];
    }
    
    if (iconRow == nil && tableIcon) {
        
        // Table Icon
        iconRow = [self tableIconWithTableName:featureTable andGeometryType:geometryType];
        
    }
    
    return iconRow;
}

-(GPKGIconRow *) iconDefaultWithTableName: (NSString *) featureTable andId: (int) featureId andTableIcon: (BOOL) tableIcon{
    return [self iconWithTableName:featureTable andId:featureId andGeometryType:SF_NONE andTableIcon:tableIcon];
}

/**
 * Get the styles for feature id from the style mapping dao
 *
 * @param featureId  geometry feature id or feature table id
 * @param mappingDao style mapping dao
 * @return styles
 */
-(GPKGStyles *) stylesWithId: (int) featureId andDao: (GPKGStyleMappingDao *) mappingDao{
    
    GPKGStyles *styles = nil;
    
    if (mappingDao != nil) {
        
        GPKGStyleDao *styleDao = [self styleDao];
        
        if (styleDao != nil) {
            
            NSArray<GPKGStyleMappingRow *> * styleMappingRows = [mappingDao queryByBaseFeatureId:featureId];
            if(styleMappingRows.count > 0){
                
                for(GPKGStyleMappingRow *styleMappingRow in styleMappingRows){
                    
                    GPKGStyleRow *styleRow = [styleDao queryForRow:styleMappingRow];
                    if(styleRow != nil){
                        if(styles == nil){
                            styles = [[GPKGStyles alloc] init];
                        }
                        [styles setStyle:styleRow forGeometryType:[styleMappingRow geometryType]];
                    }
                }
            }
        }
    }
    
    return styles;
}

/**
 * Get the icons for feature id from the icon mapping dao
 *
 * @param featureId  geometry feature id or feature table id
 * @param mappingDao icon mapping dao
 * @return icons
 */
-(GPKGIcons *) iconsWithId: (int) featureId andDao: (GPKGStyleMappingDao *) mappingDao{
    
    GPKGIcons *icons = nil;
    
    if (mappingDao != nil) {
        
        GPKGIconDao *iconDao = [self iconDao];
        
        if (iconDao != nil) {
            
            NSArray<GPKGStyleMappingRow *> * styleMappingRows = [mappingDao queryByBaseFeatureId:featureId];
            if(styleMappingRows.count > 0){
                
                for(GPKGStyleMappingRow *styleMappingRow in styleMappingRows){
                    
                    GPKGIconRow *iconRow = [iconDao queryForRow:styleMappingRow];
                    if(iconRow != nil){
                        if(icons == nil){
                            icons = [[GPKGIcons alloc] init];
                        }
                        [icons setIcon:iconRow forGeometryType:[styleMappingRow geometryType]];
                    }
                }
            }
        }
    }
    
    return icons;
}

-(void) setTableFeatureStylesWithTable: (GPKGFeatureTable *) featureTable andFeatureStyles: (GPKGFeatureStyles *) featureStyles{
    [self setTableFeatureStylesWithTableName:featureTable.tableName andFeatureStyles:featureStyles];
}

-(void) setTableFeatureStylesWithTableName: (NSString *) featureTable andFeatureStyles: (GPKGFeatureStyles *) featureStyles{
    if(featureStyles != nil){
        [self setTableStylesWithTableName:featureTable andStyles:featureStyles.styles];
        [self setTableIconsWithTableName:featureTable andIcons:featureStyles.icons];
    }else{
        // TODO [self deleteTableFeatureStylesWithTable:featureTable];
    }
}

-(void) setTableStylesWithTable: (GPKGFeatureTable *) featureTable andStyles: (GPKGStyles *) styles{
    [self setTableStylesWithTableName:featureTable.tableName andStyles:styles];
}

-(void) setTableStylesWithTableName: (NSString *) featureTable andStyles: (GPKGStyles *) styles{
    
    // TODO [self deleteTableStylesWithTable:featureTable];
    
    if(styles != nil){
        
        if([styles defaultStyle] != nil){
            [self setTableStyleDefaultWithTableName:featureTable andStyle:[styles defaultStyle]];
        }
        
        NSDictionary<NSNumber *, GPKGStyleRow *> *allStyles = [styles allStyles];
        for(NSNumber *geometryTypeNumber in [allStyles allKeys]){
            GPKGStyleRow *style = [allStyles objectForKey:geometryTypeNumber];
            [self setTableStyleWithTableName:featureTable andGeometryType:[geometryTypeNumber intValue] andStyle:style];
        }
        
    }
}

-(void) setTableStyleDefaultWithTable: (GPKGFeatureTable *) featureTable andStyle: (GPKGStyleRow *) style{
    [self setTableStyleDefaultWithTableName:featureTable.tableName andStyle:style];
}

-(void) setTableStyleDefaultWithTableName: (NSString *) featureTable andStyle: (GPKGStyleRow *) style{
    [self setTableStyleWithTableName:featureTable andGeometryType:SF_NONE andStyle:style];
}

-(void) setTableStyleWithTable: (GPKGFeatureTable *) featureTable andGeometryType: (enum SFGeometryType) geometryType andStyle: (GPKGStyleRow *) style{
    [self setTableStyleWithTableName:featureTable.tableName andGeometryType:geometryType andStyle:style];
}

-(void) setTableStyleWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType andStyle: (GPKGStyleRow *) style{
    
    // TODO [self deleteTableStyleWithTableName:featureTable andGeometryType:geometryType];
    
    if(style != nil){
        
        [self createTableStyleRelationshipWithTable:featureTable];
        
        int featureContentsId = [[self.contentsId getOrCreateIdForTableName:featureTable] intValue];
        
        // TODO int styleId = [self getOrInsertStyle:style];
        
        GPKGStyleMappingDao *mappingDao = [self tableStyleMappingDaoWithTable:featureTable];
        // TODO [self insertStyleMappingWithDao:mappingDao andBaseId:featureContentsId andRelatedId:styleId andGeometryType:geometryType];
        
    }
    
}

-(void) setTableIconsWithTable: (GPKGFeatureTable *) featureTable andIcons: (GPKGIcons *) icons{
    [self setTableIconsWithTableName:featureTable.tableName andIcons:icons];
}

-(void) setTableIconsWithTableName: (NSString *) featureTable andIcons: (GPKGIcons *) icons{
    
    // TODO [self deleteTableIconsWithTable:featureTable];
    
    if(icons != nil){
        
        if([icons defaultIcon] != nil){
            [self setTableIconDefaultWithTableName:featureTable andIcon:[icons defaultIcon]];
        }
        
        NSDictionary<NSNumber *, GPKGIconRow *> *allIcons = [icons allIcons];
        for(NSNumber *geometryTypeNumber in [allIcons allKeys]){
            GPKGIconRow *icon = [allIcons objectForKey:geometryTypeNumber];
            [self setTableIconWithTableName:featureTable andGeometryType:[geometryTypeNumber intValue] andIcon:icon];
        }
        
    }
}

-(void) setTableIconDefaultWithTable: (GPKGFeatureTable *) featureTable andIcon: (GPKGIconRow *) icon{
    [self setTableIconDefaultWithTableName:featureTable.tableName andIcon:icon];
}

-(void) setTableIconDefaultWithTableName: (NSString *) featureTable andIcon: (GPKGIconRow *) icon{
    [self setTableIconWithTableName:featureTable andGeometryType:SF_NONE andIcon:icon];
}

-(void) setTableIconWithTable: (GPKGFeatureTable *) featureTable andGeometryType: (enum SFGeometryType) geometryType andIcon: (GPKGIconRow *) icon{
    [self setTableIconWithTableName:featureTable.tableName andGeometryType:geometryType andIcon:icon];
}

-(void) setTableIconWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType andIcon: (GPKGIconRow *) icon{
    
    // TODO [self deleteTableIconWithTableName:featureTable andGeometryType:geometryType];
    
    if(icon != nil){
        
        [self createTableIconRelationshipWithTable:featureTable];
        
        int featureContentsId = [[self.contentsId getOrCreateIdForTableName:featureTable] intValue];
        
        // TODO int iconId = [self getOrInsertIcon:icon];
        
        GPKGStyleMappingDao *mappingDao = [self tableIconMappingDaoWithTable:featureTable];
        // TODO [self insertStyleMappingWithDao:mappingDao andBaseId:featureContentsId andRelatedId:iconId andGeometryType:geometryType];
        
    }
    
}

// TODO

@end
