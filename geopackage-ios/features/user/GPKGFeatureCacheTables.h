//
//  GPKGFeatureCacheTables.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/25/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureCache.h"

/**
 * Feature Row Cache for multiple feature tables in a single GeoPackage
 */
@interface GPKGFeatureCacheTables : NSObject

/**
 * Max Cache size
 */
@property (nonatomic) int maxCacheSize;

/**
 *  Initialize, created with cache size of GPKGFeatureCache DEFAULT_FEATURE_CACHE_MAX_SIZE
 *
 *  @return new feature cache tables
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param maxCacheSize max feature rows to retain in each feature table cache
 *
 *  @return new feature cache tables
 */
-(instancetype) initWithMaxCacheSize: (int) maxCacheSize;

/**
 * Get the feature table names with a feature row cache
 *
 * @return feature table names
 */
-(NSArray<NSString *> *) tables;

/**
 * Get or create a feature row cache for the table name
 *
 * @param tableName feature table name
 * @return feature row cache
 */
-(GPKGFeatureCache *) cacheForTable: (NSString *) tableName;

/**
 * Get or create a feature row cache for the feature row
 *
 * @param featureRow feature row
 * @return feature row cache
 */
-(GPKGFeatureCache *) cacheForRow: (GPKGFeatureRow *) featureRow;

/**
 * Get the cache max size for the table name
 *
 * @param tableName feature table name
 * @return max size
 */
-(int) maxSizeForTable: (NSString *) tableName;

/**
 * Get the current cache size, number of feature rows cached, for the table name
 *
 * @param tableName feature table name
 * @return cache size
 */
-(int) sizeForTable: (NSString *) tableName;

/**
 * Get the cached feature row by table name and feature id
 *
 * @param tableName feature table name
 * @param featureId feature row id
 * @return feature row or null
 */
-(GPKGFeatureRow *) rowByTable: (NSString *) tableName andId: (int) featureId;

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
 * @param tableName feature table name
 * @param featureId feature row id
 * @return removed feature row or null
 */
-(GPKGFeatureRow *) removeRowByTable: (NSString *) tableName andId: (int) featureId;

/**
 * Clear the feature table cache
 *
 * @param tableName feature table name
 */
-(void) clearForTable: (NSString *) tableName;

/**
 * Clear all caches
 */
-(void) clear;

/**
 * Resize the feature table cache
 *
 * @param tableName    feature table name
 * @param maxCacheSize max cache size
 */
-(void) resizeForTable: (NSString *) tableName withMaxCacheSize: (int) maxCacheSize;

/**
 * Resize all caches and update the max cache size
 *
 * @param maxCacheSize max cache size
 */
-(void) resizeWithMaxCacheSize: (int) maxCacheSize;

/**
 * Clear and resize the feature table cache
 *
 * @param tableName    feature table name
 * @param maxCacheSize max cache size
 */
-(void) clearAndResizeForTable: (NSString *) tableName withMaxCacheSize: (int) maxCacheSize;

/**
 * Clear and resize all caches and update the max cache size
 *
 * @param maxCacheSize max cache size
 */
-(void) clearAndResizeWithMaxCacheSize: (int) maxCacheSize;

@end

