//
//  GPKGRelatedTablesExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "GPKGUserRelatedTable.h"
#import "GPKGUserMappingTable.h"
#import "GPKGMediaTable.h"
#import "GPKGSimpleAttributesTable.h"

extern NSString * const GPKG_EXTENSION_RELATED_TABLES_AUTHOR;
extern NSString * const GPKG_EXTENSION_RELATED_TABLES_NAME_NO_AUTHOR;
extern NSString * const GPKG_PROP_EXTENSION_RELATED_TABLES_DEFINITION;

/**
 * Related Tables extension
 */
@interface GPKGRelatedTablesExtension : GPKGBaseExtension

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new related tables
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get the extended relations DAO
 *
 * @return extended relations DAO
 */
-(GPKGExtendedRelationsDao *) getExtendedRelationsDao;

/**
 *  Get the extension name
 *
 *  @return extension name
 */
-(NSString *) getExtensionName;

/**
 *  Get the extension definition
 *
 *  @return extension definition
 */
-(NSString *) getExtensionDefinition;

/**
 * Determine if the GeoPackage has the extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 * Determine if the GeoPackage has the extension for the mapping table
 
 * @param mappingTable
 *            mapping table name
 * @return true if has extension
 */
-(BOOL) hasWithMappingTable: (NSString *) mappingTable;

/**
 * Get the primary key of a table
 *
 * @param tableName
 *            table name
 * @return the column name
 */
-(NSString *) primaryKeyColumnNameOfTable: (NSString *) tableName;

/**
 * Returns the relationships defined through this extension
 *
 * @return a list of ExtendedRelation objects
 */
-(NSArray<GPKGExtendedRelation *> *) relationships;

/**
 * Adds a relationship between the base and related table. Creates a default
 * user mapping table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param mappingTableName
 *            mapping table name
 * @param relationType
 *            relation type
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andMappingTableName: (NSString *) mappingTableName andRelation: (enum GPKGRelationType) relationType;

/**
 * Adds a relationship between the base and related table. Creates a default
 * user mapping table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param mappingTableName
 *            mapping table name
 * @param relationAuthor
 *            relation author
 * @param relationName
 *            relation name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andMappingTableName: (NSString *) mappingTableName andRelationAuthor: (NSString *) relationAuthor andRelationName: (NSString *) relationName;

/**
 * Adds a relationship between the base and related table. Creates a default
 * user mapping table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param mappingTableName
 *            mapping table name
 * @param relationName
 *            relation name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andMappingTableName: (NSString *) mappingTableName andRelationName: (NSString *) relationName;

/**
 * Adds a relationship between the base and related table. Creates the user
 * mapping table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param userMappingTable
 *            user mapping table
 * @param relationType
 *            relation type
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable andRelation: (enum GPKGRelationType) relationType;

/**
 * Adds a relationship between the base and related table. Creates the user
 * mapping table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param userMappingTable
 *            user mapping table
 * @param relationAuthor
 *            relation author
 * @param relationName
 *            relation name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable andRelationAuthor: (NSString *) relationAuthor andRelationName: (NSString *) relationName;

/**
 * Adds a relationship between the base and related table. Creates the user
 * mapping table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param userMappingTable
 *            user mapping table
 * @param relationName
 *            relation name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable andRelationName: (NSString *) relationName;

/**
 * Adds a relationship between the base and user related table. Creates a
 * default user mapping table and the related table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTable
 *            user related table
 * @param mappingTableName
 *            user mapping table name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserRelatedTable: (GPKGUserRelatedTable *) relatedTable andMappingTableName: (NSString *) mappingTableName;

/**
 * Adds a relationship between the base and user related table. Creates the
 * user mapping table and related table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTable
 *            user related table
 * @param userMappingTable
 *            user mapping table
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserRelatedTable: (GPKGUserRelatedTable *) relatedTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

/**
 * Adds a features relationship between the base feature and related feature
 * table. Creates a default user mapping table if needed.
 *
 * @param baseFeaturesTableName
 *            base features table name
 * @param relatedFeaturesTableName
 *            related features table name
 * @param mappingTableName
 *            mapping table name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addFeaturesRelationshipWithBaseTable: (NSString *) baseFeaturesTableName andRelatedTable: (NSString *) relatedFeaturesTableName andMappingTableName: (NSString *) mappingTableName;

/**
 * Adds a features relationship between the base feature and related feature
 * table. Creates the user mapping table if needed.
 *
 * @param baseFeaturesTableName
 *            base features table name
 * @param relatedFeaturesTableName
 *            related features table name
 * @param userMappingTable
 *            user mapping table
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addFeaturesRelationshipWithBaseTable: (NSString *) baseFeaturesTableName andRelatedTable: (NSString *) relatedFeaturesTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

/**
 * Adds a media relationship between the base table and user media related
 * table. Creates a default user mapping table and the media table if
 * needed.
 *
 * @param baseTableName
 *            base table name
 * @param mediaTable
 *            user media table
 * @param mappingTableName
 *            user mapping table name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addMediaRelationshipWithBaseTable: (NSString *) baseTableName andMediaTable: (GPKGMediaTable *) mediaTable andMappingTableName: (NSString *) mappingTableName;

/**
 * Adds a media relationship between the base table and user media related
 * table. Creates the user mapping table and media table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param mediaTable
 *            user media table
 * @param userMappingTable
 *            user mapping table
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addMediaRelationshipWithBaseTable: (NSString *) baseTableName andMediaTable: (GPKGMediaTable *) mediaTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

/**
 * Adds a simple attributes relationship between the base table and user
 * simple attributes related table. Creates a default user mapping table and
 * the simple attributes table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param simpleAttributesTable
 *            user simple attributes table
 * @param mappingTableName
 *            user mapping table name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addSimpleAttributesRelationshipWithBaseTable: (NSString *) baseTableName andSimpleAttributesTable: (GPKGSimpleAttributesTable *) simpleAttributesTable andMappingTableName: (NSString *) mappingTableName;

/**
 * Adds a simple attributes relationship between the base table and user
 * simple attributes related table. Creates the user mapping table and
 * simple attributes table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param simpleAttributesTable
 *            user simple attributes table
 * @param userMappingTable
 *            user mapping table
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addSimpleAttributesRelationshipWithBaseTable: (NSString *) baseTableName andSimpleAttributesTable: (GPKGSimpleAttributesTable *) simpleAttributesTable  andUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

/**
 * Create a default user mapping table and extension row if either does not
 * exist. When not created, there is no guarantee that an existing table has
 * the same schema as the provided tabled.
 *
 * @param mappingTableName
 *            user mapping table name
 * @return true if table was created, false if the table already existed
 */
-(BOOL) createUserMappingTableWithName: (NSString *) mappingTableName;

/**
 * Create a user mapping table and extension row if either does not exist.
 * When not created, there is no guarantee that an existing table has the
 * same schema as the provided tabled.
 *
 * @param userMappingTable
 *            user mapping table
 * @return true if table was created, false if the table already existed
 */
-(BOOL) createUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

/**
 * Create a user related table if it does not exist. When not created, there
 * is no guarantee that an existing table has the same schema as the
 * provided tabled.
 *
 * @param relatedTable
 *            user related table
 * @return true if created, false if the table already existed
 */
-(BOOL) createRelatedTable: (GPKGUserRelatedTable *) relatedTable;

/**
 * Remove a specific relationship from the GeoPackage
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param relationType
 *            relation type
 */
-(void) removeRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andRelation: (enum GPKGRelationType) relationType;

/**
 * Remove a specific relationship from the GeoPackage
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param relationAuthor
 *            relation author
 * @param relationName
 *            relation name
 */
-(void) removeRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andRelationAuthor: (NSString *) relationAuthor andRelationName: (NSString *) relationName;

/**
 * Remove a specific relationship from the GeoPackage
 *
 * @param extendedRelation
 *            extended relation
 */
-(void) removeRelationship: (GPKGExtendedRelation *) extendedRelation;

/**
 * Remove a specific relationship from the GeoPackage
 *
 * @param baseTableName
 *            base table name
 * @param relatedTableName
 *            related table name
 * @param relationName
 *            relation name
 */
-(void) removeRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTableName andRelationName: (NSString *) relationName;

/**
 * Remove all trace of the extension
 */
-(void) removeExtension;

/**
 * Build the custom relation name with author
 *
 * @param author
 *            relation author
 * @param name
 *            base relation name
 * @return custom relation name
 */
-(NSString *) buildRelationNameWithAuthor: (NSString *) author andName: (NSString *) name;

@end
