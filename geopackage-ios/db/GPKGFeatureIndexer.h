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
-(void) indexFeatureRow: (GPKGFeatureRow *) row;

/**
 *  Determine if the database table is indexed after database modifications
 *
 *  @return true if indexed, false if not
 */
-(BOOL) isIndexed;

@end
