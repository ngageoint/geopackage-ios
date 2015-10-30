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
@property (nonatomic, strong)  GPKGFeatureDao * featureDao;

/**
 *  Progress callbacks
 */
@property (nonatomic, strong)  NSObject<GPKGProgress> * progress;

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
 * @param row
 * @return true if deleted
 */
-(BOOL) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row;

/**
 * Delete the index for the geometry id
 *
 * @param geomId
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
-(NSDate *) getLastIndexed;

/**
 * Query for all Geometry Metadata
 *
 * @return geometry metadata results
 */
-(GPKGResultSet *) query;

/**
 * Query for all Geometry Metadata count
 *
 * @return count
 */
-(int) count;

/**
 * Query for Geometry Metadata within the bounding box, projected
 * correctly
 *
 * @param boundingBox
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for Geometry Metadata count within the bounding box, projected
 * correctly
 *
 * @param boundingBox
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Query for Geometry Metadata within the Geometry Envelope
 *
 * @param envelope
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryWithEnvelope: (WKBGeometryEnvelope *) envelope;

/**
 * Query for Geometry Metadata count within the Geometry Envelope
 *
 * @param envelope
 * @return count
 */
-(int) countWithEnvelope: (WKBGeometryEnvelope *) envelope;

/**
 * Query for Geometry Metadata within the bounding box in
 * the provided projection
 *
 * @param boundingBox
 * @param projection  projection of the provided bounding box
 * @return geometry metadata results
 */
-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection;

/**
 * Query for Geometry Metadata count within the bounding box in
 * the provided projection
 *
 * @param boundingBox
 * @param projection  projection of the provided bounding box
 * @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection;

/**
 * Get the Geometry Metadata for the current place in the cursor
 *
 * @param resultSet
 * @return geometry metadata
 */
-(GPKGGeometryMetadata *) getGeometryMetadataWithResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the feature row for the current place in the cursor
 *
 * @param resultSet
 * @return feature row
 */
-(GPKGFeatureRow *) getFeatureRowWithResultSet: (GPKGResultSet *) resultSet;

/**
 * Get the feature row for the Geometry Metadata
 *
 * @param geometryMetadata
 * @return feature row
 */
-(GPKGFeatureRow *) getFeatureRowWithGeometryMetadata: (GPKGGeometryMetadata *) geometryMetadata;

@end
