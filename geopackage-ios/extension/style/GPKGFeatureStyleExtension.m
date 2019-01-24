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

@end
