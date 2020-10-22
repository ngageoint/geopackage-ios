//
//  GPKGRelatedTablesExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedTablesExtension.h"
#import "GPKGProperties.h"
#import "GPKGUserCustomTableReader.h"
#import "GPKGGeoPackageConstants.h"

NSString * const GPKG_EXTENSION_RELATED_TABLES_NAME_NO_AUTHOR = @"related_tables";
NSString * const GPKG_PROP_EXTENSION_RELATED_TABLES_DEFINITION = @"geopackage.extensions.extended_relations";

@interface GPKGRelatedTablesExtension ()

@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionDefinition;
@property (nonatomic, strong) GPKGExtendedRelationsDao *extendedRelationsDao;

@end

@implementation GPKGRelatedTablesExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_RELATED_TABLES_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties valueOfProperty:GPKG_PROP_EXTENSION_RELATED_TABLES_DEFINITION];
        self.extendedRelationsDao = [self extendedRelationsDao];
    }
    return self;
}

-(NSString *) extensionName{
    return _extensionName;
}

-(NSString *) extensionDefinition{
    return _extensionDefinition;
}

-(GPKGExtensions *) extensionCreate{
    
    // Create table
    [self createExtendedRelationsTable];
    
    GPKGExtensions *extension = [self extensionCreateWithName:self.extensionName andTableName:GPKG_ER_TABLE_NAME andColumnName:nil andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(GPKGExtensions *) extensionCreateWithMappingTable: (NSString *) mappingTable{
    
    [self extensionCreate];
    
    GPKGExtensions * extension = [self extensionCreateWithName:self.extensionName andTableName:mappingTable andColumnName:nil andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(BOOL) has{
    return [self hasWithExtensionName:self.extensionName andTableName:GPKG_ER_TABLE_NAME andColumnName:nil]
        && [self.geoPackage isTable:GPKG_ER_TABLE_NAME];
}

-(BOOL) hasWithMappingTable: (NSString *) mappingTable{
    return [self has] && [self hasWithExtensionName:self.extensionName andTableName:mappingTable andColumnName:nil];
}

-(GPKGExtendedRelationsDao *) extendedRelationsDao{
    return _extendedRelationsDao;
}

+(GPKGExtendedRelationsDao *) extendedRelationsDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [GPKGExtendedRelationsDao createWithDatabase:geoPackage.database];
}

+(GPKGExtendedRelationsDao *) extendedRelationsDaoWithDatabase: (GPKGConnection *) database{
    return [GPKGExtendedRelationsDao createWithDatabase:database];
}

-(BOOL) createExtendedRelationsTable{
    [self verifyWritable];
    
    BOOL created = NO;
    if(![self.extendedRelationsDao tableExists]){
        created = [[self.geoPackage tableCreator] createExtendedRelations] > 0;
    }
    
    return created;
}

-(NSString *) primaryKeyColumnNameOfTable: (NSString *) tableName{
    GPKGUserCustomTable *table = [GPKGUserCustomTableReader readTableWithConnection:self.geoPackage.database andTableName:tableName];
    GPKGUserColumn *pkColumn = [table pkColumn];
    if(pkColumn == nil){
        [NSException raise:@"No Primary Key" format:@"Found no primary key for table %@", tableName];
    }
    return pkColumn.name;
}

-(void) setContentsInTable: (GPKGUserTable *) table{
    GPKGContentsDao *dao = [self.geoPackage contentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForIdObject:table.tableName];
    if(contents == nil){
        [NSException raise:@"No Contents Table" format:@"No Contents Table exists for table name: %@", table.tableName];
    }
    [table setContents:contents];
}

-(NSArray<GPKGExtendedRelation *> *) relationships{
    NSMutableArray<GPKGExtendedRelation *> *relationships = [NSMutableArray array];
    if([self.extendedRelationsDao tableExists]){
        GPKGResultSet *resultSet = [self.extendedRelationsDao queryForAll];
        @try {
            while([resultSet moveToNext]){
                [relationships addObject:[self.extendedRelationsDao relation:resultSet]];
            }
        } @finally {
            [resultSet close];
        }
    }
    return relationships;
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andMappingTableName: (NSString *) mappingTableName andRelation: (enum GPKGRelationType) relationType{
    return [self addRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andMappingTableName:mappingTableName andRelationName:[GPKGRelationTypes name:relationType]];
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andMappingTableName: (NSString *) mappingTableName andRelationAuthor: (NSString *) relationAuthor andRelationName: (NSString *) relationName{
    return [self addRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andMappingTableName:mappingTableName andRelationName:[self buildRelationNameWithAuthor:relationAuthor andName:relationName]];
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andMappingTableName: (NSString *) mappingTableName andRelationName: (NSString *) relationName{
    
    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:mappingTableName];

    GPKGExtendedRelation *extendedRelation = [self addRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andUserMappingTable:userMappingTable andRelationName:relationName];
    
    return extendedRelation;
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable andRelation: (enum GPKGRelationType) relationType{
    return [self addRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andUserMappingTable:userMappingTable andRelationName:[GPKGRelationTypes name:relationType]];
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable andRelationAuthor: (NSString *) relationAuthor andRelationName: (NSString *) relationName{
    return [self addRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andUserMappingTable:userMappingTable andRelationName:[self buildRelationNameWithAuthor:relationAuthor andName:relationName]];
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable andRelationName: (NSString *) relationName{
    
    // Validate the relation
    [self validateRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andRelationName:relationName];
    
    // Create the user mapping table if needed
    [self createUserMappingTable:userMappingTable];
    
    // Add a row to gpkgext_relations
    GPKGExtendedRelation *extendedRelation = [[GPKGExtendedRelation alloc] init];
    [extendedRelation setBaseTableName:baseTableName];
    [extendedRelation setBasePrimaryColumn:[self primaryKeyColumnNameOfTable:baseTableName]];
    [extendedRelation setRelatedTableName:relatedTableName];
    [extendedRelation setRelatedPrimaryColumn:[self primaryKeyColumnNameOfTable:relatedTableName]];
    [extendedRelation setMappingTableName:userMappingTable.tableName];
    [extendedRelation setRelationName:relationName];
    long long id = [self.extendedRelationsDao create:extendedRelation];
    [extendedRelation setId:[NSNumber numberWithLongLong:id]];
    
    return extendedRelation;
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserRelatedTable: (GPKGUserRelatedTable *) relatedTable andMappingTableName: (NSString *) mappingTableName{
    return [self addRelationshipWithBaseTable:baseTableName andUserTable:relatedTable andRelationName:[relatedTable relationName] andMappingTableName:mappingTableName];
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserRelatedTable: (GPKGUserRelatedTable *) relatedTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
    return [self addRelationshipWithBaseTable:baseTableName andUserTable:relatedTable andRelationName:[relatedTable relationName] andUserMappingTable:userMappingTable];
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserTable: (GPKGUserTable *) relatedTable andMappingTableName: (NSString *) mappingTableName{
    return [self addRelationshipWithBaseTable:baseTableName andUserTable:relatedTable andRelationName:[relatedTable dataType] andMappingTableName:mappingTableName];
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserTable: (GPKGUserTable *) relatedTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
    return [self addRelationshipWithBaseTable:baseTableName andUserTable:relatedTable andRelationName:[relatedTable dataType] andUserMappingTable:userMappingTable];
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserTable: (GPKGUserTable *) relatedTable andRelationName: (NSString *) relationName andMappingTableName: (NSString *) mappingTableName{
    
    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:mappingTableName];

    return [self addRelationshipWithBaseTable:baseTableName andUserTable:relatedTable andRelationName:relationName andUserMappingTable:userMappingTable];
}

-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserTable: (GPKGUserTable *) relatedTable andRelationName: (NSString *) relationName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
    
    // Create the related table if needed
    [self createRelatedTable:relatedTable];
    
    return [self addRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTable.tableName andUserMappingTable:userMappingTable andRelationName:relationName];
}

-(GPKGExtendedRelation *) addFeaturesRelationshipWithBaseTable: (NSString *) baseFeaturesTableName andRelatedTable: (NSString *) relatedFeaturesTableName andMappingTableName: (NSString *) mappingTableName{
    return [self addRelationshipWithBaseTable:baseFeaturesTableName andRelatedTable:relatedFeaturesTableName andMappingTableName:mappingTableName andRelation:GPKG_RT_FEATURES];
}

-(GPKGExtendedRelation *) addFeaturesRelationshipWithBaseTable: (NSString *) baseFeaturesTableName andRelatedTable: (NSString *) relatedFeaturesTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
        return [self addRelationshipWithBaseTable:baseFeaturesTableName andRelatedTable:relatedFeaturesTableName andUserMappingTable:userMappingTable andRelation:GPKG_RT_FEATURES];
}

-(GPKGExtendedRelation *) addMediaRelationshipWithBaseTable: (NSString *) baseTableName andMediaTable: (GPKGMediaTable *) mediaTable andMappingTableName: (NSString *) mappingTableName{
    return [self addRelationshipWithBaseTable:baseTableName andUserRelatedTable:mediaTable andMappingTableName:mappingTableName];
}

-(GPKGExtendedRelation *) addMediaRelationshipWithBaseTable: (NSString *) baseTableName andMediaTable: (GPKGMediaTable *) mediaTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
    return [self addRelationshipWithBaseTable:baseTableName andUserRelatedTable:mediaTable andUserMappingTable:userMappingTable];
}

-(GPKGExtendedRelation *) addSimpleAttributesRelationshipWithBaseTable: (NSString *) baseTableName andSimpleAttributesTable: (GPKGSimpleAttributesTable *) simpleAttributesTable andMappingTableName: (NSString *) mappingTableName{
    return [self addRelationshipWithBaseTable:baseTableName andUserRelatedTable:simpleAttributesTable andMappingTableName:mappingTableName];
}

-(GPKGExtendedRelation *) addSimpleAttributesRelationshipWithBaseTable: (NSString *) baseTableName andSimpleAttributesTable: (GPKGSimpleAttributesTable *) simpleAttributesTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
    return [self addRelationshipWithBaseTable:baseTableName andUserRelatedTable:simpleAttributesTable andUserMappingTable:userMappingTable];
}

-(GPKGExtendedRelation *) addAttributesRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedAttributesTableName andMappingTableName: (NSString *) mappingTableName{
    return [self addRelationshipWithBaseTable:baseTableName andRelatedTable:relatedAttributesTableName andMappingTableName:mappingTableName andRelation:GPKG_RT_ATTRIBUTES];
}

-(GPKGExtendedRelation *) addAttributesRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedAttributesTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
    return [self addRelationshipWithBaseTable:baseTableName andRelatedTable:relatedAttributesTableName andUserMappingTable:userMappingTable andRelation:GPKG_RT_ATTRIBUTES];
}

-(GPKGExtendedRelation *) addAttributesRelationshipWithBaseTable: (NSString *) baseTableName andAttributesTable: (GPKGAttributesTable *) attributesTable andMappingTableName: (NSString *) mappingTableName{
    return [self addRelationshipWithBaseTable:baseTableName andUserTable:attributesTable andMappingTableName:mappingTableName];
}

-(GPKGExtendedRelation *) addAttributesRelationshipWithBaseTable: (NSString *) baseTableName andAttributesTable: (GPKGAttributesTable *) attributesTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
    return [self addRelationshipWithBaseTable:baseTableName andUserTable:attributesTable andUserMappingTable:userMappingTable];
}

-(GPKGExtendedRelation *) addTilesRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTilesTableName andMappingTableName: (NSString *) mappingTableName{
    return [self addRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTilesTableName andMappingTableName:mappingTableName andRelation:GPKG_RT_TILES];
}

-(GPKGExtendedRelation *) addTilesRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTilesTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
    return [self addRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTilesTableName andUserMappingTable:userMappingTable andRelation:GPKG_RT_TILES];
}

-(GPKGExtendedRelation *) addTilesRelationshipWithBaseTable: (NSString *) baseTableName andTileTable: (GPKGTileTable *) tileTable andMappingTableName: (NSString *) mappingTableName{
    return [self addRelationshipWithBaseTable:baseTableName andUserTable:tileTable andMappingTableName:mappingTableName];
}

-(GPKGExtendedRelation *) addTilesRelationshipWithBaseTable: (NSString *) baseTableName andTileTable: (GPKGTileTable *) tileTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
    return [self addRelationshipWithBaseTable:baseTableName andUserTable:tileTable andUserMappingTable:userMappingTable];
}

/**
 * Validate that the relation name is valid between the base and related
 * table
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param relationName
 *            relation name
 */
-(void) validateRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andRelationName: (NSString *) relationName{
    
    // Verify the base and related tables exist
    if(![self.geoPackage isTableOrView:baseTableName]){
        [NSException raise:@"Base Table" format:@"Base Relationship table does not exist: %@, Relation: %@", baseTableName, relationName];
    }
     if(![self.geoPackage isTableOrView:relatedTableName]){
        [NSException raise:@"Related Table" format:@"Related Relationship table does not exist: %@, Relation: %@", relatedTableName, relationName];
    }
    
    // Verify spec defined relation types
    enum GPKGRelationType relationType = [GPKGRelationTypes fromName:relationName];
    if ((int)relationType >= 0) {
        [self validateRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andRelation:relationType];
    }
    
}

/**
 * Determine if the relation type is valid between the base and related
 * table
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param relationType
 *            relation type
 */
-(void) validateRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andRelation: (enum GPKGRelationType) relationType{
    
    if ((int)relationType >= 0) {
        
        if(![self.geoPackage isTable:relatedTableName ofTypeName:[GPKGRelationTypes dataType:relationType]]){
            [NSException raise:@"Related Table" format:@"The related table must be a %@ table. Related Table: %@, Type: %@", [GPKGRelationTypes dataType:relationType], relatedTableName, [self.geoPackage typeOfTable:relatedTableName]];
        }
        
    }
    
}

-(BOOL) createUserMappingTableWithName: (NSString *) mappingTableName{
    
    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:mappingTableName];

    return [self createUserMappingTable:userMappingTable];
}

-(BOOL) createUserMappingTable: (GPKGUserMappingTable *) userMappingTable{
    
    BOOL created = NO;
    
    NSString *userMappingTableName = userMappingTable.tableName;
    [self extensionCreateWithMappingTable:userMappingTableName];
    
    if(![self.geoPackage isTableOrView:userMappingTableName]){
        
        [self.geoPackage createUserTable:userMappingTable];
        
        created = YES;
    }
    
    return created;
}

-(BOOL) createRelatedTable: (GPKGUserTable *) relatedTable{
    
    BOOL created = NO;
    
    NSString *relatedTableName = relatedTable.tableName;
    if(![self.geoPackage isTableOrView:relatedTableName]){
        
        [self.geoPackage createUserTable:relatedTable];
        
        // Create the contents
        GPKGContents *contents = [[GPKGContents alloc] init];
        [contents setTableName:relatedTableName];
        [contents setDataType:[relatedTable dataType]];
        [contents setIdentifier:relatedTableName];
        GPKGContentsDao *contentsDao = [self.geoPackage contentsDao];
        [contentsDao create:contents];
        contents = (GPKGContents *)[contentsDao queryForIdObject:relatedTableName];
        
        [relatedTable setContents:contents];
        
        created = YES;
    }
    
    return created;
}

-(void) removeRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andRelation: (enum GPKGRelationType) relationType{
    [self removeRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andRelationName:[GPKGRelationTypes name:relationType]];
}

-(void) removeRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andRelationAuthor: (NSString *) relationAuthor andRelationName: (NSString *) relationName{
    [self removeRelationshipWithBaseTable:baseTableName andRelatedTable:relatedTableName andRelationName:[self buildRelationNameWithAuthor:relationAuthor andName:relationName]];
}

-(void) removeRelationship: (GPKGExtendedRelation *) extendedRelation{
    if([self.extendedRelationsDao tableExists]){
        [self.geoPackage deleteTable:extendedRelation.mappingTableName];
        [self.extendedRelationsDao delete:extendedRelation];
    }
}

-(void) removeRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andRelationName: (NSString *) relationName{
    
    if([self.extendedRelationsDao tableExists]){
        GPKGResultSet *results = [self relationsWithBaseTable:baseTableName andRelatedTable:relatedTableName andRelation:relationName andMappingTable:nil];
        [self removeRelationships:results];
    }
    
}

-(void) removeRelationshipsWithTable: (NSString *) table{
    
    if([self.extendedRelationsDao tableExists]){
        GPKGResultSet *results = [self.extendedRelationsDao relationsToTable:table];
        [self removeRelationships:results];
    }

}

-(void) removeRelationshipsWithMappingTable: (NSString *) mappingTable{

    if([self.extendedRelationsDao tableExists]){
        GPKGResultSet *results = [self relationsWithBaseTable:nil andRelatedTable:nil andMappingTable:mappingTable];
        [self removeRelationships:results];
    }

}

/**
 * Remove all extended relations from the results and close
 *
 * @param results
 *            extended relation results
 */
-(void) removeRelationships: (GPKGResultSet *) results{
    if(results != nil){
        NSMutableArray<GPKGExtendedRelation *> *extendedRelations = [NSMutableArray array];
        @try {
            while([results moveToNext]){
                GPKGExtendedRelation *extendedRelation = [self.extendedRelationsDao relation:results];
                [extendedRelations addObject:extendedRelation];
            }
        } @finally {
            [results close];
        }
        for(GPKGExtendedRelation *extendedRelation in extendedRelations){
            [self removeRelationship:extendedRelation];
        }
    }
}

-(void) removeExtension{
    
    if([self.extendedRelationsDao tableExists]){
        NSMutableArray<NSString *> *mappingTables = [NSMutableArray array];
        GPKGResultSet *extendedRelations = [self.extendedRelationsDao queryForAll];
        @try {
            while([extendedRelations moveToNext]){
                GPKGExtendedRelation *extendedRelation = [self.extendedRelationsDao relation:extendedRelations];
                [mappingTables addObject:extendedRelation.mappingTableName];
            }
        } @finally {
            [extendedRelations close];
        }
        for(NSString *mappingTable in mappingTables){
            [self.geoPackage deleteTable:mappingTable];
        }
        [self.extendedRelationsDao dropTable];
    }
    if([self.extensionsDao tableExists]){
        [self.extensionsDao deleteByExtension:self.extensionName];
    }

}

-(BOOL) hasRelationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable{
    return [self hasRelationsWithBaseTable:baseTable andBaseColumn:nil andRelatedTable:relatedTable andRelatedColumn:nil andRelation:nil andMappingTable:nil];
}

-(GPKGResultSet *) relationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable{
    return [self relationsWithBaseTable:baseTable andBaseColumn:nil andRelatedTable:relatedTable andRelatedColumn:nil andRelation:nil andMappingTable:nil];
}

-(BOOL) hasRelationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable andMappingTable: (NSString *) mappingTable{
    return [self hasRelationsWithBaseTable:baseTable andBaseColumn:nil andRelatedTable:relatedTable andRelatedColumn:nil andRelation:nil andMappingTable:mappingTable];
}

-(GPKGResultSet *) relationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable andMappingTable: (NSString *) mappingTable{
    return [self relationsWithBaseTable:baseTable andBaseColumn:nil andRelatedTable:relatedTable andRelatedColumn:nil andRelation:nil andMappingTable:mappingTable];
}

-(BOOL) hasRelationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable andRelation: (NSString *) relation andMappingTable: (NSString *) mappingTable{
    return [self hasRelationsWithBaseTable:baseTable andBaseColumn:nil andRelatedTable:relatedTable andRelatedColumn:nil andRelation:relation andMappingTable:mappingTable];
}

-(GPKGResultSet *) relationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable andRelation: (NSString *) relation andMappingTable: (NSString *) mappingTable{
    return [self relationsWithBaseTable:baseTable andBaseColumn:nil andRelatedTable:relatedTable andRelatedColumn:nil andRelation:relation andMappingTable:mappingTable];
}

-(BOOL) hasRelationsWithBaseTable: (NSString *) baseTable andBaseColumn: (NSString *) baseColumn andRelatedTable: (NSString *) relatedTable andRelatedColumn: (NSString *) relatedColumn andRelation: (NSString *) relation andMappingTable: (NSString *) mappingTable{
    BOOL has = NO;
    GPKGResultSet *results = [self relationsWithBaseTable:baseTable andBaseColumn:baseColumn andRelatedTable:relatedTable andRelatedColumn:relatedColumn andRelation:relation andMappingTable:mappingTable];
    if(results != nil){
        @try {
            has = results.count > 0;
        } @finally {
            [results close];
        }
    }
    return has;
}

-(GPKGResultSet *) relationsWithBaseTable: (NSString *) baseTable andBaseColumn: (NSString *) baseColumn andRelatedTable: (NSString *) relatedTable andRelatedColumn: (NSString *) relatedColumn andRelation: (NSString *) relation andMappingTable: (NSString *) mappingTable{
    
    GPKGResultSet *relations = nil;
    
    if([self.extendedRelationsDao tableExists]){
        relations = [self.extendedRelationsDao relationsWithBaseTable:baseTable andBaseColumn:baseColumn andRelatedTable:relatedTable andRelatedColumn:relatedColumn andRelation:relation andMappingTable:mappingTable];
    }
    
    return relations;
}

-(NSString *) buildRelationNameWithAuthor: (NSString *) author andName: (NSString *) name{
    return [NSString stringWithFormat:@"x-%@_%@", author, name];
}

-(GPKGUserCustomDao *) userDaoForTableName: (NSString *) tableName{
    return [GPKGUserCustomDao readTableWithDatabase:self.geoPackage.name andConnection:self.geoPackage.database andTable:tableName];
}

-(GPKGUserMappingDao *) mappingDaoForRelation: (GPKGExtendedRelation *) extendedRelation{
    return [self mappingDaoForTableName:extendedRelation.mappingTableName];
}

-(GPKGUserMappingDao *) mappingDaoForTableName: (NSString *) tableName{
    return [[GPKGUserMappingDao alloc] initWithDao:[self userDaoForTableName:tableName]];
}

-(GPKGMediaDao *) mediaDaoForTable: (GPKGMediaTable *) mediaTable{
    return [self mediaDaoForTableName:mediaTable.tableName];
}

-(GPKGMediaDao *) mediaDaoForRelation: (GPKGExtendedRelation *) extendedRelation{
    return [self mediaDaoForTableName:extendedRelation.relatedTableName];
}

-(GPKGMediaDao *) mediaDaoForTableName: (NSString *) tableName{
    GPKGMediaDao *mediaDao = [[GPKGMediaDao alloc] initWithDao:[self userDaoForTableName:tableName]];
    [self setContentsInTable:[mediaDao table]];
    return mediaDao;
}

-(GPKGSimpleAttributesDao *) simpleAttributesDaoForTable: (GPKGSimpleAttributesTable *) simpleAttributesTable{
    return [self simpleAttributesDaoForTableName:simpleAttributesTable.tableName];
}

-(GPKGSimpleAttributesDao *) simpleAttributesDaoForRelation: (GPKGExtendedRelation *) extendedRelation{
    return [self simpleAttributesDaoForTableName:extendedRelation.relatedTableName];
}

-(GPKGSimpleAttributesDao *) simpleAttributesDaoForTableName: (NSString *) tableName{
    GPKGSimpleAttributesDao *simpleAttributesDao = [[GPKGSimpleAttributesDao alloc] initWithDao:[self userDaoForTableName:tableName]];
    [self setContentsInTable:[simpleAttributesDao table]];
    return simpleAttributesDao;
}

-(NSArray<NSNumber *> *) mappingsForRelation: (GPKGExtendedRelation *) extendedRelation withBaseId: (int) baseId{
    return [self mappingsForTableName:extendedRelation.mappingTableName withBaseId:baseId];
}

-(NSArray<NSNumber *> *) mappingsForTableName: (NSString *) tableName withBaseId: (int) baseId{
    
    NSMutableArray<NSNumber *> *relatedIds = [NSMutableArray array];
    
    GPKGUserMappingDao *userMappingDao = [self mappingDaoForTableName:tableName];
    GPKGResultSet *resultSet = [userMappingDao queryByBaseId:baseId];
    @try{
        while([resultSet moveToNext]){
            GPKGUserMappingRow *row = [userMappingDao row:resultSet];
            [relatedIds addObject:[NSNumber numberWithInt:[row relatedId]]];
        }
    }@finally{
        [resultSet close];
    }
    
    return relatedIds;
}

-(NSArray<NSNumber *> *) mappingsForRelation: (GPKGExtendedRelation *) extendedRelation withRelatedId: (int) relatedId{
    return [self mappingsForTableName:extendedRelation.mappingTableName withRelatedId:relatedId];
}

-(NSArray<NSNumber *> *) mappingsForTableName: (NSString *) tableName withRelatedId: (int) relatedId{
    
    NSMutableArray<NSNumber *> *baseIds = [NSMutableArray array];
    
    GPKGUserMappingDao *userMappingDao = [self mappingDaoForTableName:tableName];
    GPKGResultSet *resultSet = [userMappingDao queryByRelatedId:relatedId];
    @try{
        while([resultSet moveToNext]){
            GPKGUserMappingRow *row = [userMappingDao row:resultSet];
            [baseIds addObject:[NSNumber numberWithInt:[row baseId]]];
        }
    }@finally{
        [resultSet close];
    }
    
    return baseIds;
}

-(BOOL) hasMappingWithTableName: (NSString *) tableName andBaseId: (int) baseId andRelatedId: (int) relatedId{
    GPKGUserMappingDao *userMappingDao = [self mappingDaoForTableName:tableName];
    return [userMappingDao countByBaseId:baseId andRelatedId:relatedId] > 0;
}

@end
