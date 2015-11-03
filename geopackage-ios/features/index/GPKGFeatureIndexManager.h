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
 *  Get the feature table index, used to index inside the GeoPackage as an extension
 *
 *  @return feature table index
 */
-(GPKGFeatureTableIndex *) getFeatureTableIndex;

/**
 *  Get the feature indexer, used to index in metadata tables
 *
 *  @return feature indexer
 */
-(GPKGFeatureIndexer *) getFeatureIndexer;

/**
 *  Prioritize the query location order.  The type is placed at the front of the query order,
 *  leaving the remaining locations in their current order.
 *
 *  @param featureIndexTypes array of feature index type names
 */
-(void) prioritizeQueryLocationWithType: (enum GPKGFeatureIndexType) featureIndexType;

/**
 *  Prioritize the query location order.  All types are placed at the front of the query order
 *  in the order they are given. Omitting a location leaves it at it's current priority location.
 *
 *  @param featureIndexTypes array of feature index type names
 */
-(void) prioritizeQueryLocationWithTypes: (NSArray *) featureIndexTypes;

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
 *  Delete the feature index for the geometry id
 *
 *  @param type   index location type
 *  @param geomId geometry id
 *
 *  @return true if deleted
 */
-(BOOL) deleteIndexWithFeatureIndexType: (enum GPKGFeatureIndexType) type andGeomId: (int) geomId;

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
-(NSDate *) getLastIndexed;

/**
 *  Get the date last indexed
 *
 *  @param type index location type
 *
 *  @return last indexed date or null
 */
-(NSDate *) getLastIndexedWithFeatureIndexType: (enum GPKGFeatureIndexType) type;

/**
 *  Query for all feature index results
 *
 *  @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) query;

/**
 *  Query for all feature index count
 *
 *  @return count
 */
-(int) count;

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
 *  Query for feature index count within the bounding box, projected
 *  correctly
 *
 *  @param boundingBox bounding box
 *
 *  @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Query for feature index results within the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithGeometryEnvelope: (WKBGeometryEnvelope *) envelope;

/**
 *  Query for feature index count within the Geometry Envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return count
 */
-(int) countWithGeometryEnvelope: (WKBGeometryEnvelope *) envelope;

/**
 *  Query for feature index results within the bounding box in
 *  the provided projection
 *
 *  @param boundingBox bounding box
 *  @param projection bounding box projection
 *
 *  @return feature index results, close when done
 */
-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection;

/**
 *  Query for feature index count within the bounding box in
 *  the provided projection
 *
 *  @param boundingBox bounding box
 *  @param projection bounding box projection
 *
 *  @return count
 */
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection;

@end
