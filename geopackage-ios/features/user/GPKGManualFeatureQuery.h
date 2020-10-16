//
//  GPKGManualFeatureQuery.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/11/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureDao.h"
#import "GPKGManualFeatureQueryResults.h"

/**
 * Performs manual brute force queries against feature rows
 * See GPKGFeatureIndexManager for performing indexed queries.
 */
@interface GPKGManualFeatureQuery : NSObject

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
 *  @param featureDao feature DAO
 *
 *  @return new manual feature query
 */
-(instancetype)initWithFeatureDao:(GPKGFeatureDao *) featureDao;

/**
 * Get the feature DAO
 *
 * @return feature DAO
 */
-(GPKGFeatureDao *) featureDao;

/**
 * Query for features
 *
 * @return feature results
 */
-(GPKGResultSet *) query;

/**
 * Query for features
 *
 * @param distinct distinct rows
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct;

/**
 * Query for features
 *
 * @param columns columns
 * @return feature results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns;

/**
 * Query for features
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns;

/**
 * Get the count of features
 *
 * @return count
 */
-(int) count;

/**
 * Get the count of features with non null geometries
 *
 * @return count
 */
-(int) countWithGeometries;

/**
 * Get a count of results
 *
 * @param column count column name
 * @return count
 */
-(int) countWithColumn: (NSString *) column;

/**
 * Get a count of results
 *
 * @param distinct distinct column values
 * @param column   count column name
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column;

/**
 * Query for features
 *
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryWithFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features
 *
 * @param distinct    distinct rows
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features
 *
 * @param columns     columns
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count features
 *
 * @param fieldValues field values
 * @return count
 */
-(int) countWithFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count features
 *
 * @param column      count column name
 * @param fieldValues field values
 * @return count
 */
-(int) countWithColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count features
 *
 * @param distinct    distinct column values
 * @param column      count column name
 * @param fieldValues field values
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features
 *
 * @param where where clause
 * @return feature results
 */
-(GPKGResultSet *) queryWhere: (NSString *) where;

/**
 * Query for features
 *
 * @param distinct distinct rows
 * @param where    where clause
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andWhere: (NSString *) where;

/**
 * Query for features
 *
 * @param columns columns
 * @param where   where clause
 * @return feature results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Query for features
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param where    where clause
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where;

/**
 * Count features
 *
 * @param where where clause
 * @return count
 */
-(int) countWhere: (NSString *) where;

/**
 * Count features
 *
 * @param column count column name
 * @param where  where clause
 * @return count
 */
-(int) countWithColumn: (NSString *) column andWhere: (NSString *) where;

/**
 * Count features
 *
 * @param distinct distinct column values
 * @param column   count column name
 * @param where    where clause
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where;

/**
 * Query for features
 *
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features
 *
 * @param distinct  distinct rows
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features
 *
 * @param columns   columns
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features
 *
 * @param distinct  distinct rows
 * @param columns   columns
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count features
 *
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count features
 *
 * @param column    count column name
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWithColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count features
 *
 * @param distinct  distinct column values
 * @param column    count column name
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually build the bounds of the feature table
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBox;

/**
 * Manually build the bounds of the feature table in the provided projection
 *
 * @param projection
 *            desired projection
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection;

/**
 * Manually query for rows within the bounding box
 *
 * @param boundingBox
 *            bounding box
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Manually query for rows within the bounding box
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Manually query for rows within the bounding box
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Manually query for rows within the bounding box
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Manually count the rows within the bounding box
 *
 * @param boundingBox bounding box
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Manually query for rows within the bounding box
 *
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounding box
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounding box
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounding box
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually count the rows within the bounding box
 *
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounding box
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounding box
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param where       where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounding box
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounding box
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Manually count the rows within the bounding box
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounding box
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounding box
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounding box
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounding box
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually count the rows within the bounding box
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Manually count the rows within the bounding box in the provided
 * projection
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually count the rows within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Manually count the rows within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounding box in the provided
 * projection
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually count the rows within the bounding box in the provided
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
 * Manually query for rows within the geometry envelope
 *
 * @param envelope
 *            geometry envelope
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param distinct distinct rows
 * @param envelope geometry envelope
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param envelope geometry envelope
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Manually count the rows within the geometry envelope
 *
 * @param envelope
 *            geometry envelope
 * @return count
 */
-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param distinct    distinct rows
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param columns     columns
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually count the rows within the geometry envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return count
 */
-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param distinct distinct rows
 * @param envelope geometry envelope
 * @param where    where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @param where    where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param envelope geometry envelope
 * @param where    where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Manually count the rows within the geometry envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return count
 */
-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param distinct  distinct rows
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param columns   columns
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the geometry envelope
 *
 * @param distinct  distinct rows
 * @param columns   columns
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually count the rows within the geometry envelope
 *
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return count
 */
-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounds
 *
 * @param minX
 *            min x
 * @param minY
 *            min y
 * @param maxX
 *            max x
 * @param maxY
 *            max y
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Manually query for rows within the bounds
 *
 * @param distinct distinct rows
 * @param minX     min x
 * @param minY     min y
 * @param maxX     max x
 * @param maxY     max y
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Manually query for rows within the bounds
 *
 * @param columns columns
 * @param minX    min x
 * @param minY    min y
 * @param maxX    max x
 * @param maxY    max y
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Manually query for rows within the bounds
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param minX     min x
 * @param minY     min y
 * @param maxX     max x
 * @param maxY     max y
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Manually count the rows within the bounds
 *
 * @param minX
 *            min x
 * @param minY
 *            min y
 * @param maxX
 *            max x
 * @param maxY
 *            max y
 * @return count
 */
-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Manually query for rows within the bounds
 *
 * @param minX        min x
 * @param minY        min y
 * @param maxX        max x
 * @param maxY        max y
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounds
 *
 * @param distinct    distinct rows
 * @param minX        min x
 * @param minY        min y
 * @param maxX        max x
 * @param maxY        max y
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounds
 *
 * @param columns     columns
 * @param minX        min x
 * @param minY        min y
 * @param maxX        max x
 * @param maxY        max y
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounds
 *
 * @param distinct    distinct rows
 * @param columns     columns
 * @param minX        min x
 * @param minY        min y
 * @param maxX        max x
 * @param maxY        max y
 * @param fieldValues field values
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually count the rows within the bounds
 *
 * @param minX        min x
 * @param minY        min y
 * @param maxX        max x
 * @param maxY        max y
 * @param fieldValues field values
 * @return count
 */
-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Manually query for rows within the bounds
 *
 * @param minX  min x
 * @param minY  min y
 * @param maxX  max x
 * @param maxY  max y
 * @param where where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounds
 *
 * @param distinct distinct rows
 * @param minX     min x
 * @param minY     min y
 * @param maxX     max x
 * @param maxY     max y
 * @param where    where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounds
 *
 * @param columns columns
 * @param minX    min x
 * @param minY    min y
 * @param maxX    max x
 * @param maxY    max y
 * @param where   where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounds
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param minX     min x
 * @param minY     min y
 * @param maxX     max x
 * @param maxY     max y
 * @param where    where clause
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where;

/**
 * Manually count the rows within the bounds
 *
 * @param minX  min x
 * @param minY  min y
 * @param maxX  max x
 * @param maxY  max y
 * @param where where clause
 * @return count
 */
-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where;

/**
 * Manually query for rows within the bounds
 *
 * @param minX      min x
 * @param minY      min y
 * @param maxX      max x
 * @param maxY      max y
 * @param where     where clause
 * @param whereArgs where args
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounds
 *
 * @param distinct  distinct rows
 * @param minX      min x
 * @param minY      min y
 * @param maxX      max x
 * @param maxY      max y
 * @param where     where clause
 * @param whereArgs where args
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounds
 *
 * @param columns   columns
 * @param minX      min x
 * @param minY      min y
 * @param maxX      max x
 * @param maxY      max y
 * @param where     where clause
 * @param whereArgs where args
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually query for rows within the bounds
 *
 * @param distinct  distinct rows
 * @param columns   columns
 * @param minX      min x
 * @param minY      min y
 * @param maxX      max x
 * @param maxY      max y
 * @param where     where clause
 * @param whereArgs where args
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Manually count the rows within the bounds
 *
 * @param minX      min x
 * @param minY      min y
 * @param maxX      max x
 * @param maxY      max y
 * @param where     where clause
 * @param whereArgs where args
 * @return count
 */
-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

@end
