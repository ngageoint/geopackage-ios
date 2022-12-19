//
//  GPKGRelatedTablesExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "GPKGExtendedRelationsDao.h"
#import "GPKGUserMappingDao.h"
#import "GPKGMediaDao.h"
#import "GPKGSimpleAttributesDao.h"

extern NSString * const GPKG_EXTENSION_RELATED_TABLES_NAME_NO_AUTHOR;
extern NSString * const GPKG_PROP_EXTENSION_RELATED_TABLES_DEFINITION;

/**
 * Related Tables extension
 * <p>
 * <a href="http://docs.opengeospatial.org/is/18-000/18-000.html">http://docs.opengeospatial.org/is/18-000/18-000.html</a>
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
 *  Get the extension name
 *
 *  @return extension name
 */
-(NSString *) extensionName;

/**
 *  Get the extension definition
 *
 *  @return extension definition
 */
-(NSString *) extensionDefinition;

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
 * Get the extended relations DAO
 *
 * @return extended relations DAO
 */
-(GPKGExtendedRelationsDao *) extendedRelationsDao;

/**
 * Get a Extended Relations DAO
 *
 * @param geoPackage
 *            GeoPackage
 * @return extended relations dao
 */
+(GPKGExtendedRelationsDao *) extendedRelationsDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get a Extended Relations DAO
 *
 * @param database
 *            database connection
 * @return extended relations dao
 */
+(GPKGExtendedRelationsDao *) extendedRelationsDaoWithDatabase: (GPKGConnection *) database;

/**
 * Create the Extended Relations Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createExtendedRelationsTable;

/**
 * Get the primary key of a table
 *
 * @param tableName
 *            table name
 * @return the column name
 */
-(NSString *) primaryKeyColumnNameOfTable: (NSString *) tableName;

/**
 * Set the contents in the user table
 *
 * @param table
 *            user table
 */
-(void) setContentsInTable: (GPKGUserTable *) table;

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
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserTable: (GPKGUserTable *) relatedTable andMappingTableName: (NSString *) mappingTableName;

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
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserTable: (GPKGUserTable *) relatedTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

/**
 * Adds a relationship between the base and user related table. Creates a
 * default user mapping table and the related table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTable
 *            user related table
 * @param relationName
 *            relation name
 * @param mappingTableName
 *            user mapping table name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserTable: (GPKGUserTable *) relatedTable andRelationName: (NSString *) relationName andMappingTableName: (NSString *) mappingTableName;

/**
 * Adds a relationship between the base and user related table. Creates the
 * user mapping table and related table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTable
 *            user related table
 * @param relationName
 *            relation name
 * @param userMappingTable
 *            user mapping table
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addRelationshipWithBaseTable: (NSString *) baseTableName andUserTable: (GPKGUserTable *) relatedTable andRelationName: (NSString *) relationName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

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
 * Adds an attributes relationship between the base table and related
 * attributes table. Creates a default user mapping table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedAttributesTableName
 *            related attributes table name
 * @param mappingTableName
 *            mapping table name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addAttributesRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedAttributesTableName andMappingTableName: (NSString *) mappingTableName;

/**
 * Adds an attributes relationship between the base table and related
 * attributes table. Creates the user mapping table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedAttributesTableName
 *            related attributes table name
 * @param userMappingTable
 *            user mapping table
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addAttributesRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedAttributesTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

/**
 * Adds an attributes relationship between the base table and user
 * attributes related table. Creates a default user mapping table and the
 * attributes table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param attributesTable
 *            user attributes table
 * @param mappingTableName
 *            user mapping table name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addAttributesRelationshipWithBaseTable: (NSString *) baseTableName andAttributesTable: (GPKGAttributesTable *) attributesTable andMappingTableName: (NSString *) mappingTableName;

/**
 * Adds an attributes relationship between the base table and user
 * attributes related table. Creates the user mapping table and an
 * attributes table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param attributesTable
 *            user attributes table
 * @param userMappingTable
 *            user mapping table
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addAttributesRelationshipWithBaseTable: (NSString *) baseTableName andAttributesTable: (GPKGAttributesTable *) attributesTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

/**
 * Adds a tiles relationship between the base table and related tiles table.
 * Creates a default user mapping table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTilesTableName
 *            related tiles table name
 * @param mappingTableName
 *            mapping table name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addTilesRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTilesTableName andMappingTableName: (NSString *) mappingTableName;

/**
 * Adds a tiles relationship between the base table and related tiles table.
 * Creates the user mapping table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param relatedTilesTableName
 *            related tiles table name
 * @param userMappingTable
 *            user mapping table
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addTilesRelationshipWithBaseTable: (NSString *) baseTableName andRelatedTable: (NSString *) relatedTilesTableName andUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

/**
 * Adds a tiles relationship between the base table and user tiles related
 * table. Creates a default user mapping table and the tile table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param tileTable
 *            user tile table
 * @param mappingTableName
 *            user mapping table name
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addTilesRelationshipWithBaseTable: (NSString *) baseTableName andTileTable: (GPKGTileTable *) tileTable andMappingTableName: (NSString *) mappingTableName;

/**
 * Adds a tiles relationship between the base table and user tiles related
 * table. Creates the user mapping table and a tile table if needed.
 *
 * @param baseTableName
 *            base table name
 * @param tileTable
 *            user tile table
 * @param userMappingTable
 *            user mapping table
 * @return The relationship that was added
 */
-(GPKGExtendedRelation *) addTilesRelationshipWithBaseTable: (NSString *) baseTableName andTileTable: (GPKGTileTable *) tileTable andUserMappingTable: (GPKGUserMappingTable *) userMappingTable;

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
-(BOOL) createRelatedTable: (GPKGUserTable *) relatedTable;

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
 * Remove all relationships that include the table
 *
 * @param table
 *            base or related table name
 */
-(void) removeRelationshipsWithTable: (NSString *) table;

/**
 * Remove all relationships with the mapping table
 *
 * @param mappingTable
 *            mapping table
 */
-(void) removeRelationshipsWithMappingTable: (NSString *) mappingTable;

/**
 * Remove all trace of the extension
 */
-(void) removeExtension;

/**
 * Determine if has one or more relations matching the base table and
 * related table
 *
 * @param baseTable
 *            base table name
 * @param relatedTable
 *            related table name
 * @return true if has relations
 */
-(BOOL) hasRelationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable;

/**
 * Get the relations to the base table and related table
 *
 * @param baseTable
 *            base table name
 * @param relatedTable
 *            related table name
 * @return extended relations
 */
-(GPKGResultSet *) relationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable;

/**
 * Determine if has one or more relations matching the non null provided
 * values
 *
 * @param baseTable
 *            base table name
 * @param relatedTable
 *            related table name
 * @param mappingTable
 *            mapping table name
 * @return true if has relations
 */
-(BOOL) hasRelationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable andMappingTable: (NSString *) mappingTable;

/**
 * Get the relations matching the non null provided values
 *
 * @param baseTable
 *            base table name
 * @param relatedTable
 *            related table name
 * @param mappingTable
 *            mapping table name
 * @return extended relations
 */
-(GPKGResultSet *) relationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable andMappingTable: (NSString *) mappingTable;

/**
 * Determine if has one or more relations matching the non null provided
 * values
 *
 * @param baseTable
 *            base table name
 * @param relatedTable
 *            related table name
 * @param relation
 *            relation name
 * @param mappingTable
 *            mapping table name
 * @return true if has relations
 */
-(BOOL) hasRelationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable andRelation: (NSString *) relation andMappingTable: (NSString *) mappingTable;

/**
 * Get the relations matching the non null provided values
 *
 * @param baseTable
 *            base table name
 * @param relatedTable
 *            related table name
 * @param relation
 *            relation name
 * @param mappingTable
 *            mapping table name
 * @return extended relations
 */
-(GPKGResultSet *) relationsWithBaseTable: (NSString *) baseTable andRelatedTable: (NSString *) relatedTable andRelation: (NSString *) relation andMappingTable: (NSString *) mappingTable;

/**
 * Determine if has one or more relations matching the non null provided
 * values
 *
 * @param baseTable
 *            base table name
 * @param baseColumn
 *            base primary column name
 * @param relatedTable
 *            related table name
 * @param relatedColumn
 *            related primary column name
 * @param relation
 *            relation name
 * @param mappingTable
 *            mapping table name
 * @return true if has relations
 */
-(BOOL) hasRelationsWithBaseTable: (NSString *) baseTable andBaseColumn: (NSString *) baseColumn andRelatedTable: (NSString *) relatedTable andRelatedColumn: (NSString *) relatedColumn andRelation: (NSString *) relation andMappingTable: (NSString *) mappingTable;

/**
 * Get the relations matching the non null provided values
 *
 * @param baseTable
 *            base table name
 * @param baseColumn
 *            base primary column name
 * @param relatedTable
 *            related table name
 * @param relatedColumn
 *            related primary column name
 * @param relation
 *            relation name
 * @param mappingTable
 *            mapping table name
 * @return extended relations
 */
-(GPKGResultSet *) relationsWithBaseTable: (NSString *) baseTable andBaseColumn: (NSString *) baseColumn andRelatedTable: (NSString *) relatedTable andRelatedColumn: (NSString *) relatedColumn andRelation: (NSString *) relation andMappingTable: (NSString *) mappingTable;

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

/**
 * Get the relations to the base table
 *
 * @param baseTable
 *            base table name
 * @return extended relations
 */
-(GPKGResultSet *) relationsToBaseTable: (NSString *) baseTable;

/**
 * Determine if there are relations to the base table
 *
 * @param baseTable
 *            base table name
 * @return true if has extended relations
 */
-(BOOL) hasRelationsToBaseTable: (NSString *) baseTable;

/**
 * Get the relations to the related table
 *
 * @param relatedTable
 *            related table name
 * @return extended relations
 */
-(GPKGResultSet *) relationsToRelatedTable: (NSString *) relatedTable;

/**
 * Determine if there are relations to the related table
 *
 * @param relatedTable
 *            related table name
 * @return true if has extended relations
 */
-(BOOL) hasRelationsToRelatedTable: (NSString *) relatedTable;

/**
 * Get the relations to the table
 *
 * @param table
 *            table name
 * @return extended relations
 */
-(GPKGResultSet *) relationsToTable: (NSString *) table;

/**
 * Determine if there are relations to the table
 *
 * @param table
 *            table name
 * @return true if has extended relations
 */
-(BOOL) hasRelationsToTable: (NSString *) table;

/**
 * Get a User Custom DAO from a table name
 *
 * @param tableName
 *            table name
 * @return user custom dao
 */
-(GPKGUserCustomDao *) userDaoForTableName: (NSString *) tableName;

/**
 * Get a User Mapping DAO from an extended relation
 *
 * @param extendedRelation
 *            extended relation
 * @return user mapping dao
 */
-(GPKGUserMappingDao *) mappingDaoForRelation: (GPKGExtendedRelation *) extendedRelation;

/**
 * Get a User Mapping DAO from a table name
 *
 * @param tableName
 *            mapping table name
 * @return user mapping dao
 */
-(GPKGUserMappingDao *) mappingDaoForTableName: (NSString *) tableName;

/**
 * Get a related media table DAO
 *
 * @param mediaTable
 *            media table
 * @return media DAO
 */
-(GPKGMediaDao *) mediaDaoForTable: (GPKGMediaTable *) mediaTable;

/**
 * Get a related media table DAO
 *
 * @param extendedRelation
 *            extended relation
 * @return media DAO
 */
-(GPKGMediaDao *) mediaDaoForRelation: (GPKGExtendedRelation *) extendedRelation;

/**
 * Get a related media table DAO
 *
 * @param tableName
 *            media table name
 * @return media DAO
 */
-(GPKGMediaDao *) mediaDaoForTableName: (NSString *) tableName;

/**
 * Get a related simple attributes table DAO
 *
 * @param simpleAttributesTable
 *            simple attributes table
 * @return simple attributes DAO
 */
-(GPKGSimpleAttributesDao *) simpleAttributesDaoForTable: (GPKGSimpleAttributesTable *) simpleAttributesTable;

/**
 * Get a related simple attributes table DAO
 *
 * @param extendedRelation
 *            extended relation
 * @return simple attributes DAO
 */
-(GPKGSimpleAttributesDao *) simpleAttributesDaoForRelation: (GPKGExtendedRelation *) extendedRelation;

/**
 * Get a related simple attributes table DAO
 *
 * @param tableName
 *            simple attributes table name
 * @return simple attributes DAO
 */
-(GPKGSimpleAttributesDao *) simpleAttributesDaoForTableName: (NSString *) tableName;

/**
 * Get the related id mappings for the base id
 *
 * @param extendedRelation
 *            extended relation
 * @param baseId
 *            base id
 * @return IDs representing the matching related IDs
 */
-(NSArray<NSNumber *> *) mappingsForRelation: (GPKGExtendedRelation *) extendedRelation withBaseId: (int) baseId;

/**
 * Get the related id mappings for the base id
 *
 * @param tableName
 *            mapping table name
 * @param baseId
 *            base id
 * @return IDs representing the matching related IDs
 */
-(NSArray<NSNumber *> *) mappingsForTableName: (NSString *) tableName withBaseId: (int) baseId;

/**
 * Get the base id mappings for the related id
 *
 * @param extendedRelation
 *            extended relation
 * @param relatedId
 *            related id
 * @return IDs representing the matching base IDs
 */
-(NSArray<NSNumber *> *) mappingsForRelation: (GPKGExtendedRelation *) extendedRelation withRelatedId: (int) relatedId;

/**
 * Get the base id mappings for the related id
 *
 * @param tableName
 *            mapping table name
 * @param relatedId
 *            related id
 * @return IDs representing the matching base IDs
 */
-(NSArray<NSNumber *> *) mappingsForTableName: (NSString *) tableName withRelatedId: (int) relatedId;

/**
 * Determine if the base id and related id mapping exists
 *
 * @param tableName mapping table name
 * @param baseId    base id
 * @param relatedId related id
 * @return true if mapping exists
 */
-(BOOL) hasMappingWithTableName: (NSString *) tableName andBaseId: (int) baseId andRelatedId: (int) relatedId;

/**
 * Count the number of mappings to the base table and id
 *
 * @param baseTable base table name
 * @param baseId    base id
 * @return mappings count
 */
-(int) countMappingsToBaseTable: (NSString *) baseTable andBaseId: (int) baseId;

/**
 * Determine if a mapping to the base table and id exists
 *
 * @param baseTable base table name
 * @param baseId    base id
 * @return true if mapping exists
 */
-(BOOL) hasMappingToBaseTable: (NSString *) baseTable andBaseId: (int) baseId;

/**
 * Count the number of mappings in the extended relations to the base id
 *
 * @param extendedRelations extended relations
 * @param baseId            base id
 * @return mappings count
 */
-(int) countMappingsInRelations: (GPKGResultSet *) extendedRelations toBaseId: (int) baseId;

/**
 * Determine if a mapping in the extended relations to the base id exists
 *
 * @param extendedRelations extended relations
 * @param baseId            base id
 * @return true if mapping exists
 */
-(BOOL) hasMappingInRelations: (GPKGResultSet *) extendedRelations toBaseId: (int) baseId;

/**
 * Count the number of mappings in the extended relation to the base id
 *
 * @param extendedRelation extended relation
 * @param baseId           base id
 * @return mappings count
 */
-(int) countMappingsInRelation: (GPKGExtendedRelation *) extendedRelation toBaseId: (int) baseId;

/**
 * Determine if a mapping in the extended relation to the base id exists
 *
 * @param extendedRelation extended relation
 * @param baseId           base id
 * @return true if mapping exists
 */
-(BOOL) hasMappingInRelation: (GPKGExtendedRelation *) extendedRelation toBaseId: (int) baseId;

/**
 * Delete mappings to the base table and id
 *
 * @param baseTable base table name
 * @param baseId    base id
 * @return rows deleted
 */
-(int) deleteMappingsToBaseTable: (NSString *) baseTable andBaseId: (int) baseId;

/**
 * Delete mappings in the extended relations to the base id
 *
 * @param extendedRelations extended relations
 * @param baseId            base id
 * @return rows deleted
 */
-(int) deleteMappingsInRelations: (GPKGResultSet *) extendedRelations toBaseId: (int) baseId;

/**
 * Delete mappings in the extended relation to the base id
 *
 * @param extendedRelation extended relation
 * @param baseId           base id
 * @return rows deleted
 */
-(int) deleteMappingsInRelation: (GPKGExtendedRelation *) extendedRelation toBaseId: (int) baseId;

/**
 * Count the number of mappings to the related table and id
 *
 * @param relatedTable related table name
 * @param relatedId    related id
 * @return mappings count
 */
-(int) countMappingsToRelatedTable: (NSString *) relatedTable andRelatedId: (int) relatedId;

/**
 * Determine if a mapping to the related table and id exists
 *
 * @param relatedTable related table name
 * @param relatedId    related id
 * @return true if mapping exists
 */
-(BOOL) hasMappingToRelatedTable: (NSString *) relatedTable andRelatedId: (int) relatedId;

/**
 * Count the number of mappings in the extended relations to the related id
 *
 * @param extendedRelations extended relations
 * @param relatedId         related id
 * @return mappings count
 */
-(int) countMappingsInRelations: (GPKGResultSet *) extendedRelations toRelatedId: (int) relatedId;

/**
 * Determine if a mapping in the extended relations to the related id exists
 *
 * @param extendedRelations extended relations
 * @param relatedId         related id
 * @return true if mapping exists
 */
-(BOOL) hasMappingInRelations: (GPKGResultSet *) extendedRelations toRelatedId: (int) relatedId;

/**
 * Count the number of mappings in the extended relation to the related id
 *
 * @param extendedRelation extended relation
 * @param relatedId        related id
 * @return mappings count
 */
-(int) countMappingsInRelation: (GPKGExtendedRelation *) extendedRelation toRelatedId: (int) relatedId;

/**
 * Determine if a mapping in the extended relation to the related id exists
 *
 * @param extendedRelation extended relation
 * @param relatedId        related id
 * @return true if mapping exists
 */
-(BOOL) hasMappingInRelation: (GPKGExtendedRelation *) extendedRelation toRelatedId: (int) relatedId;

/**
 * Delete mappings to the related table and id
 *
 * @param relatedTable related table name
 * @param relatedId    related id
 * @return rows deleted
 */
-(int) deleteMappingsToRelatedTable: (NSString *) relatedTable andRelatedId: (int) relatedId;

/**
 * Delete mappings in the extended relations to the related id
 *
 * @param extendedRelations extended relations
 * @param relatedId         related id
 * @return rows deleted
 */
-(int) deleteMappingsInRelations: (GPKGResultSet *) extendedRelations toRelatedId: (int) relatedId;

/**
 * Delete mappings in the extended relation to the related id
 *
 * @param extendedRelation extended relation
 * @param relatedId        related id
 * @return rows deleted
 */
-(int) deleteMappingsInRelation: (GPKGExtendedRelation *) extendedRelation toRelatedId: (int) relatedId;

/**
 * Count the number of mappings to the table and id
 *
 * @param table table name
 * @param id    table id
 * @return mappings count
 */
-(int) countMappingsToTable: (NSString *) table andId: (int) id;

/**
 * Determine if a mapping to the table and id exists
 *
 * @param table table name
 * @param id    table id
 * @return true if mapping exists
 */
-(BOOL) hasMappingToTable: (NSString *) table andId: (int) id;

/**
 * Delete mappings to the table and id
 *
 * @param table table name
 * @param id    table id
 * @return rows deleted
 */
-(int) deleteMappingsToTable: (NSString *) table andId: (int) id;

@end
