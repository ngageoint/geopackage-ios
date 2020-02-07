//
//  GPKGRTreeIndexTableDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomDao.h"
#import "GPKGRTreeIndexExtension.h"
#import "GPKGProgress.h"
#import "GPKGRTreeIndexTableRow.h"

@interface GPKGRTreeIndexTableDao : GPKGUserCustomDao

/**
 *  Progress callbacks
 */
@property (nonatomic, strong) NSObject<GPKGProgress> *progress;

/**
 *  Query range tolerance
 */
@property (nonatomic) double tolerance;

/**
 * Initialize
 *
 * @param rTree      RTree extension
 * @param dao        user custom data access object
 * @param featureDao feature DAO
 */
-(instancetype) initWithExtension: (GPKGRTreeIndexExtension *) rTree andDao: (GPKGUserCustomDao *) dao andFeatureDao: (GPKGFeatureDao *) featureDao;

/**
 * Determine if this feature table has the RTree extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 * Create the RTree extension for the feature table
 *
 * @return extension
 */
-(GPKGExtensions *) create;

/**
 * Delete the RTree extension for the feature table
 */
-(void) delete;

/**
 * Get the RTree index extension
 *
 * @return RTree index extension
 */
-(GPKGRTreeIndexExtension *) rTreeIndexExtension;

/**
 * Get the feature DAO
 *
 * @return feature DAO
 */
-(GPKGFeatureDao *) featureDao;

/**
 * Get the RTree Index Table row from the current result set location
 *
 * @param resultSet result set
 * @return RTree Index Table row
 */
-(GPKGRTreeIndexTableRow *) row: (GPKGResultSet *) resultSet;

/**
 * Get the RTree Index Table row from the user custom row
 *
 * @param row custom row
 * @return RTree Index Table row
 */
-(GPKGRTreeIndexTableRow *) rowFromUserCustomRow: (GPKGUserCustomRow *) row;

/**
 * Get the feature row from the RTree Index Table row
 *
 * @param row RTree Index Table row
 * @return feature row
 */
-(GPKGFeatureRow *) featureRowFromRTreeRow: (GPKGRTreeIndexTableRow *) row;

/**
 * Get the feature row from the RTree Index Table row
 *
 * @param resultSet result set
 * @return feature row
 */
-(GPKGFeatureRow *) featureRow: (GPKGResultSet *) resultSet;

/**
 * Get the feature row from the user custom row
 *
 * @param row custom row
 * @return feature row
 */
-(GPKGFeatureRow *) featureRowFromUserCustomRow: (GPKGUserCustomRow *) row;

/**
 * Query for all features
 *
 * @return feature results
 */
-(GPKGResultSet *) queryFeatures;

/**
 * Query for all features
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
 * Query for rows within the bounding box
 *
 * @param boundingBox bounding box
 * @return results
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for rows within the bounding box
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @return results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Count the rows within the bounding box
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
 * @param columns     columns
 * @param boundingBox bounding box
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Count the features within the bounding box
 *
 * @param boundingBox bounding box
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox;

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
 * @param columns     columns
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the bounding box
 *
 * @param boundingBox bounding box
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues;

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
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

/**
 * Count the features within the bounding box
 *
 * @param boundingBox bounding box
 * @param where       where clause
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where;

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
 * @param columns     columns
 * @param boundingBox bounding box
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
 * Query for rows within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @return results
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for rows within the bounding box in the provided projection
 *
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @return results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Count the rows within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
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
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @return feature results
 */
 -(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Count the features within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @return count
 */
-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

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
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues;

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
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where;

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
 * @param columns     columns
 * @param boundingBox bounding box
 * @param projection  projection
 * @param where       where clause
 * @param whereArgs   where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
 * Query for rows within the geometry envelope
 *
 * @param envelope geometry envelope
 * @return results
 */
-(GPKGResultSet *) queryWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for rows within the geometry envelope
 *
 * @param columns  columns
 * @param envelope geometry envelope
 * @return results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Count the rows within the geometry envelope
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
 * @param columns  columns
 * @param envelope geometry envelope
 * @return feature results
 */
 -(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Count the features within the geometry envelope
 *
 * @param envelope geometry envelope
 * @return count
 */
-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope;

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
 * @param columns     columns
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the geometry envelope
 *
 * @param envelope    geometry envelope
 * @param fieldValues field values
 * @return count
 */
-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues;

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
 * @param columns  columns
 * @param envelope geometry envelope
 * @param where    where clause
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

/**
 * Count the features within the geometry envelope
 *
 * @param envelope geometry envelope
 * @param where    where clause
 * @return count
 */
-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where;

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
 * @param columns   columns
 * @param envelope  geometry envelope
 * @param where     where clause
 * @param whereArgs where arguments
 * @return feature results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

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
 * Query for rows within the bounds
 *
 * @param minX min x
 * @param minY min y
 * @param maxX max x
 * @param maxY max y
 * @return results
 */
-(GPKGResultSet *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Query for rows within the bounds
 *
 * @param columns columns
 * @param minX    min x
 * @param minY    min y
 * @param maxX    max x
 * @param maxY    max y
 * @return results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Count the rows within the bounds
 *
 * @param minX min x
 * @param minY min y
 * @param maxX max x
 * @param maxY max y
 * @return count
 */
-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Query for features within the bounds
 *
 * @param minX min x
 * @param minY min y
 * @param maxX max x
 * @param maxY max y
 * @return results
 */
-(GPKGResultSet *) queryFeaturesWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Query for features within the bounds
 *
 * @param columns columns
 * @param minX    min x
 * @param minY    min y
 * @param maxX    max x
 * @param maxY    max y
 * @return results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Count the features within the bounds
 *
 * @param minX min x
 * @param minY min y
 * @param maxX max x
 * @param maxY max y
 * @return results
 */
-(int) countFeaturesWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

/**
 * Query for features within the bounds
 *
 * @param minX        min x
 * @param minY        min y
 * @param maxX        max x
 * @param maxY        max y
 * @param fieldValues field values
 * @return results
 */
-(GPKGResultSet *) queryFeaturesWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the bounds
 *
 * @param columns     columns
 * @param minX        min x
 * @param minY        min y
 * @param maxX        max x
 * @param maxY        max y
 * @param fieldValues field values
 * @return results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Count the features within the bounds
 *
 * @param minX        min x
 * @param minY        min y
 * @param maxX        max x
 * @param maxY        max y
 * @param fieldValues field values
 * @return results
 */
-(int) countFeaturesWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andFieldValues: (GPKGColumnValues *) fieldValues;

/**
 * Query for features within the bounds
 *
 * @param minX  min x
 * @param minY  min y
 * @param maxX  max x
 * @param maxY  max y
 * @param where where clause
 * @return results
 */
-(GPKGResultSet *) queryFeaturesWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where;

/**
 * Query for features within the bounds
 *
 * @param columns columns
 * @param minX    min x
 * @param minY    min y
 * @param maxX    max x
 * @param maxY    max y
 * @param where   where clause
 * @return results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where;

/**
 * Count the features within the bounds
 *
 * @param minX  min x
 * @param minY  min y
 * @param maxX  max x
 * @param maxY  max y
 * @param where where clause
 * @return results
 */
-(int) countFeaturesWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where;

/**
 * Query for features within the bounds
 *
 * @param minX      min x
 * @param minY      min y
 * @param maxX      max x
 * @param maxY      max y
 * @param where     where clause
 * @param whereArgs where arguments
 * @return results
 */
-(GPKGResultSet *) queryFeaturesWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Query for features within the bounds
 *
 * @param columns   columns
 * @param minX      min x
 * @param minY      min y
 * @param maxX      max x
 * @param maxY      max y
 * @param where     where clause
 * @param whereArgs where arguments
 * @return results
 */
-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 * Count the features within the bounds
 *
 * @param minX      min x
 * @param minY      min y
 * @param maxX      max x
 * @param maxY      max y
 * @param where     where clause
 * @param whereArgs where arguments
 * @return results
 */
-(int) countFeaturesWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

@end
