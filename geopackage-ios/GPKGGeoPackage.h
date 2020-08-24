//
//  GPKGGeoPackage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "GPKGConnection.h"
#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGContentsDao.h"
#import "GPKGGeometryColumnsDao.h"
#import "GPKGFeatureTable.h"
#import "GPKGFeatureDao.h"
#import "GPKGTileDao.h"
#import "GPKGBoundingBox.h"
#import "GPKGTileMatrixSetDao.h"
#import "GPKGTileMatrixDao.h"
#import "GPKGTileTable.h"
#import "GPKGDataColumnsDao.h"
#import "GPKGDataColumnConstraintsDao.h"
#import "GPKGMetadataDao.h"
#import "GPKGMetadataReferenceDao.h"
#import "GPKGExtensionsDao.h"
#import "GPKGTableIndexDao.h"
#import "GPKGGeometryIndexDao.h"
#import "GPKGMetadataDb.h"
#import "GPKGFeatureTileLinkDao.h"
#import "GPKGGriddedCoverageDao.h"
#import "GPKGGriddedTileDao.h"
#import "GPKGAttributesTable.h"
#import "GPKGAttributesDao.h"
#import "GPKGTileScalingDao.h"
#import "GPKGExtendedRelationsDao.h"
#import "GPKGContentsIdDao.h"
#import "GPKGConstraint.h"
#import "GPKGUserCustomDao.h"
#import "GPKGGeoPackageTableCreator.h"

/**
 *  A single GeoPackage database connection
 */
@interface GPKGGeoPackage : NSObject

/**
 *  GeoPackage name
 */
@property (nonatomic, strong) NSString *name;

/**
 *  GeoPackage file path
 */
@property (nonatomic, strong) NSString *path;

/**
 *  Database connection
 */
@property (nonatomic) GPKGConnection *database;

/**
 *  Writable GeoPackage flag
 */
@property (nonatomic) BOOL writable;

/**
 *  Metadata db
 */
@property (nonatomic, strong)  GPKGMetadataDb * metadataDb;

/**
 *  Initialize
 *
 *  @param database database connection
 *  @param writable writable flag
 *
 *  @return new GeoPackage
 */
-(instancetype) initWithConnection: (GPKGConnection *) database andWritable: (BOOL) writable andMetadataDb: (GPKGMetadataDb *) metadataDb;

/**
 *  Close the GeoPackage connection
 */
-(void) close;

/**
 * Get the Table Creator
 *
 * @return table creator
 */
-(GPKGGeoPackageTableCreator *) tableCreator;

/**
 *  Get the application id
 *
 *  @return application id
 */
-(NSString *) applicationId;

/**
 * Get the application id integer
 *
 * @return application id integer
 */
-(NSNumber *) applicationIdNumber;

/**
 * Get the application id as a hex string prefixed with 0x
 *
 * @return application id hex string
 */
-(NSString *) applicationIdHex;
/**
 *  Get the user version
 *
 *  @return user version
 */
-(NSNumber *) userVersion;

/**
 *  Get the major user version
 *
 *  @return major user version
 */
-(NSNumber *) userVersionMajor;

/**
 *  Get the minor user version
 *
 *  @return minor user version
 */
-(NSNumber *) userVersionMinor;

/**
 *  Get the patch user version
 *
 *  @return patch user version
 */
-(NSNumber *) userVersionPatch;

/**
 *  Get the feature tables
 *
 *  @return feature table names
 */
-(NSArray<NSString *> *) featureTables;

/**
 *  Get the tile tables
 *
 *  @return tile table names
 */
-(NSArray<NSString *> *) tileTables;

/**
 *  Get the attributes tables
 *
 *  @return attributes table names
 */
-(NSArray<NSString *> *) attributesTables;

/**
 * Get the tables for the contents data type
 *
 * @param type
 *            data type
 * @return table names
 */
-(NSArray<NSString *> *) tablesByType: (enum GPKGContentsDataType) type;

/**
 * Get the tables for the contents data types
 *
 * @param types
 *            data types
 * @return table names
 */
-(NSArray<NSString *> *) tablesByTypes: (NSArray<NSNumber *> *) types;

/**
 * Get the tables for the contents data type
 *
 * @param type
 *            data type
 * @return table names
 */
-(NSArray<NSString *> *) tablesByTypeName: (NSString *) type;

/**
 * Get the tables for the contents data types
 *
 * @param types
 *            data types
 * @return table names
 */
-(NSArray<NSString *> *) tablesByTypeNames: (NSArray<NSString *> *) types;

/**
 * Get the contents for the data type
 *
 * @param type
 *            data type
 * @return contents
 */
-(NSArray<GPKGContents *> *) contentsByType: (enum GPKGContentsDataType) type;

/**
 * Get the contents for the data types
 *
 * @param types
 *            data types
 * @return contents
 */
-(NSArray<GPKGContents *> *) contentsByTypes: (NSArray<NSNumber *> *) types;

/**
 * Get the contents for the data type
 *
 * @param type
 *            data type
 * @return contents
 */
-(NSArray<GPKGContents *> *) contentsByTypeName: (NSString *) type;

/**
 * Get the contents for the data types
 *
 * @param types
 *            data types
 * @return contents
 */
-(NSArray<GPKGContents *> *) contentsByTypeNames: (NSArray<NSString *> *) types;

/**
 *  Get the feature and tile tables
 *
 *  @return feature and tile table names
 */
-(NSArray<NSString *> *) tables;

/**
 *  Check if the table is a feature table
 *
 *  @param table table name
 *
 *  @return true if a feature table
 */
-(BOOL) isFeatureTable: (NSString *) table;

/**
 *  Check if the table is a tile table
 *
 *  @param table table name
 *
 *  @return true if a tile table
 */
-(BOOL) isTileTable: (NSString *) table;

/**
 *  Check if the table is an attribute table
 *
 *  @param table table name
 *
 *  @return true if a tile table
 */
-(BOOL) isAttributeTable: (NSString *) table;

/**
 *  Check if the table is the provided type
 *
 *  @param table table name
 *  @param type contents data type
 *
 *  @return true if the type of table
 */
-(BOOL) isTable: (NSString *) table ofType: (enum GPKGContentsDataType) type;

/**
 *  Check if the table is one of the provided types
 *
 *  @param table table name
 *  @param types contents data types
 *
 *  @return true if the type of table
 */
-(BOOL) isTable: (NSString *) table ofTypes: (NSArray<NSNumber *> *) types;

/**
 *  Check if the table is the provided type
 *
 *  @param table table name
 *  @param type contents data type
 *
 *  @return true if the type of table
 */
-(BOOL) isTable: (NSString *) table ofTypeName: (NSString *) type;

/**
 * Check if the table is one of the provided types
 *
 * @param table
 *            table name
 * @param types
 *            data types
 * @return true if the type of table
 */
-(BOOL) isTable: (NSString *) table ofTypeNames: (NSArray<NSString *> *) types;

/**
 * Check if the table exists as a user contents table
 *
 * @param table
 *            table name
 * @return true if a user contents table
 */
-(BOOL) isContentsTable: (NSString *) table;

/**
 * Check if the table exists
 *
 * @param table
 *            table name
 * @return true if a table
 */
-(BOOL) isTable: (NSString *) table;

/**
 * Check if the view exists
 *
 * @param view
 *            view name
 * @return true if a view
 */
-(BOOL) isView: (NSString *) view;

/**
 * Check if the table or view exists
 *
 * @param name
 *            table or view name
 * @return true if a table or view
 */
-(BOOL) isTableOrView: (NSString *) name;

/**
 * Get the contents of the user table
 *
 * @param table
 *            table name
 * @return contents
 */
-(GPKGContents *) contentsOfTable: (NSString *) table;

/**
 * Get the contents data type of the user table
 *
 * @param table
 *            table name
 * @return table type
 */
-(NSString *) typeOfTable: (NSString *) table;

/**
 * Get the contents data type of the user table
 *
 * @param table
 *            table name
 * @return table type or -1 if not an enumerated type
 */
-(enum GPKGContentsDataType) dataTypeOfTable: (NSString *) table;

/**
 *  Get the feature table count
 *
 *  @return number of feature tables
 */
-(int) featureTableCount;

/**
 *  Get the tile table count
 *
 *  @return number of tile tables
 */
-(int) tileTableCount;

/**
 *  Get the feature and tile table count
 *
 *  @return number of feature and tile tables
 */
-(int) tableCount;

/**
 * Get the bounding box for all table contents in the provided projection
 *
 * @param projection
 *            desired bounding box projection
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) contentsBoundingBoxInProjection: (SFPProjection *) projection;

/**
 * Get the bounding box for all tables in the provided projection, including
 * contents and table metadata
 *
 * @param projection
 *            desired bounding box projection
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection;

/**
 * Get the bounding box for all tables in the provided projection, including
 * contents, table metadata, and manual queries if enabled
 *
 * @param projection
 *            desired bounding box projection
 * @param manual
 *            manual query flag, true to determine missing bounds manually
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection andManual: (BOOL) manual;

/**
 * Get the bounding box for all tables in the provided projection, using
 * only table metadata
 *
 * @param projection
 *            desired bounding box projection
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) tableBoundingBoxInProjection: (SFPProjection *) projection;

/**
 * Get the bounding box for all tables in the provided projection, using
 * only table metadata and manual queries if enabled
 *
 * @param projection
 *            desired bounding box projection
 * @param manual
 *            manual query flag, true to determine missing bounds manually
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) tableBoundingBoxInProjection: (SFPProjection *) projection andManual: (BOOL) manual;

/**
 * Get the bounding box from the contents for the table in the table's
 * projection
 *
 * @param table
 *            table name
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) contentsBoundingBoxOfTable: (NSString *) table;

/**
 * Get the bounding box from the contents for the table in the provided
 * projection
 *
 * @param table
 *            table name
 * @param projection
 *            desired bounding box projection
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) contentsBoundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 * Get the bounding box for the table in the table's projection, including
 * contents and table metadata
 *
 * @param table
 *            table name
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table;

/**
 * Get the bounding box for the table in the provided projection, including
 * contents and table metadata
 *
 * @param table
 *            table name
 * @param projection
 *            desired bounding box projection
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 * Get the bounding box for the table in the table's projection, including
 * contents, table metadata, and manual queries if enabled
 *
 * @param table
 *            table name
 * @param manual
 *            manual query flag, true to determine missing bounds manually
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table andManual: (BOOL) manual;

/**
 * Get the bounding box for the table in the provided projection, including
 * contents, table metadata, and manual queries if enabled
 *
 * @param table
 *            table name
 * @param projection
 *            desired bounding box projection
 * @param manual
 *            manual query flag, true to determine missing bounds manually
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection andManual: (BOOL) manual;

/**
 * Get the bounding box for the table in the table's projection, using only
 * table metadata
 *
 * @param table
 *            table name
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) tableBoundingBoxOfTable: (NSString *) table;

/**
 * Get the bounding box for the table in the provided projection, using only
 * table metadata
 *
 * @param projection
 *            desired bounding box projection
 * @param table
 *            table name
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) tableBoundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection;

/**
 * Get the bounding box for the table in the table's projection, using only
 * table metadata and manual queries if enabled
 *
 * @param table
 *            table name
 * @param manual
 *            manual query flag, true to determine missing bounds manually
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) tableBoundingBoxOfTable: (NSString *) table andManual: (BOOL) manual;

/**
 * Get the bounding box for the table in the provided projection, using only
 * table metadata and manual queries if enabled
 *
 * @param projection
 *            desired bounding box projection
 * @param table
 *            table name
 * @param manual
 *            manual query flag, true to determine missing bounds manually
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) tableBoundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection andManual: (BOOL) manual;

/**
 * Get the projection of the table contents
 *
 * @param table
 *            table name
 * @return projection
 */
-(SFPProjection *) contentsProjectionOfTable: (NSString *) table;

/**
 * Get the projection of the table
 *
 * @param table
 *            table name
 * @return projection
 */
-(SFPProjection *) projectionOfTable: (NSString *) table;

/**
 * Get the feature table bounding box
 *
 * @param table
 *            table name
 * @param projection
 *            desired projection
 * @param manual
 *            true to manually query if not indexed
 * @return bounding box
 */
-(GPKGBoundingBox *) featureBoundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection andManual: (BOOL) manual;

/**
 *  Get a Spatial Reference System DAO
 *
 *  @return Spatial Reference System DAO
 */
-(GPKGSpatialReferenceSystemDao *) spatialReferenceSystemDao;

/**
 *  Get a Contents DAO
 *
 *  @return Contents DAO
 */
-(GPKGContentsDao *) contentsDao;

/**
 *  Get a Geometry Columns DAO
 *
 *  @return Geometry Columns DAO
 */
-(GPKGGeometryColumnsDao *) geometryColumnsDao;

/**
 *  Create the Geometry Columns table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createGeometryColumnsTable;

/**
 *  Create a new feature table
 *
 *  WARNING: only creates the feature table, call
 *  createFeatureTableWithMetadata instead to create both
 *  the table and required GeoPackage metadata
 *
 *  @param table feature table
 */
-(void) createFeatureTable: (GPKGFeatureTable *) table;

/**
 * Create a new feature table with GeoPackage metadata including: geometry
 * columns table and row, user feature table, and contents row.
 *
 * @param metadata
 *            feature table metadata
 * @return feature table
 */
-(GPKGFeatureTable *) createFeatureTableWithMetadata: (GPKGFeatureTableMetadata *) metadata;

/**
 *  Get a Tile Matrix Set DAO
 *
 *  @return Tile Matrix Set DAO
 */
-(GPKGTileMatrixSetDao *) tileMatrixSetDao;

/**
 *  Create the Tile Matrix Set table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createTileMatrixSetTable;

/**
 *  Get a Tile Matrix DAO
 *
 *  @return Tile Matrix DAO
 */
-(GPKGTileMatrixDao *) tileMatrixDao;

/**
 *  Create the Tile Matrix table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createTileMatrixTable;

/**
 *  Create a new tile table
 *
 * WARNING: only creates the tile table, call
 * createTileTableWithMetadata instead to create both the
 * table and required GeoPackage metadata
 *
 *  @param table tile table
 */
-(void) createTileTable: (GPKGTileTable *) table;

/**
 * Create a new tile table with GeoPackage metadata including: tile matrix
 * set table and row, tile matrix table, user tile table, and contents row.
 *
 * @param metadata
 *            tile table metadata
 * @return tile table
 */
-(GPKGTileTable *) createTileTableWithMetadata: (GPKGTileTableMetadata *) metadata;

/**
 * Create a new attributes table
 *
 * WARNING: only creates the attributes table, call
 * createAttributesTableWithMetadata instead to
 * create both the table and required GeoPackage metadata
 *
 * @param table
 *            attributes table
 */
-(void) createAttributesTable: (GPKGAttributesTable *) table;

/**
 * Create a new attributes table with GeoPackage metadata including: user
 * attributes table and contents row.
 *
 * @param metadata
 *            attributes table metadata
 * @return attributes table
 */
-(GPKGAttributesTable *) createAttributesTableWithMetadata: (GPKGAttributesTableMetadata *) metadata;

/**
 *  Get a Data Columns DAO
 *
 *  @return Data Columns DAO
 */
-(GPKGDataColumnsDao *) dataColumnsDao;

/**
 *  Create the Data Columns table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createDataColumnsTable;

/**
 *  Get a Data Column Constraints DAO
 *
 *  @return Data Column Constraints DAO
 */
-(GPKGDataColumnConstraintsDao *) dataColumnConstraintsDao;

/**
 *  Create the Data Column Constraints table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createDataColumnConstraintsTable;

/**
 *  Get a Metadata DAO
 *
 *  @return Metadata DAO
 */
-(GPKGMetadataDao *) metadataDao;

/**
 *  Create the Metadata table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createMetadataTable;

/**
 *  Get a Metadata Reference DAO
 *
 *  @return Metadata Reference DAO
 */
-(GPKGMetadataReferenceDao *) metadataReferenceDao;

/**
 *  Create the Metadata Reference table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createMetadataReferenceTable;

/**
 *  Get an Extensions DAO
 *
 *  @return Extensions DAO
 */
-(GPKGExtensionsDao *) extensionsDao;

/**
 *  Create the Extensions table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createExtensionsTable;

/**
 *  Delete the table and all GeoPackage metadata
 *
 *  @param tableName table name
 */
-(void) deleteTable: (NSString *) tableName;

/**
 *  Attempt to delete the table and all GeoPackage metadata quietly
 *
 *  @param tableName table name
 */
-(void) deleteTableQuietly: (NSString *) tableName;

/**
 * Get a Table Index DAO
 *
 * @return table index dao
 */
-(GPKGTableIndexDao *) tableIndexDao;

/**
 * Create the Table Index Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createTableIndexTable;

/**
 * Get a Geometry Index DAO
 *
 * @return geometry index dao
 */
-(GPKGGeometryIndexDao *) geometryIndexDao;

/**
 * Create Geometry Index Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createGeometryIndexTable;

/**
 * Index the Geometry Index Table if needed
 *
 * @return true if indexed
 */
-(BOOL) indexGeometryIndexTable;

/**
 * Un-index the Geometry Index Table if needed
 *
 * @return true if unindexed
 */
-(BOOL) unindexGeometryIndexTable;

/**
 * Get a Feature Tile Link DAO
 *
 * @return feature tile link dao
 */
-(GPKGFeatureTileLinkDao *) featureTileLinkDao;

/**
 * Create the Feature Tile Link Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createFeatureTileLinkTable;

/**
 *  Verify the GeoPackage is writable and throw an exception if it is not
 */
-(void) verifyWritable;

/**
 *  Get a Feature DAO from Geometry Columns
 *
 *  @param geometryColumns Geometry Columns
 *
 *  @return Feature DAO
 */
-(GPKGFeatureDao *) featureDaoWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

/**
 *  Get a Feature DAO from Contents
 *
 *  @param contents Contents
 *
 *  @return Feature DAO
 */
-(GPKGFeatureDao *) featureDaoWithContents: (GPKGContents *) contents;

/**
 *  Get a Feature DAO from a table name
 *
 *  @param tableName table name
 *
 *  @return Feature DAO
 */
-(GPKGFeatureDao *) featureDaoWithTableName: (NSString *) tableName;

/**
 *  Get a Tile DAO from Tile Matrix Set
 *
 *  @param tileMatrixSet Tile Matrix Set
 *
 *  @return Tile DAO
 */
-(GPKGTileDao *) tileDaoWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Get a Tile DAO from Contents
 *
 *  @param contents Contents
 *
 *  @return Tile DAO
 */
-(GPKGTileDao *) tileDaoWithContents: (GPKGContents *) contents;

/**
 *  Get a Tile DAO from a table name
 *
 *  @param tableName table name
 *
 *  @return Tile DAO
 */
-(GPKGTileDao *) tileDaoWithTableName: (NSString *) tableName;

/**
 * Get an Attributes DAO from Contents
 *
 * @param contents
 *            contents
 * @return attributes dao
 */
-(GPKGAttributesDao *) attributesDaoWithContents: (GPKGContents *) contents;

/**
 * Get an Attributes DAO from a table name
 *
 * @param tableName
 *            table name
 * @return attributes dao
 */
-(GPKGAttributesDao *) attributesDaoWithTableName: (NSString *) tableName;

/**
 * Get a User Custom DAO from a table name
 *
 * @param tableName
 *            table name
 * @return user custom dao
 */
-(GPKGUserCustomDao *) userCustomDaoWithTableName: (NSString *) tableName;

/**
 * Get a User Custom DAO from a table
 *
 * @param table table
 * @return user custom dao
 */
-(GPKGUserCustomDao *) userCustomDaoWithTable: (GPKGUserCustomTable *) table;

/**
 *  Execute the sql on the GeoPackage database
 *
 *  @param sql sql
 */
-(void) execSQL: (NSString *) sql;

/**
 * Begin a transaction
 */
-(void) beginTransaction;

/**
 * Commit the transaction
 */
-(void) commitTransaction;

/**
 * Rollback the transaction
 */
-(void) rollbackTransaction;

/**
 * Determine if currently within a transaction
 *
 * @return true if in transaction
 */
-(BOOL) inTransaction;

/**
 * If foreign keys is disabled and there are no foreign key violations,
 * enables foreign key checks, else logs violations
 *
 * @return true if enabled or already enabled, false if foreign key
 *         violations and not enabled
 */
-(BOOL) enableForeignKeys;

/**
 * Query for the foreign keys value
 *
 * @return true if enabled, false if disabled
 */
-(BOOL) foreignKeys;

/**
 * Change the foreign keys state
 *
 * @param on
 *            true to turn on, false to turn off
 * @return previous foreign keys value
 */
-(BOOL) foreignKeysAsOn: (BOOL) on;

/**
 *  Drop the table if it exists. Drops the table with the table name, not
 +	limited to GeoPackage specific tables.
 *
 *  @param table table to drop
 */
-(void) dropTable: (NSString *) table;

/**
 * Drop the view if it exists. Drops the view with the view name, not
 * limited to GeoPackage specific tables.
 *
 * @param view
 *            view name
 */
-(void) dropView: (NSString *) view;

/**
 * Rename the table
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 */
-(void) renameTable: (NSString *) tableName toTable: (NSString *) newTableName;

/**
 * Copy the table with transferred contents and extensions
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 */
-(void) copyTable: (NSString *) tableName toTable: (NSString *) newTableName;

/**
 * Copy the table with transferred contents but no extensions
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 */
-(void) copyTableNoExtensions: (NSString *) tableName toTable: (NSString *) newTableName;

/**
 * Copy the table but leave the user table empty and without extensions
 *
 * @param tableName
 *            table name
 * @param newTableName
 *            new table name
 */
-(void) copyTableAsEmpty: (NSString *) tableName toTable: (NSString *) newTableName;

/**
 * Rebuild the GeoPackage, repacking it into a minimal amount of disk space
 */
-(void) vacuum;

/**
 *  Perform a raw query on the database
 *
 *  @param sql  sql
 *  @param args sql args
 *
 *  @return result set
 */
-(GPKGResultSet *) rawQuery: (NSString *) sql andArgs: (NSArray *) args;

/**
 *  Perform a foreign key check on the database
 *
 *  @return nil if check passed, open result set with results if failed
 */
-(GPKGResultSet *) foreignKeyCheck;

/**
 * Perform a foreign key check on the database table
 *
 * @param tableName
 *            table name
 * @return null if check passed, open result set with results if failed
 */
-(GPKGResultSet *) foreignKeyCheckOnTable: (NSString *) tableName;

/**
 *  Perform an integrity check on the database
 *
 *  @return nil if check passed, open result set with results if failed
 */
-(GPKGResultSet *) integrityCheck;

/**
 *  Perform a quick integrity check on the database
 *
 *  @return nil if check passed, open result set with results if failed
 */
-(GPKGResultSet *) quickCheck;

/**
 * Get an extension manager on the GeoPackage
 *
 * @return extension manager
 */
-(GPKGExtensionManager *) extensionManager;

/**
 * Create a new user table
 *
 * @param table
 *            user table
 */
-(void) createUserTable: (GPKGUserTable *) table;

@end
