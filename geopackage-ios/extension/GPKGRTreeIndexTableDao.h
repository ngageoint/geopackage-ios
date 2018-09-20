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
 * Perform a raw query
 *
 * @param sql           sql statement
 * @param selectionArgs selection arguments
 * @return result set
 */
-(GPKGResultSet *) rawQuery:(NSString *)sql andArgs:(NSArray *)selectionArgs;

/**
 * Query for rows within the bounding box
 *
 * @param boundingBox bounding box
 * @return cursor results
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for rows within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @return cursor results
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Count the rows within the bounding box
 *
 * @param boundingBox bounding box
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Count the rows within the bounding box in the provided projection
 *
 * @param boundingBox bounding box
 * @param projection  projection
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection;

/**
 * Query for rows within the geometry envelope
 *
 * @param envelope geometry envelope
 * @return cursor results
 */
-(GPKGResultSet *) queryWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Count the rows within the geometry envelope
 *
 * @param envelope geometry envelope
 * @return count
 */
-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Query for rows within the bounds
 *
 * @param minX min x
 * @param minY min y
 * @param maxX max x
 * @param maxY max y
 * @return cursor results
 */
-(GPKGResultSet *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

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

@end
