//
//  GPKGFeatureIndexManager.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexTypes.h"
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
 * Index geometries using geodesic lines
 */
@property (nonatomic) BOOL geodesic;

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
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param featureTable feature table
 *  @param geodesic     index using geodesic bounds
 *
 *  @return new feature index manager
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureTable: (NSString *) featureTable andGeodesic: (BOOL) geodesic;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param featureDao feature data access object
 *  @param geodesic     index using geodesic bounds
 *
 *  @return new feature index manager
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao andGeodesic: (BOOL) geodesic;

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

/**
 * Get the feature table id column name, the default column ordering
 *
 * @return feature table id column name
 */
-(NSString *) idColumn;

/**
 *  Query for all feature index results
 *
 *  @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) query;

/**
 * Query for all feature index results
 *
 * @param distinct distinct rows
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct;

/**
 * Query for all feature index results
 *
 * @param columns columns
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns;

/**
 * Query for all feature index results
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns;

/**
 * Query for all feature index count
 *
 * @param column count column name
 * @return count
 */
-(int) countWithColumn: (NSString *) column;

/**
 * Query for all feature index count
 *
 * @param distinct distinct column values
 * @param column   count column name
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column;

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
 * @param distinct    distinct rows
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results
 *
 * @param columns     columns
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count
 *
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(int) countWithFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count
 *
 * @param column      count column name
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(int) countWithColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues;

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
 * @param distinct distinct rows
 * @param where    where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andWhere: (NSString *) where;

/**
 * Query for feature index results
 *
 * @param columns columns
 * @param where   where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Query for feature index results
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param where    where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Query for feature index count
 *
 * @param where where clause
 * @return count
 */
-(int) countWhere: (NSString *) where;

/**
 * Query for feature index count
 *
 * @param column count column name
 * @param where  where clause
 * @return count
 */
-(int) countWithColumn: (NSString *) column andWhere: (NSString *) where;

/**
 * Query for feature index count
 *
 * @param distinct distinct column values
 * @param column   count column name
 * @param where    where clause
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where;

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
 * @param distinct  distinct rows
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
 * Query for feature index results
 *
 * @param distinct  distinct rows
 * @param columns   columns
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count
 *
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count
 *
 * @param column    count column name
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWithColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count
 *
 * @param distinct  distinct column values
 * @param column    count column name
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
-(GPKGBoundingBox *) boundingBoxInProjection: (PROJProjection *) projection;

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
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox;

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
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

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
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @return count
 */
-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox;

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
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

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
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

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
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param column      column name
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return count
 */
-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param column      column name
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

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
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

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
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

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
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param column      column name
 * @param boundingBox bounding box
 * @param where       where clause
 * @return count
 */
-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param distinct    distinct column values
 * @param column      column name
 * @param boundingBox bounding box
 * @param where       where clause
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

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
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
 * Query for feature index results within the bounding box, projected
 * correctly
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param column      count column value
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count within the bounding box, projected
 * correctly
 *
 * @param distinct    distinct column values
 * @param column      count column value
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Query for feature index results within the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param distinct distinct rows
 * @param envelope geometry envelope
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param envelope geometry envelope
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 *  Query for feature index count within the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return count
 */
-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param column   count column name
 * @param envelope geometry envelope
 * @return count
 */
-(int) countWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param distinct distinct column values
 * @param column   count column name
 * @param envelope geometry envelope
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param distinct    distinct rows
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param columns     columns
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return count
 */
-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param column      count column name
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return count
 */
-(int) countWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param distinct distinct rows
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return count
 */
-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param column   count column name
 * @param envelope geometry envelope
 * @param where    where clause
 * @return count
 */
-(int) countWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param distinct distinct column values
 * @param column   count column name
 * @param envelope geometry envelope
 * @param where    where clause
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param distinct  distinct rows
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param columns   columns
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index results within the Geometry Envelope
 *
 * @param distinct  distinct rows
 * @param columns   columns
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param column    count column name
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count within the Geometry Envelope
 *
 * @param distinct  distinct column values
 * @param column    count column name
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Query for feature index results within the bounding box in
 *  the provided projection
 *
 *  @param boundingBox bounding box
 *  @param projection bounding box projection
 *
 *  @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

/**
 *  Query for feature index count within the bounding box in
 *  the provided projection
 *
 *  @param boundingBox bounding box
 *  @param projection bounding box projection
 *
 *  @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @return count
 */
-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

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
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param column      count column value
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return count
 */
-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct column values
 * @param column      count column value
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where;

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
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return count
 */
-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where;

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
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index results within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for feature index count within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Determine if the results are paginated
 *
 * @param results
 *            query results
 * @return true if paginated
 */
+(BOOL) isPaginated: (GPKGFeatureIndexResults *) results;

/**
 * Paginate the results
 *
 * @param results
 *            feature index results
 * @return feature paginated results
 */
-(GPKGRowPaginatedResults *) paginate: (GPKGFeatureIndexResults *) results;

/**
 * Paginate the results
 *
 * @param results
 *            feature index results
 * @param dao
 *            feature DAO
 * @return feature paginated results
 */
+(GPKGRowPaginatedResults *) paginate: (GPKGFeatureIndexResults *) results withDao: (GPKGFeatureDao *) dao;

/**
 * Query for all feature index results ordered by id, starting at the offset
 * and returning no more than the limit
 *
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithLimit: (int) limit;

/**
 * Query for all feature index results ordered by id, starting at the offset
 * and returning no more than the limit
 *
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithLimit: (int) limit andOffset: (int) offset;

/**
 * Query for all feature index results, starting at the offset and returning
 * no more than the limit
 *
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for all feature index results, starting at the offset and returning
 * no more than the limit
 *
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for all feature index results ordered by id, starting at the offset
 * and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andLimit: (int) limit;

/**
 * Query for all feature index results ordered by id, starting at the offset
 * and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for all feature index results, starting at the offset and returning
 * no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for all feature index results, starting at the offset and returning
 * no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for all feature index results ordered by id, starting at the offset
 * and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andLimit: (int) limit;

/**
 * Query for all feature index results ordered by id, starting at the offset
 * and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for all feature index results, starting at the offset and returning
 * no more than the limit
 *
 * @param columns
 *            columns
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for all feature index results, starting at the offset and returning
 * no more than the limit
 *
 * @param columns
 *            columns
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for all feature index results ordered by id, starting at the offset
 * and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andLimit: (int) limit;

/**
 * Query for all feature index results ordered by id, starting at the offset
 * and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for all feature index results, starting at the offset and returning
 * no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for all feature index results, starting at the offset and returning
 * no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id, starting at the offset and
 * returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results, starting at the offset and returning no
 * more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 *
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param boundingBox
 *            bounding box
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param boundingBox
 *            bounding box
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box,
 * projected correctly, starting at the offset and returning no more than
 * the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box, projected
 * correctly, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the Geometry
 * Envelope, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the Geometry Envelope, starting at
 * the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param envelope
 *            geometry envelope
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param fieldValues
 *            field values
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit;

/**
 * Query for feature index results ordered by id within the bounding box in
 * the provided projection, starting at the offset and returning no more
 * than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit;

/**
 * Query for feature index results within the bounding box in the provided
 * projection, starting at the offset and returning no more than the limit
 *
 * @param distinct
 *            distinct rows
 * @param columns
 *            columns
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @param where
 *            where clause
 * @param whereArgs
 *            where arguments
 * @param orderBy
 *            order by
 * @param limit
 *            chunk limit
 * @param offset
 *            chunk query offset
 * @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset;

@end
