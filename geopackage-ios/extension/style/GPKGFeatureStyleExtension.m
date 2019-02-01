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
        [self deleteTableFeatureStylesWithTableName:featureTable];
    }
}

-(void) setTableStylesWithTable: (GPKGFeatureTable *) featureTable andStyles: (GPKGStyles *) styles{
    [self setTableStylesWithTableName:featureTable.tableName andStyles:styles];
}

-(void) setTableStylesWithTableName: (NSString *) featureTable andStyles: (GPKGStyles *) styles{
    
    [self deleteTableStylesWithTableName:featureTable];
    
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
    
    [self deleteTableStyleWithTableName:featureTable andGeometryType:geometryType];
    
    if(style != nil){
        
        [self createTableStyleRelationshipWithTable:featureTable];
        
        int featureContentsId = [[self.contentsId getOrCreateIdForTableName:featureTable] intValue];
        
        int styleId = [self getOrInsertStyle:style];
        
        GPKGStyleMappingDao *mappingDao = [self tableStyleMappingDaoWithTable:featureTable];
        [self insertStyleMappingWithDao:mappingDao andBaseId:featureContentsId andRelatedId:styleId andGeometryType:geometryType];
        
    }
    
}

-(void) setTableIconsWithTable: (GPKGFeatureTable *) featureTable andIcons: (GPKGIcons *) icons{
    [self setTableIconsWithTableName:featureTable.tableName andIcons:icons];
}

-(void) setTableIconsWithTableName: (NSString *) featureTable andIcons: (GPKGIcons *) icons{
    
    [self deleteTableIconsWithTableName:featureTable];
    
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
    
    [self deleteTableIconWithTableName:featureTable andGeometryType:geometryType];
    
    if(icon != nil){
        
        [self createTableIconRelationshipWithTable:featureTable];
        
        int featureContentsId = [[self.contentsId getOrCreateIdForTableName:featureTable] intValue];
        
        int iconId = [self getOrInsertIcon:icon];
        
        GPKGStyleMappingDao *mappingDao = [self tableIconMappingDaoWithTable:featureTable];
        [self insertStyleMappingWithDao:mappingDao andBaseId:featureContentsId andRelatedId:iconId andGeometryType:geometryType];
        
    }
    
}

-(void) setFeatureStylesWithFeature: (GPKGFeatureRow *) featureRow andFeatureStyles: (GPKGFeatureStyles *) featureStyles{
    [self setFeatureStylesWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andFeatureStyles:featureStyles];
}

-(void) setFeatureStylesWithTableName: (NSString *) featureTable andId: (int) featureId andFeatureStyles: (GPKGFeatureStyles *) featureStyles{
    if (featureStyles != nil) {
        [self setStylesWithTableName:featureTable andId:featureId andStyles:featureStyles.styles];
        [self setIconsWithTableName:featureTable andId:featureId andIcons:featureStyles.icons];
    } else {
        [self deleteStylesWithTableName:featureTable andId:featureId];
        [self deleteIconsWithTableName:featureTable andId:featureId];
    }
}

-(void) setFeatureStyleWithFeature: (GPKGFeatureRow *) featureRow andFeatureStyle: (GPKGFeatureStyle *) featureStyle{
    [self setFeatureStyleWithFeature:featureRow andGeometryType:[featureRow getGeometryType] andFeatureStyle:featureStyle];
}

-(void) setFeatureStyleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType andFeatureStyle: (GPKGFeatureStyle *) featureStyle{
    [self setFeatureStyleWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:geometryType andFeatureStyle:featureStyle];
}

-(void) setFeatureStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow andFeatureStyle: (GPKGFeatureStyle *) featureStyle{
    [self setFeatureStyleWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:SF_NONE andFeatureStyle:featureStyle];
}

-(void) setFeatureStyleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType andFeatureStyle: (GPKGFeatureStyle *) featureStyle{
    if (featureStyle != nil) {
        [self setStyleWithTableName:featureTable andId:featureId andGeometryType:geometryType andStyle:featureStyle.style];
        [self setIconWithTableName:featureTable andId:featureId andGeometryType:geometryType andIcon:featureStyle.icon];
    } else {
        [self deleteStyleWithTableName:featureTable andId:featureId andGeometryType:geometryType];
        [self deleteIconWithTableName:featureTable andId:featureId andGeometryType:geometryType];
    }
}

-(void) setFeatureStyleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId andFeatureStyle: (GPKGFeatureStyle *) featureStyle{
    [self setFeatureStyleWithTableName:featureTable andId:featureId andGeometryType:SF_NONE andFeatureStyle:featureStyle];
}

-(void) setStylesWithFeature: (GPKGFeatureRow *) featureRow andStyles: (GPKGStyles *) styles{
    [self setStylesWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andStyles:styles];
}

-(void) setStylesWithTableName: (NSString *) featureTable andId: (int) featureId andStyles: (GPKGStyles *) styles{
    [self deleteStylesWithTableName:featureTable andId:featureId];
    
    if (styles != nil) {
        
        if ([styles defaultStyle] != nil) {
            [self setStyleDefaultWithTableName:featureTable andId:featureId andStyle:[styles defaultStyle]];
        }
        
        NSDictionary<NSNumber *, GPKGStyleRow *> *allStyles = [styles allStyles];
        for(NSNumber *geometryTypeNumber in [allStyles allKeys]){
            GPKGStyleRow *style = [allStyles objectForKey:geometryTypeNumber];
            [self setStyleWithTableName:featureTable andId:featureId andGeometryType:[geometryTypeNumber intValue] andStyle:style];
        }
        
    }
}

-(void) setStyleWithFeature: (GPKGFeatureRow *) featureRow andStyle: (GPKGStyleRow *) style{
    [self setStyleWithFeature:featureRow andGeometryType:[featureRow getGeometryType] andStyle:style];
}

-(void) setStyleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType andStyle: (GPKGStyleRow *) style{
    [self setStyleWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:geometryType andStyle:style];
}

-(void) setStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow andStyle: (GPKGStyleRow *) style{
    [self setStyleWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:SF_NONE andStyle:style];
}

-(void) setStyleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType andStyle: (GPKGStyleRow *) style{
    [self deleteStyleWithTableName:featureTable andId:featureId andGeometryType:geometryType];
    if(style != nil){
        
        [self createStyleRelationshipWithTable:featureTable];
        
        int styleId = [self getOrInsertStyle:style];
        
        GPKGStyleMappingDao *mappingDao = [self styleMappingDaoWithTable:featureTable];
        [self insertStyleMappingWithDao:mappingDao andBaseId:featureId andRelatedId:styleId andGeometryType:geometryType];
        
    }
}

-(void) setStyleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId andStyle: (GPKGStyleRow *) style{
    [self setStyleWithTableName:featureTable andId:featureId andGeometryType:SF_NONE andStyle:style];
}

-(void) setIconsWithFeature: (GPKGFeatureRow *) featureRow andIcons: (GPKGIcons *) icons{
    [self setIconsWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andIcons:icons];
}

-(void) setIconsWithTableName: (NSString *) featureTable andId: (int) featureId andIcons: (GPKGIcons *) icons{
    [self deleteIconsWithTableName:featureTable andId:featureId];
    
    if (icons != nil) {
        
        if ([icons defaultIcon] != nil) {
            [self setIconDefaultWithTableName:featureTable andId:featureId andIcon:[icons defaultIcon]];
        }
        
        NSDictionary<NSNumber *, GPKGIconRow *> *allIcons = [icons allIcons];
        for(NSNumber *geometryTypeNumber in [allIcons allKeys]){
            GPKGIconRow *icon = [allIcons objectForKey:geometryTypeNumber];
            [self setIconWithTableName:featureTable andId:featureId andGeometryType:[geometryTypeNumber intValue] andIcon:icon];
        }
        
    }
}

-(void) setIconWithFeature: (GPKGFeatureRow *) featureRow andIcon: (GPKGIconRow *) icon{
    [self setIconWithFeature:featureRow andGeometryType:[featureRow getGeometryType] andIcon:icon];
}

-(void) setIconWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType andIcon: (GPKGIconRow *) icon{
    [self setIconWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:geometryType andIcon:icon];
}

-(void) setIconDefaultWithFeature: (GPKGFeatureRow *) featureRow andIcon: (GPKGIconRow *) icon{
    [self setIconWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:SF_NONE andIcon:icon];
}

-(void) setIconWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType andIcon: (GPKGIconRow *) icon{
    [self deleteIconWithTableName:featureTable andId:featureId andGeometryType:geometryType];
    if(icon != nil){
        
        [self createIconRelationshipWithTable:featureTable];
        
        int iconId = [self getOrInsertIcon:icon];
        
        GPKGStyleMappingDao *mappingDao = [self iconMappingDaoWithTable:featureTable];
        [self insertStyleMappingWithDao:mappingDao andBaseId:featureId andRelatedId:iconId andGeometryType:geometryType];
        
    }
}

-(void) setIconDefaultWithTableName: (NSString *) featureTable andId: (int) featureId andIcon: (GPKGIconRow *) icon{
    [self setIconWithTableName:featureTable andId:featureId andGeometryType:SF_NONE andIcon:icon];
}

/**
 * Get the style id, either from the existing style or by inserting a new
 * one
 *
 * @param style style row
 * @return style id
 */
-(int) getOrInsertStyle: (GPKGStyleRow *) style{
    int styleId;
    if ([style hasId]) {
        styleId = [[style getId] intValue];
    } else {
        GPKGStyleDao *styleDao = [self styleDao];
        styleId = (int)[styleDao create:style];
    }
    return styleId;
}

/**
 * Get the icon id, either from the existing icon or by inserting a new one
 *
 * @param icon icon row
 * @return icon id
 */
-(int) getOrInsertIcon: (GPKGIconRow *) icon{
    int iconId;
    if ([icon hasId]) {
        iconId = [[icon getId] intValue];
    } else {
        GPKGIconDao *iconDao = [self iconDao];
        iconId = (int)[iconDao create:icon];
    }
    return iconId;
}

/**
 * Insert a style mapping row
 *
 * @param mappingDao   mapping dao
 * @param baseId       base id, either contents id or feature id
 * @param relatedId    related id, either style or icon id
 * @param geometryType geometry type or null
 */
-(void) insertStyleMappingWithDao: (GPKGStyleMappingDao *) mappingDao andBaseId: (int) baseId andRelatedId: (int) relatedId andGeometryType: (enum SFGeometryType) geometryType{
    
    GPKGStyleMappingRow *row = [mappingDao newRow];
    
    [row setBaseId:baseId];
    [row setRelatedId:relatedId];
    [row setGeometryType:geometryType];
    
    [mappingDao insert:row];
}

-(void) deleteAllFeatureStylesWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteAllFeatureStylesWithTableName:featureTable.tableName];
}

-(void) deleteAllFeatureStylesWithTableName: (NSString *) featureTable{
    [self deleteTableFeatureStylesWithTableName:featureTable];
    [self deleteFeatureStylesWithTableName:featureTable];
}

-(void) deleteAllStylesWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteAllStylesWithTableName:featureTable.tableName];
}

-(void) deleteAllStylesWithTableName: (NSString *) featureTable{
    [self deleteTableStylesWithTableName:featureTable];
    [self deleteStylesWithTableName:featureTable];
}

-(void) deleteAllIconsWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteAllIconsWithTableName:featureTable.tableName];
}

-(void) deleteAllIconsWithTableName: (NSString *) featureTable{
    [self deleteTableIconsWithTableName:featureTable];
    [self deleteIconsWithTableName:featureTable];
}

-(void) deleteTableFeatureStylesWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteTableFeatureStylesWithTableName:featureTable.tableName];
}

-(void) deleteTableFeatureStylesWithTableName: (NSString *) featureTable{
    [self deleteTableStylesWithTableName:featureTable];
    [self deleteTableIconsWithTableName:featureTable];
}

-(void) deleteTableStylesWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteTableStylesWithTableName:featureTable.tableName];
}

-(void) deleteTableStylesWithTableName: (NSString *) featureTable{
    [self deleteTableMappingsWithDao:[self tableStyleMappingDaoWithTable:featureTable] andTableName:featureTable];
}

-(void) deleteTableStyleDefaultWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteTableStyleDefaultWithTableName:featureTable.tableName];
}

-(void) deleteTableStyleDefaultWithTableName: (NSString *) featureTable{
    [self deleteTableStyleWithTableName:featureTable andGeometryType:SF_NONE];
}

-(void) deleteTableStyleWithTable: (GPKGFeatureTable *) featureTable andGeometryType: (enum SFGeometryType) geometryType{
    [self deleteTableStyleWithTableName:featureTable.tableName andGeometryType:geometryType];
}

-(void) deleteTableStyleWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType{
    [self deleteTableMappingWithDao:[self tableStyleMappingDaoWithTable:featureTable] andTableName:featureTable andGeometryType:geometryType];
}

-(void) deleteTableIconsWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteTableIconsWithTableName:featureTable.tableName];
}

-(void) deleteTableIconsWithTableName: (NSString *) featureTable{
    [self deleteTableMappingsWithDao:[self tableIconMappingDaoWithTable:featureTable] andTableName:featureTable];
}

-(void) deleteTableIconDefaultWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteTableIconDefaultWithTableName:featureTable.tableName];
}

-(void) deleteTableIconDefaultWithTableName: (NSString *) featureTable{
    [self deleteTableIconWithTableName:featureTable andGeometryType:SF_NONE];
}

-(void) deleteTableIconWithTable: (GPKGFeatureTable *) featureTable andGeometryType: (enum SFGeometryType) geometryType{
    [self deleteTableIconWithTableName:featureTable.tableName andGeometryType:geometryType];
}

-(void) deleteTableIconWithTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType{
    [self deleteTableMappingWithDao:[self tableIconMappingDaoWithTable:featureTable] andTableName:featureTable andGeometryType:geometryType];
}

/**
 * Delete the table style mappings
 *
 * @param mappingDao   mapping dao
 * @param featureTable feature table
 */
-(void) deleteTableMappingsWithDao: (GPKGStyleMappingDao *) mappingDao andTableName: (NSString *) featureTable{
    if (mappingDao != nil) {
        NSNumber *featureContentsId = [self.contentsId getIdForTableName:featureTable];
        if(featureContentsId != nil){
            [mappingDao deleteByBaseId:[featureContentsId intValue]];
        }
    }
}

/**
 * Delete the table style mapping with the geometry type value
 *
 * @param mappingDao   mapping dao
 * @param featureTable feature table
 * @param geometryType geometry type
 */
-(void) deleteTableMappingWithDao: (GPKGStyleMappingDao *) mappingDao andTableName: (NSString *) featureTable andGeometryType: (enum SFGeometryType) geometryType{
    if (mappingDao != nil) {
        NSNumber *featureContentsId = [self.contentsId getIdForTableName:featureTable];
        if (featureContentsId != nil) {
            [mappingDao deleteByBaseId:[featureContentsId intValue] andGeometryType:geometryType];
        }
    }
}

-(void) deleteFeatureStylesWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteFeatureStylesWithTableName:featureTable.tableName];
}

-(void)  deleteFeatureStylesWithTableName: (NSString *) featureTable{
    [self deleteStylesWithTableName:featureTable];
    [self deleteIconsWithTableName:featureTable];
}

-(void) deleteStylesWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteStylesWithTableName:featureTable.tableName];
}

-(void) deleteStylesWithTableName: (NSString *) featureTable{
    [self deleteMappingsWithDao: [self styleMappingDaoWithTable:featureTable]];
}

-(void) deleteStylesWithFeature: (GPKGFeatureRow *) featureRow{
    [self deleteStylesWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue]];
}

-(void) deleteStylesWithTableName: (NSString *) featureTable andId: (int) featureId{
    [self deleteMappingsWithDao:[self styleMappingDaoWithTable:featureTable] andId:featureId];
}

-(void) deleteStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow{
    [self deleteStyleDefaultWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue]];
}

-(void) deleteStyleDefaultWithTableName: (NSString *) featureTable andId: (int) featureId{
    [self deleteStyleWithTableName:featureTable andId:featureId andGeometryType:SF_NONE];
}

-(void) deleteStyleWithFeature: (GPKGFeatureRow *) featureRow{
    [self deleteStyleWithFeature:featureRow andGeometryType:[featureRow getGeometryType]];
}

-(void) deleteStyleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    [self deleteStyleWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:geometryType];
}

-(void) deleteStyleWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self deleteMappingWithDao:[self styleMappingDaoWithTable:featureTable] andId:featureId andGeometryType:geometryType];
}

-(void) deleteIconsWithTable: (GPKGFeatureTable *) featureTable{
    [self deleteIconsWithTableName:featureTable.tableName];
}

-(void) deleteIconsWithTableName: (NSString *) featureTable{
    [self deleteMappingsWithDao:[self iconMappingDaoWithTable:featureTable]];
}

-(void) deleteIconsWithFeature: (GPKGFeatureRow *) featureRow{
    [self deleteIconsWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue]];
}

-(void) deleteIconsWithTableName: (NSString *) featureTable andId: (int) featureId{
    [self deleteMappingsWithDao:[self iconMappingDaoWithTable:featureTable] andId:featureId];
}

-(void) deleteIconDefaultWithFeature: (GPKGFeatureRow *) featureRow{
    [self deleteIconDefaultWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue]];
}

-(void) deleteIconDefaultWithTableName: (NSString *) featureTable andId: (int) featureId{
    [self deleteIconWithTableName:featureTable andId:featureId andGeometryType:SF_NONE];
}

-(void) deleteIconWithFeature: (GPKGFeatureRow *) featureRow{
    [self deleteIconWithFeature:featureRow andGeometryType:[featureRow getGeometryType]];
}

-(void) deleteIconWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    [self deleteIconWithTableName:featureRow.table.tableName andId:[[featureRow getId] intValue] andGeometryType:geometryType];
}

-(void) deleteIconWithTableName: (NSString *) featureTable andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self deleteMappingWithDao:[self iconMappingDaoWithTable:featureTable] andId:featureId andGeometryType:geometryType];
}

/**
 * Delete all style mappings
 *
 * @param mappingDao mapping dao
 */
-(void) deleteMappingsWithDao: (GPKGStyleMappingDao *) mappingDao{
    if (mappingDao != nil) {
        [mappingDao deleteAll];
    }
}

/**
 * Delete the style mappings
 *
 * @param mappingDao mapping dao
 * @param featureId  feature id
 */
-(void) deleteMappingsWithDao: (GPKGStyleMappingDao *) mappingDao andId: (int) featureId{
    if (mappingDao != nil) {
        [mappingDao deleteByBaseId:featureId];
    }
}

/**
 * Delete the style mapping with the geometry type value
 *
 * @param mappingDao   mapping dao
 * @param featureId    feature id
 * @param geometryType geometry type
 */
-(void) deleteMappingWithDao: (GPKGStyleMappingDao *) mappingDao andId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    if (mappingDao != nil) {
        [mappingDao deleteByBaseId:featureId andGeometryType:geometryType];
    }
}

-(NSArray<NSNumber *> *) allTableStyleIdsWithTable: (GPKGFeatureTable *) featureTable{
    return [self allTableStyleIdsWithTableName:featureTable.tableName];
}

-(NSArray<NSNumber *> *) allTableStyleIdsWithTableName: (NSString *) featureTable{
    NSArray<NSNumber *> *styleIds = nil;
    GPKGStyleMappingDao *mappingDao = [self tableStyleMappingDaoWithTable:featureTable];
    if(mappingDao != nil){
        styleIds = [mappingDao uniqueRelatedIds];
    }
    return styleIds;
}

-(NSArray<NSNumber *> *) allTableIconIdsWithTable: (GPKGFeatureTable *) featureTable{
    return [self allTableIconIdsWithTableName:featureTable.tableName];
}

-(NSArray<NSNumber *> *) allTableIconIdsWithTableName: (NSString *) featureTable{
    NSArray<NSNumber *> *iconIds = nil;
    GPKGStyleMappingDao *mappingDao = [self tableIconMappingDaoWithTable:featureTable];
    if(mappingDao != nil){
        iconIds = [mappingDao uniqueRelatedIds];
    }
    return iconIds;
}

-(NSArray<NSNumber *> *) allStyleIdsWithTable: (GPKGFeatureTable *) featureTable{
    return [self allStyleIdsWithTableName:featureTable.tableName];
}

-(NSArray<NSNumber *> *) allStyleIdsWithTableName: (NSString *) featureTable{
    NSArray<NSNumber *> *styleIds = nil;
    GPKGStyleMappingDao *mappingDao = [self styleMappingDaoWithTable:featureTable];
    if(mappingDao != nil){
        styleIds = [mappingDao uniqueRelatedIds];
    }
    return styleIds;
}

-(NSArray<NSNumber *> *) allIconIdsWithTable: (GPKGFeatureTable *) featureTable{
    return [self allIconIdsWithTableName:featureTable.tableName];
}

-(NSArray<NSNumber *> *) allIconIdsWithTableName: (NSString *) featureTable{
    NSArray<NSNumber *> *iconIds = nil;
    GPKGStyleMappingDao *mappingDao = [self iconMappingDaoWithTable:featureTable];
    if(mappingDao != nil){
        iconIds = [mappingDao uniqueRelatedIds];
    }
    return iconIds;
}

@end
