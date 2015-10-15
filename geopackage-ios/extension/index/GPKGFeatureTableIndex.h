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
@interface GPKGFeatureTableIndex : NSObject

/**
 *  Progress
 */
@property (nonatomic, strong) NSObject<GPKGProgress> * progress;

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
 *  Get the GeoPackage
 *
 *  @return GeoPackage
 */
-(GPKGGeoPackage *) getGeoPackage;

/**
 *  Get the Feature DAO
 *
 *  @return feature dao
 */
-(GPKGFeatureDao *) getFeatureDao;

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
 *  Get the table name
 *
 *  @return table name
 */
-(NSString *) getTableName;

/**
 *  Get the column name
 *
 *  @return column name
 */
-(NSString *) getColumnName;

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
 * @param row
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
 * @param row
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
-(GPKGTableIndex *) getTableIndex;

/**
 *  Get the date last indexed
 *
 *  @return last indexed date or null
 */
-(NSDate *) getLastIndexed;

/**
 *  Get the extension
 *
 *  @return extensions object or null if one does not exist
 */
-(GPKGExtensions *) getExtension;

/**
 *  Query for all Geometry Index objects
 *
 *  @return geometry indices result set
 */
-(GPKGResultSet *) query;

/**
 *  Query for all Geometry Index count
 *
 *  @return count
 */
-(int) count;

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
 *  Query for Geometry Index count within the bounding box, projected
 *  correctly
 *
 *  @param boundingBox bounding box
 *
 *  @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Query for Geometry Index objects within the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return geometry indices result set
 */
-(GPKGResultSet *) queryWithGeometryEnvelope: (WKBGeometryEnvelope *) envelope;

/**
 *  Query for Geometry Index count within the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return count
 */
-(int) countWithGeometryEnvelope: (WKBGeometryEnvelope *) envelope;

/**
 * Query for Geometry Index objects within the bounding box in
 * the provided projection
 *
 * @param boundingBox
 * @param projection  projection of the provided bounding box
 * @return geometry indices result set
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection;

/**
 * Query for Geometry Index count within the bounding box in
 * the provided projection
 *
 * @param boundingBox
 * @param projection  projection of the provided bounding box
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection;

/**
 * Get the Geometry Index for the current place in the cursor
 *
 * @param resultSet
 * @return geometry index
 */
-(GPKGGeometryIndex *) getGeometryIndexWithResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the feature row for the current place in the cursor
 *
 * @param resultSet
 * @return feature row
 */
-(GPKGFeatureRow *) getFeatureRowWithResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the feature row for the Geometry Index
 *
 * @param geometryIndex
 * @return feature row
 */
-(GPKGFeatureRow *) getFeatureRowWithGeometryIndex: (GPKGGeometryIndex *) geometryIndex;


@end
