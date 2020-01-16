//
//  GPKGFeatureTableIndex.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"
#import "GPKGFeatureDao.h"
#import "GPKGProgress.h"
#import "GPKGBaseExtension.h"

extern NSString * const GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR;
extern NSString * const GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR;
extern NSString * const GPKG_PROP_EXTENSION_GEOMETRY_INDEX_DEFINITION;

/**
 * Feature Table Index NGA Extension implementation. This extension is used to
 * index Geometries within a feature table by their minimum bounding box for
 * bounding box queries. This extension is required to provide an index
 * implementation when a SQLite version is used before SpatialLite support
 * (iOS).
 */
@interface GPKGFeatureTableIndex : GPKGBaseExtension

/**
 *  Progress
 */
@property (nonatomic, strong) NSObject<GPKGProgress> *progress;

/**
 *  Query single chunk limit
 */
@property (nonatomic) int chunkLimit;

/**
 *  Query range tolerance
 */
@property (nonatomic) double tolerance;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param featureDao feature data access object
 *
 *  @return new feature table index
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao;

/**
 *  Get the Feature DAO
 *
 *  @return feature dao
 */
-(GPKGFeatureDao *) featureDao;

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
 *  Get the feature projection
 *
 *  @return projection
 */
-(SFPProjection *) projection;

/**
 *  Get the table name
 *
 *  @return table name
 */
-(NSString *) tableName;

/**
 *  Get the column name
 *
 *  @return column name
 */
-(NSString *) columnName;

/**
 * Close the table index
 */
-(void) close;

/**
 *  Index the feature table if needed
 *
 *  @return count
 */
-(int) index;

/**
 *  Index the feature table
 *
 *  @param force true to force re-indexing
 *
 *  @return count
 */
-(int) indexWithForce: (BOOL) force;

/**
 * Index the feature row. This method assumes that indexing has been
 * completed and maintained as the last indexed time is updated.
 *
 * @param row feature row
 * @return true if indexed
 */
-(BOOL) indexFeatureRow: (GPKGFeatureRow *) row;

/**
 *  Delete the feature table index
 *
 *  @return true if index deleted
 */
-(BOOL) deleteIndex;

/**
 *  Delete the index for the geometry id
 *
 *  @param geomId geometry id
 *
 *  @return deleted rows, should be 0 or 1
 */
-(int) deleteIndexWithGeomId: (int) geomId;

/**
 * Delete the index for the feature row
 *
 * @param row feature row
 * @return deleted rows, should be 0 or 1
 */
-(int) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row;

/**
 *  Determine if the feature table is indexed
 *
 *  @return true if indexed
 */
-(BOOL) isIndexed;

/**
 *  Get the table index
 *
 *  @return table index
 */
-(GPKGTableIndex *) tableIndex;

/**
 *  Get the date last indexed
 *
 *  @return last indexed date or null
 */
-(NSDate *) lastIndexed;

/**
 *  Get the extension
 *
 *  @return extensions object or null if one does not exist
 */
-(GPKGExtensions *) extension;

/**
 *  Query for all Geometry Index objects
 *
 *  @return geometry indices result set
 */
-(GPKGResultSet *) query;

/**
 * Query SQL for all row ids
 *
 * @return SQL
 */
-(NSString *) queryIdsSQL;

/**
 *  Query for all Geometry Index count
 *
 *  @return count
 */
-(int) count;

/**
 * Query for the bounds of the feature table index
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBox;

/**
 * Query for the feature index bounds and return in the provided projection
 *
 * @param projection
 *            desired projection
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection;

/**
 *  Query for Geometry Index objects within the bounding box, projected
 *  correctly
 *
 *  @param boundingBox bounding box
 *
 *  @return geometry indices result set
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for Geometry Index objects within the bounding box, projected
 * correctly
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection of the provided bounding box
 * @return geometry indices iterator
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 *  Query for Geometry Index count within the bounding box, projected
 *  correctly
 *
 *  @param boundingBox bounding box
 *
 *  @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for Geometry Index count within the bounding box, projected
 * correctly
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection of the provided bounding box
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 *  Query for Geometry Index objects within the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return geometry indices result set
 */
-(GPKGResultSet *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 *  Build where clause for the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return where clause
 */
-(NSString *) whereWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 *  Build where clause arguments for the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return where clause arguments
 */
-(NSArray *) whereArgsWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query SQL for all row ids
 *
 * @param envelope
 *            geometry envelope
 * @return SQL
 */
-(NSString *) queryIdsSQLWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 *  Query for Geometry Index count within the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return count
 */
-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Get the Geometry Index for the current place in the cursor
 *
 * @param resultSet result set
 * @return geometry index
 */
-(GPKGGeometryIndex *) geometryIndexWithResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the feature row for the current place in the cursor
 *
 * @param resultSet result set
 * @return feature row
 */
-(GPKGFeatureRow *) featureRowWithResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the feature row for the Geometry Index
 *
 * @param geometryIndex geometry index
 * @return feature row
 */
-(GPKGFeatureRow *) featureRowWithGeometryIndex: (GPKGGeometryIndex *) geometryIndex;

/**
 * Build SQL for selecting ids from the query builder
 *
 * @param where where clause
 * @param args   where args
 * @return SQL
 */
-(NSString *) queryIdsSQLWhere: (NSString *) where;

@end
