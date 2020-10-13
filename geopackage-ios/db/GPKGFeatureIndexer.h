//
//  GPKGFeatureIndexer.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/29/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureDao.h"
#import "GPKGProgress.h"
#import "GPKGGeometryMetadata.h"
#import "GPKGMetadataDb.h"

/**
 *  Feature Indexer, indexes feature geometries into a table for searching
 */
@interface GPKGFeatureIndexer : NSObject

/**
 *  Feature DAO
 */
@property (nonatomic, strong) GPKGFeatureDao *featureDao;

/**
 *  Progress callbacks
 */
@property (nonatomic, strong) NSObject<GPKGProgress> *progress;

/**
 *  Query single chunk limit
 */
@property (nonatomic) int chunkLimit;

/**
 *  Initialize
 *
 *  @param featureDao feature DAO
 *
 *  @return new feature indexer
 */
-(instancetype)initWithFeatureDao:(GPKGFeatureDao *) featureDao;

/**
 *  Close the database connection in the feature indexer
 */
-(void) close;

/**
 *  Index the feature table if needed
 *
 *  @return indexed count
 */
-(int) index;

/**
 *  Index the feature table
 *
 *  @param force true to force re-indexing
 *
 *  @return indexed count
 */
-(int) indexWithForce: (BOOL) force;

/**
 *  Index the feature row. This method assumes that indexing has been completed and
 *  maintained as the last indexed time is updated.
 *
 *  @param row feature row
 */
-(BOOL) indexFeatureRow: (GPKGFeatureRow *) row;

/**
 * Delete the feature table index
 *
 * @return true if index deleted
 */
-(BOOL) deleteIndex;

/**
 * Delete the index for the feature row
 *
 * @param row feature row
 * @return true if deleted
 */
-(BOOL) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row;

/**
 * Delete the index for the geometry id
 *
 * @param geomId geometry id
 * @return true if deleted
 */
-(BOOL) deleteIndexWithGeomId: (NSNumber *) geomId;

/**
 *  Determine if the database table is indexed after database modifications
 *
 *  @return true if indexed, false if not
 */
-(BOOL) isIndexed;

/**
 * Get the date last indexed
 *
 * @return last indexed date or null
 */
-(NSDate *) lastIndexed;

/**
 * Query for all Geometry Metadata
 *
 * @return geometry metadata results
 */
-(GPKGResultSet *) query;

/**
 * Query for all Geometry Metadata
 *
 * @param columns columns
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns;

/**
 * Query for all Geometry Metadata ids
 *
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryIds;

/**
 * Query for all Geometry Metadata count
 *
 * @return count
 */
-(int) count;

/**
 * Query for all features
 *
 * @return feature results
 */
-(GPKGResultSet *) queryFeatures;

/**
 * Query for all features
 *
 * @param distinct distinct rows
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct;

/**
 * Query for all features
 *
 * @param columns columns
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns;

/**
 * Query for all features
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns;

/**
 * Count features
 *
 * @return count
 */
-(int) countFeatures;

/**
 * Count features
 *
 * @param column count column name
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column;

/**
 * Count features
 *
 * @param distinct distinct column values
 * @param column   count column name
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column;

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
 * @param distinct    distinct rows
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features
 *
 * @param columns     columns
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count features
 *
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count features
 *
 * @param column      count column name
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count features
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues;

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
 * @param distinct distinct rows
 * @param where    where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andWhere: (NSString *) where;

/**
 * Query for features
 *
 * @param columns columns
 * @param where   where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Query for features
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param where    where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Count features
 *
 * @param where where clause
 * @return count
 */
-(int) countFeaturesWhere: (NSString *) where;

/**
 * Count features
 *
 * @param column count column name
 * @param where  where clause
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andWhere: (NSString *) where;

/**
 * Count features
 *
 * @param distinct distinct column values
 * @param column   count column name
 * @param where    where clause
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where;

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
 * @param distinct  distinct rows
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
 * Query for features
 *
 * @param distinct  distinct rows
 * @param columns   columns
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count features
 *
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countFeaturesWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count features
 *
 * @param column    count column name
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count features
 *
 * @param distinct  distinct column values
 * @param column    count column name
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for the bounds of the feature table index
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBox;

/**
 * Query for the feature index bounds and return in the provided projection
 *
 * @param projection desired projection
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection;

/**
 * Query for Geometry Metadata within the bounding box, projected
 * correctly
 *
 * @param boundingBox bounding box
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for Geometry Metadata within the bounding box, projected
 * correctly
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for Geometry Metadata ids within the bounding box, projected
 * correctly
 *
 * @param boundingBox bounding box
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryIdsWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for Geometry Metadata count within the bounding box, projected
 * correctly
 *
 * @param boundingBox bounding box
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for features within the bounding box
 *
 * @param boundingBox bounding box
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for features within the bounding box
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for features within the bounding box
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for features within the bounding box
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Count the features within the bounding box
 *
 * @param boundingBox bounding box
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Count the features within the bounding box
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Count the features within the bounding box
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for features within the bounding box
 *
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the bounding box
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the bounding box
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the bounding box
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the bounding box
 *
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the bounding box
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the bounding box
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the bounding box
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Query for features within the bounding box
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Query for features within the bounding box
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Query for features within the bounding box
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Count the features within the bounding box
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Count the features within the bounding box
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @param where       where clause
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Count the features within the bounding box
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @param where       where clause
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Query for features within the bounding box
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features within the bounding box
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features within the bounding box
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features within the bounding box
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the features within the bounding box
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the features within the bounding box
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the features within the bounding box
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for Geometry Metadata within the bounding box in
 * the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for Geometry Metadata within the bounding box in
 * the provided projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for Geometry Metadata ids within the bounding box in
 * the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryIdsWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for Geometry Metadata count within the bounding box in
 * the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection of the provided bounding box
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
  * Query for features within the bounding box in the provided projection
  *
  * @param boundingBox bounding box
  * @param projection  projection
  * @return feature results
  */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for features within the bounding box in the provided projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

 /**
  * Query for features within the bounding box in the provided projection
  *
  * @param columns     columns
  * @param boundingBox bounding box
  * @param projection  projection
  * @return feature results
  */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for features within the bounding box in the provided projection
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

 /**
  * Count the features within the bounding box in the provided projection
  *
  * @param boundingBox bounding box
  * @param projection  projection
  * @return count
  */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Count the features within the bounding box in the provided projection
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Count the features within the bounding box in the provided projection
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

 /**
  * Query for features within the bounding box in the provided projection
  *
  * @param boundingBox bounding box
  * @param projection  projection
  * @param fieldValues field values
  * @return feature results
  */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the bounding box in the provided projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

 /**
  * Query for features within the bounding box in the provided projection
  *
  * @param columns     columns
  * @param boundingBox bounding box
  * @param projection  projection
  * @param fieldValues field values
  * @return feature results
  */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the bounding box in the provided projection
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

 /**
  * Count the features within the bounding box in the provided projection
  *
  * @param boundingBox bounding box
  * @param projection  projection
  * @param fieldValues field values
  * @return count
  */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the bounding box in the provided projection
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the bounding box in the provided projection
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

 /**
  * Query for features within the bounding box in the provided projection
  *
  * @param boundingBox bounding box
  * @param projection  projection
  * @param where       where clause
  * @return feature results
  */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Query for features within the bounding box in the provided projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

 /**
  * Query for features within the bounding box in the provided projection
  *
  * @param columns     columns
  * @param boundingBox bounding box
  * @param projection  projection
  * @param where       where clause
  * @return feature results
  */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Query for features within the bounding box in the provided projection
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

 /**
  * Count the features within the bounding box in the provided projection
  *
  * @param boundingBox bounding box
  * @param projection  projection
  * @param where       where clause
  * @return count
  */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Count the features within the bounding box in the provided projection
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Count the features within the bounding box in the provided projection
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

 /**
  * Query for features within the bounding box in the provided projection
  *
  * @param boundingBox bounding box
  * @param projection  projection
  * @param where       where clause
  * @param whereArgs   where arguments
  * @return feature results
  */
-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features within the bounding box in the provided projection
 *
 * @param distinct    distinct column values
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

 /**
  * Query for features within the bounding box in the provided projection
  *
  * @param columns     columns
  * @param boundingBox bounding box
  * @param projection  projection
  * @param where       where clause
  * @param whereArgs   where arguments
  * @return feature results
  */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features within the bounding box in the provided projection
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

 /**
  * Count the features within the bounding box in the provided projection
  *
  * @param boundingBox bounding box
  * @param projection  projection
  * @param where       where clause
  * @param whereArgs   where arguments
  * @return count
  */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the features within the bounding box in the provided projection
 *
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the features within the bounding box in the provided projection
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for Geometry Metadata within the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for Geometry Metadata within the Geometry Envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for Geometry Metadata idswithin the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryIdsWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for Geometry Metadata count within the Geometry Envelope
 *
 * @param envelope geometry envelope
 * @return count
 */
-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for features within the geometry envelope
 *
 * @param envelope geometry envelope
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for features within the geometry envelope
 *
 * @param distinct distinct column values
 * @param envelope geometry envelope
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for features within the geometry envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for features within the geometry envelope
 *
 * @param distinct distinct column values
 * @param columns  columns
 * @param envelope geometry envelope
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Count the features within the geometry envelope
 *
 * @param envelope geometry envelope
 * @return count
 */
-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Count the features within the geometry envelope
 *
 * @param column   count column name
 * @param envelope geometry envelope
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Count the features within the geometry envelope
 *
 * @param distinct distinct column values
 * @param column   count column name
 * @param envelope geometry envelope
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for features within the geometry envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the geometry envelope
 *
 * @param distinct    distinct rows
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the geometry envelope
 *
 * @param columns     columns
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the geometry envelope
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the geometry envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the geometry envelope
 *
 * @param column      count column name
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the geometry envelope
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the geometry envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for features within the geometry envelope
 *
 * @param distinct distinct rows
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for features within the geometry envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for features within the geometry envelope
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Count the features within the geometry envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return count
 */
-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Count the features within the geometry envelope
 *
 * @param column   count column name
 * @param envelope geometry envelope
 * @param where    where clause
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Count the features within the geometry envelope
 *
 * @param distinct distinct column values
 * @param column   count column name
 * @param envelope geometry envelope
 * @param where    where clause
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Query for features within the geometry envelope
 *
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features within the geometry envelope
 *
 * @param distinct  distinct rows
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features within the geometry envelope
 *
 * @param columns   columns
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features within the geometry envelope
 *
 * @param distinct  distinct rows
 * @param columns   columns
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the features within the geometry envelope
 *
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the features within the geometry envelope
 *
 * @param column    count column name
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the features within the geometry envelope
 *
 * @param distinct  distinct column values
 * @param column    count column name
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Get the Geometry Metadata for the current place in the result set
 *
 * @param resultSet result set
 * @return geometry metadata
 */
-(GPKGGeometryMetadata *) geometryMetadataWithResultSet: (GPKGResultSet *) resultSet;

/**
* Get the Geometry Id for the current place in the result set
*
* @param resultSet result set
* @return geometry id
*/
-(NSNumber *) geometryIdWithResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the feature row for the current place in the result set
 *
 * @param resultSet result set
 * @return feature row
 */
-(GPKGFeatureRow *) featureRowWithResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the feature row for the Geometry Metadata
 *
 * @param geometryMetadata geometry metadata
 * @return feature row
 */
-(GPKGFeatureRow *) featureRowWithGeometryMetadata: (GPKGGeometryMetadata *) geometryMetadata;

/**
 * Get the query range tolerance
 *
 * @return tolerance
 */
-(double) tolerance;

/**
 * Set the query range tolerance
 *
 * @param tolerance query range tolerance
 */
-(void) setTolerance: (double) tolerance;

@end
