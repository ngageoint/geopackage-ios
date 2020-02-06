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

/**
 * Query for all Features
 *
 * @return feature results
 */
-(GPKGResultSet *) queryFeatures;

/**
 * Query for all Features
 *
 * @param columns columns
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns;

/**
 * Query for features
 *
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features
 *
 * @param columns     columns
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count features
 *
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features
 *
 * @param where where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWhere: (NSString *) where;

/**
 * Query for features
 *
 * @param columns columns
 * @param where   where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Count features
 *
 * @param where where clause
 * @return count
 */
-(int) countFeaturesWhere: (NSString *) where;

/**
 * Query for features
 *
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features
 *
 * @param columns   columns
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count features
 *
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countFeaturesWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for Features within the bounding box, projected correctly
 *
 * @param boundingBox bounding box
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for Features within the bounding box, projected correctly
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Count the Features within the bounding box, projected correctly
 *
 * @param boundingBox bounding box
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for Features within the bounding box, projected correctly
 *
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for Features within the bounding box, projected correctly
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the Features within the bounding box, projected correctly
 *
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for Features within the bounding box, projected correctly
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Query for Features within the bounding box, projected correctly
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Count the Features within the bounding box, projected correctly
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Query for Features within the bounding box, projected correctly
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for Features within the bounding box, projected correctly
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
 -(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the Features within the bounding box, projected correctly
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for Features within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for Features within the bounding box in the provided projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @return feature results
 */
 -(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Count the Features within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for Features within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for Features within the bounding box in the provided projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the Features within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for Features within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Query for Features within the bounding box in the provided projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Count the Features within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @param where       where clause
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Query for Features within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for Features within the bounding box in the provided projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the Features within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for Features within the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for Features within the Geometry Envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @return feature results
 */
 -(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Count the Features within the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @return count
 */
-(int) countFeaturesWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for Features within the Geometry Envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for Features within the Geometry Envelope
 *
 * @param columns     columns
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature results
 */
 -(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andGeometryEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the Features within the Geometry Envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for Features within the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for Features within the Geometry Envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature results
 */
 -(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Count the Features within the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return count
 */
 -(int) countFeaturesWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for Features within the Geometry Envelope
 *
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for Features within the Geometry Envelope
 *
 * @param columns   columns
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the Features within the Geometry Envelope
 *
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countFeaturesWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

@end
