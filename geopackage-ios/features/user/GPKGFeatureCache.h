//
//  GPKGFeatureCache.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/25/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureRow.h"

/**
 * Default max number of feature rows to retain in cache
 */
static int DEFAULT_FEATURE_CACHE_MAX_SIZE = 1000;

/**
 * Feature Row Cache for a single feature table
 */
@interface GPKGFeatureCache : NSObject

/**
 *  Initialize
 *
 *  @return new feature cache
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param maxSize max feature rows to retain in the cache
 *
 *  @return new feature cache
 */
-(instancetype) initWithMaxSize: (int) maxSize;

/**
 * Get the cache max size
 *
 * @return max size
 */
-(int) maxSize;

/**
 * Get the current cache size, number of feature rows cached
 *
 * @return cache size
 */
-(int) size;

/**
 * Get the cached feature row by feature id
 *
 * @param featureId feature row id
 * @return feature row or null
 */
-(GPKGFeatureRow *) rowById: (int) featureId;

/**
 * Cache the feature row
 *
 * @param featureRow feature row
 * @return previous cached feature row or null
 */
-(GPKGFeatureRow *) putRow: (GPKGFeatureRow *) featureRow;

/**
 * Remove the cached feature row
 *
 * @param featureRow feature row
 * @return removed feature row or null
 */
-(GPKGFeatureRow *) removeRow: (GPKGFeatureRow *) featureRow;

/**
 * Remove the cached feature row by id
 *
 * @param featureId feature row id
 * @return removed feature row or null
 */
-(GPKGFeatureRow *) removeById: (int) featureId;

/**
 * Clear the cache
 */
-(void) clear;

/**
 * Resize the cache
 *
 * @param maxSize max size
 */
-(void) resizeWithMaxSize: (int) maxSize;

/**
 * Clear and resize the cache
 *
 * @param maxSize max size of the cache
 */
-(void) clearAndResizeWithMaxSize: (int) maxSize;

@end
