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
    return nil; // TODO
}

-(BOOL) has{
    return NO; // TODO
}

-(BOOL) hasWithTable: (NSString *) featureTable{
    return NO; // TODO
}

-(GPKGRelatedTablesExtension *) relatedTables{
    return nil; // TODO
}

-(GPKGContentsIdExtension *) contentsId{
    return nil; // TODO
}

-(void) createRelationshipsWithTable: (NSString *) featureTable{
    // TODO
}

-(BOOL) hasRelationshipWithTable: (NSString *) featureTable{
    return NO; // TODO
}

-(void) createStyleRelationshipWithTable: (NSString *) featureTable{
    // TODO
}

-(BOOL) hasStyleRelationshipWithTable: (NSString *) featureTable{
    return NO; // TODO
}

-(void) createTableStyleRelationshipWithTable: (NSString *) featureTable{
    // TODO
}

-(BOOL) hasTableStyleRelationshipWithTable: (NSString *) featureTable{
    return NO; // TODO
}

-(void) createIconRelationshipWithTable: (NSString *) featureTable{
    // TODO
}

-(BOOL) hasIconRelationshipWithTable: (NSString *) featureTable{
    return NO; // TODO
}

-(void) createTableIconRelationshipWithTable: (NSString *) featureTable{
    // TODO
}

-(BOOL) hasTableIconRelationshipWithTable: (NSString *) featureTable{
    return NO; // TODO
}

-(NSString *) mappingTableNameWithPrefix: (NSString *) tablePrefix andTable: (NSString *) featureTable{
    return nil; // TODO
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
    
    return NO; // TODO
    /*
    boolean has = false;
    
    try {
        has = relatedTables.hasRelations(baseTable, relatedTable,
                                         mappingTableName);
    } catch (SQLException e) {
        throw new GeoPackageException(
                                      "Failed to check if Feature Style Relationship exists. Base Table: "
                                      + baseTable + ", Related Table: " + relatedTable
                                      + ", Mapping Table: " + mappingTableName, e);
    }
    
    return has;
     */
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
    
    // TODO
    /*
    if (!hasStyleRelationship(mappingTableName, baseTable, relatedTable)) {
        
        // Create the extension
        getOrCreate(featureTable);
        
        if (baseTable.equals(ContentsId.TABLE_NAME)) {
            if (!contentsId.has()) {
                contentsId.getOrCreateExtension();
            }
        }
        
        StyleMappingTable mappingTable = new StyleMappingTable(
                                                               mappingTableName);
        
        if (relatedTable.equals(StyleTable.TABLE_NAME)) {
            relatedTables.addAttributesRelationship(baseTable,
                                                    new StyleTable(), mappingTable);
        } else {
            relatedTables.addMediaRelationship(baseTable, new IconTable(),
                                               mappingTable);
        }
    }
     */
    
}

-(void) deleteRelationships{
    // TODO
}

-(void) deleteRelationshipsWithTable: (NSString *) featureTable{
    // TODO
}

-(void) deleteStyleRelationshipWithTable: (NSString *) featureTable{
    // TODO
}

-(void) deleteTableStyleRelationshipWithTable: (NSString *) featureTable{
    // TODO
}

-(void) deleteIconRelationshipWithTable: (NSString *) featureTable{
    // TODO
}

-(void) deleteTableIconRelationshipWithTable: (NSString *) featureTable{
    // TODO
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
    
    // TODO
    /*
    relatedTables.removeRelationshipsWithMappingTable(mappingTableName);
    
    if (!hasRelationship(featureTable)) {
        try {
            if (extensionsDao.isTableExists()) {
                extensionsDao.deleteByExtension(EXTENSION_NAME,
                                                featureTable);
            }
        } catch (SQLException e) {
            throw new GeoPackageException(
                                          "Failed to delete Feature Style extension. GeoPackage: "
                                          + geoPackage.getName() + ", Feature Table: "
                                          + featureTable, e);
        }
    }
     */
    
}

-(void) removeExtension{
    // TODO
}

@end
