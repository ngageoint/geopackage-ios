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
-(void)close;

/**
 *  Get the feature tables
 *
 *  @return feature table names
 */
-(NSArray *)getFeatureTables;

/**
 *  Get the tile tables
 *
 *  @return tile table names
 */
-(NSArray *)getTileTables;

/**
 *  Get the feature and tile tables
 *
 *  @return feature and tile table names
 */
-(NSArray *)getTables;

/**
 *  Get the feature table count
 *
 *  @return number of feature tables
 */
-(int)getFeatureTableCount;

/**
 *  Get the tile table count
 *
 *  @return number of tile tables
 */
-(int)getTileTableCount;

/**
 *  Get the feature and tile table count
 *
 *  @return number of feature and tile tables
 */
-(int)getTableCount;

/**
 *  Get a Spatial Reference System DAO
 *
 *  @return Spatial Reference System DAO
 */
-(GPKGSpatialReferenceSystemDao *) getSpatialReferenceSystemDao;

/**
 *  Get a Contents DAO
 *
 *  @return Contents DAO
 */
-(GPKGContentsDao *) getContentsDao;

/**
 *  Get a Geometry Columns DAO
 *
 *  @return Geometry Columns DAO
 */
-(GPKGGeometryColumnsDao *) getGeometryColumnsDao;

/**
 *  Create the Geometry Columns table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createGeometryColumnsTable;

/**
 *  Create a new feature table
 *
 *  @param table feature table
 */
-(void) createFeatureTable: (GPKGFeatureTable *) table;

/**
 *  Create a new feature table with GeoPackage metadata. Create the Geometry
 *  Columns table if needed, create a user feature table, create a new
 *  Contents, insert the new Geometry Columns.
 *
 *  The user feature table will be created with 2 columns, an id column named
 *  "id" and a geometry column using GPKGGeometryColumns columnName.
 *
 *  @param geometryColumns geometry columns
 *  @param boundingBox     bounding box
 *  @param srsId           Spatial Reference System Id
 *
 *  @return Geometry Columns
 */
-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                andSrsId: (NSNumber *) srsId;

/**
 *  Create a new feature table with GeoPackage metadata. Create the Geometry
 *  Columns table if needed, create a user feature table, create a new
 *  Contents, insert the new Geometry Columns.
 *
 *
 * The user feature table will be created with 2 columns, an id column with
 * the provided name and a geometry column using GPKGGeometryColumns columnName.
 *
 *  @param geometryColumns geometry columns
 *  @param idColumnName    id column name
 *  @param boundingBox     bounding box
 *  @param srsId           Spatial Reference System Id
 *
 *  @return Geometry Columns
 */
-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                               andIdColumnName: (NSString *) idColumnName
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                      andSrsId: (NSNumber *) srsId;

/**
 *  Create a new feature table with GeoPackage metadata. Create the Geometry
 *  Columns table if needed, create a user feature table, create a new
 *  Contents, insert the new Geometry Columns.
 *
 *  The user feature table will be created with 2 + [additionalColumns count]
 *  columns, an id column named "id", a geometry column using
 *  GPKGGeometryColumns columnName, and the provided additional
 *  columns.
 *
 *  @param geometryColumns   geometry columns
 *  @param additionalColumns additional user feature table columns to create in addition to id and geometry columns
 *  @param boundingBox       bounding box
 *  @param srsId             Spatial Reference System Id
 *
 *  @return Geometry Columns
 */
-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                          andAdditionalColumns: (NSArray *) additionalColumns
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                      andSrsId: (NSNumber *) srsId;

/**
 *  Create a new feature table with GeoPackage metadata. Create the Geometry
 *  Columns table if needed, create a user feature table, create a new
 *  Contents, insert the new Geometry Columns.
 *
 *  The user feature table will be created with 2 + [additionalColumns count]
 *  columns, an id column with the provided name, a geometry column using
 *  GPKGGeometryColumns columnName, and the provided additional
 *  columns.
 *
 *  @param geometryColumns   geometry columns
 *  @param idColumnName      id column name
 *  @param additionalColumns additional user feature table columns to create in addition to id and geometry columns
 *  @param boundingBox       bounding box
 *  @param srsId             Spatial Reference System Id
 *
 *  @return Geometry Columns
 */
-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                               andIdColumnName: (NSString *) idColumnName
                                          andAdditionalColumns: (NSArray *) additionalColumns
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                      andSrsId: (NSNumber *) srsId;

/**
 *  Create a new feature table with GeoPackage metadata. Create the Geometry
 *  Columns table if needed, create a user feature table, create a new
 *  Contents, insert the new Geometry Columns.
 *
 *  The user feature table will be created using only the provided columns.
 *  These should include the id column and the geometry column defined in
 *  GPKGGeometryColumns columnName
 *
 *  @param geometryColumns geometry columns
 *  @param boundingBox     bounding box
 *  @param srsId           Spatial Reference System Id
 *  @param columns         user feature table columns to create
 *
 *  @return Geometry Columns
 */
-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                      andSrsId: (NSNumber *) srsId
                                                    andColumns: (NSArray *) columns;

/**
 *  Get a Tile Matrix Set DAO
 *
 *  @return Tile Matrix Set DAO
 */
-(GPKGTileMatrixSetDao *) getTileMatrixSetDao;

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
-(GPKGTileMatrixDao *) getTileMatrixDao;

/**
 *  Create the Tile Matrix table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createTileMatrixTable;

/**
 *  Create a new tile table
 *
 *  @param table tile table
 */
-(void) createTileTable: (GPKGTileTable *) table;

/**
 *  Create a new tile table with GeoPackage metadata
 *
 *  @param tableName                table name
 *  @param contentsBoundingBox      Contents table bounding box
 *  @param contentsSrsId            Contents table Spatial Reference System Id
 *  @param tileMatrixSetBoundingBox Tile Matrix Set table bounding box
 *  @param tileMatrixSetSrsId       Tile Matrix Set table Spatial Reference System Id
 *
 *  @return Tile Matrix Set
 */
-(GPKGTileMatrixSet *) createTileTableWithTableName: (NSString *) tableName
                                                andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox
                                                andContentsSrsId: (NSNumber *) contentsSrsId
                                                andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox
                                                andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId;

/**
 *  Get a Data Columns DAO
 *
 *  @return Data Columns DAO
 */
-(GPKGDataColumnsDao *) getDataColumnsDao;

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
-(GPKGDataColumnConstraintsDao *) getDataColumnConstraintsDao;

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
-(GPKGMetadataDao *) getMetadataDao;

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
-(GPKGMetadataReferenceDao *) getMetadataReferenceDao;

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
-(GPKGExtensionsDao *) getExtensionsDao;

/**
 *  Create the Extensions table if it does not already exist
 *
 *  @return true if created
 */
-(BOOL) createExtensionsTable;

/**
 *  Delete the user table (a feature or tile table) and all GeoPackage metadata
 *
 *  @param tableName table name
 */
-(void) deleteUserTable: (NSString *) tableName;

/**
 *  Attempt to delete the user table (a feature or tile table) and all GeoPackage metadata quietly
 *
 *  @param tableName table name
 */
-(void) deleteUserTableQuietly: (NSString *) tableName;

/**
 * Get a Table Index DAO
 *
 * @return table index dao
 */
-(GPKGTableIndexDao *) getTableIndexDao;

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
-(GPKGGeometryIndexDao *) getGeometryIndexDao;

/**
 * Create Geometry Index Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createGeometryIndexTable;

/**
 * Get a Feature Tile Link DAO
 *
 * @return feature tile link dao
 */
-(GPKGFeatureTileLinkDao *) getFeatureTileLinkDao;

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
-(GPKGFeatureDao *) getFeatureDaoWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

/**
 *  Get a Feature DAO from Contents
 *
 *  @param contents Contents
 *
 *  @return Feature DAO
 */
-(GPKGFeatureDao *) getFeatureDaoWithContents: (GPKGContents *) contents;

/**
 *  Get a Feature DAO from a table name
 *
 *  @param tableName table name
 *
 *  @return Feature DAO
 */
-(GPKGFeatureDao *) getFeatureDaoWithTableName: (NSString *) tableName;

/**
 *  Get a Tile DAO from Tile Matrix Set
 *
 *  @param tileMatrixSet Tile Matrix Set
 *
 *  @return Tile DAO
 */
-(GPKGTileDao *) getTileDaoWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Get a Tile DAO from Contents
 *
 *  @param contents Contents
 *
 *  @return Tile DAO
 */
-(GPKGTileDao *) getTileDaoWithContents: (GPKGContents *) contents;

/**
 *  Get a Tile DAO from a table name
 *
 *  @param tableName table name
 *
 *  @return Tile DAO
 */
-(GPKGTileDao *) getTileDaoWithTableName: (NSString *) tableName;

/**
 *  Execute the sql on the GeoPackage database
 *
 *  @param sql sql
 */
-(void) execSQL: (NSString *) sql;

/**
 *  Drop the table if it exists. Drops the table with the table name, not
 +	limited to GeoPackage specific tables.
 *
 *  @param table table to drop
 */
-(void) dropTable: (NSString *) table;

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

@end
