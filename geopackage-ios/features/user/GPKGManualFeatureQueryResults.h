//
//  GPKGManualFeatureQueryResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/11/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGFeatureIndexResults.h"
#import "GPKGFeatureDao.h"

/**
 * Manual Feature Query Results which includes the ids used to read each row
 */
@interface GPKGManualFeatureQueryResults : GPKGFeatureIndexResults

/**
 *  Initialize
 *
 *  @param featureDao feature dao
 *  @param featureIds feature ids
 *
 *  @return feature index results
 */
-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao andIds: (NSArray<NSNumber *> *) featureIds;

/**
 * Get the feature DAO
 *
 * @return feature DAO
 */
-(GPKGFeatureDao *) featureDao;

/**
 * Get the feature ids
 *
 * @return feature ids
 */
-(NSArray<NSNumber *> *) featureIds;

@end
