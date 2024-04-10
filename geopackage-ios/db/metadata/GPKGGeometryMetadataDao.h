//
//  GPKGGeometryMetadataDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGGeometryMetadata.h"

/**
 * Geometry Metadata Data Access Object
 */
@interface GPKGGeometryMetadataDao : GPKGBaseDao

/**
 *  Query range tolerance
 */
@property (nonatomic) double tolerance;

/**
 * Index geometries using geodesic lines
 */
@property (nonatomic) BOOL geodesic;

/**
 * Features projection
 */
@property (nonatomic, strong) PROJProjection *projection;

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new Geometry Metadata DAO
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Initialize
 *
 *  @param database database connection
 *  @param geodesic index geodesic geometries flag
 *  @param projection feature projection
 *
 *  @return new Geometry Metadata DAO
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database andGeodesic: (BOOL) geodesic andProjection: (PROJProjection *) projection;

/**
 *  Create geometry metadata
 *
 *  @param geoPackageName GeoPackage name
 *  @param tableName      table name
 *  @param geomId         Geometry id
 *  @param envelope       Geometry Envelope
 *
 *  @return geometry metadata
 */
-(GPKGGeometryMetadata *) createMetadataWithGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andId: (NSNumber *) geomId andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 *  Create geometry metadata
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *  @param geomId       Geometry id
 *  @param envelope     Geometry Envelope
 *
 *  @return geometry metadata
 */
-(GPKGGeometryMetadata *) createMetadataWithGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) geomId andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 *  Populate geometry metadata
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *  @param geomId       Geometry id
 *  @param envelope     Geometry Envelope
 *
 *  @return geometry metadata
 */
-(GPKGGeometryMetadata *) populateMetadataWithGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) geomId andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 *  Delete geometry metadata
 *
 *  @param metadata metadata
 *
 *  @return true if deleted
 */
-(BOOL) deleteMetadata: (GPKGGeometryMetadata *) metadata;

/**
 *  Delete geometry metadata by name
 *
 *  @param name geometry metadata name
 *
 *  @return true if deleted
 */
-(BOOL) deleteByGeoPackageName: (NSString *) name;

/**
 *  Delete geometry metadata by GeoPackage id
 *
 *  @param geoPackageId GeoPackage id
 *
 *  @return true if deleted
 */
-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId;

/**
 *  Delete geometry metadata by GeoPackage name and table name
 *
 *  @param name      GeoPackage name
 *  @param tableName table name
 *
 *  @return true if deleted
 */
-(BOOL) deleteByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName;

/**
 *  Delete geometry metadata by GeoPackage id and table name
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *
 *  @return true if deleted
 */
-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

/**
 *  Delete geometry metadata by GeoPackage name, table name, and geometry id
 *
 *  @param name      GeoPackage name
 *  @param tableName table name
 *  @param geomId    geometry id
 *
 *  @return true if deleted
 */
-(BOOL) deleteByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName andId: (NSNumber *) geomId;

/**
 *  Delete geometry metadata by GeoPackage id, table name, and geometry id
 *
 *  @param geoPackageId      GeoPackage id
 *  @param tableName table name
 *  @param geomId    geometry id
 *
 *  @return true if deleted
 */
-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) geomId;

/**
 *  Create of update geometry metadata
 *
 *  @param metadata geometry metadata
 *
 *  @return true if created or updated
 */
-(BOOL) createOrUpdateMetadata: (GPKGGeometryMetadata *) metadata;

/**
 *  Update geometry metadata
 *
 *  @param metadata geometry metadata
 *
 *  @return true if updated
 */
-(BOOL) updateMetadata: (GPKGGeometryMetadata *) metadata;

/**
 *  Check if geometry metadata exists
 *
 *  @param metadata geometry metadata
 *
 *  @return true if exists
 */
-(BOOL) existsByMetadata: (GPKGGeometryMetadata *) metadata;

/**
 *  Get geometry metadata by metadata
 *
 *  @param metadata geometry metadata
 *
 *  @return geometry metadata
 */
-(GPKGGeometryMetadata *) metadataByMetadata: (GPKGGeometryMetadata *) metadata;

/**
 *  Get geometry metadata by GeoPackage name, table name, and id
 *
 *  @param geoPackageName GeoPackage name
 *  @param tableName      table name
 *  @param id             id
 *
 *  @return geometry metadata
 */
-(GPKGGeometryMetadata *) metadataByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andId: (NSNumber *) id;

/**
 *  Get geometry metadata by GeoPackage id, table name, and id
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *  @param id           id
 *
 *  @return geometry metadata
 */
-(GPKGGeometryMetadata *) metadataByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) id;

/**
 *  Query for geometry metadata
 *
 *  @param geoPackageName GeoPackage name
 *  @param tableName      table name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName;

/**
 * Query for all table geometry metadata geometry ids
 *
 * @param geoPackageName GeoPackage name
 * @param tableName  table name
 * @return result set
 */
-(GPKGResultSet *) queryIdsByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName;

/**
 * Query for all table geometry metadata
 *
 * @param geoPackageName GeoPackage name
 * @param tableName  table name
 * @param columns    queried columns
 * @return result set
 */
-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andColumns: (NSArray<NSString *> *) columns;

/**
 *  Query for geometry metadata count
 *
 *  @param geoPackageName GeoPackage name
 *  @param tableName      table name
 *
 *  @return count
 */
-(int) countByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName;

/**
 * Query for the bounds of the feature table index
 *
 * @param geoPackageName GeoPackage name
 * @param tableName  table name
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName;

/**
 * Query for the bounds of the feature table index
 *
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

/**
 *  Query for geometry metadata
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

/**
 * Query for all table geometry metadata geometry ids
 *
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @return result set
 */
-(GPKGResultSet *) queryIdsByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

/**
 * Query for all table geometry metadata
 *
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @param columns      queried columns
 * @return result set
 */
-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andColumns: (NSArray<NSString *> *) columns;

/**
 *  Query for geometry metadata count
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *
 *  @return count
 */
-(int) countByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

/**
 * Get the query SQL for a GeoPackage id and table name
 *
 * @return SQL
 */
-(NSString *) querySQL;

/**
 * Get the query SQL args for a GeoPackage id and table name
 *
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @return SQL args
 */
-(NSArray *) querySQLArgsWithGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

/**
 *  Query for all geometry metadata matching the bounding box in the same projection
 *
 *  @param geoPackageName GeoPackage name
 *  @param tableName      table name
 *  @param boundingBox    bounding box
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for all table geometry metadata ids matching the bounding box in the same projection
 *
 * @param geoPackageName  GeoPackage name
 * @param tableName   table name
 * @param boundingBox bounding box
 * @return result set
 */
-(GPKGResultSet *) queryIdsByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for all table geometry metadata matching the bounding box in the same projection
 *
 * @param geoPackageName  GeoPackage name
 * @param tableName   table name
 * @param columns     queried columns
 * @param boundingBox bounding box
 * @return result set
 */
-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Query for all geometry metadata count matching the bounding box in the same projection
 *
 *  @param geoPackageName GeoPackage name
 *  @param tableName      table name
 *  @param boundingBox    bounding box
 *
 *  @return count
 */
-(int) countByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Query for all geometry metadata matching the bounding box in the same projection
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *  @param boundingBox  bounding box
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for all table geometry metadata ids matching the bounding box in the same projection
 *
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @param boundingBox  bounding box
 * @return result set
 */
-(GPKGResultSet *) queryIdsByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for all table geometry metadata matching the bounding box in the same projection
 *
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @param columns      queried columns
 * @param boundingBox  bounding box
 * @return result set
 */
-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Query for all geometry metadata count matching the bounding box in the same projection
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *  @param boundingBox  bounding box
 *
 *  @return count
 */
-(int) countByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Query for all geometry metadata matching the envelope
 *
 *  @param geoPackageName GeoPackage name
 *  @param tableName      table name
 *  @param envelope       geometry envelope
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for all table geometry metadata ids matching the envelope
 *
 * @param geoPackageName GeoPackage name
 * @param tableName  table name
 * @param envelope   geometry envelope
 * @return result set
 */
-(GPKGResultSet *) queryIdsByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for all table geometry metadata matching the envelope
 *
 * @param geoPackageName GeoPackage name
 * @param tableName  table name
 * @param columns    queried columns
 * @param envelope   geometry envelope
 * @return result set
 */
-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 *  Query for all geometry metadata count matching the envelope
 *
 *  @param geoPackageName GeoPackage name
 *  @param tableName      table name
 *  @param envelope       geometry envelope
 *
 *  @return count
 */
-(int) countByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for all table geometry metadata matching the envelope
 *
 * @param geoPackageName GeoPackage name
 * @param tableName  table name
 * @param distinct   distinct flag
 * @param columns    queried columns
 * @param envelope   geometry envelope
 * @param orderBy    order by
 * @param limit      limit
 * @return result set
 */
-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (NSString *) limit;

/**
 *  Query for all geometry metadata matching the envelope
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *  @param envelope     geometry envelope
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for all table geometry metadata ids matching the envelope
 *
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @param envelope     geometry envelope
 * @return result set
 */
-(GPKGResultSet *) queryIdsByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for all table geometry metadata matching the envelope
 *
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @param columns      queried columns
 * @param envelope     geometry envelope
 * @return result set
 */
-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for all table geometry metadata count matching the envelope
 *
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @param envelope     geometry envelope
 * @return count
 */
-(int) countByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for all table geometry metadata matching the envelope
 *
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @param distinct     distinct flag
 * @param columns      queried columns
 * @param envelope     geometry envelope
 * @param orderBy      order by
 * @param limit        limit
 * @return result set
 */
-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (NSString *) limit;

/**
 * Get the query SQL for an envelope, GeoPackage id, and table name
 *
 * @param envelope geometry envelope
 * @return SQL
 */
-(NSString *) querySQLWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Get the query SQL args for an envelope, GeoPackage id, and table name
 *
 * @param envelope     geometry envelope
 * @param geoPackageId GeoPackage id
 * @param tableName    table name
 * @return SQL args
 */
-(NSArray *) querySQLArgsWithEnvelope: (SFGeometryEnvelope *) envelope andGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

/**
 *  Get GeoPackage id for the GeoPackage name
 *
 *  @param name GeoPackage name
 *
 *  @return GeoPackage id
 */
-(NSNumber *) geoPackageIdForGeoPackageName: (NSString *) name;

/**
 * Get the geometry metadata geometry id
 *
 * @param resultSet  result set
 * @return id
 */
+(NSNumber *) idWithResultSet: (GPKGResultSet *) resultSet;

@end
