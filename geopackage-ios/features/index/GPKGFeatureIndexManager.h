//
//  GPKGFeatureIndexManager.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureIndexTypes.h"
#import "GPKGGeoPackage.h"
#import "GPKGFeatureTableIndex.h"
#import "GPKGFeatureIndexer.h"
#import "GPKGFeatureIndexResults.h"
#import "GPKGRTreeIndexTableDao.h"
#import "GPKGFeatureIndexLocation.h"

@class GPKGFeatureIndexLocation;

/**
 * Feature Index Manager to manage indexing of feature geometries in both Android metadata and
 * within a GeoPackage using the Geometry Index Extension
 */
@interface GPKGFeatureIndexManager : NSObject

/**
 *  Index location
 */
@property (nonatomic) enum GPKGFeatureIndexType indexLocation;

/**
 * When an exception occurs on a certain index, continue to other index
 * types to attempt to retrieve the value
 */
@property (nonatomic) BOOL continueOnError;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param featureTable feature table
 *
 *  @return new feature index manager
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureTable: (NSString *) featureTable;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param featureDao feature data access object
 *
 *  @return new feature index manager
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao;

/**
 *  Close the index connections
 */
-(void) close;

/**
 *  Get the feature DAO
 *
 *  @return feature DAO
 */
-(GPKGFeatureDao *) featureDao;

/**
 *  Get the feature table index, used to index inside the GeoPackage as an extension
 *
 *  @return feature table index
 */
-(GPKGFeatureTableIndex *) featureTableIndex;

/**
 *  Get the feature indexer, used to index in metadata tables
 *
 *  @return feature indexer
 */
-(GPKGFeatureIndexer *) featureIndexer;

/**
 *  Get the RTree Index Table DAO
 *
 *  @return RTree index table DAO
 */
-(GPKGRTreeIndexTableDao *) rTreeIndexTableDao;

/**
 * Get the ordered index query locations
 *
 * @return ordered index types
 */
-(NSArray *) indexLocationQueryOrder;

/**
 *  Prioritize the query location order.  The type is placed at the front of the query order,
 *  leaving the remaining locations in their current order.
 *
 *  @param featureIndexType feature index type
 */
-(void) prioritizeQueryLocationWithType: (enum GPKGFeatureIndexType) featureIndexType;

/**
 *  Prioritize the query location order.  All types are placed at the front of the query order
 *  in the order they are given. Omitting a location leaves it at it's current priority location.
 *
 *  @param featureIndexTypes array of feature index type names
 */
-(void) prioritizeQueryLocationWithTypes: (NSArray<NSString *> *) featureIndexTypes;

/**
 * Set the index location order, overriding all previously set types
 *
 * @param featureIndexTypes feature index types
 */
-(void) setIndexLocationOrderWithTypes: (NSArray *) featureIndexTypes;

/**
 *  Set the GeoPackage Progress
 *
 *  @param progress progress
 */
-(void) setProgress: (NSObject<GPKGProgress> *) progress;

/**
 *  Index the feature table if needed, using the set index location
 *
 *  @return count
 */
-(int) index;

/**
 * Index the feature tables if needed for the index types
 *
 * @param types feature index types
 * @return largest count of indexed features
 */
-(int) indexFeatureIndexTypes: (NSArray<NSString *> *) types;

/**
 *  Index the feature table if needed
 *
 *  @param type index location type
 *
 *  @return count
 */
-(int) indexWithFeatureIndexType: (enum GPKGFeatureIndexType) type;

/**
 *  Index the feature table, using the set index location
 *
 *  @param force true to force re-indexing
 *
 *  @return count
 */
-(int) indexWithForce: (BOOL) force;

/**
 * Index the feature tables for the index types
 *
 * @param force true to force re-indexing
 * @param types feature index types
 * @return largest count of indexed features
 */
-(int) indexWithForce: (BOOL) force andFeatureIndexTypes: (NSArray<NSString *> *) types;

/**
 *  Index the feature table
 *
 *  @param type  index location type
 *  @param force true to force re-indexing
 *
 *  @return count
 */
-(int) indexWithFeatureIndexType:(enum GPKGFeatureIndexType) type andForce: (BOOL) force;

/**
 *  Index the feature row, using the set index location.
 *  This method assumes that indexing has been completed and
 *  maintained as the last indexed time is updated.
 *
 *  @param row feature row to index
 *
 *  @return true if indexed
 */
-(BOOL) indexWithFeatureRow: (GPKGFeatureRow *) row;

/**
 * Index the feature row for the index types.
 * This method assumes that indexing has been completed and
 * maintained as the last indexed time is updated.
 *
 * @param row   feature row to index
 * @param types feature index types
 * @return true if indexed from any type
 */
-(BOOL) indexWithFeatureRow: (GPKGFeatureRow *) row andFeatureIndexTypes: (NSArray<NSString *> *) types;

/**
 *  Index the feature row. This method assumes that indexing has been completed and
 *  maintained as the last indexed time is updated.
 *
 *  @param type index location type
 *  @param row  feature row to index
 *
 *  @return true if indexed
 */
-(BOOL) indexWithFeatureIndexType:(enum GPKGFeatureIndexType) type andFeatureRow: (GPKGFeatureRow *) row;

/**
 *  Delete the feature index
 *
 *  @return true if deleted
 */
-(BOOL) deleteIndex;

/**
 * Delete the feature index from all query order locations
 *
 * @return true if deleted
 */
-(BOOL) deleteAllIndexes;

/**
 * Delete the feature index from the index types
 *
 * @param types feature index types
 * @return true if deleted from any type
 */
-(BOOL) deleteIndexWithFeatureIndexTypes: (NSArray<NSString *> *) types;

/**
 *  Delete the feature index
 *
 *  @param type index location type
 *
 *  @return true if deleted
 */
-(BOOL) deleteIndexWithFeatureIndexType:(enum GPKGFeatureIndexType) type;

/**
 *  Delete the feature index for the feature row
 *
 *  @param row feature row
 *
 *  @return true if deleted
 */
-(BOOL) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row;

/**
 * Delete the feature index for the feature row from the index types
 *
 * @param row   feature row
 * @param types feature index types
 * @return true if deleted from any type
 */
-(BOOL) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row andFeatureIndexTypes: (NSArray<NSString *> *) types;

/**
 *  Delete the feature index for the feature row
 *
 *  @param type index location type
 *  @param row  feature row
 *
 *  @return true if deleted
 */
-(BOOL) deleteIndexWithFeatureIndexType: (enum GPKGFeatureIndexType) type andFeatureRow: (GPKGFeatureRow *) row;

/**
 *  Delete the feature index for the geometry id
 *
 *  @param geomId geometry id
 *
 *  @return true if deleted
 */
-(BOOL) deleteIndexWithGeomId: (int) geomId;

/**
 * Delete the feature index for the geometry id from the index types
 *
 * @param geomId geometry id
 * @param types  feature index types
 * @return true if deleted from any type
 */
-(BOOL) deleteIndexWithGeomId: (int) geomId andFeatureIndexTypes: (NSArray<NSString *> *) types;

/**
 *  Delete the feature index for the geometry id
 *
 *  @param type   index location type
 *  @param geomId geometry id
 *
 *  @return true if deleted
 */
-(BOOL) deleteIndexWithFeatureIndexType: (enum GPKGFeatureIndexType) type andGeomId: (int) geomId;

/**
 * Retain the feature index from the index types and delete the others
 *
 * @param type feature index type to retain
 * @return true if deleted from any type
 */
-(BOOL) retainIndexWithFeatureIndexType: (enum GPKGFeatureIndexType) type;

/**
 * Retain the feature index from the index types and delete the others
 *
 * @param types feature index types to retain
 * @return true if deleted from any type
 */
-(BOOL) retainIndexWithFeatureIndexTypes: (NSArray<NSString *> *) types;

/**
 * Get the indexed types that are currently indexed
 *
 * @return indexed types
 */
-(NSArray<NSString *> *) indexedTypes;

/**
 *  Determine if the feature table is indexed
 *
 *  @return true if indexed
 */
-(BOOL) isIndexed;

/**
 *  Is the feature table indexed in the provided type location
 *
 *  @param type index location type
 *
 *  @return true if indexed
 */
-(BOOL) isIndexedWithFeatureIndexType: (enum GPKGFeatureIndexType) type;

/**
 *  Get the date last indexed
 *
 *  @return last indexed date or null
 */
-(NSDate *) lastIndexed;

/**
 *  Get the date last indexed
 *
 *  @param type index location type
 *
 *  @return last indexed date or null
 */
-(NSDate *) lastIndexedWithFeatureIndexType: (enum GPKGFeatureIndexType) type;

/**
 *  Query for all feature index results
 *
 *  @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) query;

/**
 * Query for all feature index results
 *
 * @param columns columns
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns;

/**
 *  Query for all feature index count
 *
 *  @return count
 */
-(int) count;

/**
 * Query for feature index results
 *
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results
 *
 * @param columns     columns
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count
 *
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(int) countWithFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results
 *
 * @param where where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWhere: (NSString *) where;

/**
 * Query for feature index results
 *
 * @param columns columns
 * @param where   where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Query for feature index count
 *
 * @param where where clause
 * @return count
 */
-(int) countWhere: (NSString *) where;

/**
 * Query for feature index results
 *
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index results
 *
 * @param columns   columns
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature index results, close when done
 */
 -(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count
 *
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for the feature index bounds
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
 *  Query for feature index results within the bounding box, projected
 *  correctly
 *
 *  @param boundingBox bounding box
 *
 *  @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Query for feature index count within the bounding box, projected
 *  correctly
 *
 *  @param boundingBox bounding box
 *
 *  @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature index results, close when done
 */
 -(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Query for feature index results within the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 *  Query for feature index count within the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return count
 */
-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param columns     columns
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andGeometryEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return count
 */
-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return count
 */
-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param columns   columns
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Query for feature index results within the bounding box in
 *  the provided projection
 *
 *  @param boundingBox bounding box
 *  @param projection bounding box projection
 *
 *  @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 *  Query for feature index count within the bounding box in
 *  the provided projection
 *
 *  @param boundingBox bounding box
 *  @param projection bounding box projection
 *
 *  @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return feature index results, close when done
 */
 -(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Get a feature index location to iterate over indexed types
 *
 * @return feature index location
 */
-(GPKGFeatureIndexLocation *) location;

/**
 * Get the first ordered indexed type
 *
 * @return feature index type
 */
-(enum GPKGFeatureIndexType) indexedType;

@end
