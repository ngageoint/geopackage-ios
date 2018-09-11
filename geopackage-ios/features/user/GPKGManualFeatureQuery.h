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
@property (nonatomic, strong) NSNumber *chunkLimit;

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
 * Manually count the rows within the bounding box
 *
 * @param boundingBox
 *            bounding box
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox;

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
 * Manually query for rows within the geometry envelope
 *
 * @param envelope
 *            geometry envelope
 * @return results
 */
-(GPKGManualFeatureQueryResults *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Manually count the rows within the geometry envelope
 *
 * @param envelope
 *            geometry envelope
 * @return count
 */
-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope;

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
-(GPKGManualFeatureQueryResults *) queryWithMinX: (double) minxX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

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
-(int) countWithMinX: (double) minxX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY;

@end
